import os
from geonode.settings import *


##################################
# Basic config
##################################

ROOT_URLCONF = os.getenv('ROOT_URLCONF', 'spcgeonode.urls')


##################################
# Geoserver fix admin password
##################################

# TODO : reenable this once login works
# OGC_SERVER['default']['USER'] = open('/run/secrets/admin_username','r').read()
# OGC_SERVER['default']['PASSWORD'] = open('/run/secrets/admin_password','r').read()

# TODO : this is needed in 2.6.3 as it's not set by default, but is set by default in 2.6.x (?!!!)
OGC_SERVER['default']['GEOFENCE_SECURITY_ENABLED'] = True

##################################
# Misc / debug / hack
##################################

# We use a relative URL because we want to keep scheme/host
# TODO : see if this has no side effects / maybe put it in Docker env
SITEURL = os.getenv('SITEURL', "/")

# Can be removed after geonode>=2.7.x as it will be like this in main settings
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS').split(',')

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