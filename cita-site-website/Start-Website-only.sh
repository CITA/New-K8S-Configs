#!/bin/bash
set -euo pipefail

NS="cita-site-website"

echo "===== Starting WordPress ====="
kubectl scale deployment/cita-site-website -n "$NS" --replicas=1

kubectl rollout status deployment/cita-site-website \
  -n "$NS" --timeout=300s

echo "===== Final Status ====="
kubectl get deployments,pods,svc -n "$NS"

echo "WordPress started. MariaDB unchanged."
