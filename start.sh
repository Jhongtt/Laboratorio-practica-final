#!/bin/bash

# Script de inicio para TesloShop
echo "Iniciando TesloShop..."
echo ""

# Verificar que Docker está corriendo.
# "docker info" falla si el demonio no está activo.
if !docker info > /dev/null 2>&1; then
    echo "Error: Docker no está corriendo. Por favor inicia Docker Desktop."
    exit 1
fi

echo "Docker está corriendo"
echo ""

# Construir las imágenes (si cambiaron) e iniciar todos los servicios.
# -d = detached: corre en segundo plano y libera la terminal.
echo "Construyendo e iniciando contenedores..."
docker-compose up --build -d

echo ""
echo "Esperando a que los servicios estén listos..."
sleep 10

echo ""
echo "TesloShop está corriendo!"
echo ""
echo "Accede a la aplicación:"
echo "   Frontend:    http://localhost"
echo "   Backend API: http://localhost:3000/api"
echo "   Base de datos: localhost:5432"
echo ""
echo "Ver logs:"
echo "   docker-compose logs -f"
echo ""
echo "Detener la aplicación:"
echo "   docker-compose down"
echo ""