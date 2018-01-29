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
- use defaut .env variables which set `LAN_HOST=127.0.0.1`, `WAN_HOST=local.example.com`, `ADMIN_EMAIL=admin@example.com` and `LETSENCRYPT_MODE=disabled` (set `local.example.com` to `127.0.0.1` in your hosts file for better local testing)


### Production

Make sure the needed images are published to docker hub or that you rebuilt the images locally.

Note : to avoid hitting LetsEncrypt limits if anything fails, you should add `LETSENCRYPT_MODE=staging` to your env vars during first tests, and only remove it once you see tests certificates are properly loading. Hitting the limits is annoying as you can be blocked for a few days...

Windows Powershell
```
# 1. Create a swarm
docker swarm init

# 2. Set variables (Windows)
$env:WAN_HOST="local.example.com"
$env:LAN_HOST="127.0.0.1"
$env:ADMIN_USERNAME="super"
$env:ADMIN_PASSWORD="duper"
$env:ADMIN_EMAIL="admin@example.com"

# 3. Deploy the stack

docker secret rm admin_username
echo "$ADMIN_USERNAME" | docker secret create admin_username -
docker secret rm admin_password
echo "$ADMIN_PASSWORD" | docker secret create admin_password -
docker stack deploy spcgeonode_stack --compose-file docker-compose.yml

# 4. Cleanup
$env:WAN_HOST=""
$env:LAN_HOST=""
$env:ADMIN_USERNAME=""
$env:ADMIN_PASSWORD=""
$env:ADMIN_EMAIL=""
```

Linux
```
# 1. Create a swarm
sudo docker swarm init

# 2. Set variables (Windows)
set WAN_HOST="local.example.com"
set LAN_HOST="127.0.0.1"
set ADMIN_USERNAME="super"
set ADMIN_PASSWORD="duper"
set ADMIN_EMAIL="admin@example.com"

# 3. Deploy the stack (again: MAKE SURE YOU'VE JUST REBUILD THE IMAGES)
# this creates the docker secrets
sudo docker secret rm admin_username
echo "$ADMIN_USERNAME" | sudo docker secret create admin_username -
sudo docker secret rm admin_password
echo "$ADMIN_PASSWORD" | sudo docker secret create admin_password -
sudo docker stack deploy spcgeonode --compose-file docker-compose.yml

# 4. Cleanup
set WAN_HOST=
set LAN_HOST=
set ADMIN_USERNAME=
set ADMIN_PASSWORD=
set ADMIN_EMAIL=
```

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
- geoserver starts with empty geodatadir. Geonode's entrypoint script ensures there is a geonode workspace initialized using REST API. (in geonode-project, initial data-dir is pulled from http://build.geonode.org/geoserver/latest/data-$GEOSERVER_VERSION.zip , see waybarrios/geoserver Docker image) TODO : IS THIS STILL TRUE ?
- Geonode/Geoserver user database is shared at postgres level so users are always synced
- the geodatadir for Geoserver is included in the git repository rather than being pulled

This is very similar to https://github.com/kartoza/kartoza-rancher-catalogue

Key differences :

- we use geoserver instead of qgis server
- working celery admin panels
- https encryption
- use secrets for sensitive data instead of env variables
- Geonode/Geoserver user database is shared at postgres level so users are always synced
- the geodatadir for Geoserver is included in the git repository rather than being pulled
