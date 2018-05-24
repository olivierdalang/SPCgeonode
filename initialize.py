"""
This script initializes Geonode
"""

#########################################################
# Setting up the  context
#########################################################

import os, requests, json, uuid, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'spcgeonode.settings')
django.setup()


#########################################################
# Imports
#########################################################

from django.core.management import call_command
from geonode.people.models import Profile
from oauth2_provider.models import Application
from django.conf import settings

# Getting the secrets
admin_username = open('/run/secrets/admin_username','r').read()
admin_password = open('/run/secrets/admin_password','r').read()


#########################################################
# 1. Running the migrations
#########################################################

print("-"*80 + "\n1. Running the migrations")
call_command('migrate', '--noinput')


#########################################################
# 2. Creating superuser if it doesn't exist
#########################################################

print("-"*80 + "\n2. Creating/updating superuser")
try:
    superuser = Profile.objects.create_superuser(
        admin_username,
        os.getenv('ADMIN_EMAIL'),
        admin_password
    )
    print('superuser successfully created')    
except django.db.IntegrityError as e:
    superuser = Profile.objects.get(username=admin_username)
    superuser.set_password(admin_password)
    superuser.is_active = True
    superuser.email = os.getenv('ADMIN_EMAIL')
    superuser.save()
    print('superuser successfully updated')


#########################################################
# 3. Create an OAuth2 provider to use authorisations keys
#########################################################

print("-"*80 + "\n3. Create/update an OAuth2 provider to use authorisations keys")
app, created = Application.objects.get_or_create(
    pk=1,
    name='GeoServer',
    client_type='confidential',
    authorization_grant_type='authorization-code'
)
redirect_uris = [
    'http://{}/geoserver'.format(os.getenv('HTTPS_HOST',"") if os.getenv('HTTPS_HOST',"") != "" else os.getenv('HTTP_HOST')),
    'http://{}/geoserver/index.html'.format(os.getenv('HTTPS_HOST',"") if os.getenv('HTTPS_HOST',"") != "" else os.getenv('HTTP_HOST')),
]
app.redirect_uris = "\n".join(redirect_uris)
app.save()
if created:
    print('oauth2 provider successfully created')
else:
    print('oauth2 provider successfully updated')


#########################################################
# 4. Loading fixtures
#########################################################

print("-"*80 + "\n4. Loading fixtures")
call_command('loaddata', 'initial_data')


#########################################################
# 5. Running updatemaplayerip
#########################################################

print("-"*80 + "\n5. Running updatemaplayerip")
# call_command('updatelayers') # TODO CRITICAL : this overrides the layer thumbnail of existing layers even if unchanged !!!
call_command('updatemaplayerip')


#########################################################
# 6. Collecting static files
#########################################################

print("-"*80 + "\n6. Collecting static files")
call_command('collectstatic', '--noinput')


#########################################################
# 7. Securing GeoServer
#########################################################

print("-"*80 + "\n7. Securing GeoServer")

# Getting the old password
r1 = requests.get('http://geoserver:8080/geoserver/rest/security/masterpw.json', auth=(admin_username, admin_password))
r1.raise_for_status()
old_password = json.loads(r1.text)["oldMasterPassword"]

if old_password=='M(cqp{V1':
    print("Randomizing master password")
    new_password = uuid.uuid4().hex
    data = json.dumps({"oldMasterPassword":old_password,"newMasterPassword":new_password})
    r2 = requests.put('http://geoserver:8080/geoserver/rest/security/masterpw.json', data=data, headers={'Content-Type': 'application/json'}, auth=(admin_username, admin_password))
    r2.raise_for_status()
else:
    print("Master password was already changed. No changes made.")
