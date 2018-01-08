#!/bin/sh

# Exit script in case of error
set -e

printf '\n--- START Geoserver Docker Entrypoint ---\n'

# Run migrations
printf '\nInitializing data dir\n'
if test "$(ls -A "/spcnode-geodatadir/")"; then
    printf 'Geodatadir not empty, skipping initialization...\n'
else
    printf 'Geodatadir empty, we copy the files...\n'
    cp -R /geodatadir-template/* /spcnode-geodatadir/
fi

printf '\n--- END Geoserver Docker Entrypoint ---\n\n'

# Run the CMD 
exec "bin/startup.sh"
