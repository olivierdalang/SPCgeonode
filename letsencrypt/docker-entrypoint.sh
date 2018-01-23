#!/bin/sh

# Exit script in case of error
set -e

# TODO : test this online



# LAN setup

printf "\n\nSetting up autoissued certificates for LAN Host ($LAN_HOST)\n"

if [ ! -f "/spcgeonode-certbot-keys/autoissued/$LAN_HOST/key" ] || [ ! -f "/spcgeonode-certbot-keys/autoissued/$LAN_HOST/cert" ]; then

    printf "\nNo existing certificates found... Creating placeholder certificates...\n"

    mkdir -p "/spcgeonode-certbot-keys/autoissued/$LAN_HOST/"
    openssl req -x509 -nodes -days 395 -newkey rsa:2048 -keyout "/spcgeonode-certbot-keys/autoissued/$LAN_HOST/key" -out "/spcgeonode-certbot-keys/autoissued/$LAN_HOST/cert" -subj "/CN=$LAN_HOST" 

else

    printf "\nExisting certificates found. We leave them in place as they will be updated by cron eventually.\n"

fi


# WAN setup

printf "\n\nSetting up certificates for WAN Host ($WAN_HOST)\n"

# If there are no certificates, we create a placeholder certificate while waiting for the real cerificates from certbot.
# This allows Nginx to start properly. The browser will display an alert because it doesn't like autoissued certificates though.
if [ ! -f "/spcgeonode-certbot-keys/live/$WAN_HOST/privkey.pem" ] || [ ! -f "/spcgeonode-certbot-keys/live/$WAN_HOST/fullchain.pem" ]; then

    printf "\nNo existing certificates found... Creating placeholder certificates...\n"
    
    mkdir -p "/spcgeonode-certbot-keys/autoissued/$WAN_HOST/"
    openssl req -x509 -nodes -days 0 -newkey rsa:2048 -keyout "/spcgeonode-certbot-keys/autoissued/$WAN_HOST/privkey.pem" -out "/spcgeonode-certbot-keys/autoissued/$WAN_HOST/fullchain.pem" -subj "/CN=$WAN_HOST"
    mkdir -p "/spcgeonode-certbot-keys/live/$WAN_HOST/"
    ln -s -f "/spcgeonode-certbot-keys/autoissued/$WAN_HOST/privkey.pem" "/spcgeonode-certbot-keys/live/$WAN_HOST/privkey.pem"
    ln -s -f "/spcgeonode-certbot-keys/autoissued/$WAN_HOST/fullchain.pem" "/spcgeonode-certbot-keys/live/$WAN_HOST/fullchain.pem"

else

    printf "\nExisting certificates found. We leave them in place as they will be updated by cron eventually.\n"

fi


printf "\nMaking sure Nginx is running\n"
# We need to make sure Nginx is running before getting the certificates because we must serve the challenge file
# TODO : can't we use healthcheck ?
mkdir -p /spcgeonode-certbot-challenge/.well-known/
echo 'ok' > /spcgeonode-certbot-challenge/.well-known/running.txt
curl --output /dev/null --head --fail --silent -S --retry 0 http://nginx/.well-known/running.txt

# TODO : remove --staging !
printf "\nGetting the certificates\n"
certbot --config-dir /spcgeonode-certbot-keys/ -vvv certonly --webroot -w /spcgeonode-certbot-challenge/ -d "$WAN_HOST" -m "$ADMIN_EMAIL" --agree-tos --non-interactive --staging

printf "\nTesting autorenew\n"
certbot --config-dir /spcgeonode-certbot-keys/ -vvv renew --dry-run

printf "\n\nInstalling cronjobs\n"
# notes : first one is letsencrypt (we run it twice a day), second one is autoissued (we renew every year, as it's duration is 365 days + 30 days)
( echo "0 0,12 * * * date && certbot renew" ; echo "0 0 1 1 * date && openssl req -x509 -nodes -days 395 -newkey rsa:2048 -keyout /spcgeonode-certbot-keys/autoissued/$LAN_HOST/key -out /spcgeonode-certbot-keys/autoissued/$LAN_HOST/cert -subj \"/CN=$LAN_HOST\"") | /usr/bin/crontab -
# We print the crontab just for debugging purposes
/usr/bin/crontab -l

# Run the CMD 
exec "$@"
