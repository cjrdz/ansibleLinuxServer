#!/bin/bash
# Script de configuración mejorado del proyecto con seguimiento de estado y ejecución condicional de playbooks
# Este script verifica si los servidores ya están configurados y solo ejecuta playbooks cuando es necesario

set -euo pipefail

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin Color

# Configuración
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATE_FILE="${PROJECT_ROOT}/.setup_state"
LOG_FILE="${PROJECT_ROOT}/logs/setup_env.log"
NGINX_INDEX_FILE="index.nginx-debian.html"
REMOTE_NGINX_PATH="/var/www/html/${NGINX_INDEX_FILE}"

# Asegurar que el directorio de logs existe
mkdir -p "${PROJECT_ROOT}/logs"

# Función de registro
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log_info() {
    log "${BLUE}[INFO]${NC} $1"
}

log_success() {
    log "${GREEN}[ÉXITO]${NC} $1"
}

log_warning() {
    log "${YELLOW}[ADVERTENCIA]${NC} $1"
}

log_error() {
    log "${RED}[ERROR]${NC} $1"
}

# Encabezado
log ""
log "${BLUE}================================${NC}"
log "${BLUE}Configuración del Proyecto de Hardening de Servidores Ubuntu con NGINX${NC}"
log "${BLUE}================================${NC}"
log ""

# Verificar si .env existe
if [ ! -f "${PROJECT_ROOT}/.env" ]; then
    log_warning "Archivo .env no encontrado"
    if [ -f "${PROJECT_ROOT}/.env.example" ]; then
        log_info "Creando .env desde plantilla..."
        cp "${PROJECT_ROOT}/.env.example" "${PROJECT_ROOT}/.env"
        log_success ".env creado"
        log_warning "Por favor editar .env con tus rutas de claves SSH y ejecutar el script nuevamente"
        exit 0
    else
        log_error ".env.example no encontrado"
        exit 1
    fi
fi

# Cargar variables de entorno
log_info "Cargando variables de entorno desde .env..."
set +a
source "${PROJECT_ROOT}/.env"
set -a

# Crear directorio de logs
mkdir -p "${PROJECT_ROOT}/logs"

# Verificar que las claves SSH existan
log_info "Verificando claves SSH..."
KEYS_VALID=true

# Función para obtener ruta de clave SSH para un host (por host o común)
get_ssh_key_for_host() {
    local host_name="$1"
    local host_key_var="ANSIBLE_SSH_KEY_PATH_${host_name^^}"
    local host_key="${!host_key_var:-}"
    
    if [ -n "$host_key" ]; then
        echo "$host_key"
    elif [ -n "${ANSIBLE_SSH_KEY_PATH:-}" ]; then
        echo "$ANSIBLE_SSH_KEY_PATH"
    else
        echo ""
    fi
}

# Verificar clave SSH común o claves por host
if [ -n "${ANSIBLE_SSH_KEY_PATH:-}" ]; then
    if [ -f "$ANSIBLE_SSH_KEY_PATH" ]; then
        log_success "Clave SSH común encontrada: $ANSIBLE_SSH_KEY_PATH"
    else
        log_error "Clave SSH común no encontrada en: $ANSIBLE_SSH_KEY_PATH"
        KEYS_VALID=false
    fi
fi

# Verificar claves por host si existen (sobrescritura opcional)
for host in MASTER NODE1; do
    host_key_var="ANSIBLE_SSH_KEY_PATH_${host}"
    if [ -n "${!host_key_var:-}" ]; then
        if [ -f "${!host_key_var}" ]; then
            log_success "Clave SSH ${host} encontrada: ${!host_key_var}"
        else
            log_error "Clave SSH ${host} no encontrada en: ${!host_key_var}"
            KEYS_VALID=false
        fi
    fi
done

# Validar que al menos la clave común o todas las claves por host estén configuradas
if [ -z "${ANSIBLE_SSH_KEY_PATH:-}" ] && \
   ([ -z "${ANSIBLE_SSH_KEY_PATH_MASTER:-}" ] || [ -z "${ANSIBLE_SSH_KEY_PATH_NODE1:-}" ]); then
    log_error "Debe configurarse ANSIBLE_SSH_KEY_PATH o tanto ANSIBLE_SSH_KEY_PATH_MASTER como ANSIBLE_SSH_KEY_PATH_NODE1"
    KEYS_VALID=false
fi

if [ "$KEYS_VALID" = false ]; then
    log_error "Validación de claves SSH falló"
    exit 1
fi

log_success "Claves SSH validadas"
log ""

# Función para obtener hash del estado actual
get_current_state_hash() {
    # Crear un hash de la configuración actual y lista de servidores
    (
        echo "# configuración .env"
        grep -E "^export ANSIBLE_" "${PROJECT_ROOT}/.env" | sort
        echo "# hosts del inventario"
        grep -E "^\s+[a-zA-Z].*:" "${PROJECT_ROOT}/inventory.yml" | head -20 | sort
    ) | sha256sum | awk '{print $1}'
}

# Función para verificar si un servidor tiene nginx con la página de índice
check_server_nginx_status() {
    local server_name="$1"
    local ansible_host="$2"
    local ssh_key="$3"

    if [ -z "$ansible_host" ] || [ -z "$ssh_key" ]; then
        log_warning "Omitiendo $server_name - falta configuración de host o clave SSH"
        return 2
    fi

    # Verificar si nginx está instalado y ejecutándose
    if ssh -o StrictHostKeyChecking=no \
           -o UserKnownHostsFile=/dev/null \
           -o ConnectTimeout=5 \
           -i "$ssh_key" \
           "ubuntu@${ansible_host}" \
           "systemctl is-active nginx > /dev/null 2>&1 && [ -f ${REMOTE_NGINX_PATH} ]" 2>/dev/null; then
        log_success "$server_name ($ansible_host): nginx con página de índice encontrado ✓"
        return 0
    else
        log_warning "$server_name ($ansible_host): nginx o página de índice no encontrado"
        return 1
    fi
}

# Función para obtener toda la información del servidor desde el entorno y el inventario
get_server_info() {
    local server_config=""
    local ssh_key=""

    # Servidor Master
    if [ -n "${ANSIBLE_HOST_MASTER:-}" ]; then
        ssh_key="${ANSIBLE_SSH_KEY_PATH_MASTER:-${ANSIBLE_SSH_KEY_PATH:-}}"
        if [ -n "$ssh_key" ]; then
            server_config+="serverMaster|${ANSIBLE_HOST_MASTER}|${ssh_key}\n"
        fi
    fi

    # Servidor Node1
    if [ -n "${ANSIBLE_HOST_NODE1:-}" ]; then
        ssh_key="${ANSIBLE_SSH_KEY_PATH_NODE1:-${ANSIBLE_SSH_KEY_PATH:-}}"
        if [ -n "$ssh_key" ]; then
            server_config+="serverNode1|${ANSIBLE_HOST_NODE1}|${ssh_key}\n"
        fi
    fi

    echo -e "$server_config"
}

# Verificar todos los servidores
log_info "Verificando estado de servidores..."
log ""

SERVERS_NEED_SETUP=false
SERVERS_UP_TO_DATE=0
SERVERS_NEED_CONFIG=0

while IFS='|' read -r server_name ansible_host ssh_key; do
    [ -z "$server_name" ] && continue

    if check_server_nginx_status "$server_name" "$ansible_host" "$ssh_key"; then
        ((SERVERS_UP_TO_DATE++))
    else
        ((SERVERS_NEED_CONFIG++))
        SERVERS_NEED_SETUP=true
    fi
done < <(get_server_info)

log ""
log_info "Resumen de Estado de Servidores:"
log "  • Servidores con nginx configurado: $SERVERS_UP_TO_DATE"
log "  • Servidores que necesitan configuración: $SERVERS_NEED_CONFIG"
log ""

# Verificar si la configuración ha cambiado
CURRENT_STATE_HASH=$(get_current_state_hash)
PREVIOUS_STATE_HASH=""

if [ -f "$STATE_FILE" ]; then
    PREVIOUS_STATE_HASH=$(cat "$STATE_FILE")
fi

CONFIG_CHANGED=false
if [ "$CURRENT_STATE_HASH" != "$PREVIOUS_STATE_HASH" ]; then
    CONFIG_CHANGED=true
    log_warning "La configuración ha cambiado (.env o inventory.yml)"
fi

# Determinar si el playbook debe ejecutarse
SHOULD_RUN_PLAYBOOK=false

if [ "$SERVERS_NEED_CONFIG" -gt 0 ]; then
    log_warning "Algunos servidores necesitan configuración de nginx"
    SHOULD_RUN_PLAYBOOK=true
elif [ "$CONFIG_CHANGED" = true ]; then
    log_warning "La configuración del servidor ha cambiado"
    SHOULD_RUN_PLAYBOOK=true
else
    log_success "Todos los servidores están correctamente configurados y la configuración no ha cambiado"
fi

log ""

# Ejecutar playbook si es necesario
if [ "$SHOULD_RUN_PLAYBOOK" = true ]; then
    log_info "Ejecutando playbook master_setup.yml..."
    log ""

    cd "$PROJECT_ROOT"

    # Ejecutar el playbook
    if ansible-playbook -i inventory.yml playbooks/master_setup.yml; then
        log_success "Ejecución del playbook completada exitosamente"

        # Guardar estado después de ejecución exitosa
        echo "$CURRENT_STATE_HASH" > "$STATE_FILE"
        log_success "Estado de configuración guardado"
    else
        log_error "Ejecución del playbook falló"
        log_error "Verificar logs en ${LOG_FILE} para detalles"
        exit 1
    fi
else
    log_success "No se detectaron cambios - omitiendo ejecución del playbook"
    # Actualizar archivo de estado aunque no se necesitaron cambios
    echo "$CURRENT_STATE_HASH" > "$STATE_FILE"
fi

log ""
log_success "¡Configuración completa!"
log ""
log_info "Referencia rápida:"
log "  • Verificar conectividad: source .env && ansible ubuntu_servers -m ping"
log "  • Ver logs: tail -f ${LOG_FILE}"
log "  • Forzar ejecución completa del playbook: rm ${STATE_FILE} && ./scripts/setup_env.sh"
log ""
