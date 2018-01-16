#!/bin/sh

# Exit script in case of error
set -e

printf "\n\nLoading nginx autoreloader\n"
sh /docker-autoreload.sh &

printf "\n\nReplacing environement variables"
envsubst '\$LAN_HOST \$WAN_HOST' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

cat /etc/nginx/nginx.conf

# Run the CMD 
exec "$@"
