# CITA Forms - Kubernetes Operations Runbook

Namespace: cita-forms
Configuration directory: /k8s/configs/forms
Production URL: https://forms.cita.utoronto.ca/

Application:
- Deployment: cita-forms
- Pod: 3 containers (Nginx, MySQL, Django)

## 1. Stop / Start CITA Forms

cd /k8s/configs/forms

Stop application:

./Stop-Forms.sh

Start application:

./Start-Forms.sh

Both commands affect all three containers.

## 2. Apply Configuration Changes

cd /k8s/configs/forms

# 1. Validate and apply configuration
./Apply-Changes.sh

# 2. Stop application
./Stop-Forms.sh

# 3. Start application
./Start-Forms.sh

## 3. Important Notes

- Apply-Changes.sh validates before applying.
- If Apply-Changes.sh fails, stop and investigate.
- Applying Deployment changes may automatically restart Pods.
- The subsequent stop/start creates a fresh Pod.
- Do not delete PVCs or PVs during routine maintenance.
- TLS certificates are managed using nginx-certs-keys.sh.
- The PVC is managed separately from Kustomize.
- Stop/start also stops the MySQL database.
- Avoid stopping during active database backups.
