#!/bin/bash
set -euo pipefail

NS="cita-indico"

start_workload() {
    local type="$1"
    local name="$2"

    echo "===== Starting $name ====="
    kubectl scale "$type/$name" -n "$NS" --replicas=1

    kubectl rollout status "$type/$name" \
        -n "$NS" --timeout=300s

    echo "$name ready."
}

start_workload statefulset indico-postgres
start_workload deployment indico-redis
start_workload deployment indico-celery
start_workload deployment cita-indico
start_workload deployment indico-celery-beat

echo "===== Final Status ====="
kubectl get deployments,statefulsets,pods,svc -n "$NS"

echo "CITA Indico started."
