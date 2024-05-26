# Mediawiki
Contains Docker, kubernetes files and helm chart for setting up the Mediawiki v1.41 on Kubernetes cluster

## Docker
- /Dockerfile - This Dockerfile is used to create a Docker image for running MediaWiki. The image is based on Red Hat Enterprise Linux (RHEL) 8 and includes all the necessary dependencies for running MediaWiki.
- For Mediawiki database we are using `mariadb:latest` image.

## Deployment using K8s-manifests
The kubernetes objects are defined in `K8s-manifests` folder.
### K8s-manifests/mariadb 
This directory contains the necessary Kubernetes manifest files to deploy a MariaDB database, which is a prerequisite for running MediaWiki.

It consists of:

- db-deployment.yaml
- db-service.yaml 
- pvc.yaml
- secret-password.yaml - for storing `base64` converted password string to be used for variable `MARIADB_ROOT_PASSWORD`.
- secret.yaml - for storing `base64` converted db init script for creating an user and database.

#### Deploy
```
kubectl apply -f k8s-manifests/mariadb/ -n "namespace"
```
### K8s-manifests/mediaWiki
This directory contains the necessary Kubernetes manifest files to deploy a mediawiki and an example LocalSettings.php which can be mounted using ConfigMap after its generation.

For first time deployment, please comment out the following blocks inside the mediawiki.yaml file.

```
volumeMounts:
  - name: config-volume
    mountPath: /var/www/mediawiki/LocalSettings.php
    subPath: LocalSettings.php
```
```
volumes:
- name: config-volume
  configMap:
    name: mediawiki-config
```
#### Deploy
```
kubectl apply -f k8s-manifests/mediawiki/ -n "namespace"
```

