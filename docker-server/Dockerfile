FROM ubuntu:20.04

# Evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

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

# Copiar archivos de configuración
COPY --chown=steam:steam cluster.ini /home/steam/.klei/DoNotStarveTogether/MyDediServer/
COPY --chown=steam:steam Master/ /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master/
COPY --chown=steam:steam Caves/ /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/

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