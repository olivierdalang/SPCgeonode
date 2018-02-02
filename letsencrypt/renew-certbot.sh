#!/bin/sh

# Exit script in case of error
set -e

##########################################
# WAN setup
##########################################

printf "\n\nSetting up certificates for WAN Host ($WAN_HOST)\n"

# We cleanup previously the certificate if it was a placeholder not created by certbot
if [ -f "/spcgeonode-certbot/live/$WAN_HOST/placeholder_flag" ]; then
    printf "\nDeleting previously create placeholder certificate\n"
    rm -rf /spcgeonode-certbot/live/$WAN_HOST/
fi

# We run the command
set +e # do not exist on fail
if [ "$LETSENCRYPT_MODE" == "staging" ]; then
    printf "\nTrying to get STAGING certificate\n"
    certbot --config-dir /spcgeonode-certbot/ certonly --webroot -w /spcgeonode-certbot/ -d "$WAN_HOST" -m "$ADMIN_EMAIL" --agree-tos --non-interactive --staging
elif [ "$LETSENCRYPT_MODE" == "production" ]; then
    printf "\nTrying to get PRODUCTION certificate\n"
    certbot --config-dir /spcgeonode-certbot/ certonly --webroot -w /spcgeonode-certbot/ -d "$WAN_HOST" -m "$ADMIN_EMAIL" --agree-tos --non-interactive
else
    printf "\nNot trying to get certificate (simulating failure, because LETSENCRYPT_MODE variable was neither staging nor production\n"
    /bin/false
fi

# If the certbot comand failed, we will create a placeholder certificate
if [ ! $? -eq 0 ]; then
    set -e

    printf "\nFailed to get the certificates ! We create a placeholder certificate\n"
    
    mkdir -p "/spcgeonode-certbot/live/$WAN_HOST/"
    openssl req -x509 -nodes -days 1 -newkey rsa:2048 -keyout "/spcgeonode-certbot/live/$WAN_HOST/privkey.pem" -out "/spcgeonode-certbot/live/$WAN_HOST/fullchain.pem" -subj "/CN=PLACEHOLDER"
    touch "/spcgeonode-certbot/live/$WAN_HOST/placeholder_flag"

    printf "\nWaiting 30s to avoid hitting Letsencrypt rate limits if restarting too soon in case of failure\n"
    sleep 30

    exit 1
fi

set -e
printf "\nCertificate have been create/renewed successfully\n"    
