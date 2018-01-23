#!/bin/sh

# Exit script in case of error
set -e

# TODO : test this online



# LAN setup

printf "\n\nSetting up autoissued certificates for LAN Host ($LAN_HOST)\n"

mkdir -p "/etc/letsencrypt/autoissued/$LAN_HOST/"
openssl req -x509 -nodes -days 395 -newkey rsa:2048 -keyout "/etc/letsencrypt/autoissued/$LAN_HOST/key" -out "/etc/letsencrypt/autoissued/$LAN_HOST/cert" -subj "/CN=$LAN_HOST" 



# WAN setup

printf "\n\nSetting up certificates for WAN Host ($WAN_HOST)\n"

# If there are no certificates, we create a placeholder certificate while waiting for the real cerificates from certbot.
# This allows Nginx to start properly. The browser will display an alert because it doesn't like autoissued certificates though.
if [ ! -f "/etc/letsencrypt/live/$WAN_HOST/privkey.pem" ] || [ ! -f "/etc/letsencrypt/live/$WAN_HOST/privkey.pem" ]; then

    printf "\nNo existing certificates found... Creating placeholder certificates...\n"
    
    mkdir -p "/etc/letsencrypt/autoissued/$WAN_HOST/"
    openssl req -x509 -nodes -days 0 -newkey rsa:2048 -keyout "/etc/letsencrypt/autoissued/$WAN_HOST/privkey.pem" -out "/etc/letsencrypt/autoissued/$WAN_HOST/fullchain.pem" -subj "/CN=$WAN_HOST"
    mkdir -p "/etc/letsencrypt/live/$WAN_HOST/"
    ln -rf "/etc/letsencrypt/autoissued/$WAN_HOST/privkey.pem" "/etc/letsencrypt/live/$WAN_HOST/privkey.pem"
    ln -rf "/etc/letsencrypt/autoissued/$WAN_HOST/fullchain.pem" "/etc/letsencrypt/live/$WAN_HOST/fullchain.pem"

else

    printf "\nExisting certificates found.\n"

fi


printf "\nWaiting for Nginx to launch Certbox\n"
# We create a file to see if Nginx is up and running.
# We need Nginx to be running beore we run certbot because of the challenge (let's encrypt will try to find a challenge file on the host)
mkdir -p "/spcgeonode-certbot-challenge/.well-known/"
echo "ok" > /spcgeonode-certbot-challenge/.well-known/online.txt

curl --output /dev/null --head --fail -S --retry 10 --retry-delay 10 http://nginx/.well-known/online.txt
if [ $? -eq 0 ]; then
    # If we can connect, we run certbot
    printf "\nConnection to Nginx sucessful. We run certbox.\n"

    # Certbot may fail
    # TODO : remove --staging !
    set +e
    certbot certonly --webroot -w /spcgeonode-certbot-challenge/ -d "$WAN_HOST" -m "$ADMIN_EMAIL" --agree-tos --non-interactive --staging
    if [ $? -eq 0 ]; then
        set -e
        printf "\nTesting autorenew\n"
        certbot renew --dry-run
    else
        set -e
        printf "\nCertbot failed. This is /var/log/letsencrypt/letsencrypt.log:\n\n\n"
        cat /var/log/letsencrypt/letsencrypt.log
        printf "\n\n\n***We won't have real SSL certificates.***\n"
    fi


else
    # If we can connect, we run certbot
    printf "\nCould not connect to Nginx.\n***We won't have real SSL certificates.***\n"

fi


printf "\n\nInstalling cronjobs\n"

# notes : first one is letsencrypt (we run it twice a day), second one is autoissued (we renew every year, as it's duration is 365 days + 30 days)
( echo "0 0,12 * * * date && certbot renew" ; echo "0 0 1 1 * date && openssl req -x509 -nodes -days 395 -newkey rsa:2048 -keyout /etc/letsencrypt/autoissued/$LAN_HOST/key -out /etc/letsencrypt/autoissued/$LAN_HOST/cert -subj \"/CN=$LAN_HOST\"") | /usr/bin/crontab -
# We print the crontab just for debugging purposes
/usr/bin/crontab -l

# Run the CMD 
exec "$@"
