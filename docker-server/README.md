# Servidor Don't Starve Together con Docker en EasyPanel

## Requisitos Previos

1. **Cuenta en EasyPanel** con acceso a deploy Docker containers
2. **Steam Token** - Necesitas generar un token desde tu cuenta de Steam:
   - Ve a https://accounts.klei.com/account/game/servers?game=DontStarveTogether
   - Genera un nuevo token para tu servidor

## Archivos Necesarios

Todos los archivos están en la carpeta `docker-server/`:

- `Dockerfile` - Imagen base del servidor
- `docker-compose.yml` - Configuración de servicios
- `cluster.ini` - Configuración general del cluster
- `Master/` - Configuración del mundo principal
- `Caves/` - Configuración del mundo de cuevas
- `start_server.sh` - Script de inicialización
- `supervisord.conf` - Configuración de procesos

## Pasos para Desplegar en VPS con Docker

### 1. Preparar el VPS

Asegúrate de que tu VPS tenga:
- Docker instalado y funcionando
- Docker Compose instalado
- Puertos abiertos: 10999/udp, 10998/udp, 10888/tcp, 27017/tcp, 8767/tcp
- Al menos 2GB de RAM disponible
- Espacio en disco suficiente (mínimo 5GB)

### 2. Clonar y Configurar

```bash
# Clonar el repositorio
git clone <tu-repositorio>
cd dts-server/docker-server

# Copiar y configurar variables de entorno
cp env.example .env
nano .env  # Editar con tu token de Steam
```

### 3. Obtener Token de Steam

1. Ve a https://accounts.klei.com/account/game/servers?game=DontStarveTogether
2. Genera un nuevo token
3. Copia el token en el archivo `.env`

### 4. Deployment

```bash
# Construir y ejecutar
docker-compose up -d

# Ver logs
docker-compose logs -f

# Ver logs específicos
docker-compose logs -f dst-server
```

### 5. Verificar el Estado

```bash
# Estado de los contenedores
docker-compose ps

# Logs del servidor Master
docker-compose exec dst-server tail -f /var/log/dst-master.log

# Logs del servidor Caves
docker-compose exec dst-server tail -f /var/log/dst-caves.log
```

### 4. Configuración Avanzada

#### Modificar Configuraciones:

1. **Cambiar nombre del servidor**: Edita `cluster_name` en `cluster.ini`
2. **Establecer contraseña**: Edita `cluster_password` en `cluster.ini` 
3. **Modificar mods**: Edita los archivos `modoverrides.lua` en Master/ y Caves/
4. **Ajustar configuración del mundo**: Edita `leveldataoverride.lua`

#### Mods Incluidos:

- Global Positions (1818688368)
- Status Announcements (375859599)
- Don't Drop Everything (347079953)
- Minimap HUD (358749986)
- Stacks Mod (374550642)
- Combined Status (458940297)
- Multi-language UI (623749604)
- Food Values (666155465)
- Combat Indicator (2078243581)

### 5. Monitoreo y Logs

Para ver los logs del servidor:

```bash
# Logs del contenedor
docker logs dont-starve-together

# Logs específicos
docker exec dont-starve-together tail -f /var/log/dst-master.log
docker exec dont-starve-together tail -f /var/log/dst-caves.log
```

### 6. Persistencia de Datos

Los volúmenes Docker garantizan que:
- Los mundos generados se conserven
- Los saves de jugadores persistan
- La configuración se mantenga entre reinicios

### 7. Troubleshooting

#### El servidor no aparece en la lista:
- Verifica que el token de Steam sea válido
- Asegúrate de que los puertos estén abiertos correctamente
- Revisa los logs para errores de conexión

#### Problemas de performance:
- Aumenta la memoria asignada al contenedor
- Considera usar un VPS con mejor CPU si hay muchos jugadores

#### Mods no cargan:
- Verifica que los IDs de mods en `modoverrides.lua` sean correctos
- Los mods se descargan automáticamente al iniciar el servidor

### 8. Backup y Mantenimiento

```bash
# Backup de los saves
docker cp dont-starve-together:/home/steam/.klei/DoNotStarveTogether/MyDediServer/save ./backup/

# Actualizar el servidor
docker exec dont-starve-together /home/steam/steamcmd.sh +force_install_dir /home/steam/dst +login anonymous +app_update 343050 validate +quit
docker restart dont-starve-together
```

## Notas Importantes

- El servidor incluye tanto el mundo principal (Master) como las cuevas (Caves)
- La configuración está basada en tu setup actual
- Los mods instalados son los mismos que tienes configurados
- El servidor se reinicia automáticamente si se cierra inesperadamente

¡Tu servidor estará disponible en la IP de tu EasyPanel en los puertos configurados!