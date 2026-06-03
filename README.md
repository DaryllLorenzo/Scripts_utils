# Scripts Utilitarios

## Índice
- [Scripts de Sistema](#scripts-de-sistema)
- [Scripts de Multimedia](#scripts-de-multimedia)
- [Scripts de Docker](#scripts-de-docker)
- [CI/CD Workflows](#workflows-de-cicd-github-actions)

## Scripts de Sistema

### restore-pg-backup.sh
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

### php_researcher.sh
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

### snap_to_flatpak.sh

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

### system-monitor.sh
**Propósito:** Monitor del sistema en tiempo real con estadísticas de uso.

**Uso:**
```bash
./system-monitor.sh
```

**Qué hace:**
1. Muestra en tiempo real uso de CPU, memoria, disco y red
2. Actualiza automáticamente cada segundo
3. Registra picos máximos de uso durante la sesión
4. Calcula estadísticas de red (descarga/subida total)

**Características:**
- Mide picos de CPU, memoria y swap
- Calcula tráfico total de red durante la sesión
- Detección automática de interfaz de red activa
- Reporte final de sesion al terminar (Ctrl+C)

**Ejemplo:**
```bash
chmod +x system-monitor.sh
./system-monitor.sh
```

**Salida al terminar (Ctrl+C):**
```
TIME
  Duration: 180 seconds (3 minutes)
  Updates: 180
  Frequency: 1 second(s)

USAGE PEAKS
  CPU max: 85%
  Memory max: 72%
  Swap max: 15%

NETWORK
  Interface: eth0
  Total download: 45 MB
  Total upload: 8 MB
  Avg download: 256 KB/s
  Avg upload: 45 KB/s
```


## Scripts de Multimedia

### `unir_video_audio_salida.sh`

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

### `compress_video.sh`

**Propósito:** Comprimir videos con dos niveles de compresión: soft (buena calidad, menor reducción) y hard (máxima reducción, menor calidad).

**Uso:**
```bash
./compress_video.sh <archivo_entrada> [archivo_salida]
```

**Qué hace:**
1. Presenta un menú para elegir entre compresión soft o hard
2. **Soft compression:** Mantiene buena calidad con reducción moderada
   - MP4: Usa H.264 + AAC con CRF 24
   - WebM: Usa VP9 + Opus con CRF 32
   - Otros formatos: Convierte a MP4 con H.264
3. **Hard compression:** Máxima reducción de tamaño, menor calidad
   - Escala a 1280p, 24fps
   - Elimina audio
   - Usa CRF 32 para máxima compresión

**Características:**
- Soporte para múltiples formatos (MP4, WebM, otros)
- Dos modos de compresión
- Eliminación opcional de audio en modo hard
- Optimización para streaming web (faststart)
- Comparación de tamaños antes y después

**Ejemplo:**
```bash
./compress_video.sh video_original.mp4 video_comprimido.mp4
./compress_video.sh video_grande.mp4  # Usará nombre por defecto
```
**Requisitos:** `ffmpeg` instalado en el sistema

---

## Scripts de Docker

### n8n-docker.sh

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

##  **docker-manager.sh**
**Propósito:** Gestor básico de contenedores Docker

**Uso:**
```bash
./docker-manager.sh [comando]
```

**Comandos disponibles:**
- `list` - Listar contenedores activos
- `list --all` - Listar todos los contenedores
- `images` - Listar imágenes Docker
- `volumes` - Listar volúmenes
- `stats` - Mostrar estadísticas del sistema
- `ports` - Ver puertos mapeados
- `clean` - Limpiar contenedores parados
- `clean-all` - Limpiar TODO (con confirmación)
- `prune` - Eliminar recursos no usados
- `restart <nombre>` - Reiniciar contenedor
- `stop-all` - Detener todos los contenedores

**Ejemplos:**
```bash
./docker-manager.sh list
./docker-manager.sh stats
./docker-manager.sh clean-all
./docker-manager.sh restart mi_contenedor
```

## Workflows de CI/CD (GitHub Actions)

Los workflows están ubicados en `cicd/github/` y automatizan tareas de calidad de código, versionado y validación.

### `net-code-quality.yml`
**Propósito:** Análisis de calidad de código para proyectos .NET en cada Pull Request.

**Qué hace:**
1. Configura .NET 8.0 y cachea paquetes NuGet
2. Verifica el formato del código (`dotnet format`)
3. Compila con analizadores Roslyn activados
4. Trata warnings como errores para mantener código limpio

**Trigger:** Se ejecuta automáticamente en cada Pull Request.

---

### `python-code-quality.yml`
**Propósito:** Análisis de calidad de código para proyectos Python en cada Pull Request.

**Qué hace:**
1. Ejecuta `ruff check` para detectar errores de código (linting)
2. Verifica el formato con `ruff format --check`
3. Realiza type checking con MyPy

**Trigger:** Se ejecuta automáticamente en cada Pull Request.

---

### `release-versioning.yml`
**Propósito:** Automatiza el versionado semántico y la creación de releases basándose en Conventional Commits.

**Qué hace:**
1. Analiza commits desde el último tag para determinar el tipo de bump:
   - `fix:` → patch (1.0.0 → 1.0.1)
   - `feat:` → minor (1.0.0 → 1.1.0)
   - `feat!:` o `BREAKING CHANGE:` → major (1.0.0 → 2.0.0)
2. Construye el proyecto con MinVer para versionado automático
3. Genera changelog con `git-cliff`
4. Crea un tag y un GitHub Release con las notas de la versión

**Trigger:** Solo en pushes a `main` o `master` (ignora cambios en `.md` y `.github/`).

**Requisitos:**
- Usar Conventional Commits en los mensajes de commit
- Tener `cliff.toml` configurado para git-cliff
- El paquete MinVer debe estar referenciado en los `.csproj`

---

### `validate-commits.yml`
**Propósito:** Valida que los mensajes de commit sigan el formato Conventional Commits.

**Qué hace:**
- Verifica que los commits cumplan con las reglas definidas en `commitlint.config.js`
- Funciona tanto en pushes como en Pull Requests

**Trigger:** En pushes y PRs a `main`, `master` y `develop`.

**Requisitos:** Tener un archivo `commitlint.config.js` en la raíz del repositorio.