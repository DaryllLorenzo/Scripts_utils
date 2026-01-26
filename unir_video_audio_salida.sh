#!/bin/bash

# Verificar que se pasen los argumentos correctos
if [ "$#" -ne 3 ]; then
    echo "Uso: $0 <video.mp4> <audio_final.webm> <salida.mp4>"
    exit 1
fi

VIDEO_MP4="$1"
AUDIO_WEBM="$2"
SALIDA="$3"

# Archivos temporales
AUDIO1="temp_audio1.aac"
AUDIO2="temp_audio2.aac"
AUDIO_TOTAL="temp_audio_total.aac"
LISTA="temp_lista.txt"

# Función para limpiar archivos temporales
cleanup() {
    rm -f "$AUDIO1" "$AUDIO2" "$AUDIO_TOTAL" "$LISTA"
}

# Registrar limpieza al salir (aunque falle)
trap cleanup EXIT

# Detectar si el MP4 tiene pista de audio
echo "🔍 Verificando si el video tiene audio..."
ffprobe -v quiet -show_streams -select_streams a "$VIDEO_MP4" | grep -q "codec_type=audio"
TIENE_AUDIO=$?

if [ $TIENE_AUDIO -eq 0 ]; then
    echo " El video tiene audio. Extrayendo..."
    ffmpeg -y -i "$VIDEO_MP4" -vn -acodec aac "$AUDIO1" || { echo " Error al extraer audio del MP4"; exit 1; }

    echo " Convirtiendo audio WebM a AAC..."
    ffmpeg -y -i "$AUDIO_WEBM" -acodec aac "$AUDIO2" || { echo " Error al convertir WebM a AAC"; exit 1; }

    echo " Creando lista para concatenar audios..."
    echo "file '$AUDIO1'" > "$LISTA"
    echo "file '$AUDIO2'" >> "$LISTA"

    echo " Concatenando audios..."
    ffmpeg -y -f concat -safe 0 -i "$LISTA" -c copy "$AUDIO_TOTAL" || { echo "❌ Error al concatenar audios"; exit 1; }

    echo " Uniendo video con audio combinado..."
    ffmpeg -y -i "$VIDEO_MP4" -i "$AUDIO_TOTAL" -c:v copy -c:a aac -shortest "$SALIDA" || { echo " Error al unir video y audio"; exit 1; }

else
    echo " El video NO tiene audio. Usando solo el audio del WebM..."
    ffmpeg -y -i "$VIDEO_MP4" -i "$AUDIO_WEBM" -c:v copy -c:a aac -shortest "$SALIDA" || { echo " Error al unir video y audio"; exit 1; }
fi

echo " ¡Listo! Archivo de salida: $SALIDA"
