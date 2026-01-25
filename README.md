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
./php_researcher.sh dominio.com
```

**Qué detecta:**
- Archivos .php en HTML y JavaScript
- Paneles de administración (/admin/, /login/)
- Archivos críticos (config.php, phpinfo.php)
- Estructura de templates

**Ejemplo:**
```bash
./php_researcher.sh example.com
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
sudo ./remove-snap.sh
```

**Requisito:** Ejecutar como root (`sudo`)
