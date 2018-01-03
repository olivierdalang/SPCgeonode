from django.conf import settings

if not hasattr(settings, 'OFFLINE_OSM_BBX'):
    settings.OFFLINE_OSM_BBOX = [
        [176.8, -18.6], # BOTTOMLEFT
        [179.3, -17.1], # TOPRIGHT
    ];

print( settings.OFFLINE_OSM_BBOX )

settings.MAP_BASELAYERS.append(
    {
        "source": {"ptype": "gxp_olsource"},
        "type":"OpenLayers.Layer.WMS",
        "name": "Offline OSM",
        "group":"background",
        "visibility": False,
        "fixed": True,
        "args":[
            "Offline OSM",
            settings.GEOSERVER_PUBLIC_LOCATION+"wms",
            {
                "layers":["geonode:offline_osm_multipolygons"],
                "format":"image/png",
                "bgcolor":"0xb5d0d0",
                "tiled": True
            }
            ]
    }
)