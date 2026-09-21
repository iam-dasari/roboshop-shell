#!/usr/bin/env bash

set -Eeuo pipefail

BACKUP_FILE="${1:-}"

MYSQL_HOST="${MYSQL_HOST:-localhost}"
MYSQL_USER="${MYSQL_USER:-root}"

if [[ -z "$BACKUP_FILE" ]]; then
    echo "Usage:"
    echo "$0 <backup.sql.gz>"
    exit 1
fi

if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "ERROR: Backup file does not exist:"
    echo "$BACKUP_FILE"
    exit 1
fi

if [[ -z "${MYSQL_PASSWORD:-}" ]]; then
    echo "ERROR: MYSQL_PASSWORD is not set."
    exit 1
fi

echo "======================================"
echo " MySQL Restore"
echo "======================================"
echo "Backup: $BACKUP_FILE"
echo

read -r -p "WARNING: This can overwrite database data. Continue? [y/N]: " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Restore cancelled."
    exit 0
fi

echo "Restoring database..."

gzip -dc "$BACKUP_FILE" |
mysql \
    -h "$MYSQL_HOST" \
    -u "$MYSQL_USER" \
    -p"$MYSQL_PASSWORD"

echo
echo "Database restore completed."

#Usage: sudo MYSQL_PASSWORD='your-password' \
#./05-restore.sh /opt/roboshop/backups/mysql-20260921-190000.sql.gz