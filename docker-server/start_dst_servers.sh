#!/bin/bash

# Esperar a que la inicialización termine
echo "Esperando a que la inicialización termine..."
sleep 30

# Verificar que los archivos necesarios existen
if [ ! -f "/home/steam/.klei/DoNotStarveTogether/MyDediServer/cluster_token.txt" ] && [ -z "$STEAM_TOKEN" ]; then
    echo "ADVERTENCIA: No hay token configurado. El servidor solo funcionará en modo LAN."
fi

# Iniciar los servidores
echo "Iniciando servidor Master..."
supervisorctl start dst-master

sleep 5

echo "Iniciando servidor Caves..."
supervisorctl start dst-caves

echo "Servidores iniciados!"