# Playbook de Hardening SSH

## Resumen
Este playbook de Ansible aplica una configuración de baseline segura al demonio SSH (sshd).
Reduce la superficie de ataque del acceso remoto al hacer cumplir las mejores prácticas
de seguridad SSH modernas en todos los servidores gestionados.

## Qué Hace Este Playbook
- Deshabilita el acceso SSH directo para el usuario root
- Deshabilita la autenticación basada en contraseña (solo claves SSH)
- Restringe el acceso SSH a grupos de usuarios específicos
- Fuerza tiempos de espera de sesiones SSH inactivas
- Deshabilita características innecesarias como el reenvío X11
- Fuerza el uso del protocolo SSH versión 2

## Prerrequisitos
❗**Importante**: La autenticación basada en claves SSH debe estar configurada **antes** de ejecutar este playbook.

Deberías poder iniciar sesión sin contraseña:
```bash
ssh user@server_ip
```

## Requisitos
- Servidores basados en Ubuntu
- Acceso de Ansible a los hosts objetivo
- Al menos un usuario no root con privilegios sudo
- Claves públicas SSH ya instaladas en el servidor

## Configuración
Las siguientes variables se pueden personalizar dentro del playbook:

```yaml
allowed_ssh_groups: "ubuntu sudo"
client_alive_timeout: 300
```
❗Asegurar que tu usuario SSH pertenezca a uno de los grupos permitidos para evitar bloqueo.

## Uso
Ejecutar los comandos del playbook:

**Ejecución en Modo Prueba | Desarrollo**
```bash
# El --check te permite probar el playbook sin hacer cambios, como una vista previa
ansible-playbook playbooks/04_ssh_hardening.yml --check
```
**Ejecución en Producción**
```bash
# Este comando ejecuta el playbook y aplica los cambios o configuración
ansible-playbook playbooks/04_ssh_hardening.yml
```
**Limitar ejecución a un solo host**
```bash
# Ejecutar el comando source para cargar variables de entorno
source .env
# Ahora ejecutar el playbook con el archivo de inventario especificado y límite
ansible-playbook playbooks/04_ssh_hardening.yml -i inventory.yml --limit serverNode1
```
## Resultados Esperados
Después de la ejecución:

- El inicio de sesión root vía SSH está deshabilitado
- La autenticación por contraseña está deshabilitada
- Solo grupos de usuarios aprobados pueden acceder a SSH
- Las sesiones SSH inactivas se terminan automáticamente
- El servicio SSH se reinicia para aplicar cambios

## Cuándo usar este playbook

- Después de aprovisionar nuevos servidores
- Después de actualizaciones de SSH o del sistema operativo
- Como parte del hardening de baseline del sistema
- Después de revisiones de seguridad o auditorías
- Después de implementar nuevas políticas de seguridad
