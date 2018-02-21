# SPCgeonode

SPCgeonode is a skeletton for Geonode deployement at SPC. It makes it easy to deploy a customized version of Geonode.

The setup aims to be usable for production.

## Prerequisites

Make sure you have a version of Docker (tested with 17.12) and docker-compose.

On **Linux** : https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-from-a-package and https://docs.docker.com/compose/install/#install-compose

On **Windows**: https://store.docker.com/editions/community/docker-ce-desktop-windows


## Usage

### Developpement

```
docker-compose up -d --build
```

Difference of dev setup vs prod setup:

- mount django source as volume and set uwsgi to live reload
- mount django static and media in the volumes folder
- mount geoserver's data volume in the volumes folder
- mount letsencyrpt volumes in the volumes folder
- set django debug=True
- expose postgres port 5432
- activates nginx debug mode
- run celery using djcelery (so that output goes to admin) 
- use docker dev tags instead of latest
- use defaults secrets from _dev-secrets `admin_username=super` and `admin_password=duper`
- use defaut .env variables which set `HTTP_HOST=127.0.0.1`, `HTTPS_HOST=local.example.com`, `ADMIN_EMAIL=admin@example.com` and `LETSENCRYPT_MODE=disabled` (set `local.example.com` to `127.0.0.1` in your hosts file for better local testing)


### Production

```
# 1. Override default env variables (defaults are in .env)
export HTTPS_HOST="local.example.com"
export HTTP_HOST="127.0.0.1"
export ADMIN_EMAIL="admin@example.com"
export LETSENCRYPT_MODE="staging"
export REMOTE_SYNCTHING_MACHINE_ID="0000000-0000000-0000000-0000000-0000000-0000000-0000000-0000000"
export AWS_BUCKET_NAME="spcgeonode-test"
export AWS_BUCKET_REGION="ap-southeast-2"

# 2. Create the secrets
mkdir _secrets
printf "super" > _secrets/admin_username
printf "duper" > _secrets/admin_password
printf "aaa" > _secrets/aws_access_key
printf "bbb" > _secrets/aws_secret_key

# 3. Run the stack
docker-compose -f docker-compose.yml up -d --build
...

Note : to avoid hitting LetsEncrypt limits if anything fails, you should add `LETSENCRYPT_MODE=staging` to your env vars during first tests, and only remove it once you see tests certificates are properly loading. Hitting the limits is annoying as you can be blocked for a few days...


### Publishing the images

Pushes to github trigger automatic builds on docker hub (for master branch -> dev and for x.x.x tags -> x.x.x).

If you need to publish the images manually, just rebuilt the containers (`docker-compose -f docker-compose.yml build`), then use :

```
docker login
docker-compose -f docker-compose.yml push
```

### Rancher

This setup can almost be used as is by Rancher. Some minor adaptations must be made to docker-compose though : 

- version "3.x" => "2"
- yaml anchors are not supported : manually replace each `<< : *default-common-django` occurence by the `&default-common-django` block
- deploy block are not supported
- if unversionned tags (e.g. latest) add `labels: io.rancher.container.pull_image: always` to all images that may change so that they are pulled again from the repository


## How it works

### Geonode/Django

Geonode is installed as a "geonode django project" (under `django`). This allows easy customization/extension as it is a regular django application.

The django project is initialised (install requirements, migrate, collectstatic and fixtures) at launch, and then served using uwsgi.

### Nginx

Nginx proxies to uwsgi (django) and geoserver. It also directly serves django static and media files.

### Geoserver / Django

Geoserver and Django share the same users (using postgres tables).

## Compared to similar tools

This is very similar to https://github.com/GeoNode/geonode-project but aims to be suitable for deployement.

Key differences :

- dockerfiles for nginx and geoserver are in same repo, since they need to be customized for a deployement
- other services (postgres, elasticsearch, rabbit) images use a specific tag, so we know which one will be pulled 
- settings imports from geonode.settings so most defaults don't need to be modified
- geoserver starts with empty geodatadir. Geonode's entrypoint script ensures there is a geonode workspace initialized using REST API. 
- Geonode/Geoserver user database is shared at postgres level so users are always synced
- the geodatadir for Geoserver is included in the git repository rather than being pulled

This is very similar to https://github.com/kartoza/kartoza-rancher-catalogue

Key differences :

- we use geoserver instead of qgis server
- working celery admin panels
- https encryption
- use secrets for sensitive data instead of env variables
- the geodatadir for Geoserver is included in the git repository rather than being pulled
