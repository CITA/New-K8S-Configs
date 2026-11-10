#!/bin/bash
set -e

NAMESPACE="cita-wiki"
SECRET="apache2-certs-keys"
TLS_DIR="/k8s/configs/TLS"

kubectl -n "$NAMESPACE" create secret generic "$SECRET" \
  --from-file=cita-wildcard.crt="$TLS_DIR/fullchain.pem" \
  --from-file=cita-wildcard.key="$TLS_DIR/cita-wildcard.key" \
  --from-file=STAR_cita_utoronto_ca.ca-bundle="$TLS_DIR/STAR_cita_utoronto_ca.ca-bundle" \
  --dry-run=client -o yaml |
kubectl apply -f -
