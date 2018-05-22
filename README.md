# SPCgeonode [![Build Status](https://travis-ci.org/olivierdalang/SPCgeonode.svg?branch=master)](https://travis-ci.org/olivierdalang/SPCgeonode)

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

Once everything started, you should be able to open http://127.0.0.1 in your browser. See how to edit the configuration below if you install on another computer.

### Production (using composer)

Note : these instructions are for Linux and must be adapted if installing on Windows.

```
# 0. Install an editor
sudo apt-get install nano

# 1. Edit configuration
nano .env

# 2. Edit the admin password (do NOT add an empty new line after content)
nano _secrets/admin_username
nano _secrets/admin_password

# 3. Setup the backup configuration (read below for details)
nano _secrets/rclone.backup.conf

# 4. Run the stack
docker-compose -f docker-compose.yml up -d --build
```

*Backups* are made using [RClone](https://rclone.org/docs/). RClone is a flexible file syncing tool that supports all commons cloud provider, regular file transfer protocols as well as local filesystem. It should be able to accomodate almost any setup.

The default configuration provided with the setup assumes Amazon S3 is being used, in which case you need to replace the following parts of the `rclone.backup.config` file : `YOUR_S3_ACCESS_KEY_HERE` and `YOUR_S3_SECRET_KEY_HERE` (watch [this](https://www.youtube.com/watch?v=BLTy2tQXQLY) to learn how to get these keys).

If you want to stup backups using another provider, check the [RClone documentation](https://rclone.org/docs/).

### Production (using Rancher)

See https://github.com/PacificCommunity/rancher-catalogue to install using Rancher.

This uses almost exactly the same docker-compose file. The adaptations are marked as comments in the docker-compose file.

### Upgrade

If at some point you want to update the SPCgeonode setup (this will work only if you didn't do modifications, if you did, you need to merge them) :
```
# Get the update setup
git pull

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
