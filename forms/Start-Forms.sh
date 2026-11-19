#!/bin/bash
set -euo pipefail

NS="cita-forms"

echo "===== Starting CITA Forms ====="

kubectl scale deployment/cita-forms \
  -n "$NS" --replicas=1

echo "===== Waiting for Deployment ====="

kubectl rollout status deployment/cita-forms \
  -n "$NS" --timeout=300s

echo "===== Final Status ====="
kubectl get deployments,pods,svc -n "$NS"

echo "CITA Forms started."
