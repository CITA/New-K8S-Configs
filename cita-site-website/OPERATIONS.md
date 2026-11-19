# CITA Production Website - Kubernetes Operations Runbook

Namespace: cita-site-website
Configuration directory: /k8s/configs/cita-site-website
Production URL: https://www.cita.utoronto.ca/

Applications:
- WordPress: cita-site-website
- MariaDB: cita-site-mariadb

## 1. Stop / Start Website Only

cd /k8s/configs/cita-site-website

Stop WordPress:

./Stop-Website-only.sh

Start WordPress:

./Start-Website-only.sh

MariaDB remains running.

## 2. Stop / Start Website and MariaDB

cd /k8s/configs/cita-site-website

Stop both applications:

./Stop-Website-DB.sh

Start both applications:

./Start-Website-DB.sh

Stop order: WordPress -> MariaDB
Start order: MariaDB -> WordPress

## 3. Apply Changes Affecting WordPress Only

cd /k8s/configs/cita-site-website

# 1. Validate and apply configuration
./Apply-Changes.sh

# 2. Stop WordPress
./Stop-Website-only.sh

# 3. Start WordPress
./Start-Website-only.sh

## 4. Apply Changes Affecting WordPress and MariaDB

cd /k8s/configs/cita-site-website

# 1. Validate and apply configuration
./Apply-Changes.sh

# 2. Stop WordPress and MariaDB
./Stop-Website-DB.sh

# 3. Start MariaDB and WordPress
./Start-Website-DB.sh

## 5. Important Notes

- Apply-Changes.sh validates before applying.
- If Apply-Changes.sh fails, stop and investigate.
- Applying Deployment changes may automatically restart Pods.
- The subsequent stop/start creates fresh Pods.
- Do not delete PVCs or PVs during routine maintenance.
- TLS certificates are managed using apache-certs-keys.sh.
- Use RECOVERY.md for disaster recovery.
- Database password changes require coordinated credential updates.
