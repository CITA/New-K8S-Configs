#!/bin/bash
set -euo pipefail

NS="cita-webmail"
DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$DIR"

echo "===== Validating Kubernetes Configuration ====="

if ! kubectl apply --dry-run=server -k .; then
    echo "ERROR: Validation failed. No changes applied."
    exit 1
fi

echo "===== Validation Successful ====="
echo "===== Applying Kubernetes Configuration ====="

if ! kubectl apply -k .; then
    echo "ERROR: Kubernetes apply failed."
    echo "Some resources may have been updated before the failure."
    exit 1
fi

echo "===== Configuration Applied Successfully ====="

kubectl get deployments,pods,svc -n "$NS"

echo "Configuration update completed."
