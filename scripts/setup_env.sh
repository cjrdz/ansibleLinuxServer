#!/bin/bash
# Enhanced project setup script with state tracking and conditional playbook execution
# This script checks if servers are already configured and only runs playbooks when needed

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATE_FILE="${PROJECT_ROOT}/.setup_state"
LOG_FILE="${PROJECT_ROOT}/logs/setup_env.log"
NGINX_INDEX_FILE="index.nginx-debian.html"
REMOTE_NGINX_PATH="/var/www/html/${NGINX_INDEX_FILE}"

# Ensure logs directory exists
mkdir -p "${PROJECT_ROOT}/logs"

# Logging function
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log_info() {
    log "${BLUE}[INFO]${NC} $1"
}

log_success() {
    log "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    log "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    log "${RED}[ERROR]${NC} $1"
}

# Header
log ""
log "${BLUE}================================${NC}"
log "${BLUE}Ubuntu servers with NGINX Hardening Project Setup${NC}"
log "${BLUE}================================${NC}"
log ""

# Check if .env exists
if [ ! -f "${PROJECT_ROOT}/.env" ]; then
    log_warning ".env file not found"
    if [ -f "${PROJECT_ROOT}/.env.example" ]; then
        log_info "Creating .env from template..."
        cp "${PROJECT_ROOT}/.env.example" "${PROJECT_ROOT}/.env"
        log_success ".env created"
        log_warning "Please edit .env with your SSH key paths and run the script again"
        exit 0
    else
        log_error ".env.example not found"
        exit 1
    fi
fi

# Load environment variables
log_info "Loading environment variables from .env..."
set +a
source "${PROJECT_ROOT}/.env"
set -a

# Create logs directory
mkdir -p "${PROJECT_ROOT}/logs"

# Verify SSH keys exist
log_info "Checking SSH keys..."
KEYS_VALID=true

if [ -n "${ANSIBLE_SSH_KEY_PATH_MASTER:-}" ]; then
    if [ -f "$ANSIBLE_SSH_KEY_PATH_MASTER" ]; then
        log_success "Master SSH key found: $ANSIBLE_SSH_KEY_PATH_MASTER"
    else
        log_error "Master SSH key not found at: $ANSIBLE_SSH_KEY_PATH_MASTER"
        KEYS_VALID=false
    fi
else
    log_error "ANSIBLE_SSH_KEY_PATH_MASTER not set in .env"
    KEYS_VALID=false
fi

if [ -n "${ANSIBLE_SSH_KEY_PATH_NODE1:-}" ]; then
    if [ -f "$ANSIBLE_SSH_KEY_PATH_NODE1" ]; then
        log_success "Node1 SSH key found: $ANSIBLE_SSH_KEY_PATH_NODE1"
    else
        log_error "Node1 SSH key not found at: $ANSIBLE_SSH_KEY_PATH_NODE1"
        KEYS_VALID=false
    fi
else
    log_error "ANSIBLE_SSH_KEY_PATH_NODE1 not set in .env"
    KEYS_VALID=false
fi

if [ "$KEYS_VALID" = false ]; then
    log_error "SSH key validation failed"
    exit 1
fi

log_success "All SSH keys validated"
log ""

# Function to get current state hash
get_current_state_hash() {
    # Create a hash of current configuration and server list
    (
        echo "# .env configuration"
        grep -E "^export ANSIBLE_" "${PROJECT_ROOT}/.env" | sort
        echo "# Inventory hosts"
        grep -E "^\s+[a-zA-Z].*:" "${PROJECT_ROOT}/inventory.yml" | head -20 | sort
    ) | sha256sum | awk '{print $1}'
}

# Function to check if a server has nginx with the index page
check_server_nginx_status() {
    local server_name="$1"
    local ansible_host="$2"
    local ssh_key="$3"

    if [ -z "$ansible_host" ] || [ -z "$ssh_key" ]; then
        log_warning "Skipping $server_name - missing host or SSH key configuration"
        return 2
    fi

    # Check if nginx is installed and running
    if ssh -o StrictHostKeyChecking=no \
           -o UserKnownHostsFile=/dev/null \
           -o ConnectTimeout=5 \
           -i "$ssh_key" \
           "ubuntu@${ansible_host}" \
           "systemctl is-active nginx > /dev/null 2>&1 && [ -f ${REMOTE_NGINX_PATH} ]" 2>/dev/null; then
        log_success "$server_name ($ansible_host): nginx with index page found ✓"
        return 0
    else
        log_warning "$server_name ($ansible_host): nginx or index page not found"
        return 1
    fi
}

# Function to get all server info from environment and inventory
get_server_info() {
    local server_config=""

    # Master server
    if [ -n "${ANSIBLE_HOST_MASTER:-}" ] && [ -n "${ANSIBLE_SSH_KEY_PATH_MASTER:-}" ]; then
        server_config+="serverMaster|${ANSIBLE_HOST_MASTER}|${ANSIBLE_SSH_KEY_PATH_MASTER}\n"
    fi

    # Node1 server
    if [ -n "${ANSIBLE_HOST_NODE1:-}" ] && [ -n "${ANSIBLE_SSH_KEY_PATH_NODE1:-}" ]; then
        server_config+="serverNode1|${ANSIBLE_HOST_NODE1}|${ANSIBLE_SSH_KEY_PATH_NODE1}\n"
    fi

    echo -e "$server_config"
}

# Check all servers
log_info "Checking server status..."
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
log_info "Server Status Summary:"
log "  • Servers with nginx configured: $SERVERS_UP_TO_DATE"
log "  • Servers needing configuration: $SERVERS_NEED_CONFIG"
log ""

# Check if configuration has changed
CURRENT_STATE_HASH=$(get_current_state_hash)
PREVIOUS_STATE_HASH=""

if [ -f "$STATE_FILE" ]; then
    PREVIOUS_STATE_HASH=$(cat "$STATE_FILE")
fi

CONFIG_CHANGED=false
if [ "$CURRENT_STATE_HASH" != "$PREVIOUS_STATE_HASH" ]; then
    CONFIG_CHANGED=true
    log_warning "Configuration has changed (.env or inventory.yml)"
fi

# Determine if playbook should run
SHOULD_RUN_PLAYBOOK=false

if [ "$SERVERS_NEED_CONFIG" -gt 0 ]; then
    log_warning "Some servers need nginx configuration"
    SHOULD_RUN_PLAYBOOK=true
elif [ "$CONFIG_CHANGED" = true ]; then
    log_warning "Server configuration has changed"
    SHOULD_RUN_PLAYBOOK=true
else
    log_success "All servers are properly configured and configuration hasn't changed"
fi

log ""

# Run playbook if needed
if [ "$SHOULD_RUN_PLAYBOOK" = true ]; then
    log_info "Running master_setup.yml playbook..."
    log ""

    cd "$PROJECT_ROOT"

    # Run the playbook
    if ansible-playbook -i inventory.yml playbooks/master_setup.yml; then
        log_success "Playbook execution completed successfully"

        # Save state after successful execution
        echo "$CURRENT_STATE_HASH" > "$STATE_FILE"
        log_success "Configuration state saved"
    else
        log_error "Playbook execution failed"
        log_error "Check logs in ${LOG_FILE} for details"
        exit 1
    fi
else
    log_success "No changes detected - skipping playbook execution"
    # Update state file even though no changes were needed
    echo "$CURRENT_STATE_HASH" > "$STATE_FILE"
fi

log ""
log_success "Setup complete!"
log ""
log_info "Quick reference:"
log "  • Check connectivity: source .env && ansible ubuntu_servers -m ping"
log "  • View logs: tail -f ${LOG_FILE}"
log "  • Force full playbook run: rm ${STATE_FILE} && ./scripts/setup_env.sh"
log ""
