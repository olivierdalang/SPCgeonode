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

## TODO : Roadmap

- choose between syncthings and rclone
- check if everything is ok with auth_keys (it seems Geonode uses expired keys...)
- tweak nginx settings (gzip output, cache, etc...)
- optimise dockerfiles
- make use of entrypoint/cmd more consistent (is it in the dockerfile ? or in the docker-compose?)
- contribute back to geonode-project
- allow empty WAN/LAN_HOST
- think about upgrade (e.g. changing variables such as admin)
- add HEALTHCHECKS to Dockerfiles where applicable
- migrate to spc repositories
- use Geoserver 2.13 instead of 2.12
- use Geonode 2.8 (? is it the latest) instead of 2.6
- see if we can use postgres for geofence too https://github.com/geoserver/geofence/wiki/GeoFence-configuration#database-configuration-1
- fix Geoserver exceptions on first launch because of missing datadir configurations
- see if we use all needed geoserver extensions (marlin-renderer, geonode's module)
- see if we can have geoserver exit on error, in not at least implement proper healtcheck
