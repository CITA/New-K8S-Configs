# CITA Wiki Kubernetes Configuration

Namespace: cita-wiki
Configuration directory: /k8s/configs/new-citawiki

## Overview

This directory contains the Kubernetes configuration for
the current CITA MediaWiki deployment.

Web Deployment: new-citawiki
Database Deployment: new-citawiki-db

Web image:
docker.io/citadockerhub/mediawiki_k8s:1.43.11-cita1-php8.3.36

Database image:
docker.io/citadockerhub/mariadb:11.4.13-ubu2404-cita1

Web LoadBalancer IP: 142.1.127.107

## Configuration Files

kustomization.yaml
  Main application configuration containing:
  - 4 ConfigMaps
  - 5 Secrets
  - 2 Services
  - 2 Deployments

namespace.yaml
  Namespace creation manifest.

web-deployment.yaml
db-deployment.yaml
  Application Deployments.

web-service.yaml
db-service.yaml
  Kubernetes Services.

web-pvc.yaml
db-pvc.yaml
  Standard PVC manifests.
  Not included in kustomization.yaml.

configmaps/
  Required Apache, PHP, and Postfix ConfigMaps.

secrets/
  Required application, database, TLS, and registry Secrets.
  Contains sensitive data. Protect this directory.

pv/
  Original PV snapshots and recovery PV/PVC manifests.

RECOVERY.md
  Complete disaster recovery procedure.

scripts/verify-new-citawiki.sh
  Web Deployment and Apache verification.

apache-certs-keys.sh
  Recreates the Apache TLS Secret from certificates
  under /k8s/configs/TLS.

## Normal Deployment

Use only when the namespace and original PVCs exist.

cd /k8s/configs/new-citawiki

kubectl apply -k .

kubectl rollout status deployment/new-citawiki-db -n cita-wiki
kubectl rollout status deployment/new-citawiki -n cita-wiki

kubectl get pods,svc,pvc -n cita-wiki

## Complete Disaster Recovery

Follow RECOVERY.md.

Do not recreate PVCs using the standard PVC manifests
if the original NFS data must be recovered.

Use the recovery PV/PVC manifests under pv/ instead.

## Storage

StorageClass: nfs-cita
NFS server: nfs.cita.utoronto.ca
NFS share: /obj/k8s/pvcs
Reclaim policy: Retain

The web Deployment also mounts:
128.100.76.92:/mnt/raid-project

## TLS Certificate Renewal

Run apache-certs-keys.sh after updating the certificate
files under /k8s/configs/TLS.

After renewal, refresh the saved Secret manifest so
disaster recovery uses the latest certificate.

## Security and Backups

- Protect all files under secrets/.
- Keep an encrypted backup outside vma.
- Keep database and wiki file backups separately.
- Do not commit Secret manifests to public Git.
- Never delete PVCs during routine application maintenance.
- Verify the original NFS data before disaster recovery.
