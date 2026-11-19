#!/bin/bash
set -euo pipefail

NS="cita-pdf"

echo "===== Stopping CITA PDF ====="

kubectl scale deployment/cita-pdf \
  -n "$NS" --replicas=0

echo "===== Waiting for Pods to Terminate ====="

kubectl wait --for=delete pod \
  -l app=cita-pdf \
  -n "$NS" --timeout=300s

echo "===== Final Status ====="
kubectl get deployments,pods -n "$NS"

echo "CITA PDF stopped."
