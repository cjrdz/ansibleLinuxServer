# UFW Firewall Playbook

## Overview
This Ansible playbook configures UFW (Uncomplicated Firewall) using a
**deny-by-default** security model. Only explicitly approved ports are
allowed, reducing network exposure and attack surface.

## What This Playbook Does
- Denies all incoming traffic by default
- Allows all outgoing traffic
- Opens only ports defined per host in the inventory
- Handles Oracle Cloud–specific iptables behavior when required
- Enables and verifies UFW configuration

## Prerequisites
- Ubuntu-based servers
- Ansible access with sudo privileges
- SSH access must be preserved by explicitly allowing the SSH port

## Configuration
Each host defines its allowed ports in `inventory.yml`:

```yaml
required_ports:
  - "22/tcp"
  - "80/tcp"
  - "443/tcp"
```
For Oracle Cloud instances:

```yaml
is_oracle_cloud: true
```
❗Always include "22/tcp" (or your custom SSH port) to avoid being locked out.

## Usage
Run the playbook commands:

**Dry | Dev run**
```bash
# The --check allows you to test the playbook without making changes, like a preview
ansible-playbook playbooks/03_ufw_firewall.yml --check
```
**Production run**
```bash
# This command runs the playbook applies the changes or configuration
ansible-playbook playbooks/03_ufw_firewall.yml
```
**Limit execution to a single host**
```bash
# Run the source command to load environment variables
source .env
# Now run the playbook with the specified inventory file and limit
ansible-playbook playbooks/03_ufw_firewall.yml -i inventory.yml --limit serverNode1
```
## Expected results
After execution:

- UFW is enabled and active
- Incoming traffic is denied by default
- Only defined ports are open
- Firewall rules are consistent across all servers

## When to use this playbook

- During initial server provisioning
- When adding or removing network services
- After infrastructure or application changes
- As part of routine security reviews
