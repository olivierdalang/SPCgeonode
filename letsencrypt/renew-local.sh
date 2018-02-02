#!/bin/sh

# Exit script in case of error
set -e

##########################################
# LAN setup
##########################################

printf "\n\nSetting up certificates for LAN Host ($LAN_HOST)\n"

mkdir -p "/spcgeonode-certbot/autoissued/$LAN_HOST/"
openssl req -x509 -nodes -days 395 -newkey rsa:2048 -keyout "/spcgeonode-certbot/autoissued/$LAN_HOST/privkey.pem" -out "/spcgeonode-certbot/autoissued/$LAN_HOST/fullchain.pem" -subj "/CN=$LAN_HOST" 
