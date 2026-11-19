#!/bin/bash
set -euo pipefail

NS="cita-indico"

stop_workload() {
    local type="$1"
    local name="$2"
    local label="$3"

    echo "===== Stopping $name ====="
    kubectl scale "$type/$name" -n "$NS" --replicas=0

    echo "Waiting for $name Pods to terminate..."

    for i in $(seq 1 60); do
        if [ -z "$(kubectl get pods -n "$NS" \
            -l "app=$label" -o name)" ]; then
            echo "$name stopped."
            return 0
        fi
        sleep 5
    done

    echo "ERROR: Timeout waiting for $name to stop." >&2
    exit 1
}

stop_workload deployment indico-celery-beat indico-celery-beat
stop_workload deployment cita-indico cita-indico
stop_workload deployment indico-celery indico-celery
stop_workload deployment indico-redis indico-redis
stop_workload statefulset indico-postgres indico-postgres

echo "===== Final Status ====="
kubectl get deployments,statefulsets,pods -n "$NS"

echo "CITA Indico stopped."
