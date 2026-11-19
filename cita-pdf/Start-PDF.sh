#!/bin/bash
set -euo pipefail

NS="cita-pdf"

echo "===== Starting CITA PDF ====="

kubectl scale deployment/cita-pdf \
  -n "$NS" --replicas=1

echo "===== Waiting for Deployment ====="

kubectl rollout status deployment/cita-pdf \
  -n "$NS" --timeout=300s

echo "===== Final Status ====="
kubectl get deployments,pods,svc -n "$NS"

echo "CITA PDF started."
