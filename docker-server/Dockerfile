# 🦊 DARKFOX DST SERVER - FORCE REBUILD: 2025-10-29-02:32-FIXED-CONTEXT
FROM ubuntu:20.04

# Evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Definir argumentos de build (no sensibles)
ARG CLUSTER_NAME=dts-server
ARG CLUSTER_DESCRIPTION="Servidor Don't Starve Together dockerizado"
ARG MAX_PLAYERS=12
ARG GAME_MODE=survival
ARG MASTER_PORT=10999
ARG CAVES_PORT=10998
ARG CLUSTER_PORT=10888
ARG STEAM_QUERY_PORT=27017
ARG STEAM_AUTH_PORT=8767
ARG BIND_IP=0.0.0.0
ARG MASTER_IP=127.0.0.1
ARG PVP=false
ARG PAUSE_WHEN_EMPTY=true
ARG CONSOLE_ENABLED=true
ARG LAN_ONLY=false
ARG OFFLINE_CLUSTER=false
ARG CLUSTER_LANGUAGE=en

# Convertir argumentos en variables de entorno (datos no sensibles)
ENV CLUSTER_NAME=$CLUSTER_NAME
ENV CLUSTER_DESCRIPTION=$CLUSTER_DESCRIPTION
ENV MAX_PLAYERS=$MAX_PLAYERS

# Instalar dependencias necesarias
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    lib32gcc-s1 \
    lib32stdc++6 \
    libcurl4-gnutls-dev \
    libcurl4:i386 \
    libcurl4-gnutls-dev:i386 \
    libgcc-s1:i386 \
    libstdc++6:i386 \
    libc6:i386 \
    wget \
    curl \
    unzip \
    supervisor \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario steam para ejecutar el servidor
RUN useradd -m steam

# Cambiar al usuario steam
USER steam
WORKDIR /home/steam

# Descargar y instalar SteamCMD
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -xvzf steamcmd_linux.tar.gz \
    && rm steamcmd_linux.tar.gz

# Crear directorios necesarios
RUN mkdir -p /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether

# Instalar Don't Starve Together Dedicated Server y configurar mods
RUN ./steamcmd.sh +force_install_dir /home/steam/dst +login anonymous +app_update 343050 validate +quit

# IMPORTANTE: DST descargará automáticamente los mods del Workshop cuando esté configurado correctamente
# Los mods se descargan la primera vez que el servidor se inicia con la configuración modoverrides.lua

# Cambiar de vuelta a root para configurar supervisor
USER root

# Crear directorios y copiar configuraciones de shards
RUN mkdir -p /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Master \
    && mkdir -p /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Caves

# Copiar archivos de configuración de shards
COPY --chown=steam:steam Master/ /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Master/
COPY --chown=steam:steam Caves/ /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Caves/

# Crear configuraciones básicas de mundo si no existen
RUN if [ ! -f "/home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Master/leveldataoverride.lua" ]; then \
        echo 'return { override_enabled = true, settings = {} }' > /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Master/leveldataoverride.lua; \
    fi && \
    if [ ! -f "/home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Caves/leveldataoverride.lua" ]; then \
        echo 'return { override_enabled = true, preset = "DST_CAVE", settings = {} }' > /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Caves/leveldataoverride.lua; \
    fi

# FORZAR USO DE NUESTROS ARCHIVOS DE MODS - Siempre copiar y sobreescribir
COPY --chown=steam:steam Master/modoverrides.lua /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Master/modoverrides.lua
COPY --chown=steam:steam Caves/modoverrides.lua /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Caves/modoverrides.lua

# Copiar configuración de mods para descarga del Workshop
COPY --chown=steam:steam dedicated_server_mods_setup.lua /home/steam/dst/mods/dedicated_server_mods_setup.lua

# Copiar configuración de supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Crear script de diagnóstico simple
# FORCE REBUILD - Version 2.0 - Oct 28 2025
RUN cat > /home/steam/start_server.sh << 'SCRIPT'
#!/bin/bash
set -e

echo "=== DIAGNÓSTICO INICIO ==="
echo "🦊 DARKFOX DST SERVER v2.0"
echo "Usuario actual: $(whoami)"
echo "Directorio actual: $(pwd)"
echo "Variables de entorno relevantes:"
echo "STEAM_TOKEN: ${STEAM_TOKEN:0:10}..." 
echo "CLUSTER_NAME: darkfox-server"
echo "CLUSTER_PASSWORD: $CLUSTER_PASSWORD"
echo "================================"

echo "Verificando directorios..."
ls -la /home/steam/ || echo "Error listando /home/steam/"
ls -la /home/steam/.klei/ || echo "Error listando .klei"

echo "Probando generación de cluster.ini..."
mkdir -p /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether
echo "Directorio creado exitosamente"

# Generar cluster.ini básico
cat > /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/cluster.ini << EOF
[GAMEPLAY]
game_mode = survival
max_players = 12
pvp = false
pause_when_empty = true
mods_enabled = true
vote_enabled = false

[NETWORK]
lan_only_cluster = false
cluster_password = ${CLUSTER_PASSWORD:-}
cluster_description = DarkFox DST Server
cluster_name = darkfox-server
offline_cluster = false
cluster_language = en

[MISC]
console_enabled = true

[SHARD]
shard_enabled = true
bind_ip = 0.0.0.0
master_ip = 127.0.0.1
master_port = 10888
cluster_key = defaultPass
EOF

echo "cluster.ini generado exitosamente"
cat /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/cluster.ini

# Configurar token
if [ ! -z "$STEAM_TOKEN" ]; then
    echo "Configurando Steam token..."
    echo "$STEAM_TOKEN" > /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/cluster_token.txt
    chown steam:steam /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/cluster_token.txt
    echo "Token configurado"
else
    echo "ADVERTENCIA: STEAM_TOKEN no configurado"
fi

echo "Verificando estructura de DST..."
ls -la /home/steam/dst/ | head -20
echo "Verificando si hay directorio data..."
ls -la /home/steam/dst/data/ 2>/dev/null | head -10 || echo "No hay directorio data en /home/steam/dst/"
echo "Buscando directorio data..."
find /home/steam/dst -name "data" -type d 2>/dev/null || echo "No se encontró directorio data"

echo "Verificando ejecutable DST..."
echo "🔍 NUEVO DIAGNÓSTICO - Version 2.0"
find /home/steam/dst -name "*dontstarve*" -type f 2>/dev/null || echo "No se encontró ejecutable DST"
ls -la /home/steam/dst/bin/ 2>/dev/null || echo "Directorio bin no existe"
ls -la /home/steam/dst/bin64/ 2>/dev/null || echo "Verificando bin64:"

echo "Verificando librerías 32-bit..."
ldd /home/steam/dst/bin/dontstarve_dedicated_server_nullrenderer 2>/dev/null | head -10 || echo "Error verificando librerías"

echo "Verificando librerías críticas..."
ldd /home/steam/dst/bin/dontstarve_dedicated_server_nullrenderer | grep "not found" || echo "✅ Todas las librerías encontradas"

echo "Probando ejecución directa..."
cd /home/steam/dst
timeout 5 ./bin/dontstarve_dedicated_server_nullrenderer -help 2>&1 | head -3 || echo "Error en ejecución directa"

echo "Verificando archivos de configuración..."
ls -la /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Master/ || echo "Master config faltante"
ls -la /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Caves/ || echo "Caves config faltante"

echo "Verificando permisos..."
chown -R steam:steam /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/

echo "Verificando configuración de mods..."
echo "Archivos modoverrides.lua:"
ls -la /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Master/modoverrides.lua
ls -la /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Caves/modoverrides.lua
echo "Contenido de modoverrides Master:"
head -5 /home/steam/.klei/DoNotStarveTogether/DoNotStarveTogether/Master/modoverrides.lua
echo "Directorio de mods DST:"
ls -la /home/steam/dst/mods/ 2>/dev/null || echo "Directorio mods no existe aún"

echo "Probando inicio manual de DST para ver errores..."
cd /home/steam/dst/bin
sudo -u steam timeout 10 ./dontstarve_dedicated_server_nullrenderer -console -cluster DoNotStarveTogether -shard Master &
sleep 3
echo "Logs del test manual:"
tail -n 20 /var/log/dst-master.log 2>/dev/null || echo "No hay logs de master aún"

echo "Verificando supervisor..."
which supervisord || echo "supervisord no encontrado"
ls -la /etc/supervisor/conf.d/supervisord.conf || echo "supervisord.conf no encontrado"

echo "=== FIN DIAGNÓSTICO ==="
echo "Iniciando supervisor en modo debug..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf -n
SCRIPT

RUN chmod +x /home/steam/start_server.sh

# Exponer puertos
EXPOSE 10999/udp 10998/udp 10888/tcp 27017/tcp 8767/tcp

# Configurar el directorio de trabajo
WORKDIR /home/steam

# Comando para iniciar el servidor
CMD ["/home/steam/start_server.sh"]
