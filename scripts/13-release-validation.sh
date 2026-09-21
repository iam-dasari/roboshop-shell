#!/usr/bin/env bash

set -Eeuo pipefail

SERVICE="${1:-}"
VERSION="${2:-}"
ECR_REPOSITORY="${3:-}"

if [[ -z "$SERVICE" || -z "$VERSION" ]]; then
    echo "Usage:"
    echo "$0 <service> <version> [ecr-repository]"
    exit 1
fi

FAILED=0

echo "======================================"
echo " Release Validation"
echo "======================================"
echo "Service : $SERVICE"
echo "Version : $VERSION"
echo

echo "[1] Git status..."

if git diff --quiet && git diff --cached --quiet; then
    echo "PASS: No uncommitted changes"
else
    echo "WARNING: Working tree contains changes"
fi

echo
echo "[2] Artifact validation..."

if [[ -n "${ARTIFACT_BASE_URL:-}" ]]; then

    ARTIFACT_URL="${ARTIFACT_BASE_URL}/${SERVICE}-${VERSION}.zip"

    if curl -fsI "$ARTIFACT_URL" >/dev/null; then
        echo "PASS: Artifact exists"
    else
        echo "FAIL: Artifact not found"
        FAILED=1
    fi
else
    echo "WARNING: ARTIFACT_BASE_URL not configured"
fi

echo
echo "[3] ECR validation..."

if [[ -n "$ECR_REPOSITORY" ]] && command -v aws >/dev/null 2>&1; then

    if aws ecr describe-images \
        --repository-name "$ECR_REPOSITORY" \
        --image-ids "imageTag=$VERSION" \
        >/dev/null; then

        echo "PASS: Image exists in ECR"

    else

        echo "FAIL: Image does not exist in ECR"
        FAILED=1
    fi
else
    echo "WARNING: ECR validation skipped"
fi

echo
echo "[4] Kubernetes manifest validation..."

if command -v kubectl >/dev/null 2>&1; then

    if kubectl apply \
        --dry-run=client \
        -f k8s/ >/dev/null 2>&1; then

        echo "PASS: Kubernetes manifests valid"

    else

        echo "WARNING: Kubernetes manifest validation failed"
    fi
fi

echo
echo "======================================"

if [[ "$FAILED" -eq 0 ]]; then
    echo "RELEASE VALIDATION: PASS"
    exit 0
else
    echo "RELEASE VALIDATION: FAIL"
    exit 1
fi