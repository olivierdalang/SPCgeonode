#!/bin/sh

# Exit script in case of error
set -e

printf '\n--- START Django Docker Entrypoint ---\n\n'


# DEV : use installed geonode_offlineosm python library
pip install -e /offlineosm/


# Wait for postgres
printf '\nWaiting for postgres...\n'
printf "import sys,time,psycopg2\n\
from spcnode.settings import DATABASE_URL\n\
while 1:\n\
  try:\n\
    psycopg2.connect(DATABASE_URL)\n\
    print('Connection to postgres successful !')\n\
    sys.exit(0)\n\
  except Exception as e:\n\
    print('Could not connect to database. Retrying in 5s')\n\
    time.sleep(5)" | python -u

# Run migrations
printf '\nRunning migrations...\n'
python manage.py migrate --noinput

# Collect static
printf '\nRunning collectstatic...\n'
python manage.py collectstatic --noinput

# Createng superuser
printf '\nCreating superuser...\n'
# TODO : fix login
printf "import os, django\n\
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'spcnode.settings')\n\
django.setup()\n\
from geonode.people.models import Profile\n\
try:\n\
  user = Profile.objects.create_superuser('super','admin@test.com','duper')\n\
  print('superuser successfully created')\n\
except django.db.IntegrityError as e:\n\
  print('superuser exists already')" | python -u

# Load fixtures
printf '\nLoading initial data...\n'
python manage.py loaddata initial_data

# Creating OAuth2 data
# printf "print('todo')" | python -u

# Load initial osm data
# printf '\nInitialize offline osm data\n'
# python manage.py updateofflineosm --no_overwrite --no_fail # TODO : Remove Already done by the plugin post_migrate

# TODO : load also OAuth settings from http://docs.geonode.org/en/master/tutorials/admin/geoserver_geonode_security/

# http://127.0.0.1/geoserver
# http://127.0.0.1/geoserver/
# http://geoserver:8080/geoserver
# http://geoserver:8080/geoserver/

printf '\n--- END Django Docker Entrypoint ---\n\n'

# Run the CMD 
exec "$@"
