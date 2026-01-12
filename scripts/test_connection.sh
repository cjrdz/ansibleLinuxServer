#!/bin/bash
# Script de prueba de conectividad de Ansible

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT" || exit 1

# Cargar .env si existe
if [ -f .env ]; then
    echo "Cargando archivo .env..."
    source .env
else
    echo "⚠️  Advertencia: archivo .env no encontrado. Las variables de entorno pueden no estar configuradas."
fi

# Verificar que las variables de entorno estén configuradas
echo ""
echo "Verificando variables de entorno..."

# Verificar direcciones IP (REQUERIDO)
if [ -n "$ANSIBLE_HOST_MASTER" ]; then
    echo "✓ ANSIBLE_HOST_MASTER: $ANSIBLE_HOST_MASTER"
else
    echo "✗ ANSIBLE_HOST_MASTER no configurado (REQUERIDO)"
fi

if [ -n "$ANSIBLE_HOST_NODE1" ]; then
    echo "✓ ANSIBLE_HOST_NODE1: $ANSIBLE_HOST_NODE1"
else
    echo "✗ ANSIBLE_HOST_NODE1 no configurado (REQUERIDO)"
fi

# Verificar rutas de claves SSH
if [ -n "$ANSIBLE_SSH_KEY_PATH_MASTER" ]; then
    echo "✓ ANSIBLE_SSH_KEY_PATH_MASTER: $ANSIBLE_SSH_KEY_PATH_MASTER"
    if [ ! -f "$ANSIBLE_SSH_KEY_PATH_MASTER" ]; then
        echo "  ✗ ¡Archivo de clave no encontrado!"
    fi
else
    echo "✗ ANSIBLE_SSH_KEY_PATH_MASTER no configurado"
fi

if [ -n "$ANSIBLE_SSH_KEY_PATH_NODE1" ]; then
    echo "✓ ANSIBLE_SSH_KEY_PATH_NODE1: $ANSIBLE_SSH_KEY_PATH_NODE1"
    if [ ! -f "$ANSIBLE_SSH_KEY_PATH_NODE1" ]; then
        echo "  ✗ ¡Archivo de clave no encontrado!"
    fi
else
    echo "✗ ANSIBLE_SSH_KEY_PATH_NODE1 no configurado"
fi

# Probar conectividad de Ansible
echo ""
echo "Probando conectividad de Ansible..."
ansible ubuntu_servers -m ping

