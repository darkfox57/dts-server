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

## Pasos para Desplegar en EasyPanel

### 1. Preparar los Archivos

Sube todos los archivos de la carpeta `docker-server/` a tu repositorio Git o directamente a EasyPanel.

### 2. Configurar en EasyPanel

1. **Crear Nueva Aplicación**:
   - Ve a tu dashboard de EasyPanel
   - Crea una nueva aplicación de tipo "Docker"

2. **Configurar Variables de Entorno**:
   ```
   STEAM_TOKEN=tu_token_aqui
   CLUSTER_NAME=dts-server
   MAX_PLAYERS=12
   ```

3. **Configurar Puertos**:
   - Puerto 10999 (UDP) - Servidor Master
   - Puerto 10998 (UDP) - Servidor Caves  
   - Puerto 10888 (TCP) - Comunicación entre shards
   - Puerto 27017 (TCP) - Steam Master Server
   - Puerto 8767 (TCP) - Autenticación Steam

### 3. Deployment con Docker Compose

Si EasyPanel soporta Docker Compose, simplemente usa el archivo `docker-compose.yml`.

Si necesitas deployment manual:

```bash
# Construir la imagen
docker build -t dst-server .

# Ejecutar el contenedor
docker run -d \
  --name dont-starve-together \
  -p 10999:10999/udp \
  -p 10998:10998/udp \
  -p 10888:10888/tcp \
  -p 27017:27017/tcp \
  -p 8767:8767/tcp \
  -e STEAM_TOKEN=tu_token_aqui \
  -v dst_data:/home/steam/.klei/DoNotStarveTogether/MyDediServer \
  dst-server
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