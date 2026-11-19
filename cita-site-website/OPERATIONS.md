# CITA Production Website - Operations Runbook

Namespace: cita-site-website
Configuration directory: /k8s/configs/cita-site-website

Applications:
- WordPress: cita-site-website
- MariaDB: cita-site-mariadb

All commands below are executed from:

cd /k8s/configs/cita-site-website

## 1. Stop / Start Website Only

Stop WordPress (MariaDB remains running):

./Stop-Website-only.sh

Start WordPress:

./Start-Website-only.sh

## 2. Stop / Start Website and MariaDB

Stop both applications:

./Stop-Website-DB.sh

This stops WordPress first, then MariaDB.

Start both applications:

./Start-Website-DB.sh

This starts MariaDB first, waits until it is ready,
then starts WordPress.

## 3. Apply Changes Affecting WordPress Only

Use after modifying:
- Apache ConfigMap
- PHP ConfigMap
- WordPress ConfigMap
- WordPress Secrets
- Web Deployment
- Web Services

Procedure:

# Stop WordPress
./Stop-Website-only.sh

# Validate and apply changes
./Apply-Changes.sh

# Start WordPress
./Start-Website-only.sh

NOTE:
Apply-Changes.sh may automatically start the Deployment
if replicas is set to 1 in the Deployment YAML.

Running Start-Website-only.sh afterward is safe.
Scaling an already running Deployment to 1 does not
restart its Pod.

If Apply-Changes.sh fails, investigate before proceeding.

## 4. Apply Changes Affecting WordPress and MariaDB

Use after modifying:
- Web and database Deployments
- ConfigMaps or Secrets affecting both applications
- Other configuration requiring both applications to stop

Procedure:

# Stop WordPress first, then MariaDB
./Stop-Website-DB.sh

# Validate and apply changes
./Apply-Changes.sh

# Start MariaDB first, then WordPress
./Start-Website-DB.sh

NOTE:
Apply-Changes.sh may automatically start both Deployments
before Start-Website-DB.sh runs.

The Start script safely sets replicas to 1 again,
but does not guarantee database-first startup if
Apply-Changes.sh already started both applications.

If Apply-Changes.sh fails, investigate before proceeding.

## 5. Important Notes

- Apply-Changes.sh validates configuration before applying.
- Validation failure prevents the apply step.
- A failed apply may leave partially updated resources.
- Never delete PVCs or PVs during routine maintenance.
- Do not delete the namespace to restart applications.
- Use RECOVERY.md for disaster recovery.
- TLS certificates are managed separately using
  apache-certs-keys.sh.
- MariaDB password changes require coordinated database
  credential updates, not just a Secret change and restart.
