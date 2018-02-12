#!/bin/sh

# Exit script in case of error
set -e

# Assert the local certificate exists
if [ ! -f "/spcgeonode-certbot/autoissued/$LAN_HOST/key" ]; then
    exit 1
fi
if [ ! -f "/spcgeonode-certbot/autoissued/$LAN_HOST/cert" ]; then
    exit 1
fi

# Assert the certbot certificate exists and they are not temporary
if [ ! -f "/spcgeonode-certbot/live/$WAN_HOST/key" ]; then
    exit 1
fi
if [ ! -f "/spcgeonode-certbot/live/$WAN_HOST/cert" ]; then
    exit 1
fi
if [ -f "/spcgeonode-certbot/live/$WAN_HOST/placeholder_flag" ]; then
    exit 1
fi
