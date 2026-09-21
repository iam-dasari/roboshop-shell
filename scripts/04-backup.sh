#!/usr/bin/env bash

set -Eeuo pipefail

BACKUP_DIR="/opt/roboshop/backups"
APP_DIR="/app"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"

echo "======================================"
echo " RoboShop Backup"
echo "======================================"

echo "[1] Application backup..."

tar -czf \
    "${BACKUP_DIR}/application-${TIMESTAMP}.tar.gz" \
    -C "$APP_DIR" .

echo "Application backup completed."

if command -v mysqldump >/dev/null 2>&1; then

    echo
    echo "[2] MySQL backup..."

    MYSQL_HOST="${MYSQL_HOST:-localhost}"
    MYSQL_USER="${MYSQL_USER:-root}"

    if [[ -z "${MYSQL_PASSWORD:-}" ]]; then
        echo "MYSQL_PASSWORD is not set."
        echo "Skipping MySQL backup."
    else

        mysqldump \
            -h "$MYSQL_HOST" \
            -u "$MYSQL_USER" \
            -p"$MYSQL_PASSWORD" \
            --all-databases \
            | gzip > "${BACKUP_DIR}/mysql-${TIMESTAMP}.sql.gz"

        echo "MySQL backup completed."
    fi
fi

echo
echo "Backup files:"
ls -lh "$BACKUP_DIR"/*"$TIMESTAMP"*

#Usage: sudo MYSQL_PASSWORD='your-password' ./04-backup.sh