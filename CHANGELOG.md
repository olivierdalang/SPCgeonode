# Changelog


## 0.0.7

- have ssl working online
- use env variables / secrets where applicable
- publish on git and autobuild images
- make docker deploy work again

## 0.0.8

- allow to disable/test let's encrypt using env variables
- we use geonode users/groups table directly for geoserver's authentication

## 0.0.9

- fix bug with rancher resolver on rancher

## 0.0.10

- we don't rely on an initial geodatadir anymore, instead we start from scratch, launch geoserver once, then do our modifications
- added a backup service using Syncthings

## 0.0.11

- added a second backup service using RClone (the idea is to test both syncthings and rclone then choose one)

## 0.0.12

- ...

## 0.0.13

- ...

## 0.0.14

- ...

## 0.0.15

- removed rancher template from repo
- removed entryponts and command from django image to prevent what looks like a bug in rancher where empty entrypoint in docker-compose isn't taken into account

## 0.0.16

- put django in main directory (so it's more clear for deploy builds)

## 0.0.17

- improve nginx<->letsencrypt (nginx can work without letsencrypt service)

## 0.0.18

- geoserver master password reset is cleaner (programmatically reset the password from initial datadir before first launch)
- support empty HTTP_HOST or HTTPS_HOST
- geosever 2.12.1 => 2.12.2
- cleaned up env vars
- upgrade should work

## 0.0.21

- use custom build of geonode (with some fixes not upstreamed yet)

## 0.0.24

- ship geoserver community extensions in the repo (as they are not properly versionned)

## TODO : Roadmap

- CRITICAL : randomize django secret
- CRITICAL : change rest.properties config
- choose between syncthings and rclone
- check if everything is ok with auth_keys (it seems Geonode uses expired keys...)
- tweak nginx settings (gzip output, cache, etc...)
- use alpine for django as well
- contribute back to geonode-project
- add HEALTHCHECKS to Dockerfiles where applicable
- migrate to spc repositories
- push to Geonode 2.8 instead of 2.6
- fix Geoserver exceptions on first launch because of missing datadir configurations
- see if we use all needed geoserver extensions (marlin-renderer, geonode's module)
- see if we can have geoserver exit on error, in not at least implement proper healtcheck
- CRITICAL : see if Geoserver authkey tokens expire (even when the key is deleted from the database, it's still possible to use it until manually clicking "sync user/group service". It looks like it's some cache, but I don't know if it expires. Maybe we need to use webservice instead of user property...)
- make "set thumbnail" work again. this involves installing geoserver-geonode-ext. see https://github.com/GeoNode/geoserver-geonode-ext/issues/60 and https://lists.osgeo.org/pipermail/geonode-users/2018-March/004190.html before working on this
- keep a version marker in the geodatadir directory in case of updates to the datadir
