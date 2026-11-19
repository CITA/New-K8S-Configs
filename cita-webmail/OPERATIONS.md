# CITA Webmail - Kubernetes Operations Runbook

Namespace: cita-webmail
Configuration directory: /k8s/configs/cita-webmail

Application:
- Deployment: cita-webmail
- Pod: 2 containers (db, web)
- External IP: 142.1.127.101

All commands below are executed from:

cd /k8s/configs/cita-webmail

## 1. Stop / Start CITA Webmail

Stop the entire application:

./Stop-Webmail.sh

This scales the cita-webmail Deployment to 0 replicas
and waits for the Pod to terminate.

Start the entire application:

./Start-Webmail.sh

This scales the Deployment to 1 replica and waits
until it becomes available.

Both operations affect:
- MariaDB
- Roundcube webmail

## 2. Apply Configuration Changes

Use after modifying:
- deployment.yaml
- service.yaml
- configmap-apache.yaml
- configmap-roundcube.yaml
- secrets.yaml
- dbbackup-secret.yaml

Procedure:

# Stop CITA Webmail
./Stop-Webmail.sh

# Validate and apply changes
./Apply-Changes.sh

# Start CITA Webmail
./Start-Webmail.sh

NOTE:
Apply-Changes.sh may automatically start the Deployment
if replicas is set to 1 in deployment.yaml.

Running Start-Webmail.sh afterward is safe.
Scaling an already running Deployment to 1 does not
restart its Pod.

If Apply-Changes.sh fails, investigate before proceeding.

## 3. TLS Certificate Renewal

The Apache TLS Secret is managed separately.

Secret:
apache2-certs-keys

Certificate source:
/k8s/configs/TLS

After updating certificate files, run:

./apache-certs-keys.sh

Verify:

kubectl get secret apache2-certs-keys -n cita-webmail

Restart CITA Webmail if Apache does not automatically
load the renewed certificate.

## 4. Verify Application

Check Kubernetes resources:

kubectl get deployments,pods,svc,pvc -n cita-webmail

Check the production HTTPS endpoint using its
configured public hostname.

Expected:
- Deployment: 1/1 Ready
- Pod: 2/2 Running
- Service external IP: 142.1.127.101

## 5. Important Notes

- Apply-Changes.sh validates configuration before applying.
- Validation failure prevents the apply step.
- A failed apply may leave partially updated resources.
- Never delete PVCs or PVs during routine maintenance.
- Do not delete the namespace to restart the application.
- The database PVC is managed separately from Kustomize.
- Docker Hub and TLS Secrets are managed separately.
- Stop/start affects both MariaDB and Roundcube.
- Do not stop the application during an active database backup.
- Database password changes require coordinated database
  credential updates, not just a Secret change and restart.
- Use a separate recovery procedure for namespace or storage loss.
