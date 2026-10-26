#!/bin/bash
set -euo pipefail
NS=${NS:-cita-wiki}

kubectl -n "$NS" rollout status deployment/new-citawiki --timeout=180s
kubectl -n "$NS" get deployment new-citawiki
kubectl -n "$NS" get pods -l app=new-citawiki -o wide
kubectl -n "$NS" get service new-citawiki -o wide
kubectl -n "$NS" get endpointslice -l kubernetes.io/service-name=new-citawiki

POD=$(kubectl -n "$NS" get pods -l app=new-citawiki -o jsonpath='{.items[0].metadata.name}')
echo "===== Apache modules ====="
kubectl -n "$NS" exec "$POD" -c web -- apache2ctl -M
echo "===== Apache syntax ====="
kubectl -n "$NS" exec "$POD" -c web -- apache2ctl -t
echo "===== Apache virtual hosts ====="
kubectl -n "$NS" exec "$POD" -c web -- apache2ctl -S
