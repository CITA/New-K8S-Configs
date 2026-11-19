# CITA PDF - Kubernetes Operations Runbook

Namespace: cita-pdf
Configuration directory: /k8s/configs/cita-pdf

Application:
- Deployment: cita-pdf
- Pod: 3 containers

All commands below are executed from:

cd /k8s/configs/cita-pdf

## 1. Stop / Start CITA PDF

Stop the entire application:

./Stop-PDF.sh

This scales the cita-pdf Deployment to 0 replicas
and waits for the Pod to terminate.

Start the entire application:

./Start-PDF.sh

This scales the Deployment to 1 replica and waits
until it becomes available.

## 2. Apply Configuration Changes

Use after modifying:
- deployment.yaml
- service.yaml
- app-config.yaml
- nginx-config.yaml
- mysql-cnf-config.yaml
- mysql-initdb-config.yaml

Procedure:

# Stop CITA PDF
./Stop-PDF.sh

# Validate and apply changes
./Apply-Changes.sh

# Start CITA PDF
./Start-PDF.sh

NOTE:
Apply-Changes.sh may automatically start the Deployment
if replicas is set to 1 in deployment.yaml.

Running Start-PDF.sh afterward is safe.
Scaling an already running Deployment to 1 does not
restart its Pod.

If Apply-Changes.sh fails, investigate before proceeding.

## 3. TLS Certificate Renewal

The Nginx TLS Secret is managed separately.

Run:

./nginx-certs-keys.sh

Restart CITA PDF if Nginx does not automatically
load the renewed certificate.

## 4. Important Notes

- Apply-Changes.sh validates configuration before applying.
- Validation failure prevents the apply step.
- A failed apply may leave partially updated resources.
- Never delete PVCs or PVs during routine maintenance.
- Do not delete the namespace to restart the application.
- The PVC is managed separately from Kustomize.
- Existing Secrets must be available before starting.
- A complete stop/start interrupts all three containers.
