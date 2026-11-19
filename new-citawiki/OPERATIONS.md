# CITA Wiki - Kubernetes Operations Runbook

Namespace: cita-wiki
Configuration directory: /k8s/configs/new-citawiki

Applications:
- MediaWiki: new-citawiki
- MariaDB: new-citawiki-db

## 1. Stop / Start Website Only

cd /k8s/configs/new-citawiki

Stop MediaWiki:

./Stop-Website-only.sh

Start MediaWiki:

./Start-Website-only.sh

MariaDB remains running.

## 2. Stop / Start Website and MariaDB

cd /k8s/configs/new-citawiki

Stop both applications:

./Stop-Website-DB.sh

Start both applications:

./Start-Website-DB.sh

Stop order: MediaWiki -> MariaDB
Start order: MariaDB -> MediaWiki

## 3. Apply Changes Affecting MediaWiki Only

cd /k8s/configs/new-citawiki

# 1. Validate and apply configuration
./Apply-Changes.sh

# 2. Stop MediaWiki
./Stop-Website-only.sh

# 3. Start MediaWiki
./Start-Website-only.sh

## 4. Apply Changes Affecting MediaWiki and MariaDB

cd /k8s/configs/new-citawiki

# 1. Validate and apply configuration
./Apply-Changes.sh

# 2. Stop MediaWiki and MariaDB
./Stop-Website-DB.sh

# 3. Start MariaDB and MediaWiki
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
