from django.core.management.base import BaseCommand
import urllib
import os
import base64
import zipfile
import ogr, osr
from django.conf import settings
import dj_database_url
from django.db import connection
import requests

from ...models import Log

datastore_xml = '''
    <dataStore>
        <name>offline_osm</name>
        <connectionParameters>
            <host>postgres</host>
            <port>5432</port>
            <database>postgres</database>
            <schema>offline_osm</schema>
            <user>postgres</user>
            <passwd>postgres</passwd>
            <dbtype>postgis</dbtype>
        </connectionParameters>
    </dataStore>'''

featuretype_xml = '''
    <featureType>
        <name>{layername}</name>
        <nativeName>{layername}</nativeName>
        <title>{layername}</title>
        <keywords>
            <string>features</string>
            <string>{layername}</string>
        </keywords>
        <srs>EPSG:4326</srs>
        <projectionPolicy>FORCE_DECLARED</projectionPolicy>
        <enabled>true</enabled>
    </featureType>'''

class Command(BaseCommand):

    download_dir = '/spcnode-media/urlretrieve/' # TODO : use temp instead
    schema_name = 'offline_osm' # TODO : use setting instead

    help = 'Updates the local offline OSM data. This will download around 1 GB so ensure to have good connection.'

    def handle(self, *args, **options):

        Log.objects.create( message="Started createbaselayers", success=True )

        rest_endpoint = settings.GEOSERVER_PUBLIC_LOCATION+'rest'
        
        res = requests.post(
            rest_endpoint + '/workspaces/geonode/datastores',
            data=datastore_xml,
            headers={'Content-type':'text/xml'}
        )
        Log.objects.create( message="Creation of datastore : {}".format(str(res)), success=True )
        # res.raise_for_status()

        for layername in ['offline_osm_lines','offline_osm_multipolygons','offline_osm_multilinestrings','offline_osm_points']:
            res = requests.post(
                rest_endpoint + '/workspaces/geonode/datastores/offline_osm/featuretypes?recalculate=nativebbox,latlonbbox',
                data=featuretype_xml.format(layername=layername),
                headers={'Content-type':'text/xml'}
            )
            # res.raise_for_status()
            Log.objects.create( message="Creation of layer {} : {}".format(layername,str(res)), success=True )

        

        """
        for f in *shp; do
            curl -u admin:geoserver -v -XPOST -H 'Content-Type:text/xml'
            -d "${f %.shp}"
            http://localhost:8080/geoserver/rest/workspaces/earthws/datastores/earthds/featuretypes;
        done

        curl -u admin:geoserver -XPOST -H 'Content-type: text/xml' 
-d '<style><name>roads_style</name><filename>roads.sld</filename></style>'
http://localhost:8080/geoserver/rest/styles

        curl -u admin:geoserver -XPUT -H 'Content-type: application/vnd.ogc.sld+xml'  -d @roads.sld
http://localhost:8080/geoserver/rest/styles/roads_style

        curl -u admin:geoserver -XPUT -H 'Content-type: text/xml' 
-d '<layer><defaultStyle><name>roads_style</name></defaultStyle></layer>' 
http://localhost:8080/geoserver/rest/layers/acme:roads


"""


        # publishTable('overpass_results_multipolygons','4326')

        Log.objects.create( message="Table published !!", success=True )

        
def publishTable(layerName, epsg, style=None):
   
    if not epsg.startswith('EPSG:'):
        epsg = 'EPSG:'+epsg
   
    gsUrl = settings.OGC_SERVER['default']['LOCATION'] + "rest"
    gsUser = settings.OGC_SERVER['default']['USER']
    gsPassword = settings.OGC_SERVER['default']['PASSWORD']
   
    cat = Catalog(gsUrl, gsUser, gsPassword)   
    if cat is None: raise GeonodeManagementError('unable to instantiate geoserver catalog')

    ws = cat.get_workspace(settings.DEFAULT_WORKSPACE)
    if ws is None: raise GeonodeManagementError('workspace %s not found in geoserver'%settings.DEFAULT_WORKSPACE)
   
    storeName = settings.OGC_SERVER['default']['DATASTORE']
    store = cat.get_store(storeName, ws)
    if store is None: raise GeonodeManagementError('workspace %s not found in geoserver'%storeName)
   
    ft = cat.publish_featuretype(layerName, store, epsg, srs=epsg)
    if ft is None: raise GeonodeManagementError('unable to publish layer %s'%layerName)
   
    cat.save(ft)
   
    if style is not None:
        publishing = cat.get_layer(layerName)
        if publishing is None: raise GeonodeManagementError('layer not found ($s)'%layerName)
        publishing.default_style = cat.get_style(style)
        cat.save(publishing)
   
    resource = cat.get_resource(layerName, store, ws)
    if resource is None: raise GeonodeManagementError('resource not found ($s)'%layerName)
   
    layer, created = Layer.objects.get_or_create(name=layerName, defaults={
                    "workspace": ws.name,
                    "store": store.name,
                    "storeType": store.resource_type,
                    "typename": "%s:%s" % (ws.name.encode('utf-8'), resource.name.encode('utf-8')),
                    "title": resource.title or 'No title provided',
                    "abstract": resource.abstract or 'No abstract provided',
                    #"owner": owner,
                    "uuid": str(uuid.uuid4()),
                    "bbox_x0": Decimal(resource.latlon_bbox[0]),
                    "bbox_x1": Decimal(resource.latlon_bbox[1]),
                    "bbox_y0": Decimal(resource.latlon_bbox[2]),
                    "bbox_y1": Decimal(resource.latlon_bbox[3])
                })
   
    set_attributes(layer, overwrite=True)
   
    if created: layer.set_default_permissions()