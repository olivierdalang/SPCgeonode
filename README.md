# SPCNode

SPCNode is a skeletton for Geonode deployement at SPC. It makes it easy to deploy a customized version of Geonode.

The setup should be usable for production.

## Usage

For **developpement** (this will mount the source as a volume, set debug=True and set uwsgi to live reload when file changes):

```
docker-compose -f docker-compose.yml -f docker-compose-dev.yml up --build
```

If you want to mount volumes on host (can make debugging easier), use:
```
docker-compose -f docker-compose.yml -f docker-compose-dev.yml -f docker-compose-mount-volumes.yml up --build
```

For **production** :

```
docker-compose up # TODO : use swarm ?
```

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
