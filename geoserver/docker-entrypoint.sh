#!/bin/sh

# Exit script in case of error
set -e

# TODO : probably some useful stuff here : https://github.com/piensa/geoserver-docker/blob/master/entrypoint.sh 

# Create the geonode workspace
curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml"
  -d "<workspace><name>geonode</name></workspace>"
  http://geoserver:8080/geoserver/rest/workspaces

# Run the CMD 
exec "bin/startup.sh"


