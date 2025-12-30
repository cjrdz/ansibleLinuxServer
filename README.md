# Ubuntu servers with NGINX Hardening Automation

Automated security hardening for Ubuntu servers with NGINX.

## Quick Start

1. Clone the repository
2. Copy `.env.example` to `.env` and configure your settings
3. Place SSH keys outside the project directory
4. Run: `ansible-playbook playbooks/master_hardening.yml --check`

## Project Structure

- `playbooks/` - Individual hardening playbooks
- `group_vars/` - Variables shared across server groups
- `host_vars/` - Host-specific configurations
- `docs/` - Project documentation
- `scripts/` - Setup and menu scripts

## Security Note

**Sensitive information (IP addresses and SSH keys) are NOT committed to version control.**

All sensitive data is configured via environment variables in the `.env` file:
- Server IP addresses (`ANSIBLE_HOST_MASTER`, `ANSIBLE_HOST_NODE1`)
- SSH key paths (`ANSIBLE_SSH_KEY_PATH_MASTER`, `ANSIBLE_SSH_KEY_PATH_NODE1`)

The `.env` file is git-ignored, so your sensitive data stays private.

## Usage

### Using the Menu Script

```bash
./scripts/run_menu.sh
```

### Running Individual Playbooks

```bash
# Updates and patching
ansible-playbook playbooks/01_updates_patching.yml

# SSH hardening
ansible-playbook playbooks/02_ssh_hardening.yml

# UFW firewall
ansible-playbook playbooks/03_ufw_firewall.yml

# Complete hardening
ansible-playbook playbooks/master_hardening.yml
```

### Environment Setup

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your server IPs and SSH key paths:
   ```bash
   # Required: Server IP addresses
   ANSIBLE_HOST_MASTER=your.master.server.ip
   ANSIBLE_HOST_NODE1=your.node1.server.ip
   
   # Required: SSH key paths
   ANSIBLE_SSH_KEY_PATH_MASTER=~/.ssh/your_master_key
   ANSIBLE_SSH_KEY_PATH_NODE1=~/.ssh/your_node1_key
   # Or use a common key:
   ANSIBLE_SSH_KEY_PATH=~/.ssh/your_key
   ```

3. Source the environment file:
   ```bash
   source .env
   ```

4. Test connectivity:
   ```bash
   ansible ubuntu_servers -m ping
   ```

## Playbooks

1. **01_updates_patching.yml** - System updates and patch management
2. **02_ssh_hardening.yml** - SSH daemon security hardening
3. **03_ufw_firewall.yml** - UFW firewall configuration

## Documentation

See the `docs/` directory for detailed documentation on each playbook.
