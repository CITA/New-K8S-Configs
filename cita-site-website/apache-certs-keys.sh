#!/bin/bash
set -e

NAMESPACE="cita-site-website"
SECRET="cita-site-tls"
TLS_DIR="/k8s/configs/TLS"

kubectl -n "$NAMESPACE" create secret generic "$SECRET" \
  --from-file=tls.crt="$TLS_DIR/fullchain.pem" \
  --from-file=tls.key="$TLS_DIR/cita-wildcard.key" \
  --from-file=ca-bundle.crt="$TLS_DIR/STAR_cita_utoronto_ca.ca-bundle" \
  --dry-run=client -o yaml |
kubectl apply -f -
