# SPCgeonode

SPCgeonode is a skeletton for Geonode deployement at SPC. It makes it easy to deploy a customized version of Geonode.

The setup aims to be usable for production.


## Prerequisites

Make sure you have a version of Docker (tested with 17.12) and docker-compose.
Checkout/download the source.

### Linux

Following these instructions https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-from-a-package and https://docs.docker.com/compose/install/#install-compose (adapt according to instructions) :

```
# Install Docker
wget https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce_17.12.1~ce-0~ubuntu_amd64.deb
sudo dpkg -i docker-ce_17.12.1~ce-0~ubuntu_amd64.deb
sudo apt-get update
sudo apt-get -f install

# Post-install Docker
sudo groupadd docker
sudo usermod -aG docker $USER

# Install Docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Checkout the source
git clone -b release https://github.com/olivierdalang/SPCgeonode.git
cd SPCGeonode
```

### Windows

Install Docker by following instructions on: https://store.docker.com/editions/community/docker-ce-desktop-windows

Download the source from https://github.com/olivierdalang/SPCgeonode/archive/release.zip, unzip it.

Open command prompt and move into the folder using `cd C:\path\to\unzipped\folder`.

## Usage

### Development

To start the whole stack
```
docker-compose up --build -d
```

Or if you want only the main services (enough to develop and a bit lighter):
```
docker-compose up --build -d django geoserver nginx postgres
```


### Production (using composer)

Note : these instructions are for Linux and must be adapted if installing on Windows.

```
# 0. Install an editor
sudo apt-get install nano

# 1. Edit configuration
nano .env

# 2. Edit the secrets (do NOT add an empty new line after content)
nano _secrets/admin_username
nano _secrets/admin_password
nano _secrets/aws_access_key
nano _secrets/aws_secret_key

# 3. Run the stack
docker-compose -f docker-compose.yml up -d --build
```

Note : to avoid hitting LetsEncrypt limits if anything fails, you should add `LETSENCRYPT_MODE=production` only when you see tests certificates are properly loading. Hitting the limits is annoying as you can be blocked for a few days...

### Production (using Rancher)

See https://github.com/PacificCommunity/rancher-catalogue to install using Rancher.

This uses almost exactly the same docker-compose file. The adaptations are marked as comments in the docker-compose file.

### Upgrade

If at some point you want to update the SPCgeonode setup :
```
# Get the update setup
git stash
git pull
git stash apply

# Upgrade the stack
docker-compose -f docker-compose.yml up -d --build
```

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

Sometimes, the automatic builds fail with no apparent reason. If so, you can publish the images manually with :

```
docker login
docker-compose -f docker-compose.yml build
docker-compose -f docker-compose.yml push
```


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
