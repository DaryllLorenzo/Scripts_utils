# Scripts Utilitarios

## restore-pg-backup.sh
**Propósito:** Convertir backups de PostgreSQL a SQL plano usando Docker temporal.

**Uso:**
```bash
./restore-pg-backup.sh archivo.backup [salida.sql]
```

**Qué hace:**
1. Crea contenedor PostgreSQL temporal
2. Restaura backup (detecta formato automáticamente)
3. Exporta a SQL plano
4. Limpia contenedor

**Ejemplo:**
```bash
./restore-pg-backup.sh produccion.backup
```

## php_researcher.sh
**Propósito:** Analizar sitios web para descubrir archivos PHP expuestos (reconocimiento pasivo).

**Uso:**
```bash
./php_research.sh dominio.com
```

**Qué detecta:**
- Archivos .php en HTML y JavaScript
- Paneles de administración (/admin/, /login/)
- Archivos críticos (config.php, phpinfo.php)
- Estructura de templates

**Ejemplo:**
```bash
./php_research.sh example.com
```

**Nota:** Solo hace UNA petición al sitio (como visitante normal).

## snap_to_flatpak.sh

**Propósito:** Eliminar completamente snap/snapd de sistemas Ubuntu y migrar a flatpak como alternativa universal.

**Uso:**
```bash
sudo ./snap_to_flatpak.sh
```

**Qué hace:**
1. Lista y elimina todos los snaps instalados
2. Desinstala snapd y bloquea su reinstalación
3. Limpia directorios residuales de snap
4. Instala y configura flatpak con Flathub
5. Ofrece reinstalar navegadores y aplicaciones comunes

**Compatibilidad:** Ubuntu 20.04+, Xubuntu, Lubuntu, Kubuntu y derivados oficiales

**Ejemplo:**
```bash
sudo ./snap_to_flatpak.sh
```

**Requisito:** Ejecutar como root (`sudo`)

## `unir_video_audio_salida.sh`

**Propósito:** Combinar un video MP4 con un audio WebM, manejando tanto videos con audio existente como sin audio.

**Uso:**
```bash
./unir_video_audio_salida.sh <video.mp4> <audio_final.webm> <salida.mp4>
```

**Qué hace:**
1. Detecta automáticamente si el video de entrada tiene pista de audio
2. **Si el video TIENE audio:**
   - Extrae el audio original del MP4 a AAC
   - Convierte el audio WebM a AAC
   - Concatena ambos audios en secuencia
   - Combina el video con el audio concatenado
3. **Si el video NO tiene audio:**
   - Convierte directamente el WebM a AAC
   - Combina el video con el audio convertido

**Características:**
- Manejo automático de diferentes escenarios de audio
- Conversión a formato compatible (AAC)
- Limpieza automática de archivos temporales
- Mantiene la calidad original del video (copia directa)

**Ejemplo:**
```bash
./unir_video_audio_salida.sh video_sin_audio.mp4 narracion.webm video_final.mp4
./unir_video_audio_salida.sh video_con_musica.mp4 voz_explicativa.webm tutorial_completo.mp4
```

**Requisitos:** `ffmpeg` y `ffprobe` instalados en el sistema

Para agregar una descripción de tu script `n8n-docker.sh` en el README, puedes añadir la siguiente sección:

---

## n8n-docker.sh

**Propósito:** Iniciar n8n (herramienta de automatización) usando Docker sin necesidad de permisos root (sudo).

**Uso:**
```bash
./n8n-docker.sh
```

**Qué hace:**
1. Crea automáticamente el directorio de datos `~/.n8n` si no existe
2. Descarga y ejecuta la imagen oficial de n8n desde Docker Hub
3. Expone n8n en el puerto 5678 (configurable en el script)
4. Monta el directorio local para persistencia de datos
5. Muestra información clara de acceso y ubicación de datos

**Características:**
- No requiere permisos de superusuario (usa Docker sin sudo)
- Persistencia de datos en `$HOME/.n8n`
- Contenedor temporal (se elimina al detener)
- Interfaz interactiva en terminal

**Ejemplo:**
```bash
chmod +x n8n-docker.sh
./n8n-docker.sh
```

**Acceso:** Una vez ejecutado, accede a `http://localhost:5678` en tu navegador

**Requisitos:**
- Docker instalado y configurado para uso sin sudo
- Conexión a internet para descargar la imagen
- Permisos de ejecución en el script

**Nota:** Asegúrate de que tu usuario tenga permisos para usar Docker sin sudo (generalmente añadiéndote al grupo `docker`)
