#!/bin/sh

# Exit script in case of error
set -e

# TODO : test this online

printf "\n\nInstalling placeholder certs\n"
# Since certbot mail fail for some reason, we don't want the whole config to break. We create autoissued certificates that will then be replace if certbot works.
# TODO : configurize admin hostname
mkdir -p "/etc/letsencrypt/live/$WAN_HOST/"
openssl req -x509 -nodes -days 0 -newkey rsa:2048 -keyout "/etc/letsencrypt/live/$WAN_HOST/privkey.pem" -out "/etc/letsencrypt/live/$WAN_HOST/fullchain.pem" -subj "/CN=$WAN_HOST"

printf "\n\nInstalling certbot\n"
# TODO : configurize admin email and hostname
# certbot certonly --webroot -w /spcgeonode-certbot-challenge/ -d "$WAN_HOST" -m "$ADMIN_EMAIL" --agree-tos --non-interactive

printf "\n\nTesting autorenew\n"
certbot renew --dry-run

printf "\n\nCreating autoissued certificate (for LAN)\n"
mkdir -p /etc/letsencrypt/autoissued/
# TODO : configurize LAN HOSTNAME
openssl req -x509 -nodes -days 395 -newkey rsa:2048 -keyout /etc/letsencrypt/autoissued/key -out /etc/letsencrypt/autoissued/cert -subj "/CN=$LAN_HOST" 

printf "\n\nInstalling cronjobs\n"

# Install the cronjobs # TODO : remove dry run !!
# notes : first one is letsencrypt (we run it twice a day), second one is autoissued (we renew every year, as it's duration is 365 days + 30 days)
( echo "0 0,12 * * * date && certbot renew" ; echo "0 0 1 1 * date && openssl req -x509 -nodes -days 395 -newkey rsa:2048 -keyout /etc/letsencrypt/autoissued/key -out /etc/letsencrypt/autoissued/cert -subj \"/CN=$LAN_HOST\"") | /usr/bin/crontab - # TODO : configurize LAN HOSTNAME
/usr/bin/crontab -l

# Run the CMD 
exec "$@"
