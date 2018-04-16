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

# TODO : this is needed in 2.6.3 as it's not set by default, but is set by default in 2.6.x (?!!!)
OGC_SERVER['default']['GEOFENCE_SECURITY_ENABLED'] = True

##################################
# Misc / debug / hack
##################################

# Can be removed after geonode>=2.7.x as it will be like this in main settings
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS').split(',')

# We define SITE_URL to HTTPS_HOST if it is set, or else to HTTP_HOST
if os.getenv('HTTPS_HOST'):
    SITEURL = 'https://{url}{port}/'.format(
        url=os.getenv('HTTPS_HOST'),
        port=':'+os.getenv('HTTPS_PORT') if os.getenv('HTTPS_PORT') != '443' else '',
    )
elif os.getenv('HTTP_HOST'):
    SITEURL = 'http://{url}{port}/'.format(
        url=os.getenv('HTTP_HOST'),
        port=':'+os.getenv('HTTP_PORT') if os.getenv('HTTP_PORT') != '80' else '',
    )
else:
    raise Exception("Misconfiguration error. You need to set at least one of HTTPS_HOST or HTTP_HOST")

# Manually replace SITEURL whereever it is used in geonode's settings.py
# OGC_SERVER['default']['LOCATION'] = 'http://nginx/geoserver/' # this is already set as ENV var in the dockerfile
OGC_SERVER['default']['PUBLIC_LOCATION'] = SITEURL + '/geoserver/'
CATALOGUE['default']['URL'] = '%scatalogue/csw' % SITEURL
PYCSW['CONFIGURATION']['metadata:main']['provider_url'] = SITEURL

# We set our custom geoserver password hashers
PASSWORD_HASHERS = (
    'spcgeonode.hashers.GeoserverDigestPasswordHasher',
    'django.contrib.auth.hashers.PBKDF2PasswordHasher',
    'django.contrib.auth.hashers.PBKDF2SHA1PasswordHasher',
    'django.contrib.auth.hashers.BCryptSHA256PasswordHasher',
    'django.contrib.auth.hashers.BCryptPasswordHasher',
    'django.contrib.auth.hashers.SHA1PasswordHasher',
    'django.contrib.auth.hashers.MD5PasswordHasher',
    'django.contrib.auth.hashers.CryptPasswordHasher',
    'spcgeonode.hashers.GeoserverPlainPasswordHasher',
)
