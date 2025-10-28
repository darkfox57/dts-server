FROM ubuntu:20.04

# Evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    lib32gcc1 \
    lib32stdc++6 \
    libcurl4-gnutls-dev:i386 \
    wget \
    curl \
    unzip \
    supervisor \
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

# Copiar script de inicio
COPY start_server.sh /home/steam/start_server.sh
RUN chmod +x /home/steam/start_server.sh

# Copiar configuración de supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Exponer puertos
EXPOSE 10999/udp 10998/udp 10888/tcp 27017/tcp 8767/tcp

# Configurar el directorio de trabajo
WORKDIR /home/steam

# Comando para iniciar supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]