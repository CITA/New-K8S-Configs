#!/bin/bash
set -euo pipefail

NS="cita-webmail"

echo "===== Starting CITA Webmail ====="

kubectl scale deployment/cita-webmail \
  -n "$NS" --replicas=1

echo "===== Waiting for Deployment ====="

kubectl rollout status deployment/cita-webmail \
  -n "$NS" --timeout=300s

echo "===== Final Status ====="
kubectl get deployments,pods,svc -n "$NS"

echo "CITA Webmail started."
