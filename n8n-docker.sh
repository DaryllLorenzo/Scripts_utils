#!/bin/bash

# Script para iniciar n8n con Docker (sin sudo)

IMAGE="n8nio/n8n"
PORT="5678"
DATA_DIR="$HOME/.n8n"

# Crear carpeta de datos si no existe
mkdir -p "$DATA_DIR"

echo "Iniciando n8n desde Docker (imagen: $IMAGE)..."
echo "Tus datos se guardan en: $DATA_DIR"
echo "Accede en tu navegador a: http://localhost:$PORT"
echo "Presiona Ctrl+C para detener."

# Ejecutar n8n SIN sudo
docker run -it --rm \
  -p "$PORT":"$PORT" \
  -v "$DATA_DIR":/home/node/.n8n \
  "$IMAGE"

echo "n8n detenido."
