# Don't Starve Together Server

Este repositorio contiene configuraciones para ejecutar un servidor Don't Starve Together de dos maneras diferentes:

## 🖥️ Servidor Local/Manual

Archivos en la raíz del repositorio para ejecutar el servidor directamente en una máquina:

- `cluster.ini` - Configuración del cluster
- `Master/` - Configuración del mundo principal
- `Caves/` - Configuración del mundo de cuevas

### Uso Local
```bash
# Copiar archivos a la carpeta de DST
cp cluster.ini ~/.klei/DoNotStarveTogether/MyDediServer/
cp -r Master ~/.klei/DoNotStarveTogether/MyDediServer/
cp -r Caves ~/.klei/DoNotStarveTogether/MyDediServer/
```

## 🐳 Servidor Docker

Archivos en `docker-server/` para desplegar usando Docker/contenedores:

- `Dockerfile` - Imagen del contenedor
- `docker-compose.yml` - Orquestación de servicios
- `supervisord.conf` - Gestión de procesos
- `Master/` y `Caves/` - Configuraciones específicas para Docker
- `deploy.sh` - Script de deployment automático

### Uso Docker
```bash
cd docker-server/
cp env.example .env
# Editar .env con tu token de Steam
./deploy.sh
```

## Diferencias Principales

| Aspecto | Local | Docker |
|---------|--------|--------|
| `bind_ip` | `127.0.0.1` | `0.0.0.0` |
| Configuración | Archivos estáticos | Generada dinámicamente |
| Deployment | Manual | Automatizado |
| Portabilidad | Específica del sistema | Multiplataforma |

## Recomendación

- **Usar configuración Docker** para deployment en VPS/servidores de producción
- **Usar configuración local** para desarrollo y testing local