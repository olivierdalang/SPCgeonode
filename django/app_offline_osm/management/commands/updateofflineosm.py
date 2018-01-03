from django.core.management.base import BaseCommand
import urllib
import os
import base64
import zipfile
import ogr, osr
import dj_database_url
from django.db import connection
from django.conf import settings
from ...models import Log
from django.core.management import call_command
import requests
from geoserver.catalog import Catalog

class Command(BaseCommand):
    """
    This command creates or updates local offline OSM data.
    """

    download_dir = '/spcnode-media/urlretrieve/' # TODO : use temp instead
    datastore_name = 'offline_osm' # TODO : use setting instead
    schema_name = 'offline_osm' # TODO : use setting instead

    help = 'Updates the local offline OSM data. This will download around 1 GB so ensure to have good connection.'

    def __init__(self, *args, **kwargs):
        if not os.path.isdir(self.download_dir):
            os.mkdir(self.download_dir)
        super(Command, self).__init__(*args, **kwargs)

    def add_arguments(self, parser):
        parser.add_argument('--source', default='overpass', choices=['overpass','pbf_and_shp'])
        
        # TODO : add parameters to load from local data

    def handle(self, *args, **options):

        Log.objects.create( message="Started updateofflineosm from source {}".format(options['source']), success=True )
        
        print('[Step 1] Downloading data')
        if options['source'] == 'overpass':
            self.download_overpass()
        else:
            self.download_shapefile()
            self.download_osmxml()

        print('[Step 2] Importing data in postgis')
        if options['source'] == 'overpass':
            self.import_overpass()
        else:
            self.import_shapefile()
            self.import_osmxml()

        print('[Step 3] Adding the layers to Geoserver')
        self.add_to_geoserver()

        print('[Step 4] Updating Geonode layers')
        call_command('updatelayers', interactive=True)

        print('[Done !]')

        Log.objects.create( message="Finished updateofflineosm", success=True )
    
    def download_shapefile(self):
        self._download("http://data.openstreetmapdata.com/simplified-land-polygons-complete-3857.zip")
        self._download("http://data.openstreetmapdata.com/land-polygons-split-3857.zip")
    def import_shapefile(self):
        self._import('simplified-land-polygons-complete-3857/simplified_land_polygons.shp')
        self._import('land-polygons-split-3857/land_polygons.shp', crop=True)

    def download_osmxml(self):
        self._download("http://download.geofabrik.de/australia-oceania-latest.osm.pbf")
    def import_osmxml(self):
        self._import('australia-oceania-latest.osm.pbf', crop=True)

    def download_overpass(self):
        bbox = settings.OFFLINE_OSM_BBOX
        overpass_endpoint = 'https://overpass.kumi.systems/api/interpreter'
        # overpass_endpoint = 'https://lz4.overpass-api.de/api/interpreter'
        # overpass_q = '( node({y1},{x1},{y2},{x2}); <; ); out meta;'
        overpass_q = '( node({y1},{x1},{y2},{x2}); <; >; ); out meta;' # TODO : test this (does recusre up <; then down >; work ?)
        overpass_q = overpass_q.format(x1=bbox[0][0],y1=bbox[0][1],x2=bbox[1][0],y2=bbox[1][1])
        url = overpass_endpoint+'?'+urllib.urlencode({'data':overpass_q})
        self._download(url, 'overpass_results.osm')
    def import_overpass(self):
        self._import('overpass_results.osm')

    def _download(self,url,filename=None):
        print('Downloading '+url)
        
        def urlretrieve_output(a,b,c):
            if c==-1:
                print("{:0.2f} MB bytes (total size unknown)".format(a*b/1000000.0))
            else:
                print("{:0.2f} MB bytes out of {:0.2f} MB ({:0f}%)".format(a*b/1000000.0,c/1000000.0, (a*b)/float(c)*100.0))

        if not filename:
            filename = url.split('/')[-1]
        filepath = os.path.join(self.download_dir,filename)

        if not os.path.exists(filepath):
            print('File does not exist, we download it...')
            urllib.urlretrieve(url, filepath, urlretrieve_output)
        else:
            # TODO : THIS IS ONLY FOR DEV, FILE SHOULD BE REDOWNLOADED BECAUSE IT IS AN UPDATE FUNCTION
            print('File already exists, we skip.')

        print('Unzipping...')
        if filename[-4:] == '.zip':
            if not os.path.isdir(os.path.join(self.download_dir,filename[:-4])):
                print('File is zipped, we unzip it...')
                # TODO : REMOVE ZIPS TO SAVE HARD DRIVE SPACE
                zip_ref = zipfile.ZipFile(filepath, 'r')
                zip_ref.extractall(self.download_dir)
                zip_ref.close()
            else:
                # TODO : THIS IS ONLY FOR DEV, FILE SHOULD BE REUNZIPPED BECAUSE IT IS AN UPDATE FUNCTION
                print('File already unzipped, we skip.')
        else:
            print("Not a zip file, we skip.")
    def _import(self, filename, crop=False):
        print('Importing {} to postgresql... This can take some time (over 10 minutes for large layers)'.format(filename))

        connection.cursor().execute('CREATE SCHEMA IF NOT EXISTS '+self.schema_name)
        connection.cursor().execute('CREATE EXTENSION IF NOT EXISTS postgis')
        
        db = settings.DATABASES['default']
        connectionString = "PG:dbname='%s' host='%s' port='%s' user='%s' password='%s'" % (db['NAME'],db['HOST'],db['PORT'],db['USER'],db['PASSWORD'])
        ogrds = ogr.Open(connectionString)

        # table_name = filename.split('/')[-1][:-4]
        table_name = 'offline_osm'
        ogr_source = ogr.Open(os.path.join(self.download_dir,filename))

        for ogr_layer in ogr_source:

            if len(ogr_source)==1:
                full_table_name = self.schema_name+'.'+table_name
            else:
                print('importing sublayer {}'.format(ogr_layer.GetName()))
                full_table_name = self.schema_name+'.'+table_name+'_'+ogr_layer.GetName()

            if crop:
                bbox = settings.OFFLINE_OSM_BBOX
                wkt_string = 'POLYGON(({x1} {y1},{x2} {y1},{x2} {y2},{x1} {y2},{x1} {y1}))'.format(x1=bbox[0][0],y1=bbox[0][1],x2=bbox[1][0],y2=bbox[1][1])
                bbox_geom = ogr.CreateGeometryFromWkt(wkt_string)

                ogr_layer_ref = int(ogr_layer.GetSpatialRef().GetAuthorityCode("PROJCS") or 4326)
                if ogr_layer_ref != 4326:
                    source, target = osr.SpatialReference(), osr.SpatialReference()
                    source.ImportFromEPSG(4326)
                    target.ImportFromEPSG(ogr_layer_ref)
                    transform = osr.CoordinateTransformation(source, target)
                    bbox_geom.Transform(transform)

                ogr_layer.SetSpatialFilter(bbox_geom)


            ogr_postgres_layer = ogrds.CopyLayer(ogr_layer,full_table_name,['OGR_INTERLEAVED_READING=YES','OVERWRITE=YES'])

    def add_to_geoserver(self):
        
        Log.objects.create( message="Started createbaselayers", success=True )

        rest_endpoint = settings.GEOSERVER_LOCATION+'rest'
        
        # TODO : use from geoserver.catalog import Catalog instead of REST API (see https://groups.google.com/forum/#!msg/geonode-users/R-u57r8aECw/AuEpydZayfIJ)

        print('creating datastore')
        res = requests.post(
            rest_endpoint + '/workspaces/geonode/datastores',
            auth=('admin', 'geoserver'), # TODO : set this
            data=self.datastore_xml.format(datastore_name=self.datastore_name),
            headers={'Content-type':'text/xml'}
        )
        if res.status_code==500 and res.text == "Store 'offline_osm' already exists in workspace 'geonode'":
            print('datastore already exists')
        else:
            res.raise_for_status()
            print('datastore successfully created')


        for layername in ['offline_osm_lines','offline_osm_multipolygons','offline_osm_multilinestrings','offline_osm_points']:
            print('creating layer {}'.format(layername))
            res = requests.post(
                rest_endpoint + '/workspaces/geonode/datastores/offline_osm/featuretypes?recalculate=nativebbox,latlonbbox',
            auth=('admin', 'geoserver'), # TODO : set this
                data=self.featuretype_xml.format(layername=layername),
                headers={'Content-type':'text/xml'}
            )
            if res.status_code==500 and res.text == "Resource named '{}' already exists in store: 'offline_osm'".format(layername):
                print('layer already exists')
            else:
                res.raise_for_status()
                print('layer successfully created')

    datastore_xml = '''
        <dataStore>
            <name>{datastore_name}</name>
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
