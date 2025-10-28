#!/bin/bash

# Script para inicializar el servidor Don't Starve Together

echo "Iniciando servidor Don't Starve Together..."

# Configurar Steam token si se proporciona
if [ ! -z "$STEAM_TOKEN" ]; then
    echo "Configurando Steam token..."
    echo "$STEAM_TOKEN" > /home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster_token.txt
fi

# Actualizar el servidor si es necesario
echo "Actualizando servidor..."
cd /home/steam
./steamcmd.sh +force_install_dir /home/steam/dst +login anonymous +app_update 343050 validate +quit

# Crear enlaces simbólicos para los archivos de configuración si no existen
echo "Verificando configuración..."

# Asegurar permisos correctos
chown -R steam:steam /home/steam/.klei/DoNotStarveTogether/MyDediServer/

echo "Configuración completada. El servidor está listo para iniciarse."