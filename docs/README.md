# Documentación de Hardening de Servidores Ubuntu con NGINX

Este directorio contiene documentación detallada para cada playbook de hardening.

## Documentación Disponible

- [Hardening SSH](SSH_HARDENING.md) - Configuración de seguridad del demonio SSH
- [Firewall UFW](UFW_FIREWALL.md) - Configuración y gestión del firewall
- [Actualizaciones y Parches](UPDATES_PATCHING.md) - Automatización de actualizaciones del sistema

## Referencia Rápida

### Hardening SSH
- Deshabilita inicio de sesión root
- Fuerza autenticación basada en claves
- Configura tiempos de espera de sesión
- Restringe acceso por grupo

### Firewall UFW
- Política de denegar por defecto
- Compatibilidad con Oracle Cloud
- Control de acceso basado en puertos

### Actualizaciones y Parches
- Actualizaciones automatizadas de paquetes
- Detección de requisitos de reinicio
- Identificación de reinicio de servicios
