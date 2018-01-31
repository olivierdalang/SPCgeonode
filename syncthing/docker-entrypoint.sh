#!/bin/sh

# Exit script in case of error
set -e

printf "\n\nReplacing environement variables"
export ADMIN_USERNAME=`cat /run/secrets/admin_username`
export ADMIN_PASSWORD=`python -c 'import bcrypt; print(bcrypt.hashpw(open("/run/secrets/admin_password").read(), bcrypt.gensalt()))'`
envsubst '\$REMOTE_SYNCTHING_MACHINE_ID \$ADMIN_USERNAME \$ADMIN_PASSWORD' < /root/.config/syncthing/config.xml.template > /root/.config/syncthing/config.xml
export ADMIN_USERNAME=""
export ADMIN_PASSWORD=""

# Run the CMD 
exec "$@"

