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
# Customization for Tonga
##################################

# Install
ADDITIONNAL_INSTALLED_APPS = ('tonga',)

##################################
# Misc / debug / hack
##################################

# Add our additionnal installed apps
INSTALLED_APPS = INSTALLED_APPS + ADDITIONNAL_INSTALLED_APPS

# Can be removed after geonode>=2.7.x as it will be like this in main settings
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS').split(',')

# We define SITE_URL to HTTPS_HOST if it is set, or else to HTTP_HOST
if os.getenv('SITEURL'):
    SITEURL = os.getenv('SITEURL')
elif os.getenv('HTTPS_HOST'):
    SITEURL = 'https://'+os.getenv('HTTPS_HOST')
elif os.getenv('HTTP_HOST'):
    SITEURL = 'http://'+os.getenv('HTTP_HOST')
else:
    raise Exception("Misconfiguration error. You need to set at least one of SITEURL, HTTPS_HOST or HTTP_HOST")

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

# Because of https://github.com/GeoNode/geonode/issues/3520 we need to manually add our templates/static folders so that they can override static files/templatest
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for app in reversed(ADDITIONNAL_INSTALLED_APPS):
    tpl_dir = os.path.join(BASE_DIR, app,'templates')
    stc_dir = os.path.join(BASE_DIR, app,'static')
    if os.path.exists(tpl_dir):
        TEMPLATES[0]["DIRS"] = [tpl_dir] + TEMPLATES[0]["DIRS"]
    if os.path.exists(stc_dir):
        STATICFILES_DIRS = [stc_dir] + STATICFILES_DIRS
