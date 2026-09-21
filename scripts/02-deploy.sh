#!/usr/bin/env bash

set -Eeuo pipefail

SERVICE="${1:-}"
VERSION="${2:-}"
ARTIFACT_BASE_URL="${ARTIFACT_BASE_URL:-https://roboshop-artifacts.s3.amazonaws.com}"

APP_DIR="/app"
BACKUP_DIR="/opt/roboshop/backups"
TMP_DIR="/tmp/roboshop"

if [[ -z "$SERVICE" || -z "$VERSION" ]]; then
    echo "Usage: $0 <service> <version>"
    echo "Example: $0 cart v3"
    exit 1
fi

mkdir -p "$APP_DIR" "$BACKUP_DIR" "$TMP_DIR"

ARTIFACT="${SERVICE}-${VERSION}.zip"
DOWNLOAD_URL="${ARTIFACT_BASE_URL}/${ARTIFACT}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/${SERVICE}-${TIMESTAMP}.tar.gz"

echo "======================================"
echo " Deploying $SERVICE"
echo "======================================"

echo "[1] Downloading artifact..."

curl -fL \
    --retry 3 \
    --retry-delay 5 \
    -o "${TMP_DIR}/${ARTIFACT}" \
    "$DOWNLOAD_URL"

echo "Artifact downloaded."

echo "[2] Backing up current application..."

if [[ -d "$APP_DIR" ]] && [[ "$(find "$APP_DIR" -mindepth 1 -print -quit)" ]]; then
    tar -czf "$BACKUP_FILE" -C "$APP_DIR" .
    echo "Backup created: $BACKUP_FILE"
fi

echo "[3] Extracting application..."

rm -rf "${TMP_DIR}/${SERVICE}"

mkdir -p "${TMP_DIR}/${SERVICE}"

unzip -q \
    "${TMP_DIR}/${ARTIFACT}" \
    -d "${TMP_DIR}/${SERVICE}"

echo "[4] Deploying application..."

rm -rf "${APP_DIR:?}"/*
cp -a "${TMP_DIR}/${SERVICE}/." "$APP_DIR/"

echo "[5] Restarting service..."

systemctl daemon-reload
systemctl restart "$SERVICE"

echo "[6] Waiting for service..."

sleep 5

if systemctl is-active --quiet "$SERVICE"; then
    echo "Service started successfully."
else
    echo "ERROR: Service failed to start."
    exit 1
fi

echo
echo "Deployment completed successfully."
echo "Service : $SERVICE"
echo "Version : $VERSION"

# Usage: sudo ./02-deploy.sh cart v3