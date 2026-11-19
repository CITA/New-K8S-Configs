# CITA PDF - Kubernetes Operations Runbook

Namespace: cita-pdf
Configuration directory: /k8s/configs/cita-pdf

Application:
- Deployment: cita-pdf
- Pod: 3 containers

## 1. Stop / Start CITA PDF

cd /k8s/configs/cita-pdf

Stop application:

./Stop-PDF.sh

Start application:

./Start-PDF.sh

Both commands affect all three containers.

## 2. Apply Configuration Changes

cd /k8s/configs/cita-pdf

# 1. Validate and apply configuration
./Apply-Changes.sh

# 2. Stop application
./Stop-PDF.sh

# 3. Start application
./Start-PDF.sh

## 3. Important Notes

- Apply-Changes.sh validates before applying.
- If Apply-Changes.sh fails, stop and investigate.
- Applying Deployment changes may automatically restart Pods.
- The subsequent stop/start creates a fresh Pod.
- Do not delete PVCs or PVs during routine maintenance.
- TLS certificates are managed using nginx-certs-keys.sh.
- The PVC is managed separately from Kustomize.
