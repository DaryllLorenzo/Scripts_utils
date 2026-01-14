#!/bin/bash
# Script: restore-pg-backup.sh
# Usage: ./restore-pg-backup.sh <backup_file> [output_file]

set -e

# Validate arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <backup_file> [output_file.sql]"
    exit 1
fi

BACKUP_FILE="$1"
SQL_FILE="${2:-${1%.*}_export.sql}"

# Check if file exists
[ ! -f "$BACKUP_FILE" ] && echo "Error: $BACKUP_FILE does not exist" && exit 1

# Configuration
CONTAINER="pg-temp-$(date +%s)"
PORT=$((5432 + RANDOM % 100))

# Start PostgreSQL container
echo "Starting container..."
docker run -d --name "$CONTAINER" \
  -e POSTGRES_PASSWORD=temp123 \
  -p "$PORT:5432" \
  -v "$(realpath "$BACKUP_FILE"):/backup" \
  postgres:latest >/dev/null 2>&1

sleep 10

# Create database
docker exec "$CONTAINER" psql -U postgres -c "CREATE DATABASE restore_db;" >/dev/null 2>&1

# Restore backup
echo "Restoring backup..."
if docker exec "$CONTAINER" pg_restore -U postgres -d restore_db /backup >/dev/null 2>&1; then
    echo "Format: pg_restore (custom)"
elif docker exec "$CONTAINER" psql -U postgres -d restore_db -f /backup >/dev/null 2>&1; then
    echo "Format: psql (SQL)"
else
    echo "Error: Unsupported backup format"
    docker stop "$CONTAINER" >/dev/null 2>&1
    docker rm "$CONTAINER" >/dev/null 2>&1
    exit 1
fi

# Export to SQL
echo "Exporting to SQL..."
docker exec "$CONTAINER" pg_dump -U postgres --clean restore_db > "$SQL_FILE"

# Cleanup
docker stop "$CONTAINER" >/dev/null 2>&1
docker rm "$CONTAINER" >/dev/null 2>&1

echo "Done: $SQL_FILE"
