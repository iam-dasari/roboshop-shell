#!/usr/bin/env bash

set -Eeuo pipefail

NAMESPACE="${1:-}"

OUTPUT_DIR="/tmp/k8s-diagnostics-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$OUTPUT_DIR"

echo "======================================"
echo " Kubernetes Diagnostics"
echo "======================================"

echo "Context:"
kubectl config current-context

echo

echo "Collecting Kubernetes information..."

run_kubectl() {
    local name="$1"
    shift

    echo "Collecting: $name"

    {
        echo "===== $name ====="
        kubectl "$@"
        echo
    } > "${OUTPUT_DIR}/${name}.txt" 2>&1 || true
}

if [[ -n "$NAMESPACE" ]]; then

    run_kubectl pods get pods -n "$NAMESPACE" -o wide

    run_kubectl deployments get deployments -n "$NAMESPACE"

    run_kubectl services get svc -n "$NAMESPACE"

    run_kubectl events get events -n "$NAMESPACE" \
        --sort-by=.lastTimestamp

    run_kubectl configmaps get configmaps -n "$NAMESPACE"

    run_kubectl ingress get ingress -n "$NAMESPACE"

else

    run_kubectl nodes get nodes -o wide

    run_kubectl pods get pods -A -o wide

    run_kubectl deployments get deployments -A

    run_kubectl services get svc -A

    run_kubectl events get events -A \
        --sort-by=.lastTimestamp

    run_kubectl ingress get ingress -A
fi

echo
echo "Diagnostics stored in:"
echo "$OUTPUT_DIR"

tar -czf "${OUTPUT_DIR}.tar.gz" \
    -C "$(dirname "$OUTPUT_DIR")" \
    "$(basename "$OUTPUT_DIR")"

echo
echo "Archive:"
echo "${OUTPUT_DIR}.tar.gz"