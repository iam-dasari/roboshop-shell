#!/usr/bin/env bash

set -Eeuo pipefail

TARGET_DIR="${1:-.}"
IMAGE="${2:-}"

FAILED=0

echo "======================================"
echo " DevSecOps Security Scan"
echo "======================================"

echo
echo "[1] Secret scanning..."

if command -v gitleaks >/dev/null 2>&1; then

    if gitleaks detect \
        --source "$TARGET_DIR" \
        --no-banner; then

        echo "PASS: No secrets detected"

    else

        echo "FAIL: Potential secrets detected"
        FAILED=1
    fi

else
    echo "WARNING: gitleaks not installed"
fi

echo
echo "[2] IaC scanning..."

if command -v checkov >/dev/null 2>&1; then

    if checkov \
        -d "$TARGET_DIR"; then

        echo "PASS: Checkov completed"

    else

        echo "FAIL: IaC security findings detected"
        FAILED=1
    fi

else
    echo "WARNING: checkov not installed"
fi

if [[ -n "$IMAGE" ]]; then

    echo
    echo "[3] Container scanning..."

    if command -v trivy >/dev/null 2>&1; then

        if trivy image \
            --severity HIGH,CRITICAL \
            --exit-code 1 \
            "$IMAGE"; then

            echo "PASS: Container scan passed"

        else

            echo "FAIL: HIGH/CRITICAL vulnerabilities detected"
            FAILED=1
        fi

    else
        echo "WARNING: trivy not installed"
    fi
fi

echo
echo "======================================"

if [[ "$FAILED" -eq 0 ]]; then
    echo "SECURITY RESULT: PASS"
    exit 0
else
    echo "SECURITY RESULT: FAIL"
    exit 1
fi

#Usage: ./12-security-scan.sh .