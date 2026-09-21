#!/usr/bin/env bash

set -Eeuo pipefail

HOST="${1:-}"
PORT="${2:-443}"

if [[ -z "$HOST" ]]; then
    echo "Usage: $0 <hostname> [port]"
    exit 1
fi

echo "======================================"
echo " TLS Certificate Check"
echo "======================================"
echo "Host: $HOST"
echo "Port: $PORT"
echo

CERT_INFO="$(
    echo |
    openssl s_client \
        -connect "${HOST}:${PORT}" \
        -servername "$HOST" \
        2>/dev/null |
    openssl x509 -noout -dates -subject -issuer
)"

if [[ -z "$CERT_INFO" ]]; then
    echo "ERROR: Could not retrieve certificate."
    exit 1
fi

echo "$CERT_INFO"

EXPIRY="$(
    echo |
    openssl s_client \
        -connect "${HOST}:${PORT}" \
        -servername "$HOST" \
        2>/dev/null |
    openssl x509 -noout -enddate |
    cut -d= -f2
)"

EXPIRY_EPOCH="$(date -d "$EXPIRY" +%s)"
NOW_EPOCH="$(date +%s)"

DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

echo
echo "Days remaining: $DAYS_LEFT"

if (( DAYS_LEFT < 0 )); then
    echo "CRITICAL: Certificate expired."
    exit 2
elif (( DAYS_LEFT < 30 )); then
    echo "WARNING: Certificate expires in less than 30 days."
    exit 1
else
    echo "PASS: Certificate is valid."
fi