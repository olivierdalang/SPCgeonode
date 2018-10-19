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

# logout and login again
```

### Windows / Mac

Install Docker by following instructions on: https://store.docker.com/editions/community/docker-ce-desktop-windows (Windows) or https://store.docker.com/editions/community/docker-ce-desktop-mac (Mac)

If familiar with Git, checkout the source, if not download it from https://github.com/olivierdalang/SPCgeonode/archive/release.zip and unzip it.

Open command prompt and move into the folder using `cd C:\path\to\folder`.

## Usage

### Development

To start the whole stack
```
docker-compose up --build -d
```

If not familiar with Docker, read below to know how to see what's happening. On first start, the containers will restart serveral times. Once everything started, you should be able to open http://127.0.0.1 in your browser. See how to edit the configuration below if you install on another computer.

### Production (using composer)

Using a text editor, edit the follow files :
```
# General configuration
.env

# Admin username and password
_secrets/admin_username
_secrets/admin_password

# Backup (optional)
_secrets/rclone.backup.conf
```

When ready, start the stack using this command :
```
# Run the stack
docker-compose -f docker-compose.yml up -d --build
```

If not familiar with Docker, read below to know how to see what's happening. On first start, the containers will restart serveral times. Once everything started, you should be able to open http://your_http_host or https://your_https_host in your browser.


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


## FAQ

### Docker-primer - How to see what's happening ?

If not familiar with Docker, here are some useful commands :

- `docker ps` : list all containers and their status
- `docker-compose logs -f` : show live stdout from all containers
- `docker-compose logs -f django` : show live stdout from a specific container (replace `django` by `geoserver`, `postgres`, etc.)
- `docker-compose down -v` : brings the stack down including volumes, allowing you to restart from scratch **THIS WILL ERASE ALL DATA !!**

### During startup, a lot of container crash and restart, is it normal ?

This is the normal startup process. Due to the nature of the setup, the containers are very interdependant. Startup from scratch can take approx. 5-10 minutes, during which all containers may restart a lot of times.

In short, Django will restart until Postgres is up so it can migrate the database. Geoserver will restart until Django has configured OAuth so it can get OAuth2 configuration. Django will restart until Geoserver is running so it can reinitialize the master password.

### Backups

*Backups* are made using [RClone](https://rclone.org/docs/). RClone is a flexible file syncing tool that supports all commons cloud provider, regular file transfer protocols as well as local filesystem. It should be able to accomodate almost any setup.

The default configuration provided with the setup assumes Amazon S3 is being used, in which case you need to replace the following parts of the `rclone.backup.config` file : `YOUR_S3_ACCESS_KEY_HERE`,`YOUR_S3_SECRET_KEY_HERE`,`YOUR_S3_REGION_HERE` and `THE_NAME_OF_YOUR_BUCKET_HERE` (watch [this](https://www.youtube.com/watch?v=BLTy2tQXQLY) to learn how to get these keys).

Also consider enabling *versionning* on the Bucket, so that if data won't get lost if deleted accidentally in GeoNode.

If you want to stup backups using another provider, check the [RClone documentation](https://rclone.org/docs/).

### How to migrate from an existing standard Geonode install

This section lists the steps done to migrate from an apt-get install of Geonode 2.4.1 (with Geoserver 2.7.4) to a fresh SPCGeonode 0.1 install. It is meant as a guide only as some steps may need some tweaking depending on your installation. Do not follow these steps if you don't understand what you're doing.

#### Prerequisites

- access to the original server
- a new server for the install (can be the same than the first one if you don’t fear losing all data) - ideally linux but should be OK as long as it runs docker (64bits)
- an external hard-drive to copy data over

#### On the old server

```
# Move to the external hard drive
cd /path/to/your/external/drive

# Find the current database password (look for DATABASE_PASSWORD, in my case it was XbFAyE4w)
more /etc/geonode/local_settings.py

# Dump the database content (you will be prompted several time for the password above)
pg_dumpall --host=127.0.0.1 --username=geonode --file=pg_dumpall.custom

# Copy all uploaded files
cp -r /var/www/geonode/uploaded uploaded

# Copy geoserver data directory
cp -r /usr/share/geoserver/data geodatadir
```

#### On the new server

Setup SPCGeonode by following the prerequisite and production steps on https://github.com/olivierdalang/SPCgeonode/tree/release up to (but not including) run the stack.

Then run these commands :

```
# Prepare the stack (without running)
docker-compose -f docker-compose.yml pull --no-parallel
docker-compose -f docker-compose.yml up --no-start

# Start the database
docker-compose -f docker-compose.yml up -d postgres

# Initialize geoserver (to create the geodatadir - this will fail because Django/Postgres arent started yet - but this is expected)
docker-compose -f docker-compose.yml run --rm geoserver exit 0

# Go to the external drive
cd /path/to/drive/

# Restore the dump (this can take a while if you have data in postgres)
cat pg_dumpall.custom | docker exec -i spcgeonode_postgres_1 psql -U postgres
# Rename the database to postgres
docker exec -i spcgeonode_postgres_1 dropdb -U postgres postgres
docker exec -i spcgeonode_postgres_1 psql -d template1 -U postgres -c "ALTER DATABASE geonode RENAME TO postgres;"

# Restore the django uploaded files
docker cp uploaded/. spcgeonode_django_1:/spcgeonode-media/

# Restore the workspaces and styles of the geoserver data directory
docker cp geodatadir/styles/. spcgeonode_geoserver_1:/spcgeonode-geodatadir/styles
docker cp geodatadir/workspaces/. spcgeonode_geoserver_1:/spcgeonode-geodatadir/workspaces
docker cp geodatadir/data/. spcgeonode_geoserver_1:/spcgeonode-geodatadir/data

# Back to SPCgeonode
cd /path/to/SPCgeonode

# Fix some inconsistency that prevents migrations (public.layers_layer shouldn’t have service_id column)
docker exec -i spcgeonode_postgres_1 psql -U postgres -c "ALTER TABLE public.layers_layer DROP COLUMN service_id;"

# Migrate with fake initial
docker-compose -f docker-compose.yml run --rm --entrypoint "" django python manage.py migrate --fake-initial

# Create the SQL diff to fix the schema # TODO : upstream some changes to django-extensions for this to work directly
docker-compose -f docker-compose.yml run --rm --entrypoint "" django /bin/sh -c "DJANGO_COLORS="nocolor" python manage.py sqldiff -ae" >> fix.sql

# Manually fix the SQL command until it runs (you can also drop the tables that have no model)
nano fix.sql

# Apply the SQL diff (review the sql file first as this may delete some important tables)
cat fix.sql | docker exec -i spcgeonode_postgres_1 psql -U postgres

# This time start the stack
docker-compose -f docker-compose.yml up -d
```

One last step was to connect to the GeoServer administration and change the PostGIS store host to ‘postgres’ instead of localhost.

### On windows, I have error like `standard_init_linux.go:190: exec user process caused "no such file or directory"`

This may be due to line endings. When checking out files, git optionnaly converts line endings to match the platform, which doesn't work well it `.sh` files.

To fix, use `git config --global core.autocrlf false` and checkout again.