#!/usr/bin/env bash

set -Eeuo pipefail

LOG_FILE="${1:-}"

if [[ -z "$LOG_FILE" ]]; then
    echo "Usage: $0 <log-file>"
    exit 1
fi

if [[ ! -f "$LOG_FILE" ]]; then
    echo "ERROR: Log file not found: $LOG_FILE"
    exit 1
fi

echo "======================================"
echo " Log Analysis"
echo "======================================"
echo "File: $LOG_FILE"
echo

echo "Total lines:"
wc -l "$LOG_FILE"

echo
echo "ERROR count:"
grep -Eic "error|exception|fatal" "$LOG_FILE" || true

echo
echo "WARNING count:"
grep -Eic "warn|warning" "$LOG_FILE" || true

echo
echo "HTTP 5xx:"
grep -Eic "HTTP/[0-9.]+\" 5[0-9]{2}" "$LOG_FILE" || true

echo
echo "HTTP 4xx:"
grep -Eic "HTTP/[0-9.]+\" 4[0-9]{2}" "$LOG_FILE" || true

echo
echo "Top errors:"
grep -Ei "error|exception|fatal" "$LOG_FILE" |
    sort |
    uniq -c |
    sort -nr |
    head -20 || true

echo
echo "Recent errors:"
grep -Ei "error|exception|fatal" "$LOG_FILE" |
    tail -20 || true

#Usage: ./07-log-analysis.sh /var/log/cart.log