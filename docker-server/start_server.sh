#!/bin/bash
set -e

# Script para inicializar el servidor Don't Starve Together

echo "Iniciando servidor Don't Starve Together..."

# Configurar Steam token si se proporciona
if [ ! -z "$STEAM_TOKEN" ]; then
    echo "Configurando Steam token..."
    echo "$STEAM_TOKEN" > /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster_token.txt
    chown steam:steam /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster_token.txt
else
    echo "ADVERTENCIA: No se proporcionó STEAM_TOKEN. El servidor funcionará solo en LAN."
fi

# Actualizar el servidor si es necesario
echo "Actualizando servidor..."
cd /home/steam
sudo -u steam ./steamcmd.sh +force_install_dir /home/steam/dst +login anonymous +app_update 343050 validate +quit

# Asegurar permisos correctos
echo "Configurando permisos..."
chown -R steam:steam /home/steam/.klei/DoNotStarveTogether/MyDediServer/
chown -R steam:steam /home/steam/dst/

# Verificar que los archivos de configuración existen
if [ ! -f "/home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster.ini" ]; then
    echo "ERROR: cluster.ini no encontrado"
    exit 1
fi

echo "Configuración completada. El servidor está listo para iniciarse."