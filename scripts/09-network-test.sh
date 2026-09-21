#!/usr/bin/env bash

set -Eeuo pipefail

HOST="${1:-}"
PORT="${2:-}"

if [[ -z "$HOST" || -z "$PORT" ]]; then
    echo "Usage: $0 <hostname> <port>"
    echo
    echo "Example:"
    echo "$0 redis.dasaridevops.online 6379"
    exit 1
fi

echo "======================================"
echo " Network Connectivity Test"
echo "======================================"
echo "Host: $HOST"
echo "Port: $PORT"
echo

echo "[1] DNS resolution..."

if getent hosts "$HOST"; then
    echo "PASS: DNS resolution successful"
else
    echo "FAIL: DNS resolution failed"
    exit 1
fi

echo
echo "[2] TCP connectivity..."

if command -v nc >/dev/null 2>&1; then

    if nc -zvw5 "$HOST" "$PORT"; then
        echo "PASS: TCP connection successful"
    else
        echo "FAIL: TCP connection failed"
        exit 1
    fi

else
    echo "WARNING: nc is not installed"
fi

echo
echo "[3] Route..."

if command -v traceroute >/dev/null 2>&1; then
    traceroute -m 5 "$HOST" || true
elif command -v tracepath >/dev/null 2>&1; then
    tracepath "$HOST" || true
else
    echo "traceroute/tracepath not installed"
fi

echo
echo "Network test completed."

