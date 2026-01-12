# Playbook de Firewall UFW

## Resumen
Este playbook de Ansible configura UFW (Uncomplicated Firewall) usando un
modelo de seguridad **denegar-por-defecto**. Solo los puertos explícitamente
aprobados están permitidos, reduciendo la exposición de red y la superficie de ataque.

## Qué Hace Este Playbook
- Deniega todo el tráfico entrante por defecto
- Permite todo el tráfico saliente
- Abre solo los puertos definidos por host en el inventario
- Maneja el comportamiento específico de iptables de Oracle Cloud cuando es requerido
- Habilita y verifica la configuración de UFW

## Prerrequisitos
- Servidores basados en Ubuntu
- Acceso de Ansible con privilegios sudo
- El acceso SSH debe preservarse permitiendo explícitamente el puerto SSH

## Configuración
Cada host define sus puertos permitidos en `inventory.yml`:

```yaml
required_ports:
  - "22/tcp"
  - "80/tcp"
  - "443/tcp"
```
Para instancias de Oracle Cloud:

```yaml
is_oracle_cloud: true
```
❗Siempre incluir "22/tcp" (o tu puerto SSH personalizado) para evitar quedar bloqueado.

## Uso
Ejecutar los comandos del playbook:

**Ejecución en Modo Prueba | Desarrollo**
```bash
# El --check te permite probar el playbook sin hacer cambios, como una vista previa
ansible-playbook playbooks/03_ufw_firewall.yml --check
```
**Ejecución en Producción**
```bash
# Este comando ejecuta el playbook y aplica los cambios o configuración
ansible-playbook playbooks/03_ufw_firewall.yml
```
**Limitar ejecución a un solo host**
```bash
# Ejecutar el comando source para cargar variables de entorno
source .env
# Ahora ejecutar el playbook con el archivo de inventario especificado y límite
ansible-playbook playbooks/03_ufw_firewall.yml -i inventory.yml --limit serverNode1
```
## Resultados Esperados
Después de la ejecución:

- UFW está habilitado y activo
- El tráfico entrante está denegado por defecto
- Solo los puertos definidos están abiertos
- Las reglas del firewall son consistentes en todos los servidores

## Cuándo usar este playbook

- Durante el aprovisionamiento inicial del servidor
- Al agregar o eliminar servicios de red
- Después de cambios en infraestructura o aplicaciones
- Como parte de revisiones de seguridad rutinarias
