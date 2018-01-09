import os
from geonode.settings import *
from datetime import timedelta



# Can be removed after geonode>=2.7.x as it will be like this in main settings
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS').split(',')

# Apps that should be prepended to INSTALLED APPS
SPCNODE_APPS = (
    'app_customization_sample',

    # 'geonode_offlineosm',
    
    'overextends', # we use this to be able to override templates still extending the parent template
)

INSTALLED_APPS = SPCNODE_APPS + INSTALLED_APPS 



OFFLINE_OSM_UPDATE_INTERVAL = 1 # TODO : remove this
OFFLINE_OSM_DATA_DIR = '/spcnode-media/urlretrieve/' # TODO : remove this ?
OFFLINE_OSM_UPDATE_AFTER_MIGRATE = False

# CELERY_IMPORTS = CELERY_IMPORTS + ('geonode_offlineosm.tasks',)
CELERY_ALWAYS_EAGER = False




# Because of https://github.com/GeoNode/geonode/issues/3520 we need to manually add our templates/static folders so that they can override static files/templatest
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for app in reversed(SPCNODE_APPS):
    tpl_dir = os.path.join(BASE_DIR, app,'templates')
    stc_dir = os.path.join(BASE_DIR, app,'static')
    if os.path.exists(tpl_dir):
        TEMPLATES[0]["DIRS"] = [tpl_dir] + TEMPLATES[0]["DIRS"]
    if os.path.exists(stc_dir):
        STATICFILES_DIRS = [stc_dir] + STATICFILES_DIRS


ROOT_URLCONF = os.getenv('ROOT_URLCONF', 'spcnode.urls')


# GOOGLE SATELLITE
MAP_BASELAYERS.append(
    {
        "source": {
            "ptype":"gxp_googlesource",
            "apiKey": 'AIzaSyCU29B1mM_p5vBnys6v9EuEUIKKMknecHQ'
            },
        "group":"background",
        "name":"SATELLITE",
        "visibility": False,
        "fixed": True,
    }
)
