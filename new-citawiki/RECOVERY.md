# CITA Wiki Kubernetes Recovery Runbook

Namespace: cita-wiki
Configuration directory: /k8s/configs/new-citawiki

## 1. Overview

This directory contains the configuration required to recreate
the current CITA MediaWiki application.

Application components:
- Web Deployment: new-citawiki
- Database Deployment: new-citawiki-db
- Web Service: new-citawiki
- Database Service: new-citawiki-db
- Web LoadBalancer IP: 142.1.127.107

The kustomization.yaml contains:
- 4 ConfigMaps
- 5 Secrets
- 2 Services
- 2 Deployments

Namespace, PVs and PVCs are managed separately.

IMPORTANT:
Do not create new dynamically provisioned PVCs during recovery
if the original NFS data must be preserved.

## 2. Normal Application Redeployment

Use when the namespace and PVCs already exist.

cd /k8s/configs/new-citawiki

kubectl apply -k .

kubectl rollout status deployment/new-citawiki-db -n cita-wiki
kubectl rollout status deployment/new-citawiki -n cita-wiki

kubectl get pods,svc,pvc -n cita-wiki

## 3. Complete Namespace Recovery

Use when the cita-wiki namespace has been deleted.

Before proceeding:
- Confirm the original NFS directories still exist.
- Confirm they contain the expected database and wiki files.
- Confirm whether the original PV objects still exist.
- Ensure the original application is not running elsewhere.
- Do not delete or modify the original NFS data.

cd /k8s/configs/new-citawiki

### Step 1: Recreate namespace

kubectl apply -f namespace.yaml

### Step 2: Restore PVs

First verify the original PVCs no longer exist:

kubectl get pvc -n cita-wiki

STOP if either original PVC still exists.

Check the original PVs:

kubectl get pv \
  pvc-214ba2bc-ec19-4906-92e2-052c54b0a81c \
  pvc-786b3ac0-fb4e-4c48-bfb2-953812a885ec

Verify each existing PV references the correct original
NFS directory and has reclaim policy Retain.

There are two possible recovery scenarios.

#### Scenario A: Original PV exists

The PV should be in Released status after the old PVC
has been deleted.

STOP if the PV is Bound, Available, or in another
unexpected state.

A Released PV normally contains a stale claimRef
referencing the deleted PVC.

Replace the entire claimRef with a reservation for
the intended new PVC.

Database PV:

kubectl patch pv \
  pvc-214ba2bc-ec19-4906-92e2-052c54b0a81c \
  --type=json \
  -p='[{"op":"replace","path":"/spec/claimRef","value":{"apiVersion":"v1","kind":"PersistentVolumeClaim","namespace":"cita-wiki","name":"new-citawiki-db-pvc"}}]'

Wiki files PV:

kubectl patch pv \
  pvc-786b3ac0-fb4e-4c48-bfb2-953812a885ec \
  --type=json \
  -p='[{"op":"replace","path":"/spec/claimRef","value":{"apiVersion":"v1","kind":"PersistentVolumeClaim","namespace":"cita-wiki","name":"new-citawiki-files-pvc"}}]'

Apply only the patch commands for PVs that exist
and have been verified as Released.

#### Scenario B: Original PV does not exist

First verify that the original NFS directory
still exists and contains the expected data.

Recreate only the missing PV objects.

Database PV:

kubectl apply -f pv/db-pv-recovery.yaml

Wiki files PV:

kubectl apply -f pv/web-pv-recovery.yaml

Do not recreate a PV object that already exists.

The recovery PV manifests contain the original
NFS server, share, subdirectory, and volume handle.

After recreating a missing PV, reserve it for
the intended PVC using a JSON patch with the
add operation.

Database PV:

kubectl patch pv \
  pvc-214ba2bc-ec19-4906-92e2-052c54b0a81c \
  --type=json \
  -p='[{"op":"add","path":"/spec/claimRef","value":{"apiVersion":"v1","kind":"PersistentVolumeClaim","namespace":"cita-wiki","name":"new-citawiki-db-pvc"}}]'

Wiki files PV:

kubectl patch pv \
  pvc-786b3ac0-fb4e-4c48-bfb2-953812a885ec \
  --type=json \
  -p='[{"op":"add","path":"/spec/claimRef","value":{"apiVersion":"v1","kind":"PersistentVolumeClaim","namespace":"cita-wiki","name":"new-citawiki-files-pvc"}}]'

Apply only the add commands for newly recreated PVs
that do not already have a claimRef.

#### Verify PV reservations

kubectl get pv \
  pvc-214ba2bc-ec19-4906-92e2-052c54b0a81c \
  pvc-786b3ac0-fb4e-4c48-bfb2-953812a885ec \
  -o yaml

Confirm:
- Both PVs exist.
- Both use reclaim policy Retain.
- Both reference the correct original NFS directories.
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

kubectl get pvc -n cita-wiki
kubectl get pv

Both PVCs must be Bound to their original PVs.

Expected database PV:
pvc-214ba2bc-ec19-4906-92e2-052c54b0a81c

Expected wiki files PV:
pvc-786b3ac0-fb4e-4c48-bfb2-953812a885ec

Do not continue unless both PVCs are correctly bound.

### Step 4: Restore application

kubectl apply -k .

Verify:

kubectl rollout status deployment/new-citawiki-db -n cita-wiki
kubectl rollout status deployment/new-citawiki -n cita-wiki

kubectl get pods,svc,pvc -n cita-wiki

### Step 5: Verify application

Confirm:
- Both Deployments are available.
- Both PVCs are Bound to the original PVs.
- MariaDB contains the expected databases.
- MediaWiki loads over HTTPS.
- Existing wiki pages and uploaded files are accessible.
- Database backup jobs work.

## 4. Storage Information

NFS server:
nfs.cita.utoronto.ca

NFS share:
/obj/k8s/pvcs

Database directory:
cita-wiki-new-citawiki-db-pvc-pvc-214ba2bc-ec19-4906-92e2-052c54b0a81c

Wiki files directory:
cita-wiki-new-citawiki-files-pvc-pvc-786b3ac0-fb4e-4c48-bfb2-953812a885ec

StorageClass:
nfs-cita

Reclaim policy:
Retain

The Retain policy preserves storage after PVC deletion,
but does not automatically reconnect new PVCs to old data.

## 5. Important Notes

- Never delete the original NFS directories during recovery.
- Never use empty dynamically provisioned PVCs for recovery.
- Do not run two MariaDB instances against the same data directory.
- Never modify a Bound PV during normal operation.
- Only replace claimRef on verified Released PVs.
- Only add claimRef on newly recreated PVs without one.
- Keep Secret YAML files protected with permissions 600.
- Store an encrypted off-cluster backup of this directory.
- Restore database contents from backups if the NFS data is lost.
- The external NFS mount at 128.100.76.92:/mnt/raid-project
  must also be available for the web application.
- Ensure the nfs-cita StorageClass and NFS CSI driver are available.
- Ensure the Docker images are available from the registry.
- A complete disaster recovery test has not yet been performed.
