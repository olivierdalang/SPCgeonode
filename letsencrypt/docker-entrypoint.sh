#!/bin/sh

# Exit script in case of error
set -e

/renew-local.sh
/renew-certbot.sh

# Run the CMD 
exec "$@"
