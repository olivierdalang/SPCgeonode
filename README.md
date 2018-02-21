# SPCgeonode

SPCgeonode is a skeletton for Geonode deployement at SPC. It makes it easy to deploy a customized version of Geonode.

The setup aims to be usable for production.


## Prerequisites

Make sure you have a version of Docker (tested with 17.12) and docker-compose.

On **Linux** : https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-from-a-package and https://docs.docker.com/compose/install/#install-compose

On **Windows**: https://store.docker.com/editions/community/docker-ce-desktop-windows


## Usage

### Developpement

To start the whole stack
```
docker-compose up --build
```

Or if you want only the main services (enough to develop and a bit lighter):
```
docker-compose up --build django geoserver nginx postgres celery
```

Note : as docker-compose is not a real containers orchestrator, it may be necessary to manually restart geoserver after first startup since healthchecks are ignored (just run the same command again).


### Production

```
# 1. Override default env variables (defaults are in .env)
HTTPS_HOST="local.example.com"
HTTP_HOST="127.0.0.1"
ADMIN_EMAIL="admin@example.com"
LETSENCRYPT_MODE="staging"
REMOTE_SYNCTHING_MACHINE_ID="0000000-0000000-0000000-0000000-0000000-0000000-0000000-0000000"
AWS_BUCKET_NAME="spcgeonode-test"
AWS_BUCKET_REGION="ap-southeast-2"

# 2. Create the secrets
mkdir _secrets
printf "super" > _secrets/admin_username
printf "duper" > _secrets/admin_password
printf "aaa" > _secrets/aws_access_key
printf "bbb" > _secrets/aws_secret_key

# 3. Run the stack
docker-compose -f docker-compose.yml up -d --build
```

Note : to avoid hitting LetsEncrypt limits if anything fails, you should add `LETSENCRYPT_MODE=production` only when you see tests certificates are properly loading. Hitting the limits is annoying as you can be blocked for a few days...

Note : as docker-compose is not a real containers orchestrator, it may be necessary to restart (just run the same command again) some containers manually after some time at first startup, since healthchecks are not used.

### Developpement vs Production

Difference of dev setup vs prod setup:

- Django source is mounted on the host and uwsgi does live reload (so that edits to the python code is reloaded live)
- Django static and media folder, Geoserver's data folder and Certificates folder are mounted on the host (just to easily see what's happening)
- Django debug is set to True
- Postgres's port 5432 is exposed (to allow debugging using pgadmin)
- Nginx debug mode is acticated (not really sure what this changes)
- Docker tags are set to dev instead of latest

### Publishing the images

Pushes to github trigger automatic builds on docker hub for tags looking like x.x.x

If you need to publish the images manually, just rebuilt the containers (`docker-compose -f docker-compose.yml build`), then use :

```
docker login
docker-compose -f docker-compose.yml push
```

### Rancher

This setup can almost be used as is by Rancher. Some minor adaptations must be made to docker-compose. The adaptations are marked as comments in the docker-compose file.


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
