#!/usr/bin/env bash

set -Eeuo pipefail

LOG_DIR="${LOG_DIR:-/var/log/roboshop}"
BACKUP_DIR="${BACKUP_DIR:-/opt/roboshop/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"

echo "======================================"
echo " Cleanup"
echo "======================================"

echo "Retention: $RETENTION_DAYS days"
echo

if [[ -d "$LOG_DIR" ]]; then
    echo "[1] Old logs..."

    find "$LOG_DIR" \
        -type f \
        -mtime +"$RETENTION_DAYS" \
        -print
fi

if [[ -d "$BACKUP_DIR" ]]; then
    echo
    echo "[2] Old backups..."

    find "$BACKUP_DIR" \
        -type f \
        -mtime +"$RETENTION_DAYS" \
        -print
fi

echo
read -r -p "Delete the files listed above? [y/N]: " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

if [[ -d "$LOG_DIR" ]]; then
    find "$LOG_DIR" \
        -type f \
        -mtime +"$RETENTION_DAYS" \
        -delete
fi

if [[ -d "$BACKUP_DIR" ]]; then
    find "$BACKUP_DIR" \
        -type f \
        -mtime +"$RETENTION_DAYS" \
        -delete
fi

if command -v docker >/dev/null 2>&1; then
    echo
    echo "[3] Docker disk usage:"
    docker system df

    echo
    echo "Docker cleanup can be performed separately with:"
    echo "docker image prune"
fi

echo
echo "Cleanup completed."

