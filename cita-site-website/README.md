# CITA Production Website - Kubernetes Configuration

This directory contains the Kubernetes recovery configuration for:

    https://www.cita.utoronto.ca/

Namespace:

    cita-site-website

Production LoadBalancer IP:

    142.1.127.106

## Components

Web application:

    Deployment: cita-site-website
    Image:      citadockerhub/wordpress_k8s:1.0.3

Database:

    Deployment: cita-site-mariadb
    Image:      mariadb:10.5
    Database:   wordpress

## Resources

WordPress web:

    requests:
      cpu:    500m
      memory: 1Gi

    limits:
      cpu:    2
      memory: 2Gi

MariaDB:

    requests:
      cpu:    500m
      memory: 1Gi

    limits:
      cpu:    2
      memory: 2Gi

## Persistent Storage

WordPress:

    PVC: cita-site-wordpress-pvc
    Size: 20Gi
    StorageClass: nfs-cita

MariaDB:

    PVC: cita-site-database-pvc
    Size: 10Gi
    StorageClass: nfs-cita

## Additional Filesystems

CITA shared web content:

    /obj/www
        -> /cita/d/www

Legacy project web content:

    128.100.76.92:/fs/lustre/project
        -> /cita/web-lustre/project

The project filesystem is mounted read-only.

## Legacy URLs

The Apache configuration preserves:

    /DHIGLS/
    /GHIGLS/
    /HOTT/
    /Jing_memorial/
    /NCPL/
    /recording/
    /rss/
    /Simplistics/
    /webpages/

CITA per-user websites are also available as:

    /~username/

## Configuration Files

    web-deployment.yaml
    web-service.yaml
    web-external-service.yaml
    web-pvc.yaml

    db-deployment.yaml
    db-service.yaml
    db-pvc.yaml

    apache-config.yaml
    php-config.yaml
    userdir-config.yaml
    wordpress-config.yaml

    secret-mariadb-root.yaml
    secret-wordpress.yaml
    secret-tls.yaml
    secret-dockerhub.yaml

    kustomization.yaml

The secret YAML files contain sensitive data and must remain protected.

## Important

These manifests reproduce the Kubernetes configuration.

The WordPress files and MariaDB database are stored on persistent
NFS-backed volumes. The YAML files themselves are NOT a backup of
the WordPress content or database.

Current production is Kubernetes.

The host ant.cita.utoronto.ca is the standby server.
