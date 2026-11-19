#!/bin/bash
set -euo pipefail

NS="cita-webmail"

echo "===== Stopping CITA Webmail ====="

kubectl scale deployment/cita-webmail \
  -n "$NS" --replicas=0

echo "===== Waiting for Pod to Terminate ====="

kubectl wait --for=delete pod \
  -l app=cita-webmail \
  -n "$NS" --timeout=300s

echo "===== Final Status ====="
kubectl get deployments,pods -n "$NS"

echo "CITA Webmail stopped."
