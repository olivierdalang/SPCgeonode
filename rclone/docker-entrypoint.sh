#!/bin/sh

# Exit script in case of error
set -e

printf "\n\nRunning sync once to see if config works"
/root/sync.sh

# Run the CMD 
exec "$@"
