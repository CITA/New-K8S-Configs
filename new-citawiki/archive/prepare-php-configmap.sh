#!/bin/bash
# Create the new deployment's PHP ConfigMap from the existing configmap-php,
# removing only the duplicate LDAP extension directive. Does not alter production.
set -euo pipefail
NS=${NS:-cita-wiki}
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

kubectl -n "$NS" get configmap configmap-php \
  -o jsonpath='{.data.php\.ini}' > "$TMP"

COUNT=$(grep -Ec '^[[:space:]]*extension[[:space:]]*=[[:space:]]*ldap([.]so)?[[:space:]]*$' "$TMP" || true)
if [ "$COUNT" -ne 1 ]; then
  echo "Expected exactly one active extension=ldap directive in configmap-php; found $COUNT. Stopping." >&2
  exit 1
fi
sed -i '/^[[:space:]]*extension[[:space:]]*=[[:space:]]*ldap\([.]so\)\?[[:space:]]*$/d' "$TMP"

if kubectl -n "$NS" get configmap new-citawiki-php >/dev/null 2>&1; then
  echo "ConfigMap new-citawiki-php already exists; not replacing it." >&2
  exit 1
fi
kubectl -n "$NS" create configmap new-citawiki-php --from-file=php.ini="$TMP"
echo "Created ConfigMap new-citawiki-php."
