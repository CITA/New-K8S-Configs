# CITA Production Website - Kubernetes Configuration

Production URL: https://www.cita.utoronto.ca/
Namespace: cita-site-website
Configuration directory: /k8s/configs/cita-site-website
External LoadBalancer IP: 142.1.127.106

## 1. Overview

This directory contains the Kubernetes configuration for
the production CITA WordPress website and MariaDB database.

Web Deployment:
  cita-site-website

Web image:
  citadockerhub/wordpress_k8s:1.0.3

Database Deployment:
  cita-site-mariadb

Database image:
  mariadb:10.5

Database:
  wordpress

Production runs on Kubernetes.
ant.cita.utoronto.ca is the standby server.

## 2. Kubernetes Resources

kustomization.yaml contains:

- 4 ConfigMaps
- 4 Secrets
- 3 Services
- 2 Deployments

Namespace, PVs and PVCs are managed separately.

## 3. Configuration Files

namespace.yaml
  Namespace creation manifest.

web-deployment.yaml
db-deployment.yaml
  Application Deployments.

web-service.yaml
web-external-service.yaml
db-service.yaml
  Kubernetes Services.

web-pvc.yaml
db-pvc.yaml
  Standard PVC definitions.
  Not included in kustomization.yaml.

apache-config.yaml
php-config.yaml
userdir-config.yaml
wordpress-config.yaml
  Application ConfigMaps.

secret-mariadb-root.yaml
secret-wordpress.yaml
secret-dockerhub.yaml
secrets/cita-site-tls.yaml
  Kubernetes Secrets containing sensitive data.

pv/
  Original PV snapshots and recovery PV/PVC manifests.

RECOVERY.md
  Complete namespace and storage recovery instructions.

apache-certs-keys.sh
  TLS certificate renewal helper.

archive/
  Historical deployment files and migration documentation.

## 4. Persistent Storage

StorageClass:
  nfs-cita

NFS server:
  nfs.cita.utoronto.ca

NFS share:
  /obj/k8s/pvcs

Reclaim policy:
  Retain

WordPress PVC:
  cita-site-wordpress-pvc
  20Gi

MariaDB PVC:
  cita-site-database-pvc
  10Gi

## 5. Additional Filesystems

Shared CITA web content:

  142.1.127.49:/obj/www
  Mounted at /cita/d/www

Legacy project content:

  128.100.76.92:/fs/lustre/project
  Mounted at /cita/web-lustre/project
  Read-only

These NFS exports must be available for the website.

## 6. Normal Deployment

Use only when the namespace and original PVCs exist.

cd /k8s/configs/cita-site-website

kubectl apply -k .

kubectl rollout status deployment/cita-site-mariadb \
  -n cita-site-website

kubectl rollout status deployment/cita-site-website \
  -n cita-site-website

kubectl get pods,svc,pvc -n cita-site-website

## 7. Disaster Recovery

Follow RECOVERY.md.

Do not recreate PVCs using standard PVC manifests
if the original NFS data must be recovered.

Use the recovery PV/PVC manifests under pv/.

## 8. TLS Certificate Renewal

Certificate source directory:

  /k8s/configs/TLS

Renew the TLS Secret using:

  ./apache-certs-keys.sh

After renewal, refresh the saved TLS Secret manifest:

  secrets/cita-site-tls.yaml

The saved Secret must contain the latest certificate
and private key for disaster recovery.

## 9. Website Verification

Verify Kubernetes resources:

kubectl get pods,svc,pvc -n cita-site-website

Verify the production website:

curl -I https://www.cita.utoronto.ca/

Confirm:
- WordPress loads over HTTPS.
- Existing pages and uploads are accessible.
- MariaDB contains the expected WordPress database.
- Legacy URLs and userdir websites work.
- External NFS mounts are available.

## 10. Security and Backups

- Protect all Secret YAML files.
- Keep an encrypted backup outside vma.
- Keep database and WordPress file backups separately.
- Do not commit unencrypted Secrets to Git.
- Never delete PVCs during routine maintenance.
- Verify the original NFS data before disaster recovery.

Production/standby synchronization direction:

  Kubernetes production -> ant standby

Do not synchronize ant -> Kubernetes unless intentionally
performing a recovery from the standby server.
