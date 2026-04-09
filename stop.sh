#!/bin/bash

# Script para detener TesloShop
echo "Deteniendo TesloShop..."
docker-compose down

echo ""
echo "TesloShop detenido"
echo ""
echo "Para eliminar también los volúmenes (base de datos):"
echo "   docker-compose down -v"
echo ""