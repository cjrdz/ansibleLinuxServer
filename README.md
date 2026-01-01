# Ubuntu Servers with NGINX Hardening Automation

Automated security hardening for Ubuntu servers with NGINX using Ansible.

## Prerequisites

- **Local Installation:** 
  - Ansible installed on your system
  - Install required collections: `ansible-galaxy collection install -r requirements.yml`
- **Docker Method:** Docker and Docker Compose installed
- SSH keys configured for accessing your target servers

## Quick Start

### Option 1: Using Docker (Recommended)

1. **Create `.env` file:**
   ```bash
   # Server IP addresses
   export ANSIBLE_HOST_MASTER=127.0.0.1
   export ANSIBLE_HOST_NODE1=127.0.0.2
   
   # SSH key path (inside container)
   export ANSIBLE_SSH_KEY_PATH=/root/.ssh/id_rsa
   ```

2. **Build and run:**
   ```bash
   docker-compose build
   docker-compose run --rm ansible ansible ubuntu_servers -m ping
   ```

### Option 2: Local Installation

1. **Create `.env` file:**
   ```bash
   export ANSIBLE_HOST_MASTER=127.0.0.1
   export ANSIBLE_HOST_NODE1=127.0.0.2
   export ANSIBLE_SSH_KEY_PATH=~/.ssh/id_rsa
   ```

2. **Install Ansible collections:**
   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

3. **Source and test:**
   ```bash
   source .env
   ansible ubuntu_servers -m ping
   ```

## Setup

### Environment Configuration

Create a `.env` file in the project root:

```bash
# Required: Server IP addresses
export ANSIBLE_HOST_MASTER=127.0.0.1
export ANSIBLE_HOST_NODE1=127.0.0.2

# Required: SSH key path
# For Docker: use container path (e.g., /root/.ssh/id_rsa)
# For Local: use host path (e.g., ~/.ssh/id_rsa)
export ANSIBLE_SSH_KEY_PATH=/root/.ssh/id_rsa
```

**SSH Key Paths:**
- **Docker:** If keys are in `~/.ssh` → use `/root/.ssh/id_rsa`
- **Docker:** If keys are elsewhere → mount in `docker-compose.yml` and use `/mnt/ssh-keys/keyname`
- **Local:** Use host path like `~/.ssh/id_rsa`

### Custom SSH Key Location (Docker)

If SSH keys are not in `~/.ssh`, update `docker-compose.yml`:

```yaml
volumes:
  - .:/workspace
  - ~/.ssh:/root/.ssh:ro
  - /path/to/your/ssh/keys:/mnt/ssh-keys:ro  # Add this
```

Then in `.env`: `export ANSIBLE_SSH_KEY_PATH=/mnt/ssh-keys/your_key_name`

## Usage

### Docker Method

```bash
# Interactive shell
docker-compose run --rm ansible bash

# Run playbook
docker-compose run --rm ansible ansible-playbook playbooks/01_updates_patching.yml

# Run menu script
docker-compose run --rm ansible ./scripts/run_menu.sh

# Test connectivity
docker-compose run --rm ansible ansible ubuntu_servers -m ping
```

### Local Method

```bash
# Source environment
source .env

# Run menu script
./scripts/run_menu.sh

# Run playbook
ansible-playbook playbooks/01_updates_patching.yml

# Test connectivity
ansible ubuntu_servers -m ping
```

## Project Structure

- `playbooks/` - Individual hardening playbooks
- `group_vars/` - Variables shared across server groups
- `host_vars/` - Host-specific configurations
- `docs/` - Detailed documentation
- `scripts/` - Setup and menu scripts
- `requirements.yml` - Ansible collections requirements
- `IMPROVEMENTS.md` - Recommended improvements and best practices

## Playbooks

1. **01_updates_patching.yml** - System updates and patch management
2. **02_nginx_ubuntu.yml** - NGINX web server installation and configuration
3. **03_ufw_firewall.yml** - UFW firewall configuration
4. **04_ssh_hardening.yml** - SSH daemon security hardening
5. **master_setup.yml** - Complete setup playbook (runs all playbooks in order)

## Security Note

**Sensitive information (IP addresses and SSH keys) are NOT committed to version control.**

All sensitive data is configured via environment variables in the `.env` file, which is git-ignored.

## Troubleshooting

### Docker Permission Denied
```bash
sudo docker-compose build
# Or add user to docker group: sudo usermod -aG docker $USER
```

### SSH Key Not Found (Docker)
- Verify path in `.env` matches container location
- Check: `docker-compose run --rm ansible ls -la /root/.ssh/`

### Can't Connect to Servers
- Test: `docker-compose run --rm ansible ping YOUR_SERVER_IP`
- Verify network mode is `host` in `docker-compose.yml`

### Environment Variables Not Working
- Ensure `.env` exists in project root
- Check format (use `export` statements)
- Verify: `docker-compose run --rm ansible env | grep ANSIBLE`

## Documentation

See the `docs/` directory for detailed documentation on each playbook.
