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
    unzip /data-2.12.x.zip -d /spcgeonode-geodatadir/
    mv /spcgeonode-geodatadir/data/* /spcgeonode-geodatadir/
    rm -rf /spcgeonode-geodatadir/data

    # We recursively replace localhost:8000 to our django public ip
    # We replace http://localhost:8000/geoserver with GEOSERVER_PUBLIC_URL and http://localhost:8000/ with GEONODE_PUBLIC_URL
    sed -i 's,http://localhost:8000/geoserver,/geoserver,g' '/spcgeonode-geodatadir/security/filter/geonode-oauth2/config.xml' # TODO : parametrize GEOSERVER_PUBLIC_URL
    sed -i 's,http://localhost:8000/,/,g' '/spcgeonode-geodatadir/security/filter/geonode-oauth2/config.xml' # TODO : parametrize GEONODE_PUBLIC_URL
    sed -i 's,http://localhost:8000/geoserver,/geoserver,g' '/spcgeonode-geodatadir/security/role/geonode REST role service/config.xml' # TODO : parametrize GEOSERVER_PUBLIC_URL
    sed -i 's,http://localhost:8000/,/,g' '/spcgeonode-geodatadir/security/role/geonode REST role service/config.xml' # TODO : parametrize GEONODE_PUBLIC_URL

    
fi

printf '\n--- END Geoserver Docker Entrypoint ---\n\n'

# Run the CMD 
exec "bin/startup.sh"
