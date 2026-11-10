#!/bin/bash
set -e

NAMESPACE="cita-pdf"
SECRET="nginx-certs-keys"
TLS_DIR="/k8s/configs/TLS"

kubectl -n "$NAMESPACE" create secret generic "$SECRET" \
  --from-file=fullchain.pem="$TLS_DIR/fullchain.pem" \
  --from-file=cita-wildcard.key="$TLS_DIR/cita-wildcard.key" \
  --dry-run=client -o yaml |
kubectl apply -f -
