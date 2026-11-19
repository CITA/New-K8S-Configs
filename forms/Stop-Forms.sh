#!/bin/bash
set -euo pipefail

NS="cita-forms"

echo "===== Stopping CITA Forms ====="

kubectl scale deployment/cita-forms \
  -n "$NS" --replicas=0

echo "===== Waiting for Pod to Terminate ====="

kubectl wait --for=delete pod \
  -l app=cita-forms \
  -n "$NS" --timeout=300s

echo "===== Final Status ====="
kubectl get deployments,pods -n "$NS"

echo "CITA Forms stopped."
