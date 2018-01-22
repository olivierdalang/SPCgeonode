import os
from geonode.settings import *


##################################
# Basic config
##################################

ROOT_URLCONF = os.getenv('ROOT_URLCONF', 'spcgeonode.urls')


##################################
# Geoserver fix admin password
##################################

OGC_SERVER['default']['USER'] = open('/run/secrets/admin_username','r').read()
OGC_SERVER['default']['PASSWORD'] = open('/run/secrets/admin_password','r').read()


##################################
# Misc / debug / hack
##################################

# Can be removed after geonode>=2.7.x as it will be like this in main settings
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS').split(',')
