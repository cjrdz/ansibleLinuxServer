# Updates & Patching Playbook

## Overview
This playbook automates system updates on Ubuntu servers to ensure
security patches and stability updates are applied consistently.

## What This Playbook Does
- Updates the apt package cache
- Installs available package upgrades
- Removes unused packages
- Cleans old package files
- Detects if a system reboot is required
- Reports services that may need restarting

## Prerequisites
- Ubuntu-based servers
- Ansible access with sudo privileges
- Sufficient disk space for package upgrades

## Configuration
This playbook uses standard apt behavior and does not require
custom configuration variables.

**Optional:**
- Installing the `needrestart` package improves service restart reporting.

## Usage
Run the playbook commands:

**Dry | Dev run**
```bash
# The --check allows you to test the playbook without making changes, like a preview
ansible-playbook playbooks/01_updates_patching.yml --check
```
**Production run**
```bash
# This command runs the playbook applies the changes or configuration
ansible-playbook playbooks/01_updates_patching.yml
```
**Limit execution to a single host**
```bash
# Run the source command to load environment variables
source .env
# Now run the playbook with the specified inventory file and limit
ansible-playbook playbooks/01_updates_patching.yml -i inventory.yml --limit serverNode1
```
## Expected results
After execution:

- System packages are fully up to date
- Unused packages are removed
- A reboot requirement is reported if needed
- Services that may require restart are listed

## When to use this playbook

- Weekly or bi-weekly maintenance windows
- After critical security advisories
- Before applying hardening or firewall playbooks
- As part of routine system maintenance
