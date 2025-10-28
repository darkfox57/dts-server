FROM ubuntu:20.04

# Evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Definir argumentos de build
ARG STEAM_TOKEN
ARG CLUSTER_NAME=dts-server
ARG CLUSTER_DESCRIPTION="Servidor Don't Starve Together dockerizado"
ARG CLUSTER_PASSWORD=""
ARG MAX_PLAYERS=12
ARG GAME_MODE=survival
ARG MASTER_PORT=10999
ARG CAVES_PORT=10998
ARG CLUSTER_PORT=10888
ARG STEAM_QUERY_PORT=27017
ARG STEAM_AUTH_PORT=8767
ARG CLUSTER_KEY=defaultPass
ARG BIND_IP=0.0.0.0
ARG MASTER_IP=127.0.0.1
ARG PVP=false
ARG PAUSE_WHEN_EMPTY=true
ARG CONSOLE_ENABLED=true
ARG LAN_ONLY=false
ARG OFFLINE_CLUSTER=false
ARG CLUSTER_LANGUAGE=en

# Convertir argumentos en variables de entorno
ENV STEAM_TOKEN=$STEAM_TOKEN
ENV CLUSTER_NAME=$CLUSTER_NAME
ENV CLUSTER_DESCRIPTION=$CLUSTER_DESCRIPTION
ENV CLUSTER_PASSWORD=$CLUSTER_PASSWORD
ENV MAX_PLAYERS=$MAX_PLAYERS

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    lib32gcc-s1 \
    lib32stdc++6 \
    libcurl4-gnutls-dev:i386 \
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

# Crear cluster.ini dinámicamente basado en argumentos de build
RUN mkdir -p /home/steam/.klei/DoNotStarveTogether/MyDediServer && \
    echo "[GAMEPLAY]" > /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "game_mode = $GAME_MODE" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "max_players = $MAX_PLAYERS" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "pvp = $PVP" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "pause_when_empty = $PAUSE_WHEN_EMPTY" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "[NETWORK]" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "lan_only_cluster = $LAN_ONLY" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "cluster_password = $CLUSTER_PASSWORD" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "cluster_description = $CLUSTER_DESCRIPTION" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "cluster_name = $CLUSTER_NAME" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "offline_cluster = $OFFLINE_CLUSTER" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "cluster_language = $CLUSTER_LANGUAGE" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "[MISC]" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "console_enabled = $CONSOLE_ENABLED" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "[SHARD]" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "shard_enabled = true" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "bind_ip = $BIND_IP" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "master_ip = $MASTER_IP" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "master_port = $CLUSTER_PORT" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini && \
    echo "cluster_key = $CLUSTER_KEY" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini

# Copiar archivos de configuración de shards
COPY --chown=steam:steam Master/ /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master/
COPY --chown=steam:steam Caves/ /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/

# Actualizar configuración de puertos en Master
RUN echo "[NETWORK]" > /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master/server.ini && \
    echo "server_port = $MASTER_PORT" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master/server.ini && \
    echo "" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master/server.ini && \
    echo "[SHARD]" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master/server.ini && \
    echo "is_master = true" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master/server.ini && \
    echo "" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master/server.ini && \
    echo "[ACCOUNT]" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master/server.ini && \
    echo "encode_user_path = true" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master/server.ini

# Actualizar configuración de puertos en Caves
RUN echo "[NETWORK]" > /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "server_port = $CAVES_PORT" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "[SHARD]" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "is_master = false" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "name = Caves" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "id = 3415167331" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "[ACCOUNT]" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "encode_user_path = true" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "[STEAM]" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "master_server_port = $STEAM_QUERY_PORT" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini && \
    echo "authentication_port = $STEAM_AUTH_PORT" >> /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/server.ini

# Copiar configuración de supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Crear script de inicialización inline
RUN echo '#!/bin/bash\n\
set -e\n\
echo "Iniciando servidor Don'\''t Starve Together..."\n\
if [ ! -z "$STEAM_TOKEN" ]; then\n\
    echo "Configurando Steam token..."\n\
    echo "$STEAM_TOKEN" > /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster_token.txt\n\
    chown steam:steam /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster_token.txt\n\
else\n\
    echo "ADVERTENCIA: No se proporcionó STEAM_TOKEN. El servidor funcionará solo en LAN."\n\
fi\n\
echo "Actualizando servidor..."\n\
cd /home/steam\n\
sudo -u steam ./steamcmd.sh +force_install_dir /home/steam/dst +login anonymous +app_update 343050 validate +quit\n\
chown -R steam:steam /home/steam/.klei/DoNotStarveTogether/MyDediServer/\n\
chown -R steam:steam /home/steam/dst/\n\
echo "Configuración completada. Iniciando supervisor..."\n\
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf' > /home/steam/start_server.sh \
    && chmod +x /home/steam/start_server.sh

# Exponer puertos
EXPOSE 10999/udp 10998/udp 10888/tcp 27017/tcp 8767/tcp

# Configurar el directorio de trabajo
WORKDIR /home/steam

# Comando para iniciar el servidor
CMD ["/home/steam/start_server.sh"]