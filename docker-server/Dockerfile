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
RUN mkdir -p /home/steam/.klei/DoNotStarveTogether/MyDediServer

# Instalar Don't Starve Together Dedicated Server
RUN ./steamcmd.sh +force_install_dir /home/steam/dst +login anonymous +app_update 343050 validate +quit

# Cambiar de vuelta a root para configurar supervisor
USER root

# Crear directorios y copiar configuraciones de shards
RUN mkdir -p /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master \
    && mkdir -p /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves

# Copiar archivos de configuración de shards
COPY --chown=steam:steam Master/ /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master/
COPY --chown=steam:steam Caves/ /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/

# Copiar configuración de supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Crear script de inicialización inline (simplificado)
RUN cat > /home/steam/start_server.sh << 'SCRIPT'
#!/bin/bash
set -e

echo "Iniciando servidor Don't Starve Together..."

# Generar cluster.ini dinámicamente
echo "Generando configuración del cluster..."
cat > /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini << EOF
[GAMEPLAY]
game_mode = ${GAME_MODE:-survival}
max_players = ${MAX_PLAYERS:-12}
pvp = ${PVP:-false}
pause_when_empty = ${PAUSE_WHEN_EMPTY:-true}

[NETWORK]
lan_only_cluster = ${LAN_ONLY:-false}
cluster_password = ${CLUSTER_PASSWORD:-}
cluster_description = ${CLUSTER_DESCRIPTION:-Servidor Don't Starve Together dockerizado}
cluster_name = ${CLUSTER_NAME:-dts-server}
offline_cluster = ${OFFLINE_CLUSTER:-false}
cluster_language = ${CLUSTER_LANGUAGE:-en}

[MISC]
console_enabled = ${CONSOLE_ENABLED:-true}

[SHARD]
shard_enabled = true
bind_ip = ${BIND_IP:-0.0.0.0}
master_ip = ${MASTER_IP:-127.0.0.1}
master_port = ${CLUSTER_PORT:-10888}
cluster_key = ${CLUSTER_KEY:-defaultPass}
EOF

# Configurar Steam token si se proporciona
if [ ! -z "$STEAM_TOKEN" ]; then
    echo "Configurando Steam token..."
    echo "$STEAM_TOKEN" > /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster_token.txt
    chown steam:steam /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster_token.txt
else
    echo "ADVERTENCIA: No se proporcionó STEAM_TOKEN. El servidor funcionará solo en LAN."
fi

echo "Actualizando servidor..."
cd /home/steam
sudo -u steam ./steamcmd.sh +force_install_dir /home/steam/dst +login anonymous +app_update 343050 validate +quit

chown -R steam:steam /home/steam/.klei/DoNotStarveTogether/MyDediServer/
chown -R steam:steam /home/steam/dst/

echo "Configuración completada. Iniciando supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
SCRIPT

RUN chmod +x /home/steam/start_server.sh

# Exponer puertos
EXPOSE 10999/udp 10998/udp 10888/tcp 27017/tcp 8767/tcp

# Configurar el directorio de trabajo
WORKDIR /home/steam

# Comando para iniciar el servidor
CMD ["/home/steam/start_server.sh"]