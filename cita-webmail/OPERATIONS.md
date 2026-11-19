# CITA Webmail - Kubernetes Operations Runbook

Namespace: cita-webmail
Configuration directory: /k8s/configs/cita-webmail

Application:
- Deployment: cita-webmail
- Pod: 2 containers (MariaDB, Roundcube)

## 1. Stop / Start CITA Webmail

cd /k8s/configs/cita-webmail

Stop application:

./Stop-Webmail.sh

Start application:

./Start-Webmail.sh

Both commands affect MariaDB and Roundcube.

## 2. Apply Configuration Changes

cd /k8s/configs/cita-webmail

# 1. Validate and apply configuration
./Apply-Changes.sh

# 2. Stop application
./Stop-Webmail.sh

# 3. Start application
./Start-Webmail.sh

## 3. Important Notes

- Apply-Changes.sh validates before applying.
- If Apply-Changes.sh fails, stop and investigate.
- Applying Deployment changes may automatically restart Pods.
- The subsequent stop/start creates a fresh Pod.
- Do not delete PVCs or PVs during routine maintenance.
- TLS certificates are managed using apache-certs-keys.sh.
- The database PVC is managed separately from Kustomize.
- Stop/start also stops MariaDB.
- Avoid stopping during active database backups.
