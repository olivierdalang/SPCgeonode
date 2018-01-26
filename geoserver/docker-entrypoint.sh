#!/bin/sh

# Exit script in case of error
set -e

printf '\n--- START Geoserver Docker Entrypoint ---\n'

# Run migrations
printf '\nInitializing data dir\n'
if test "$(ls -A "/spcgeonode-geodatadir/")"; then
    printf 'Geodatadir not empty, skipping initialization...\n'
else
    printf 'Geodatadir empty, we copy the files...\n'

    # We unzip the folder
    cp -r /geodatadir-init/* /spcgeonode-geodatadir/
    printf 'Randomizing root password...\n'
    # TODO CRITICAL : do not use default master password... to be adapted once security issue is adressed
    # this doesnt work (i was hoping a password would be regenerated but it doenst happen)
    # rm -rf /spcgeonode-geodatadir/security/masterpw
    # rm -rf /spcgeonode-geodatadir/security/pwpolicy/master
    # rm /spcgeonode-geodatadir/security/masterpw.digest
    # rm /spcgeonode-geodatadir/security/masterpw.info
    # rm /spcgeonode-geodatadir/security/masterpw.xml

    

fi
 

printf '\n--- END Geoserver Docker Entrypoint ---\n\n'

# Run the CMD 
exec "bin/startup.sh"
