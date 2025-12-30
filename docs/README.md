# Ubuntu servers with NGINX Hardening Documentation

This directory contains detailed documentation for each hardening playbook.

## Available Documentation

- [SSH Hardening](SSH_HARDENING.md) - SSH daemon security configuration
- [UFW Firewall](UFW_FIREWALL.md) - Firewall configuration and management
- [Updates & Patching](UPDATES_PATCHING.md) - System update automation

## Quick Reference

### SSH Hardening
- Disables root login
- Enforces key-based authentication
- Configures session timeouts
- Restricts access by group

### UFW Firewall
- Deny-by-default policy
- Oracle Cloud compatibility
- Port-based access control

### Updates & Patching
- Automated package updates
- Reboot requirement detection
- Service restart identification
