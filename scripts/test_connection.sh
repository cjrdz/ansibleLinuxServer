#!/bin/bash
# Test Ansible connectivity script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT" || exit 1

# Source .env if it exists
if [ -f .env ]; then
    echo "Sourcing .env file..."
    source .env
else
    echo "⚠️  Warning: .env file not found. Environment variables may not be set."
fi

# Verify environment variables are set
echo ""
echo "Checking environment variables..."

# Check IP addresses (REQUIRED)
if [ -n "$ANSIBLE_HOST_MASTER" ]; then
    echo "✓ ANSIBLE_HOST_MASTER: $ANSIBLE_HOST_MASTER"
else
    echo "✗ ANSIBLE_HOST_MASTER not set (REQUIRED)"
fi

if [ -n "$ANSIBLE_HOST_NODE1" ]; then
    echo "✓ ANSIBLE_HOST_NODE1: $ANSIBLE_HOST_NODE1"
else
    echo "✗ ANSIBLE_HOST_NODE1 not set (REQUIRED)"
fi

# Check SSH key paths
if [ -n "$ANSIBLE_SSH_KEY_PATH_MASTER" ]; then
    echo "✓ ANSIBLE_SSH_KEY_PATH_MASTER: $ANSIBLE_SSH_KEY_PATH_MASTER"
    if [ ! -f "$ANSIBLE_SSH_KEY_PATH_MASTER" ]; then
        echo "  ✗ Key file not found!"
    fi
else
    echo "✗ ANSIBLE_SSH_KEY_PATH_MASTER not set"
fi

if [ -n "$ANSIBLE_SSH_KEY_PATH_NODE1" ]; then
    echo "✓ ANSIBLE_SSH_KEY_PATH_NODE1: $ANSIBLE_SSH_KEY_PATH_NODE1"
    if [ ! -f "$ANSIBLE_SSH_KEY_PATH_NODE1" ]; then
        echo "  ✗ Key file not found!"
    fi
else
    echo "✗ ANSIBLE_SSH_KEY_PATH_NODE1 not set"
fi

# Test Ansible connectivity
echo ""
echo "Testing Ansible connectivity..."
ansible ubuntu_servers -m ping

