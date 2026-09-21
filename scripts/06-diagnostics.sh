#!/usr/bin/env bash

set -Eeuo pipefail

OUTPUT_DIR="/tmp/roboshop-diagnostics-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$OUTPUT_DIR"

echo "======================================"
echo " RoboShop System Diagnostics"
echo "======================================"

run_check() {
    local name="$1"
    shift

    echo "Collecting: $name"

    {
        echo "===== $name ====="
        "$@"
        echo
    } > "${OUTPUT_DIR}/${name}.txt" 2>&1 || true
}

run_check "system-info" uname -a
run_check "uptime" uptime
run_check "memory" free -m
run_check "disk" df -h
run_check "disk-inodes" df -ih
run_check "processes" ps aux
run_check "cpu" top -bn1
run_check "network" ss -lntup
run_check "routes" ip route
run_check "dns" cat /etc/resolv.conf
run_check "failed-services" systemctl --failed
run_check "services" systemctl list-units --type=service
run_check "recent-errors" journalctl -p err -n 100

echo
echo "Diagnostics collected:"
echo "$OUTPUT_DIR"

ARCHIVE="${OUTPUT_DIR}.tar.gz"

tar -czf "$ARCHIVE" -C "$(dirname "$OUTPUT_DIR")" "$(basename "$OUTPUT_DIR")"

echo
echo "Archive:"
echo "$ARCHIVE"

#Usage: sudo ./06-diagnostics.sh