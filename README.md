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

