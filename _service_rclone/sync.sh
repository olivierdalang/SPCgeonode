#!/bin/sh

# Exit script in case of error
set -e

export AWS_ACCESS_KEY=`cat /run/secrets/aws_access_key`
export AWS_SECRET_KEY=`cat /run/secrets/aws_secret_key`

printf "\n\nReplacing environement variables\n\n"
envsubst '\$AWS_BUCKET_NAME \$AWS_BUCKET_REGION' < /root/rclone.conf.template > /root/rclone.conf

rclone sync -v --config /root/rclone.conf /spcgeonode-geodatadir/ $AWS_BUCKET_NAME:$AWS_BUCKET_NAME/geodatadir/
rclone sync -v --config /root/rclone.conf --exclude "thumbs/*" --delete-excluded /spcgeonode-media/ $AWS_BUCKET_NAME:$AWS_BUCKET_NAME/media/
rclone sync -v --config /root/rclone.conf /spcgeonode-pgdumps/ $AWS_BUCKET_NAME:$AWS_BUCKET_NAME/pgdumps/

export AWS_ACCESS_KEY=""
export AWS_SECRET_KEY=""

printf "\nSync finished...\n"
