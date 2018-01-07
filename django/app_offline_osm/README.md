# OFFLINE_OSM

This is an app to create an offline OSM layer as a base layer for geonode.

## Settings

```python
# Extents of OSM data to be downloaded
OFFLINE_OSM_BBOX = [
    [176.8, -18.6], # BOTTOMLEFT
    [179.3, -17.1], # TOPRIGHT
]

# Whether Offline OSM should be made available as base layers
# (when true, data will be downloaded after migrations (once))
OFFLINE_OSM_AS_BASE_LAYER = True
```

## Management command

To update the data, run the following management command. Be aware that will download a lot of data and require some heavy queries.

```shell
python manage.py updateofflineosm # TODO : describe options
```
