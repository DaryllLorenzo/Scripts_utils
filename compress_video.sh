#!/bin/bash

# Script para comprimir videos manteniendo calidad
# Uso: ./comprimir_unificado.sh <archivo_entrada> [archivo_salida]

show_menu() {
    echo "========================================"
    echo "ESCOJA TIPO DE COMPRESION:"
    echo "========================================"
    echo "1) Soft compression (buena calidad, menor reduccion)"
    echo "2) Hard compression (maxima reduccion, menor calidad)"
    echo "========================================"
}

# Verificar que se proporcionó al menos un argumento
if [ $# -eq 0 ]; then
    echo "Error: No se proporcionó ningún archivo"
    echo "Uso: $0 <archivo_entrada> [archivo_salida]"
    echo "Ejemplo: $0 video.mp4 video_comprimido.mp4"
    exit 1
fi

INPUT="$1"
OUTPUT="${2:-${INPUT%.*}_comprimido.${INPUT##*.}}"

# Verificar si el archivo de entrada existe
if [ ! -f "$INPUT" ]; then
    echo "Error: El archivo '$INPUT' no existe"
    exit 1
fi

# Verificar si FFmpeg está instalado
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: FFmpeg no está instalado"
    echo "Instala FFmpeg con: sudo apt install ffmpeg (Debian/Ubuntu)"
    exit 1
fi

show_menu
read -p "Seleccione una opcion (1 o 2): " option

case $option in
    1)
        # Soft compression (original functionality from comprimir.sh)
        
        # Obtener extensión del archivo
        EXTENSION="${INPUT##*.}"
        EXTENSION=$(echo "$EXTENSION" | tr '[:upper:]' '[:lower:]')

        # Configuración de compresión según el formato
        case "$EXTENSION" in
            mp4|m4v)
                # Para MP4: H.264 + AAC con CRF (Constant Rate Factor)
                # CRF: 23-28 para buena compresión/calidad (23=calidad alta, 28=más compresión)
                CODEC_VIDEO="libx264"
                CODEC_AUDIO="aac"
                PARAMS="-crf 24 -preset slow -profile:v high -level 4.0"
                EXT_OUT="mp4"
                ;;
            webm)
                # Para WebM: VP9 + Opus (mejor compresión que VP8)
                CODEC_VIDEO="libvpx-vp9"
                CODEC_AUDIO="libopus"
                # -b:v 0 para usar CRF, -crf 30-35 para VP9
                PARAMS="-crf 32 -b:v 0 -deadline good -cpu-used 2"
                EXT_OUT="webm"
                ;;
            *)
                # Formato no soportado directamente, convertir a MP4
                echo "Formato .$EXTENSION detectado. Convirtiendo a MP4..."
                CODEC_VIDEO="libx264"
                CODEC_AUDIO="aac"
                PARAMS="-crf 24 -preset slow"
                EXT_OUT="mp4"
                OUTPUT="${OUTPUT%.*}.$EXT_OUT"
                ;;
        esac

        echo "========================================"
        echo "Comprimiendo video: $INPUT"
        echo "Formato de salida: $EXT_OUT"
        echo "========================================"

        # Comando FFmpeg con optimizaciones:
        # -map 0: copia todos los streams (video, audio, subtítulos)
        # -c:v y -c:a: codecs de video y audio
        # -movflags +faststart: optimiza MP4 para streaming web
        # -max_muxing_queue_size 1024: evita errores en algunos archivos

        if [ "$EXT_OUT" = "mp4" ]; then
            ffmpeg -i "$INPUT" \
                -map 0 \
                -c:v $CODEC_VIDEO \
                $PARAMS \
                -c:a $CODEC_AUDIO \
                -b:a 128k \
                -movflags +faststart \
                -max_muxing_queue_size 1024 \
                "$OUTPUT"
        elif [ "$EXT_OUT" = "webm" ]; then
            ffmpeg -i "$INPUT" \
                -map 0 \
                -c:v $CODEC_VIDEO \
                $PARAMS \
                -c:a $CODEC_AUDIO \
                -b:a 128k \
                -threads $(nproc) \
                "$OUTPUT"
        fi

        # Verificar si la compresión fue exitosa
        if [ $? -eq 0 ]; then
            echo ""
            echo "Compresion completada exitosamente!"
            echo ""
            echo "Archivo original: $(du -h "$INPUT" | cut -f1)"
            echo "Archivo comprimido: $(du -h "$OUTPUT" | cut -f1)"
            echo ""
            echo "Archivo de salida: $OUTPUT"
        else
            echo ""
            echo "Error durante la compresión"
            exit 1
        fi
        ;;
    2)
        # Hard compression (from comprimir_md.sh)
        
        if [ -z "$2" ]; then
            FILENAME=$(basename -- "$INPUT")
            NAME="${FILENAME%.*}"
            OUTPUT="${NAME}_md.mp4"
        else
            OUTPUT="${2%.*}.mp4"
        fi

        echo "========================================"
        echo "Modo: Markdown -> PDF (compresion extrema)"
        echo "Entrada: $INPUT"
        echo "Salida: $OUTPUT"
        echo "Audio: Eliminado"
        echo "========================================"

        ffmpeg -i "$INPUT" \
            -vf "scale=1280:-2" \
            -r 24 \
            -c:v libx264 \
            -preset slow \
            -crf 32 \
            -pix_fmt yuv420p \
            -profile:v high \
            -level 4.0 \
            -movflags +faststart \
            -an \
            -y \
            -hide_banner -loglevel error -stats \
            "$OUTPUT"

        if [ $? -eq 0 ]; then
            echo ""
            echo "Compresion completada"
            echo "----------------------------------------"
            echo "Origen: $(du -h "$INPUT" | cut -f1)"
            echo "Destino: $(du -h "$OUTPUT" | cut -f1)"
            echo "----------------------------------------"
        else
            echo ""
            echo "Error: FFmpeg falló."
            exit 1
        fi
        ;;
    *)
        echo "Opcion invalida. Por favor seleccione 1 o 2."
        exit 1
        ;;
esac