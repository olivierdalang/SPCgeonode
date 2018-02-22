"""
This script initializes Geonode
"""

#########################################################
# Setting up the  context
#########################################################

import os, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'spcgeonode.settings')
django.setup()


#########################################################
# Imports
#########################################################

from django.core.management import call_command
from geonode.people.models import Profile
from oauth2_provider.models import Application


#########################################################
# 1. Running the migrations
#########################################################

print("-"*80 + "\n1. Running the migrations")
call_command('migrate', '--noinput')


#########################################################
# 2. Collecting static files
#########################################################

print("-"*80 + "\n2. Collecting static files")
call_command('collectstatic', '--noinput')


#########################################################
# 3. Creating superuser if it doesn't exist
#########################################################

print("-"*80 + "\n3. Creating superuser if it doesn't exist")
try:
    superuser = Profile.objects.create_superuser(
        open('/run/secrets/admin_username','r').read(),
        os.getenv('ADMIN_EMAIL'),
        open('/run/secrets/admin_password','r').read()
    )
    print('superuser successfully created')    
    print('disabling old superusers if any')
    Profile.objects.filter(is_superuser=True).exclude(pk=superuser.pk).update(is_active=False)
except django.db.IntegrityError as e:
    print('superuser exists already')


#########################################################
# 4. Create an OAuth2 provider to use authorisations keys
#########################################################

print("-"*80 + "\n4. Create an OAuth2 provider to use authorisations keys")
try:
    app = Application.objects.create(
        pk=1,
        name='GeoServer',
        client_type='confidential',
        authorization_grant_type='authorization-code'
    )
    print('oauth2 provider successfully created')
except django.db.IntegrityError as e:
    print('oauth2 provider exists already')


#########################################################
# 5. Loading fixtures
#########################################################

print("-"*80 + "\n5. Loading fixtures")
call_command('loaddata', 'initial_data')
