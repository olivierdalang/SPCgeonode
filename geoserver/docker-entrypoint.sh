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
    mv /geodatadir-init/* /spcgeonode-geodatadir/

    printf 'Adapting geoserver configuration...\n'
    # TODO : http://localhost:8000/geoserver with GEOSERVER_PUBLIC_URL and http://localhost:8000/ with GEONODE_PUBLIC_URL
    sed -i 's|http://localhost:8000/geoserver|/geoserver|g' '/spcgeonode-geodatadir/security/filter/geonode-oauth2/config.xml' # TODO : parametrize GEOSERVER_PUBLIC_URL
    sed -i 's|http://localhost:8000/|/|g' '/spcgeonode-geodatadir/security/filter/geonode-oauth2/config.xml' # TODO : parametrize GEONODE_PUBLIC_URL
    sed -i 's|http://localhost:8000/geoserver|/geoserver|g' '/spcgeonode-geodatadir/security/role/geonode REST role service/config.xml' # TODO : parametrize GEOSERVER_PUBLIC_URL
    sed -i 's|http://localhost:8000/|/|g' '/spcgeonode-geodatadir/security/role/geonode REST role service/config.xml' # TODO : parametrize GEONODE_PUBLIC_URL

    printf 'Adapting geoserver admin login...\n'
    # We change the default admin//geoserver user using the secrets
    admin=`cat /run/secrets/admin_username`
    # TODO CRITICAL : encrypt the password (do not forget to set crypt2: instead of plain:)
    passw=`cat /run/secrets/admin_password`
    # passw=`openssl sha256 /run/secrets/admin_password | sed "s,SHA256(/run/secrets/admin_password)= ,,g"` # this doesn't work
    sed -i "s|name=\"admin\"|name=\"$admin\"|g" '/spcgeonode-geodatadir/security/usergroup/default/users.xml' # TODO : parametrize GEONODE_PUBLIC_URL
    sed -i -E "s|password=\"[^\"]+\"|password=\"plain:$passw\"|g" '/spcgeonode-geodatadir/security/usergroup/default/users.xml' # TODO : parametrize GEONODE_PUBLIC_URL
    sed -i "s|username=\"admin\"|username=\"$admin\"|g" '/spcgeonode-geodatadir/security/role/default/roles.xml' # TODO : parametrize GEONODE_PUBLIC_URL
    admin=''
    passw=''

    printf 'Disabling master password...\n'
    # TODO CRITICAL : do not use default master password
    # rm -rf /spcgeonode-geodatadir/security/masterpw
    # rm /spcgeonode-geodatadir/security/masterpw.info
    # rm /spcgeonode-geodatadir/security/masterpw.digest
    # rm /spcgeonode-geodatadir/security/masterpw.xml

    

fi
 

printf '\n--- END Geoserver Docker Entrypoint ---\n\n'

# Run the CMD 
exec "bin/startup.sh"
