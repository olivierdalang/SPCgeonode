#!/bin/sh

# Exit script in case of error
set -e

printf "\n\nReplacing environement variables"
envsubst '\$LAN_HOST \$WAN_HOST' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

printf "\n\nLoading nginx autoreloader\n"
sh /docker-autoreload.sh &


printf "\n\nPrinting configuration for debug purposes\n"
cat /etc/nginx/nginx.conf

# Run the CMD 
exec "$@"
