#!/bin/bash
# Capture the currently running new database Deployment, Service, and PVC so
# exact image/env/storage settings are not guessed. Exports JSON, which is valid
# Kubernetes input format. Output is a recovery snapshot, not a blind re-create
# procedure: PVC/PV binding and sensitive env refs must be reviewed before apply.
set -euo pipefail
NS=${NS:-cita-wiki}
OUT=${1:-./snapshots}
mkdir -p "$OUT"

for pair in \
  'deployment/new-citawiki-db db-deployment.json' \
  'service/new-citawiki-db db-service.json' \
  'pvc/new-citawiki-db-pvc db-pvc.json' \
  'pvc/new-citawiki-files-pvc files-pvc.json'; do
  set -- $pair
  resource=$1
  file=$2
  echo "Exporting $resource -> $OUT/$file"
  kubectl -n "$NS" get "$resource" -o json > "$OUT/$file"
done

# Export web deployment too, to help compare live state with web-deployment.yaml.
kubectl -n "$NS" get deployment new-citawiki -o json > "$OUT/new-web-live.json"
cat <<MSG
Snapshots captured. These JSON files contain live Kubernetes metadata and are
for reference/recovery. Review resourceVersion, UID, status, service IPs, PVC
binding, and secret references before attempting to reapply them. Protect these
files as configuration backups.
MSG
