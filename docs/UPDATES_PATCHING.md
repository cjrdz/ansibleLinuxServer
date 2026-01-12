# Playbook de Actualizaciones y Parches

## Resumen
Este playbook automatiza las actualizaciones del sistema en servidores Ubuntu para asegurar
que los parches de seguridad y actualizaciones de estabilidad se apliquen consistentemente.

## Qué Hace Este Playbook
- Actualiza la caché de paquetes apt
- Instala actualizaciones de paquetes disponibles
- Elimina paquetes no utilizados
- Limpia archivos antiguos de paquetes
- Detecta si se requiere un reinicio del sistema
- **Reinicia automáticamente el servidor si se requiere un reinicio** (espera a que el servidor vuelva a estar en línea)
- Reporta servicios que pueden necesitar reinicio

## Prerrequisitos
- Servidores basados en Ubuntu
- Acceso de Ansible con privilegios sudo
- Espacio en disco suficiente para actualizaciones de paquetes

## Configuración
Este playbook usa el comportamiento estándar de apt y no requiere
variables de configuración personalizadas.

**Opcional:**
- Instalar el paquete `needrestart` mejora el reporte de reinicio de servicios.

## Uso
Ejecutar los comandos del playbook:

**Ejecución en Modo Prueba | Desarrollo**
```bash
# El --check te permite probar el playbook sin hacer cambios, como una vista previa
ansible-playbook playbooks/01_updates_patching.yml --check
```
**Ejecución en Producción**
```bash
# Este comando ejecuta el playbook y aplica los cambios o configuración
ansible-playbook playbooks/01_updates_patching.yml
```
**Limitar ejecución a un solo host**
```bash
# Ejecutar el comando source para cargar variables de entorno
source .env
# Ahora ejecutar el playbook con el archivo de inventario especificado y límite
ansible-playbook playbooks/01_updates_patching.yml -i inventory.yml --limit serverNode1
```
## Resultados Esperados
Después de la ejecución:

- Los paquetes del sistema están completamente actualizados
- Los paquetes no utilizados son eliminados
- **El servidor se reinicia automáticamente si es requerido** (el playbook espera a que el servidor vuelva a estar en línea)
- Los servicios que pueden requerir reinicio se listan

## Cuándo usar este playbook

- Ventanas de mantenimiento semanales o quincenales
- Después de avisos críticos de seguridad
- Antes de aplicar playbooks de hardening o firewall
- Como parte del mantenimiento rutinario del sistema
