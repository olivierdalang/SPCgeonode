#!/bin/sh

# Exit script in case of error
set -e

echo $"\n\n\n"
echo "-----------------------------------------------------"
echo "STARTING RCLONE ENTRYPOINT --------------------------"
date

printf "\n\nRunning sync once to see if config works"
/root/sync.sh

echo "-----------------------------------------------------"
echo "FINISHED RCLONE ENTRYPOINT --------------------------"
echo "-----------------------------------------------------"

# Run the CMD 
exec "$@"
