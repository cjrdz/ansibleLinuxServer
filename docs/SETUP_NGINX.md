# Configuración de Nginx en Playbook de Servidor Ubuntu

## Resumen
Este playbook de Ansible configura Nginx en un servidor y lo configura para servir contenido estático con un archivo index.html en una instancia de Oracle Cloud Infrastructure (OCI).

## Qué Hace Este Playbook
- Instala Nginx
- Configura Nginx para servir contenido estático
- Crea un archivo index.html

## Prerrequisitos
❗**Importante**:
Debes tener una cuenta OCI válida y crear una instancia de servidor linux ubuntu en el nivel gratuito, también necesitas configurar tu VCN con una dirección IP pública y reglas de lista de seguridad para permitir tráfico HTTP. La autenticación basada en claves SSH debe estar configurada **antes** de ejecutar este playbook

## Requisitos
- Python 3.6 o posterior instalado en la máquina de control
- Ansible 2.9 o posterior instalado en la máquina de control
- Acceso SSH a la instancia del servidor ubuntu objetivo con credenciales apropiadas (clave ssh privada)

## Configuración
- Necesitas crear una instancia OCI con tu nombre preferido y seleccionar Ubuntu Server como la imagen.
- Necesitas configurar tu VCN con una dirección IP pública y reglas de lista de seguridad para permitir tráfico HTTP. 

**Tabla de Reglas de Entrada:**
| Stateless |   Source    | IP Protocol | Source PR | Destination PR | Description      |
|-----------|-------------|-------------|-----------|----------------|------------------|
| No        | 0.0.0.0/0   | TCP         | All       | 22             | SSH Remote Login |
| No        | 0.0.0.0/0   | TCP         | All       | 80             | HTTP Web Server  |
| No        | 0.0.0.0/0   | TCP         | All       | 443            | HTTPS Web Server |

## Uso
Primero, asegúrate de tener los prerrequisitos necesarios en su lugar. Luego, ejecuta el playbook usando el siguiente comando:

## Resultados Esperados

## Cuándo usar este playbook
