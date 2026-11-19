#!/bin/bash
set -euo pipefail

NS="cita-wiki"

echo "===== Starting CITA Wiki ====="
kubectl scale deployment/new-citawiki -n "$NS" --replicas=1

kubectl rollout status deployment/new-citawiki \
  -n "$NS" --timeout=300s

echo "===== Final Status ====="
kubectl get deployments,pods,svc -n "$NS"

echo "CITA Wiki started. MariaDB unchanged."
