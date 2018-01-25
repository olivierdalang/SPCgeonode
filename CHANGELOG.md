# Changelog


## 0.0.7

- have ssl working online
- use env variables / secrets where applicable
- publish on git and autobuild images
- make docker deploy work again

## 0.0.8

- allow to disable/test let's encrypt using env variables
- WIP WIP WIP : use authkey module with user property (configure postgres view to have user properties)

## Roadmap

- geonode/geoserver auth sync
- backup geoserver data folder, postgresql data...
- tweak nginx settings (gzip output, cache, etc...)
- clean Dockerfiles to make lighter images
- allow setup superuser password/login and set geoserver admin password
- optimise dockerfiles
- contribute back to geonode-project
- move rancher catalog out of this repo
- allow empty WAN/LAN_HOST
- think about upgrade (e.g. changing variables such as admin)