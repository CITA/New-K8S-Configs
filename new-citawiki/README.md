# CITA new-citawiki configuration bundle

This bundle describes the tested MediaWiki 1.43.11 web Deployment and HTTPS LoadBalancer Service, plus helper scripts for recreating deployment-specific configuration and capturing the actual database resources.

## Known current resources

- Namespace: `cita-wiki`
- Web Deployment: `new-citawiki`
- Web image: `docker.io/citadockerhub/mediawiki_k8s:1.43.11-cita1-php8.3.36`
- Web PVC: `new-citawiki-files-pvc` (mounted at `/var/www`)
- Database Service/Deployment: `new-citawiki-db`
- Database PVC: `new-citawiki-db-pvc`
- App credential Secret: `new-citawiki-app-secret`, key `password`
- Web Service: `new-citawiki`, external IP `142.1.127.107`, TCP 443
- Existing production Service/IP remains `cita-wiki` / `142.1.127.104`.
- The existing shared resources referenced by the web Deployment must exist: `dockerhub-credential`, `apache2-certs-keys`, `apache-vhost-config`, `configmap-php-confd`, `postfix-main-cf`, and the NFS export `128.100.76.92:/mnt/raid-project`.
- `new-citawiki-php` is a separate PHP ConfigMap without the duplicate LDAP extension directive.

## Files

- `web-deployment.yaml`: web Deployment manifest, pointing to the new files PVC, app Secret, shared TLS/Apache/Postfix/extension configs, and project NFS export.
- `web-service.yaml`: separate HTTPS LoadBalancer Service at `142.1.127.107`.
- `scripts/prepare-php-configmap.sh`: derives `new-citawiki-php` from the existing `configmap-php`, removing the duplicated `extension=ldap` directive. Refuses to overwrite an existing target ConfigMap.
- `scripts/create-app-secret-if-missing.sh`: creates the app Secret only if it is absent. It does not display or overwrite a password. If recreating from scratch, the generated credential must also be applied to the `citawiki_app` MariaDB account before use.
- `scripts/capture-live-db-resources.sh`: captures the actual live database Deployment, Service, PVC and web Deployment JSON. It deliberately exports the actual existing settings instead of inventing database image, environment, capacity, or storage-class values that are not defined in this bundle.
- `scripts/verify-new-citawiki.sh`: useful health/Apache checks.

## Important: current-cluster recovery vs. fresh-cluster recreation

This package contains all web manifests whose settings were confirmed in the migration conversation. Database Deployment and PVC internals (exact MariaDB image tag, resource limits, root-secret reference, storage class/capacity/access mode and related settings) were not present in the available conversation, so the capture script records those exact settings from the running cluster instead of guessing. Run it while the current database resources still exist and retain the resulting snapshots securely.

The existing PVCs already exist in the cluster; their creation specs are not fabricated in this bundle. For a fresh cluster, inspect/prepare compatible PVC manifests from the snapshots and your storage policy before applying them.

## Suggested use

1. Keep this bundle and the live-resource snapshots outside the cluster, in access-controlled storage.
2. Before reapplying `web-deployment.yaml`, ensure the referenced PVC, ConfigMaps, Secret and NFS mount are present.
3. Apply or compare manifests with `kubectl diff -f web-deployment.yaml` before `kubectl apply -f web-deployment.yaml`.
4. Apply `web-service.yaml` only after verifying the IP `142.1.127.107` remains unused and available in the MetalLB pool.
5. Run `scripts/verify-new-citawiki.sh` after applying changes.
6. Do not delete or alter production `cita-wiki` resources during test deployment maintenance.

## Security

Do not commit live Secret manifests or raw cluster exports containing secret values to public Git. Kubernetes Secret data is typically base64-encoded, not encrypted. Keep the actual credentials in the approved secret manager or a protected backup location. The helper script never exports or prints the app password.

## Migration state

The four wikis are promoted on the new PVC under `<wiki>/html` with the old copied installations retained as `<wiki>/html.old`. Do not remove `html.old`, database dumps, or the production PVC until cutover is approved and the rollback period ends.
