# CITA Indico - Kubernetes Operations Runbook

Namespace: cita-indico
Configuration directory: /k8s/configs/cita-indico

Applications:
- cita-indico (web + Nginx)
- indico-celery
- indico-celery-beat
- indico-redis
- indico-postgres (StatefulSet)

## 1. Stop / Start CITA Indico

cd /k8s/configs/cita-indico

Stop all components:

./Stop-Indico.sh

Stop order:
1. Celery Beat
2. Indico web
3. Celery workers
4. Redis
5. PostgreSQL

Start all components:

./Start-Indico.sh

Start order:
1. PostgreSQL
2. Redis
3. Celery workers
4. Indico web
5. Celery Beat

The Start script waits for each workload to become ready.

Ensure important Celery tasks have completed before stopping.

## 2. Apply Configuration Changes

cd /k8s/configs/cita-indico

# 1. Validate and apply configuration
./Apply-Changes.sh

# 2. Stop all Indico components
./Stop-Indico.sh

# 3. Start components in dependency order
./Start-Indico.sh

## 3. Important Notes

- Apply-Changes.sh validates before applying.
- If Apply-Changes.sh fails, stop and investigate.
- Applying Deployment or StatefulSet changes may restart Pods.
- The subsequent stop/start creates fresh Pods.
- Do not delete PVCs or PVs during routine maintenance.
- TLS certificates are managed using nginx-certs-keys.sh.
- Namespace and PVC are managed separately.
- PostgreSQL is a StatefulSet, not a Deployment.
- Stop Celery Beat before stopping Celery workers.
- Allow active Celery tasks to finish before shutdown.
- Stop PostgreSQL last and start PostgreSQL first.
- Avoid stopping during active database backups.
