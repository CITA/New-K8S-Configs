# CITA Indico - Kubernetes Operations Runbook

Namespace: cita-indico
Configuration directory: /k8s/configs/cita-indico
External IP: 142.1.127.105

Applications:
- cita-indico (web + Nginx)
- indico-celery
- indico-celery-beat
- indico-redis
- indico-postgres (StatefulSet)

All commands below are executed from:

cd /k8s/configs/cita-indico

## 1. Stop / Start CITA Indico

Stop the entire application:

./Stop-Indico.sh

Stop order:
1. Celery Beat
2. Indico web
3. Celery workers
4. Redis
5. PostgreSQL

Ensure important Celery tasks have completed before stopping.

Start the entire application:

./Start-Indico.sh

Start order:
1. PostgreSQL
2. Redis
3. Celery workers
4. Indico web
5. Celery Beat

The Start script waits for each workload to become
ready before proceeding.

## 2. Apply Configuration Changes

Use after modifying:
- indico-web.yaml
- indico-celery.yaml
- indico-config.yaml
- nginx-config.yaml
- postgres.yaml
- postgres-init.yaml
- redis.yaml
- service.yaml

Procedure:

# Stop CITA Indico
./Stop-Indico.sh

# Validate and apply changes
./Apply-Changes.sh

# Start CITA Indico
./Start-Indico.sh

NOTE:
Apply-Changes.sh may automatically start workloads
if replicas is set to 1 in the YAML manifests.

Running Start-Indico.sh afterward is safe.
Scaling an already running workload to 1 does not
restart its Pods.

However, Apply-Changes.sh may start workloads
simultaneously rather than in dependency order.

If Apply-Changes.sh fails, investigate before proceeding.

## 3. TLS Certificate Renewal

The Nginx TLS Secret is managed separately.

Secret:
nginx-certs-keys

Certificate source:
/k8s/configs/TLS

After updating the certificate files, run:

./nginx-certs-keys.sh

Verify:

kubectl get secret nginx-certs-keys -n cita-indico

Restart the Indico web Deployment if Nginx does not
automatically load the renewed certificate.

## 4. Verify Application

Check Kubernetes resources:

kubectl get deployments,statefulsets,pods,svc,pvc \
  -n cita-indico

Expected:
- Four Deployments: 1/1 Ready
- PostgreSQL StatefulSet: 1/1 Ready
- Indico web Pod: 2/2 Running
- Other Pods: 1/1 Running
- External IP: 142.1.127.105

## 5. Important Notes

- Apply-Changes.sh validates before applying.
- Validation failure prevents the apply step.
- A failed apply may leave partially updated resources.
- Never delete PVCs or PVs during routine maintenance.
- Do not delete the namespace to restart applications.
- Namespace and PVC are managed separately.
- Secrets must exist before application startup.
- PostgreSQL is a StatefulSet, not a Deployment.
- Stop Celery Beat before stopping Celery workers.
- Allow active Celery tasks to finish before shutdown.
- Stop PostgreSQL last and start PostgreSQL first.
- Do not stop Indico during an active database backup.
- PostgreSQL password changes require coordinated
  database credential updates.
