#!/bin/sh

# Exit script in case of error
set -e

# Initializing Django

# disabled, you have to rebuild when we change requirements
# # Install the migrations (in case requirements.txt changed but the image was not rebuilt)
# printf '\n\n\nInstalling python requirements\n'
# pip install -r /spcnode/requirements.txt

# Wait for postgres
printf '\n\n\nWaiting for postgres\n'
echo "import sys,time,psycopg2\nfrom spcnode.settings import DATABASE_URL\nwhile 1:\n  try:\n    psycopg2.connect(DATABASE_URL)\n    print('Connection to postgres successful !')\n    sys.exit(0)\n  except Exception as e:\n    print('Could not connect to database. Retrying in 5s')\n    print(str(e))\n    time.sleep(5)" | python

# Run migrations
printf '\n\n\nRunning migrations\n'
python manage.py migrate --noinput

# Collect static
printf '\n\n\nRunning collectstatic\n'
python manage.py collectstatic --noinput


# Initialize Geoserver
printf '\n\n\nWaiting for geoserver rest endpoint\n'
curl -u admin:geoserver -X GET -H "Content-type: text/xml" --retry 100000 --retry-connrefused --retry-delay 5 http://nginx/geoserver/rest/

curl -u admin:geoserver -X POST -H "Content-type: text/xml" -d "<workspace><name>geonode</name></workspace>" http://nginx/geoserver/rest/workspaces
# curl -v -u admin:geoserver -X PUT -H "Content-type: text/xml" -d "<workspace><name>geonode</name></workspace>" http://nginx/geoserver/rest/workspaces/default



# Run the CMD 
exec "$@"
