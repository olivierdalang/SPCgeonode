# spcgeonode

spcgeonode is a skeletton for Geonode deployement at SPC. It makes it easy to deploy a customized version of Geonode.

The setup should be usable for production.

## Prerequisites

Make sure you have a version of Docker (tested with 17.12) and docker-compose.

On Ubuntu 16.04 :
```
# Docker
wget https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb
sudo dpkg -i docker-ce_17.12.0~ce-0~ubuntu_amd64.deb
rm docker-ce_17.12.0~ce-0~ubuntu_amd64.deb

# Docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Test
sudo docker run hello-world
```

On Windows: https://store.docker.com/editions/community/docker-ce-desktop-windows


## Usage

For **developpement** which will :
- mount django source as volume and set uwsgi to live reload
- mount django static and media in the volumes folder
- mount geoserver's data volume in the volumes folder
- mount letsencyrpt volumes in the volumes folder
- set django debug=True
- expose postgres port 5432
- activates nginx debug mode
- run celery using djcelery (so that output goes to admin) 
- use docker dev tags instead of latest
- use defaults secrets from _dev-secrets `admin_username=super2` and `admin_password=duper2`
- use defaut .env variables which set `LAN_HOST=127.0.0.1`, `WAN_HOST=localhost` and `ADMIN_EMAIL=admin@null`

```
docker-compose up -d --build
```

To see logs, use `docker-compose logs` or that practical `docker-log.bat` script that opens a separate window for each service.

For **production** :


If using local images, build them first. If not, make sure you published the images to docker hub first (see below).
```
docker-compose -f docker-compose.yml up --build
```

And then (Windows Powershell)
```
# 1. Create a swarm
docker swarm init

# 2. Set variables (Windows)
$env:WAN_HOST="localhost"
$env:LAN_HOST="127.0.0.1"
$env:ADMIN_USERNAME="super"
$env:ADMIN_PASSWORD="duper"
$env:ADMIN_EMAIL="admin@null"

# 3. Deploy the stack

docker secret rm admin_username
echo "$ADMIN_USERNAME" | docker secret create admin_username -
docker secret rm admin_password
echo "$ADMIN_PASSWORD" | docker secret create admin_password -
docker stack deploy spcgeonode --compose-file docker-compose.yml

# 4. Cleanup
$env:ADMIN_USERNAME=""
$env:ADMIN_PASSWORD=""
```

And then (Linux)
```
# 1. Create a swarm
sudo docker swarm init

# 2. Set variables (Windows)
set WAN_HOST="localhost"
set LAN_HOST="127.0.0.1"
set ADMIN_USERNAME="super"
set ADMIN_PASSWORD="duper"
set ADMIN_EMAIL="admin@null"

# 3. Deploy the stack (again: MAKE SURE YOU'VE JUST REBUILD THE IMAGES)
# this creates the docker secrets
sudo docker secret rm admin_username
echo "$ADMIN_USERNAME" | sudo docker secret create admin_username -
sudo docker secret rm admin_password
echo "$ADMIN_PASSWORD" | sudo docker secret create admin_password -
sudo docker stack deploy spcgeonode --compose-file docker-compose.yml

# 4. Cleanup
set ADMIN_USERNAME=""
set ADMIN_PASSWORD=""
```

Checks
```
# 1. Check if everything is runing
docker service ls
# 2. If something is not fine, like container doesn't start
docker service ps SERVICE_NAME --no-trunc
# 3. If something is not fine, container crashes
docker service logs SERVICE_NAME
# or
# 1. Use portainer and check on http://127.0.0.1:9000
docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer

# If container donesn't start, I could debug it sometime with docker ps -a (then you may see a long list of retries) and then manually doing docker start CONTAINER_ID
```

## How it works

### Geonode/Django

Geonode is installed as a "geonode django project" (under `django`). This allows easy customization/extension as it is a regular django application.

The django project is initialised (install requirements, migrate, collectstatic and fixtures) at launch, and then served using uwsgi.

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
- TODO : move rancher catalog out of this repo

## Publish

When you want to publish the changes, make sure you've just rebuilt the containers (`docker-compose -f docker-compose.yml build`, then use :

```
docker login
docker-compose -f docker-compose.yml push
```

Note that this should be done autmatically using Docker autobuilds.

## Compared to Geonode project

This is very similar to https://github.com/GeoNode/geonode-project but aims to be suitable for deployement.

Key differences :


- dockerfiles for nginx and geoserver are in same repo, since they need to be customized for a deployement
- other services (postgres, elasticsearch, rabbit) images use a specific tag, so we know which one will be pulled, making 
- settings imports from geonode.settings so most defaults don't need to be modified
- geoserver starts with empty geodatadir. Geonode's entrypoint script ensures there is a geonode workspace initialized using REST API. (in geonode-project, initial data-dir is pulled from http://build.geonode.org/geoserver/latest/data-$GEOSERVER_VERSION.zip , see waybarrios/geoserver Docker image) 

This is very similar to https://github.com/kartoza/kartoza-rancher-catalogue

Key differences :

- we use geoserver instead of qgis server
- working celery admin panels
- https encryption
- use secrets for sensitive data instead of env variables

## WIP

- have ssl working online => TEST
- use env variables / secrets where applicable => DONE ?
- publish on git and autobuild images => DONE ?
- make docker deploy work again (see if finally service launched after waiting during a long time (docker service ls))
