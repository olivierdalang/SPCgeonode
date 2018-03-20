#!/bin/sh

# Exit script in case of error
set -e

echo '--- START Django Docker Entrypoint ---'

# Run migrations
echo 'Running initialize.py...'
python -u initialize.py

echo '--- END Django Docker Entrypoint ---'

# Run the CMD 
exec "$@"
