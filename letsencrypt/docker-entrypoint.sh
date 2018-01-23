#!/bin/sh

# Exit script in case of error
set -e

# TODO : test this online



# LAN setup

printf "\n\nSetting up autoissued certificates for LAN Host ($LAN_HOST)\n"

if [ ! -f "/spcgeonode-certbot/autoissued/$LAN_HOST/key" ] || [ ! -f "/spcgeonode-certbot/autoissued/$LAN_HOST/cert" ]; then

    printf "\nNo existing certificates found... Creating placeholder certificates...\n"

    mkdir -p "/spcgeonode-certbot/autoissued/$LAN_HOST/"
    openssl req -x509 -nodes -days 395 -newkey rsa:2048 -keyout "/spcgeonode-certbot/autoissued/$LAN_HOST/privkey.pem" -out "/spcgeonode-certbot/autoissued/$LAN_HOST/fullchain.pem" -subj "/CN=$LAN_HOST" 

else

    printf "\nExisting certificates found. We leave them in place as they will be updated by cron eventually.\n"

fi


# WAN setup

printf "\n\nSetting up certificates for WAN Host ($WAN_HOST)\n"

# If there are no certificates, we create a placeholder certificate while waiting for the real cerificates from certbot.
# This allows Nginx to start properly. The browser will display an alert because it doesn't like autoissued certificates though.
if [ ! -f "/spcgeonode-certbot/live/$WAN_HOST/privkey.pem" ] || [ ! -f "/spcgeonode-certbot/live/$WAN_HOST/fullchain.pem" ]; then

    printf "\nNo existing certificates found... Creating placeholder certificates...\n"
    
    mkdir -p "/spcgeonode-certbot/autoissued/$WAN_HOST/"
    openssl req -x509 -nodes -days 0 -newkey rsa:2048 -keyout "/spcgeonode-certbot/autoissued/$WAN_HOST/privkey.pem" -out "/spcgeonode-certbot/autoissued/$WAN_HOST/fullchain.pem" -subj "/CN=$WAN_HOST"

    mkdir -p "/spcgeonode-certbot/live/$WAN_HOST/"
    # We use cp instead of ln so that it works in mounted volumes
    cp "/spcgeonode-certbot/autoissued/$WAN_HOST/privkey.pem" "/spcgeonode-certbot/live/$WAN_HOST/privkey.pem"
    cp "/spcgeonode-certbot/autoissued/$WAN_HOST/fullchain.pem" "/spcgeonode-certbot/live/$WAN_HOST/fullchain.pem"

    mkdir -p "/spcgeonode-certbot/renewal/"
    printf "# renew_before_expiry = 30 days\nversion = 0.14.0\narchive_dir = /spcgeonode-certbot-keys/archive/$WAN_HOST\ncert = /spcgeonode-certbot-keys/live/$WAN_HOST/cert.pem\nprivkey = /spcgeonode-certbot-keys/live/$WAN_HOST/privkey.pem\nchain = /spcgeonode-certbot-keys/live/$WAN_HOST/chain.pem\nfullchain = /spcgeonode-certbot-keys/live/$WAN_HOST/fullchain.pem\n\n# Options used in the renewal process\n[renewalparams]\naccount = 1ec590e83d054f0b0678e9b8c6bf6167\nconfig_dir = /spcgeonode-certbot\nserver = https://acme-staging.api.letsencrypt.org/directory\nauthenticator = webroot\ninstaller = None\nwebroot_path = /spcgeonode-certbot,\n[[webroot_map]]\n$WAN_HOST = /spcgeonode-certbot" > "/spcgeonode-certbot/renewal/$WAN_HOST.conf"


else

    printf "\nExisting certificates found. We leave them in place as they will be updated by cron eventually.\n"

fi


printf "\nWaiting 20s to avoid hitting Letsencrypt rate limits if restarting in case of failure\n"
sleep 20

printf "\nGetting the certificates\n"
certbot --config-dir /spcgeonode-certbot/ -vvv certonly --webroot -w /spcgeonode-certbot/ -d "$WAN_HOST" -m "$ADMIN_EMAIL" --agree-tos --non-interactive --staging

printf "\nTesting autorenew\n"
certbot --config-dir /spcgeonode-certbot/ -vvv renew --dry-run



# Cron jobs

printf "\n\nInstalling cronjobs\n"

# notes : first one is letsencrypt (we run it twice a day), second one is autoissued (we renew every year, as it's duration is 365 days + 30 days)
( echo "0 0,12 * * * date && certbot renew" ; echo "0 0 1 1 * date && openssl req -x509 -nodes -days 395 -newkey rsa:2048 -keyout /spcgeonode-certbot/autoissued/$LAN_HOST/privkey.pem -out /spcgeonode-certbot/autoissued/$LAN_HOST/fullchain.pem -subj \"/CN=$LAN_HOST\"") | /usr/bin/crontab -
# We print the crontab just for debugging purposes
/usr/bin/crontab -l

# Run the CMD 
exec "$@"
