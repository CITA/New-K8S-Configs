#!/bin/bash
set -euo pipefail

NS="cita-wiki"

echo "===== Stopping CITA Wiki ====="
kubectl scale deployment/new-citawiki -n "$NS" --replicas=0

kubectl wait --for=delete pod \
  -l app=new-citawiki \
  -n "$NS" --timeout=300s

echo "===== Final Status ====="
kubectl get deployments,pods -n "$NS"

echo "CITA Wiki stopped. MariaDB unchanged."
