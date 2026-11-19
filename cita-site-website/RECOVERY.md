# CITA Site Website Kubernetes Recovery Runbook

Namespace: cita-site-website
Configuration directory: /k8s/configs/cita-site-website
Production URL: https://www.cita.utoronto.ca/

## 1. Overview

This directory contains the configuration required to recreate
the CITA WordPress website and MariaDB database.

Application components:
- Web Deployment: cita-site-website
- Database Deployment: cita-site-mariadb
- Web Service: cita-site-website
- External Web Service: cita-site-website-external
- Database Service: cita-site-mariadb
- External LoadBalancer IP: 142.1.127.106

The kustomization.yaml contains:
- 4 ConfigMaps
- 3 Secrets
- 3 Services
- 2 Deployments

The TLS Secret is created separately using apache-certs-keys.sh.

Namespace, PVs and PVCs are also managed separately.

IMPORTANT:
Never create new dynamically provisioned PVCs during recovery
when the original database and WordPress data must be preserved.

## 2. Normal Application Redeployment

Use when the namespace, original PVCs, and TLS Secret exist.

cd /k8s/configs/cita-site-website

# Verify required TLS Secret
kubectl get secret cita-site-tls -n cita-site-website

# Restore TLS Secret if missing
./apache-certs-keys.sh

# Apply application configuration
kubectl apply -k .

# Verify Deployments
kubectl rollout status deployment/cita-site-mariadb \
  -n cita-site-website

kubectl rollout status deployment/cita-site-website \
  -n cita-site-website

kubectl get pods,svc,pvc -n cita-site-website

## 3. Complete Namespace Recovery

Use when the cita-site-website namespace has been deleted.

Before proceeding:
- Confirm the original NFS directories still exist.
- Confirm they contain the expected database and WordPress data.
- Confirm whether the original PV objects still exist.
- Ensure the original application is not running elsewhere.
- Verify that /k8s/configs/TLS contains the required certificates.
- Do not modify or delete the original NFS data.

cd /k8s/configs/cita-site-website

### Step 1: Recreate namespace

kubectl apply -f namespace.yaml

### Step 2: Restore PVs

Verify the original PVCs no longer exist:

kubectl get pvc -n cita-site-website

STOP if either original PVC still exists.

Check the original PVs:

kubectl get pv \
  pvc-87237867-fb98-4b68-b74d-b2a139f7bcc1 \
  pvc-b27cf418-7d0f-4213-aa1a-164d58848b00

Verify the original NFS directories and Retain policies.

#### Scenario A: Original PV exists

The PV must be Released and contain a stale claimRef
referencing the deleted PVC.

STOP if the PV is Bound, Available, or in another
unexpected state.

Replace the stale claimRef with a reservation for the
intended new PVC.

Database PV:

kubectl patch pv \
  pvc-87237867-fb98-4b68-b74d-b2a139f7bcc1 \
  --type=json \
  -p='[{"op":"replace","path":"/spec/claimRef","value":{"apiVersion":"v1","kind":"PersistentVolumeClaim","namespace":"cita-site-website","name":"cita-site-database-pvc"}}]'

WordPress files PV:

kubectl patch pv \
  pvc-b27cf418-7d0f-4213-aa1a-164d58848b00 \
  --type=json \
  -p='[{"op":"replace","path":"/spec/claimRef","value":{"apiVersion":"v1","kind":"PersistentVolumeClaim","namespace":"cita-site-website","name":"cita-site-wordpress-pvc"}}]'

Apply only the patch commands for existing Released PVs.

#### Scenario B: Original PV does not exist

Verify the original NFS directory still exists
and contains the expected data.

Recreate only the missing PV objects.

Database PV:

kubectl apply -f pv/db-pv-recovery.yaml

WordPress files PV:

kubectl apply -f pv/web-pv-recovery.yaml

Do not recreate a PV object that already exists.

Reserve each newly recreated PV using a JSON patch
with the add operation.

Database PV:

kubectl patch pv \
  pvc-87237867-fb98-4b68-b74d-b2a139f7bcc1 \
  --type=json \
  -p='[{"op":"add","path":"/spec/claimRef","value":{"apiVersion":"v1","kind":"PersistentVolumeClaim","namespace":"cita-site-website","name":"cita-site-database-pvc"}}]'

WordPress files PV:

kubectl patch pv \
  pvc-b27cf418-7d0f-4213-aa1a-164d58848b00 \
  --type=json \
  -p='[{"op":"add","path":"/spec/claimRef","value":{"apiVersion":"v1","kind":"PersistentVolumeClaim","namespace":"cita-site-website","name":"cita-site-wordpress-pvc"}}]'

Apply only the add commands for newly recreated PVs
without an existing claimRef.

#### Verify PV reservations

kubectl get pv \
  pvc-87237867-fb98-4b68-b74d-b2a139f7bcc1 \
  pvc-b27cf418-7d0f-4213-aa1a-164d58848b00 \
  -o yaml

Confirm:
- Both PVs exist.
- Both have reclaim policy Retain.
- Both reference their original NFS directories.
- Each claimRef contains the correct namespace and PVC name.
- Neither claimRef contains an old UID or resourceVersion.

Do not continue until these checks pass.

### Step 3: Restore PVCs

Use the recovery PVC manifests, which explicitly
reference the original PV names.

Do NOT use db-pvc.yaml or web-pvc.yaml for
complete namespace recovery.

kubectl apply -f pv/db-pvc-recovery.yaml
kubectl apply -f pv/web-pvc-recovery.yaml

Verify:

kubectl get pvc -n cita-site-website
kubectl get pv

Both PVCs must be Bound to their original PVs.

Expected database PV:
pvc-87237867-fb98-4b68-b74d-b2a139f7bcc1

Expected WordPress files PV:
pvc-b27cf418-7d0f-4213-aa1a-164d58848b00

Do not continue unless both PVCs are correctly bound.

### Step 4: Restore TLS Secret

The TLS Secret is not included in kustomization.yaml.

It is generated from the certificate files under:

/k8s/configs/TLS

Required files:
- fullchain.pem
- cita-wildcard.key
- STAR_cita_utoronto_ca.ca-bundle

Verify the certificate files:

ls -l /k8s/configs/TLS/

Confirm all three files exist and contain the correct
current certificate, private key, and CA bundle.

Create the Kubernetes TLS Secret:

cd /k8s/configs/cita-site-website

./apache-certs-keys.sh

Verify:

kubectl get secret cita-site-tls \
  -n cita-site-website

Expected:
- Secret name: cita-site-tls
- Type: Opaque
- DATA: 3

The Secret must contain:
- tls.crt
- tls.key
- ca-bundle.crt

Do not continue if the Secret is missing.

### Step 5: Restore application

cd /k8s/configs/cita-site-website

kubectl apply -k .

Verify:

kubectl rollout status deployment/cita-site-mariadb \
  -n cita-site-website

kubectl rollout status deployment/cita-site-website \
  -n cita-site-website

kubectl get pods,svc,pvc -n cita-site-website

### Step 6: Verify application

Confirm:
- Both Deployments are available.
- Both PVCs are Bound to their original PVs.
- MariaDB contains the expected WordPress database.
- WordPress loads over HTTPS.
- Existing pages, posts, and uploads are accessible.
- Apache configuration and userdir functionality work.
- External NFS mounts are accessible.
- Database backups are working.

Check production website:

curl -I https://www.cita.utoronto.ca/

Check Apache configuration:

WEB=$(kubectl get pod \
  -n cita-site-website \
  -l app=cita-site-website \
  -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n cita-site-website "$WEB" \
  -c web -- apachectl configtest

Expected:

Syntax OK

Check WordPress URL:

kubectl exec -n cita-site-website "$WEB" \
  -c web -- \
  php /usr/share/wordpress/wp-cli.phar \
  --path=/usr/share/wordpress \
  --allow-root \
  option get home

Expected:

https://www.cita.utoronto.ca

## 4. Storage Information

StorageClass:
nfs-cita

NFS server:
nfs.cita.utoronto.ca

NFS share:
/obj/k8s/pvcs

Reclaim policy:
Retain

Database directory:
cita-site-website-cita-site-database-pvc-pvc-87237867-fb98-4b68-b74d-b2a139f7bcc1

WordPress files directory:
cita-site-website-cita-site-wordpress-pvc-pvc-b27cf418-7d0f-4213-aa1a-164d58848b00

Additional NFS mounts:

142.1.127.49:/obj/www
128.100.76.92:/fs/lustre/project

These external NFS exports must be available
for the web application.

## 5. TLS Certificate Renewal

TLS certificate files are maintained under:

/k8s/configs/TLS

After updating the certificate files, run:

cd /k8s/configs/cita-site-website

./apache-certs-keys.sh

Verify the TLS Secret:

kubectl get secret cita-site-tls \
  -n cita-site-website

Verify the certificate served by the website:

echo | openssl s_client \
  -connect www.cita.utoronto.ca:443 \
  -servername www.cita.utoronto.ca 2>/dev/null | \
  openssl x509 -noout -dates -subject

If Apache continues serving the old certificate,
restart only the web Deployment:

kubectl rollout restart deployment/cita-site-website \
  -n cita-site-website

kubectl rollout status deployment/cita-site-website \
  -n cita-site-website

Do not restart MariaDB for TLS certificate renewal.

## 6. Important Notes

- Never delete original NFS directories during recovery.
- Never use empty dynamically provisioned PVCs for recovery.
- Do not run two MariaDB instances against the same data directory.
- Never modify a Bound PV during normal operation.
- Only replace claimRef on verified Released PVs.
- Only add claimRef on newly recreated PVs without one.
- Protect all Secret YAML files.
- Keep /k8s/configs/TLS in secure off-cluster backups.
- Store an encrypted off-cluster backup of this directory.
- Keep separate backups of the database and WordPress files.
- Ensure the nfs-cita StorageClass and NFS CSI driver are available.
- Ensure the required Docker images are available.
- Ensure MetalLB can allocate 142.1.127.106.
- The TLS Secret must be created before applying Kustomize
  during complete namespace recovery.
- A complete disaster recovery test has not yet been performed.

Production:
Kubernetes cita-site-website

Standby:
ant.cita.utoronto.ca

Synchronization direction:
Kubernetes production -> ant standby

Do not synchronize ant -> Kubernetes unless intentionally
performing a recovery from the standby server.
