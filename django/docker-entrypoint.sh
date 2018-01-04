#!/bin/sh

# Exit script in case of error
set -e

printf '\n--- START Django Docker Entrypoint ---\n'

# Initializing Django

# disabled, you have to rebuild when we change requirements
# # Install the migrations (in case requirements.txt changed but the image was not rebuilt)
# printf '\nInstalling python requirements\n'
# pip install -r /spcnode/requirements.txt

# Wait for postgres
printf '\nWaiting for postgres\n'
echo "import sys,time,psycopg2\nfrom spcnode.settings import DATABASE_URL\nwhile 1:\n  try:\n    psycopg2.connect(DATABASE_URL)\n    print('Connection to postgres successful !')\n    sys.exit(0)\n  except Exception as e:\n    print('Could not connect to database. Retrying in 5s')\n    print(str(e))\n    time.sleep(5)" | python

# Run migrations
printf '\nRunning migrations\n'
python manage.py migrate --noinput

# Load fixtures
printf '\nLoading initial data\n'
python manage.py loaddata initial_data

# Collect static
printf '\nRunning collectstatic\n'
python manage.py collectstatic --noinput

# Createng superuser
printf '\nCreating superuser\n'
# TODO : fix login
echo "import os, django\nos.environ.setdefault('DJANGO_SETTINGS_MODULE', 'spcnode.settings')\ndjango.setup()\nfrom geonode.people.models import Profile\ntry:\n  user = Profile.objects.create_superuser('super','admin@test.com','duper')\n  print('superuser successfully created')\nexcept django.db.IntegrityError as e:\n  print('superuser exists already')" | python

# Initialize Geoserver (this waits for geonode and creates the geonode workspace if it doesn't exist)
printf '\nWaiting for geoserver rest endpoint and creating workspace if needed\n'
# TODO : workspace name is DEFAULT_WORKSPACE
curl -u admin:geoserver -o /dev/null -s -X POST -H "Content-type: text/xml" -d "<workspace><name>geonode</name></workspace>" --retry 100000 --retry-connrefused --retry-delay 5 http://nginx/geoserver/rest/workspaces

printf '\n--- END Django Docker Entrypoint ---\n\n'

# Run the CMD 
exec "$@"
