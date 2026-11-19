#!/bin/bash
set -euo pipefail

NS="cita-site-website"
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

echo "===== Deployment Status ====="
kubectl get deployments -n "$NS"

echo "===== Pod Status ====="
kubectl get pods -n "$NS"

echo "===== Service Status ====="
kubectl get services -n "$NS"

echo "Configuration update completed."
