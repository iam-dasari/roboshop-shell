#!/usr/bin/env bash

set -Eeuo pipefail

SERVICE="${1:-cart}"
APP_DIR="/app"
BACKUP_DIR="/opt/roboshop/backups"

echo "======================================"
echo " Application Rollback"
echo "======================================"

LATEST_BACKUP="$(find "$BACKUP_DIR" \
    -type f \
    -name "${SERVICE}-*.tar.gz" \
    -printf '%T@ %p\n' 2>/dev/null |
    sort -nr |
    head -1 |
    cut -d' ' -f2-)"

if [[ -z "$LATEST_BACKUP" ]]; then
    echo "ERROR: No backup found for $SERVICE"
    exit 1
fi

echo "Backup selected:"
echo "$LATEST_BACKUP"
echo

read -r -p "Continue rollback? [y/N]: " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Rollback cancelled."
    exit 0
fi

echo "[1] Stopping service..."

systemctl stop "$SERVICE"

echo "[2] Restoring backup..."

rm -rf "${APP_DIR:?}"/*
tar -xzf "$LATEST_BACKUP" -C "$APP_DIR"

echo "[3] Starting service..."

systemctl start "$SERVICE"

sleep 5

echo "[4] Validating service..."

if systemctl is-active --quiet "$SERVICE"; then
    echo
    echo "ROLLBACK SUCCESSFUL"
else
    echo
    echo "ROLLBACK FAILED"
    exit 1
fi

#Usage: sudo ./03-rollback.sh cart