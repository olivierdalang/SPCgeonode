import os
from geonode.settings import *

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Can be removed after geonode>=2.7.x as it will be like this in main settings
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS').split(',')

# Apps that should be prepended to INSTALLED APPS
SPCNODE_APPS = (
    'customization_sample',
    'offline_osm',
    
    'overextends', # we use this to be able to override templates still extending the parent template
)

INSTALLED_APPS = SPCNODE_APPS + INSTALLED_APPS 

# Because of https://github.com/GeoNode/geonode/issues/3520 we need to manually add our templates/static folders so that they can override static files/templatest
for app in reversed(SPCNODE_APPS):
    tpl_dir = os.path.join(BASE_DIR, app,'templates')
    stc_dir = os.path.join(BASE_DIR, app,'static')
    if os.path.exists(tpl_dir):
        TEMPLATES[0]["DIRS"] = [tpl_dir] + TEMPLATES[0]["DIRS"]
    if os.path.exists(stc_dir):
        STATICFILES_DIRS = [stc_dir] + STATICFILES_DIRS


ROOT_URLCONF = os.getenv('ROOT_URLCONF', 'spcnode.urls')



# TEMPLATES["DIRS"] += ['../templates']


#
# General Django development settings
#

# SITENAME = 'spcnode'

# LOCAL_ROOT = os.path.abspath(os.path.dirname(__file__))

# WSGI_APPLICATION = "spcnode.wsgi.application"

# DEBUG = True


# # Load more settings from a file called local_settings.py if it exists
# try:
#     from local_settings import *
# except ImportError:
#     pass

# # Additional directories which hold static files
# STATICFILES_DIRS.append(
#     os.path.join(LOCAL_ROOT, "static"),
# )

# # Location of url mappings
# ROOT_URLCONF = 'spcnode.urls'

# # Location of locale files
# LOCALE_PATHS = (
#     os.path.join(LOCAL_ROOT, 'locale'),
#     ) + LOCALE_PATHS

# INSTALLED_APPS = INSTALLED_APPS + ('spcnode',)

# TEMPLATES[0]['DIRS'].insert(0, os.path.join(LOCAL_ROOT, "templates"))