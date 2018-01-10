# spcgeonode

spcgeonode is a skeletton for Geonode deployement at SPC. It makes it easy to deploy a customized version of Geonode.

The setup should be usable for production.

## Usage

For **developpement** which will :
- mount django source as volume and set uwsgi to live reload
- mount django static and media in the volumes folder
- mount geoserver's data volume in the volumes folder
- set django debug=True
- expose postgres port 5432
- activates nginx debug mode
- run celery using djcelery (so that output goes to admin) 

```
docker-compose up -d --build
```

For **production** :

```
# 0. Create secrets (for each file in dev/secrets)
echo "mysecret" | docker secret create geonode_admin_username -
# 1. Create a swarm
docker swarm init
# 2. Deploy the stack
docker stack deploy spcgeonode --compose-file docker-compose.yml
```

To see logs, use `docker-compose logs` or that practical `docker-log.bat` script that opens a separate window for each service.

## How it works

### Geonode/Django

Geonode is installed as a "geonode django project" (under `django`). This allows easy customization/extension as it is a regular django application.

An example customization app (`customization_sample`) and an offline openstreetmap base layer app (`offline_osm`) are installed by default.

The django project is rebuilt (install requirements, makemigrations, collectstatic) at launch, and then served using uwsgi.

### Nginx

Nginx proxies to uwsgi (django) and geoserver. It also directly serves django static and media files. 

## TODOs

- TODO : backup geoserver data folder, postgresql data...
- TODO : configure nginx with let's encrypt
- TODO : tweak nginx settings (gzip output, cache, etc...)
- TODO : check how to make this works on production (can images be prebuilt ? do we need --build in production ? etc...). Probably need to check docker swarm
- TODO : clean Dockerfiles to make lighter images
- TODO : allow setup superuser password/login and set geoserver admin password
- TODO : optimise dockerfiles
- TODO : reorganize folders : django as main, other services in subfolders ?
- TODO : contribute back to geonode-project

## Publish

When you want to publish the changes, use

```
docker login
docker-compose push
```

## Compared to Geonode project

This is very similar to https://github.com/GeoNode/geonode-project but aims to be suitable for deployement.

Key differences :

- dockerfiles for nginx and geoserver are in same repo, since they need to be customized for a deployement
- other services (postgres, elasticsearch, rabbit) images use a specific tag, so we know which one will be pulled, making 
- settings imports from geonode.settings so most defaults don't need to be modified
- geoserver starts with empty geodatadir. Geonode's entrypoint script ensures there is a geonode workspace initialized using REST API. (in geonode-project, initial data-dir is pulled from http://build.geonode.org/geoserver/latest/data-$GEOSERVER_VERSION.zip , see waybarrios/geoserver Docker image) 

## WIP

- get auth django<=>geoserver either through OAuth2 (looks complicated) or through database level (looks even worse)
- end offline_osm integration (mainly make periodic celery tasks work and cleanup import (from git instead of local volume thing)