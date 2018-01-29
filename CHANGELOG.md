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

## TODO : Roadmap

- WIP : check auth_keys (it seems Geonode uses expired keys...)
- backup geoserver data folder, postgresql data...
- tweak nginx settings (gzip output, cache, etc...)
- optimise dockerfiles
- contribute back to geonode-project
- move rancher catalog out of this repo
- allow empty WAN/LAN_HOST
- think about upgrade (e.g. changing variables such as admin)
- add HEALTHCHECKS to Dockerfiles where applicable
- migrate to spc repositories
