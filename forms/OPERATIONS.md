# CITA Forms - Kubernetes Operations Runbook

Namespace: cita-forms
Configuration directory: /k8s/configs/forms
Production URL: https://forms.cita.utoronto.ca/

Application:
- Deployment: cita-forms
- Pod: 3 containers (nginx, db, web)
- External IP: 142.1.127.102

All commands below are executed from:

cd /k8s/configs/forms

## 1. Stop / Start CITA Forms

Stop the entire application:

./Stop-Forms.sh

This scales the cita-forms Deployment to 0 replicas
and waits for the Pod to terminate.

Start the entire application:

./Start-Forms.sh

This scales the Deployment to 1 replica and waits
until it becomes available.

Both operations affect all three containers:
- Nginx
- MySQL
- Django web application

## 2. Apply Configuration Changes

Use after modifying:
- deployment.yaml
- service.yaml
- configmap.yaml
- secrets.yaml
- dbbackup-secret.yaml

Procedure:

# Stop CITA Forms
./Stop-Forms.sh

# Validate and apply changes
./Apply-Changes.sh

# Start CITA Forms
./Start-Forms.sh

NOTE:
Apply-Changes.sh may automatically start the Deployment
if replicas is set to 1 in deployment.yaml.

Running Start-Forms.sh afterward is safe.
Scaling an already running Deployment to 1 does not
restart its Pod.

If Apply-Changes.sh fails, investigate before proceeding.

## 3. TLS Certificate Renewal

The Nginx TLS Secret is managed separately from Kustomize.

Secret:
nginx-certs-keys

Certificate source:
/k8s/configs/TLS

After updating the certificate files, run:

./nginx-certs-keys.sh

Verify:

kubectl get secret nginx-certs-keys -n cita-forms

Restart CITA Forms if Nginx does not automatically
load the renewed certificate.

## 4. Verify Application

Check Kubernetes resources:

kubectl get deployments,pods,svc,pvc -n cita-forms

Check application:

curl -I https://forms.cita.utoronto.ca/

Expected:
- Deployment: 1/1 Ready
- Pod: 3/3 Running
- Service external IP: 142.1.127.102

## 5. Important Notes

- Apply-Changes.sh validates configuration before applying.
- Validation failure prevents the apply step.
- A failed apply may leave partially updated resources.
- Never delete PVCs or PVs during routine maintenance.
- Do not delete the namespace to restart the application.
- The PVC is managed separately from Kustomize.
- Docker Hub and TLS Secrets are managed separately.
- Stop/start affects all three containers, including MySQL.
- Do not stop the application during an active database backup.
- MariaDB/MySQL password changes require coordinated database
  credential updates, not just a Secret change and restart.
