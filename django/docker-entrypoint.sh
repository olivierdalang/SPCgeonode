#!/bin/sh

# Exit script in case of error
set -e

# disabled, you have to rebuild when we change requirements
# # Install the migrations (in case requirements.txt changed but the image was not rebuilt)
# printf '\n\n\nInstalling python requirements\n'
# pip install -r /spcnode/requirements.txt

# Wait for postgres
echo "import sys,time,psycopg2\nfrom spcnode.settings import DATABASE_URL\nwhile 1:\n  try:\n    psycopg2.connect(DATABASE_URL)\n    print('Connection to postgres successful !')\n    sys.exit(0)\n  except Exception as e:\n    print('Could not connect to database. Retrying in 5s')\n    print(str(e))\n    time.sleep(5)" | python

# Run migrations
printf '\n\n\nRunning migrations\n'
python manage.py migrate --noinput

# Collect static
printf '\n\n\nRunning collectstatic\n'
python manage.py collectstatic --noinput

# Run the CMD 
exec "$@"
