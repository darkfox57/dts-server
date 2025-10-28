#!/bin/bash

# Script de deployment rápido para VPS
echo "=== Don't Starve Together Server Deployment ==="

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Instálalo primero:"
    echo "curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose no está instalado. Instálalo primero:"
    echo "sudo apt-get install docker-compose-plugin"
    exit 1
fi

echo "✅ Docker y Docker Compose están instalados"

# Verificar archivo .env
if [ ! -f ".env" ]; then
    echo "⚠️  Archivo .env no encontrado. Creando desde ejemplo..."
    cp env.example .env
    echo "❗ IMPORTANTE: Edita el archivo .env con tu token de Steam:"
    echo "   nano .env"
    echo "   Luego ejecuta este script nuevamente."
    exit 1
fi

# Verificar token en .env
if grep -q "tu_token_aqui" .env; then
    echo "❗ IMPORTANTE: Configura tu token de Steam en .env antes de continuar"
    echo "   nano .env"
    exit 1
fi

echo "✅ Archivo .env configurado"

# Construir y ejecutar
echo "🚀 Construyendo y ejecutando el servidor..."
docker-compose down 2>/dev/null || true
docker-compose up -d --build

echo ""
echo "🎮 Servidor Don't Starve Together iniciado!"
echo ""
echo "📊 Para monitorear:"
echo "   docker-compose logs -f"
echo ""
echo "🔍 Para ver logs específicos:"
echo "   docker-compose logs -f dst-server"
echo ""
echo "⚡ El servidor estará disponible en:"
echo "   IP: $(curl -s ifconfig.me 2>/dev/null || echo 'TU_IP_PUBLICA')"
echo "   Puerto Master: 10999"
echo "   Puerto Caves: 10998"
echo ""
echo "⏱️  Espera 2-3 minutos para que el servidor se inicialice completamente."