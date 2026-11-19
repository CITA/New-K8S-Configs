#!/bin/bash
set -euo pipefail

NS="cita-site-website"

echo "===== Stopping WordPress ====="
kubectl scale deployment/cita-site-website -n "$NS" --replicas=0

kubectl wait --for=delete pod \
  -l app=cita-site-website \
  -n "$NS" --timeout=300s

echo "===== Stopping MariaDB ====="
kubectl scale deployment/cita-site-mariadb -n "$NS" --replicas=0

kubectl wait --for=delete pod \
  -l app=cita-site-mariadb \
  -n "$NS" --timeout=300s

echo "===== Final Status ====="
kubectl get deployments,pods -n "$NS"

echo "WordPress and MariaDB stopped."
