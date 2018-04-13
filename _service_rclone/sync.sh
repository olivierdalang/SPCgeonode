#!/bin/sh

# Exit script in case of error
set -e

rclone sync -v --config /run/secrets/rclone.backup.conf /spcgeonode-geodatadir/ spcgeonode:/geodatadir/
rclone sync -v --config /run/secrets/rclone.backup.conf /spcgeonode-media/ spcgeonode:/media/
rclone sync -v --config /run/secrets/rclone.backup.conf /spcgeonode-pgdumps/ spcgeonode:/pgdumps/

printf "\nSync finished...\n"
