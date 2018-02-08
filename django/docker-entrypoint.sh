#!/bin/sh

# Exit script in case of error
set -e

printf '\n--- START Django Docker Entrypoint ---\n\n'

# Run migrations
printf '\nRunning migrations...\n'
python -u manage.py migrate --noinput

# Collect static
printf '\nRunning collectstatic...\n'
python -u manage.py collectstatic --noinput

# Creating superuser if it doesn't exist
printf '\nCreating superuser...\n'
printf "import os, django\n\
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'spcgeonode.settings')\n\
django.setup()\n\
from geonode.people.models import Profile\n\
try:\n\
  user = Profile.objects.create_superuser(open('/run/secrets/admin_username','r').read(),os.getenv('ADMIN_EMAIL'),open('/run/secrets/admin_password','r').read())\n\
  print('superuser successfully created')\n\
except django.db.IntegrityError as e:\n\
  print('superuser exists already')" | python -u

# Create an OAuth2 provider to use authorisations keys
printf '\nCreating oauth2 provider...\n'
printf "import os, django\n\
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'spcgeonode.settings')\n\
django.setup()\n\
from oauth2_provider.models import Application\n\
try:\n\
  app = Application.objects.create(pk=1,name='GeoServer',client_type='confidential',authorization_grant_type='authorization-code')\n\
  print('oauth2 provider successfully created')\n\
except django.db.IntegrityError as e:\n\
  print('oauth2 provider exists already')" | python -u

# Load fixtures
printf '\nLoading initial data...\n'
python manage.py loaddata initial_data

printf '\n--- END Django Docker Entrypoint ---\n\n'

# Run the CMD 
exec "$@"
