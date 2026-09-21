#!/usr/bin/env bash

set -Eeuo pipefail

SERVICE="${1:-cart}"
PORT="${2:-8080}"
HEALTH_URL="${3:-http://localhost:${PORT}/health}"

echo "======================================"
echo " Application Health Check"
echo "======================================"
echo "Service    : $SERVICE"
echo "Port       : $PORT"
echo "Health URL : $HEALTH_URL"
echo

FAILED=0

echo "[1] Checking systemd service..."

if systemctl is-active --quiet "$SERVICE"; then
    echo "PASS: $SERVICE service is running"
else
    echo "FAIL: $SERVICE service is not running"
    FAILED=1
fi

echo
echo "[2] Checking port $PORT..."

if command -v nc >/dev/null 2>&1; then
    if nc -z localhost "$PORT"; then
        echo "PASS: Port $PORT is listening"
    else
        echo "FAIL: Port $PORT is not listening"
        FAILED=1
    fi
else
    echo "WARNING: nc is not installed"
fi

echo
echo "[3] Checking HTTP health endpoint..."

if curl -fsS --max-time 10 "$HEALTH_URL" >/dev/null; then
    echo "PASS: Application health check successful"
else
    echo "FAIL: Application health check failed"
    FAILED=1
fi

echo
echo "======================================"

if [[ "$FAILED" -eq 0 ]]; then
    echo "RESULT: HEALTHY"
    exit 0
else
    echo "RESULT: UNHEALTHY"
    exit 1
fi

# Usage: ./01-health-check.sh cart 8080 http://localhost:8080/health