from django.conf import settings


# Should Offline OSM be available as default base layer
if not hasattr(settings, 'OFFLINE_OSM_AS_BASE_LAYER'):
    settings.OFFLINE_OSM_AS_BASE_LAYER = True


if not hasattr(settings, 'OFFLINE_OSM_BBX'):
    settings.OFFLINE_OSM_BBOX = [
        [176.8, -18.6], # BOTTOMLEFT
        [179.3, -17.1], # TOPRIGHT
    ];

if settings.OFFLINE_OSM_AS_BASE_LAYER:
    settings.MAP_BASELAYERS.append(
        {
            "source": {"ptype": "gxp_olsource"},
            "type":"OpenLayers.Layer.WMS",
            "name": "offline_osm",
            "group":"background",
            "visibility": False,
            "fixed": True,
            "args":[
                "offline_osm",
                settings.GEOSERVER_PUBLIC_LOCATION+"wms",
                {
                    "layers":["geonode:offline_osm"],
                    "format":"image/png",
                    "bgcolor":"0xb5d0d0",
                    "tiled": True
                }
            ]
        }
    )