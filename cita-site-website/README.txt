CITA site.cita.utoronto.ca Kubernetes Deployment
================================================

Namespace:
  cita-site-website

Hostname:
  site.cita.utoronto.ca

Planned MetalLB address:
  142.1.127.106

IMPORTANT:
  www.cita.utoronto.ca is out of scope.
  The existing production website/cluster must not be modified.

Persistent storage:

  cita-site-wordpress-pvc
    20Gi
    RWX
    nfs-cita
    Contains restored WordPress filesystem.

  cita-site-database-pvc
    10Gi
    RWX
    nfs-cita
    Contains MariaDB 10.5.29 data.

Database:

  MariaDB 10.5.29
  Database: wordpress
  WordPress database restored and verified.
  75 tables were present after restore.

WordPress:

  WordPress 6.9.7
  Filesystem restored from final full backup.
  Home/siteurl remain:
    https://site.cita.utoronto.ca

  Home page:
    ID 2

  Featured category:
    ID 208

TLS:

  Existing CITA wildcard certificate has been imported into
  Kubernetes Secret cita-site-tls.

Secrets:

  Secret values are stored only in Kubernetes Secrets.
  See secrets-required.txt for required Secret/key names.

Current public state:

  No public website Service has been created.
  142.1.127.106 has not been allocated.
  DNS has not been changed.

Migration source backup:

  /cita_backup/cita-newsite/full-backup-20260924-131057

Primary restore files:

  database.sql.gz
  wordpress-files.tar.gz
