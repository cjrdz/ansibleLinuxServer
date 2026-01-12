# Automatización de Hardening de Servidores Ubuntu con NGINX

Automatización de hardening de seguridad para servidores Ubuntu con NGINX usando Ansible.

## Prerrequisitos

- **Instalación Local:** 
  - Ansible instalado en tu sistema
  - Instalar colecciones requeridas: `ansible-galaxy collection install -r requirements.yml`
- **Método Docker:** Docker y Docker Compose instalados
- Claves SSH configuradas para acceder a tus servidores objetivo

## Inicio Rápido

### Opción 1: Usando Docker (Recomendado)

1. **Crear archivo `.env`:**
   ```bash
   # Direcciones IP de servidores
   export ANSIBLE_HOST_MASTER=127.0.0.1
   export ANSIBLE_HOST_NODE1=127.0.0.2
   
   # Ruta de clave SSH (dentro del contenedor)
   export ANSIBLE_SSH_KEY_PATH=/root/.ssh/id_rsa
   ```

2. **Construir y ejecutar:**
   ```bash
   # Usar 'docker compose' (espacio) para Docker Compose v2+ (recomendado)
   docker compose build
   docker compose run --rm ansible ansible ubuntu_servers -m ping
   
   # O usar 'docker-compose' (guion) si tienes docker-compose standalone instalado
   # docker-compose build
   # docker-compose run --rm ansible ansible ubuntu_servers -m ping
   ```

### Opción 2: Instalación Local

1. **Crear archivo `.env`:**
   ```bash
   export ANSIBLE_HOST_MASTER=127.0.0.1
   export ANSIBLE_HOST_NODE1=127.0.0.2
   export ANSIBLE_SSH_KEY_PATH=~/.ssh/id_rsa
   ```

2. **Instalar colecciones de Ansible:**
   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

3. **Cargar y probar:**
   ```bash
   source .env
   ansible ubuntu_servers -m ping
   ```

## Configuración

### Configuración del Entorno

Crear un archivo `.env` en la raíz del proyecto:

```bash
# Requerido: Direcciones IP de servidores
export ANSIBLE_HOST_MASTER=127.0.0.1
export ANSIBLE_HOST_NODE1=127.0.0.2

# Requerido: Ruta de clave SSH
# Para Docker: usar ruta del contenedor (ej., /root/.ssh/id_rsa)
# Para Local: usar ruta del host (ej., ~/.ssh/id_rsa)
export ANSIBLE_SSH_KEY_PATH=/root/.ssh/id_rsa
```

**Rutas de Claves SSH:**
- **Docker:** Si las claves están en `~/.ssh` → usar `/root/.ssh/id_rsa`
- **Docker:** Si las claves están en otro lugar → montar en `docker-compose.yml` y usar `/mnt/ssh-keys/nombre_clave`
- **Local:** Usar ruta del host como `~/.ssh/id_rsa`

### Ubicación Personalizada de Clave SSH (Docker)

Si las claves SSH no están en `~/.ssh`, actualizar `docker-compose.yml`:

```yaml
volumes:
  - .:/workspace
  - ~/.ssh:/root/.ssh:ro
  - /ruta/a/tus/claves/ssh:/mnt/ssh-keys:ro  # Agregar esto
```

Luego en `.env`: `export ANSIBLE_SSH_KEY_PATH=/mnt/ssh-keys/tu_nombre_clave`

## Uso

### Método Docker

```bash
# Shell interactivo
docker compose run --rm ansible bash

# Ejecutar playbook
docker compose run --rm ansible ansible-playbook playbooks/01_updates_patching.yml

# Ejecutar script de menú
docker compose run --rm ansible ./scripts/run_menu.sh

# Probar conectividad
docker compose run --rm ansible ansible ubuntu_servers -m ping

# Nota: Si tienes docker-compose standalone instalado, reemplazar 'docker compose' con 'docker-compose'
```

### Método Local

```bash
# Cargar entorno
source .env

# Ejecutar script de menú
./scripts/run_menu.sh

# Ejecutar playbook
ansible-playbook playbooks/01_updates_patching.yml

# Probar conectividad
ansible ubuntu_servers -m ping
```

## Estructura del Proyecto

- `playbooks/` - Playbooks individuales de hardening
- `group_vars/` - Variables compartidas entre grupos de servidores
- `host_vars/` - Configuraciones específicas por host
- `docs/` - Documentación detallada
- `scripts/` - Scripts de configuración y menú
- `requirements.yml` - Requisitos de colecciones de Ansible
- `IMPROVEMENTS.md` - Mejoras recomendadas y mejores prácticas

## Playbooks

1. **01_updates_patching.yml** - Actualizaciones del sistema y gestión de parches
2. **02_nginx_ubuntu.yml** - Instalación y configuración del servidor web NGINX
3. **03_ufw_firewall.yml** - Configuración del firewall UFW
4. **04_ssh_hardening.yml** - Hardening de seguridad del demonio SSH
5. **master_setup.yml** - Playbook de configuración completa (ejecuta todos los playbooks en orden)

## Nota de Seguridad

**La información sensible (direcciones IP y claves SSH) NO se confirma en el control de versiones.**

Todos los datos sensibles se configuran mediante variables de entorno en el archivo `.env`, que está ignorado por git.

## Solución de Problemas

### Permiso Denegado en Docker
```bash
sudo docker compose build
# O agregar usuario al grupo docker: sudo usermod -aG docker $USER
# Luego cerrar sesión y volver a iniciar, o usar: newgrp docker
```

### Clave SSH No Encontrada (Docker)
- Verificar que la ruta en `.env` coincida con la ubicación del contenedor
- Verificar: `docker compose run --rm ansible ls -la /root/.ssh/`

### No Se Puede Conectar a los Servidores
- Probar: `docker compose run --rm ansible ping TU_IP_SERVIDOR`
- Verificar que el modo de red sea `host` en `docker-compose.yml`

### Variables de Entorno No Funcionan
- Asegurar que `.env` exista en la raíz del proyecto
- Verificar formato (usar declaraciones `export`)
- Verificar: `docker compose run --rm ansible env | grep ANSIBLE`

### docker-compose: comando no encontrado
- Las instalaciones modernas de Docker usan `docker compose` (espacio) en lugar de `docker-compose` (guion)
- Usar: `docker compose build` en lugar de `docker-compose build`
- Si prefieres la versión standalone, instalarla: `sudo dnf install docker-compose` (Fedora/RHEL)

## Documentación

Ver el directorio `docs/` para documentación detallada de cada playbook.
