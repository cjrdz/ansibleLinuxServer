#!/bin/bash
# -----------------------------------------------------------------
# Menú de Configuración de Servidor Ubuntu con Ansible
# Menú simple con Modo Normal y Modo Verificación + Modo Verboso
# -----------------------------------------------------------------

# Obtener el directorio donde se encuentra este script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Cambiar al directorio raíz del proyecto
cd "$PROJECT_ROOT" || exit 1

# Cargar .env si existe
if [ -f .env ]; then
    source .env
fi

# Definir Rutas de Playbooks
declare -A PLAYBOOKS=(
    [1]="playbooks/01_updates_patching.yml"
    [2]="playbooks/03_ufw_firewall.yml"
    [3]="playbooks/04_ssh_hardening.yml"
)

# Variable global para almacenar opciones de comando de Ansible
ANSIBLE_OPTIONS=""
MODE_DISPLAY="Modo Normal"

# Función para alternar modo de ejecución
select_mode() {
    clear
    echo "---------------------------------------------------------------------"
    echo " 🎯 MODO DE EJECUCIÓN DE ANSIBLE"
    echo "---------------------------------------------------------------------"
    echo " 1) Modo Normal (Aplicar cambios)"
    echo " 2) Modo Verificación + Verboso (Ejecución de prueba con salida detallada)"
    echo "---------------------------------------------------------------------"
    read -rp "Seleccionar modo (1-2) [por defecto: 1]: " mode_choice

    case $mode_choice in
        2)
            ANSIBLE_OPTIONS="--check -v"
            MODE_DISPLAY="Modo Verificación + Verboso"
            ;;
        *)
            ANSIBLE_OPTIONS=""
            MODE_DISPLAY="Modo Normal"
            ;;
    esac

    echo "✓ Modo establecido en: $MODE_DISPLAY"
    sleep 1
}

# Función para ejecutar un Playbook de Ansible
run_playbook() {
    local playbook_path=$1
    local playbook_name=$(basename "$playbook_path")

    echo ""
    echo "=========================================================="
    echo "▶️ Ejecutando: $playbook_name"
    echo "Modo: $MODE_DISPLAY"
    echo "=========================================================="

    ansible-playbook "$playbook_path" $ANSIBLE_OPTIONS

    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ ÉXITO: $playbook_name completado."
        if [[ "$ANSIBLE_OPTIONS" == *"--check"* ]]; then
            echo "   (Modo verificación - no se aplicaron cambios)"
        fi
    else
        echo ""
        echo "❌ ERROR: $playbook_name falló."
    fi
}

# Función para mostrar el menú de playbooks
show_playbook_menu() {
    clear
    echo "---------------------------------------------------------------------"
    echo " CONFIGURACIÓN DE SERVIDOR UBUNTU CON ANSIBLE"
    echo " Modo: $MODE_DISPLAY"
    echo "---------------------------------------------------------------------"
    echo " 1) Actualizaciones y Parches"
    echo " 2) Firewall UFW"
    echo " 3) Hardening SSH"
    echo " 4) Cambiar Modo"
    echo " 5) Salir"
    echo "---------------------------------------------------------------------"
}

# Bucle principal del script
select_mode

while true; do
    show_playbook_menu
    read -rp "Seleccionar opción (1-5): " choice

    case $choice in
        1|2|3)
            run_playbook "${PLAYBOOKS[$choice]}"
            read -rp "Presionar Enter para continuar..."
            ;;
        4)
            select_mode
            ;;
        5)
            echo ""
            echo "Saliendo. ¡Hasta luego!"
            exit 0
            ;;
        *)
            echo "Opción inválida. Por favor intentar de nuevo."
            sleep 1
            ;;
    esac
done
