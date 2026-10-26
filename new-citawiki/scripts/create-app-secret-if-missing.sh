#!/bin/bash
# Create app credential only if absent. Never prints or overwrites the password.
set -euo pipefail
NS=${NS:-cita-wiki}
SECRET=${SECRET:-new-citawiki-app-secret}

if kubectl -n "$NS" get secret "$SECRET" >/dev/null 2>&1; then
  echo "Secret $SECRET already exists; leaving it unchanged."
  exit 0
fi

umask 077
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
openssl rand -hex 32 | tr -d '\n' > "$TMP"
kubectl -n "$NS" create secret generic "$SECRET" --from-file=password="$TMP"
echo "Created Secret $SECRET. Ensure the same password was configured for the citawiki_app database user."
