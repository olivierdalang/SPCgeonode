#!/bin/sh

# Exit script in case of error
set -e

printf '\n--- START Celery Docker Entrypoint ---\n\n'


# DEV : use installed geonode_offlineosm python library
# pip install -e /offlineosm/


printf '\n--- END Celery Docker Entrypoint ---\n\n'

# nohup python manage.py celerycam

# Run the CMD 
exec "$@"
