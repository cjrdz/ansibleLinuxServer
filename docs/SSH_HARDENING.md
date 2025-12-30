# SSH Hardening Playbook

## Overview
This Ansible playbook applies a secure baseline configuration to the SSH daemon (sshd).
It reduces the attack surface of remote access by enforcing modern SSH security best
practices across all managed servers.

## What This Playbook Does
- Disables direct SSH access for the root user
- Disables password-based authentication (SSH keys only)
- Restricts SSH access to specific user groups
- Enforces idle SSH session timeouts
- Disables unnecessary features such as X11 forwarding
- Forces the use of SSH protocol version 2

## Prerequisites
❗**Important**: SSH key-based authentication must be configured **before** running this playbook.

You should be able to log in without a password:
```bash
ssh user@server_ip
```

## Requirements
- Ubuntu-based servers
- Ansible access to the target hosts
- At least one non-root user with sudo privileges
- SSH public keys already installed on the server

## Configuration
The following variables can be customized inside the playbook:

```yaml
allowed_ssh_groups: "ubuntu sudo"
client_alive_timeout: 300
```
❗Ensure your SSH user belongs to one of the allowed groups to avoid lockout.

## Usage
Run the playbook commands:

**Dry | Dev run**
```bash
# The --check allows you to test the playbook without making changes, like a preview
ansible-playbook playbooks/02_ssh_hardening.yml --check
```
**Production run**
```bash
# This command runs the playbook applies the changes or configuration
ansible-playbook playbooks/02_ssh_hardening.yml
```
**Limit execution to a single host**
```bash
# Run the source command to load environment variables
source .env
# Now run the playbook with the specified inventory file and limit
ansible-playbook playbooks/02_ssh_hardening.yml -i inventory.yml --limit serverNode1
```
## Expected results
After execution:

- Root login via SSH is disabled
- Password authentication is disabled
- Only approved user groups can access SSH
- Idle SSH sessions are terminated automatically
- SSH service is restarted to apply changes

## When to use this playbook

- After provisioning new servers
- After SSH or operating system upgrades
- As part of baseline system hardening
- After security reviews or audits
- After implementing new security policies
