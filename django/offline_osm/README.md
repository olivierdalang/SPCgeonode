# OFFLINE_OSM

This is an app to create an offline OSM layer as a base layer for geonode.

## Manage.py command

To update the data, run the following management command. Be aware that will download a lot of data and require some heavy queries.

```
python manage.py updateofflineosm
```