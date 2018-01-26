FROM java:8-jre-alpine

# Install dependencies
RUN apk add --no-cache ca-certificates openssl
RUN update-ca-certificates

WORKDIR /

# Download Geoserver and related modules
RUN echo "Download geoserver"
RUN wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.12.1/geoserver-2.12.1-bin.zip
RUN unzip geoserver-2.12.1-bin.zip
RUN rm geoserver-2.12.1-bin.zip
RUN echo "Download printing module"
RUN wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.12.1/extensions/geoserver-2.12.1-printing-plugin.zip
RUN unzip geoserver-2.12.1-printing-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/
RUN rm geoserver-2.12.1-printing-plugin.zip

RUN echo "Download geofence module"
RUN wget http://ares.boundlessgeo.com/geoserver/2.12.x/community-2017-11-24/geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip
RUN unzip -n geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/
RUN rm geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip

# RUN echo "Download geonode module"
# README SAYS If the request has a valid sessionid cookie (this links to a user in GeoNode), GeoNode looks up the user's permissions and replies.
# BUT THIS SEEMS OBSOLETE... WHAT IS THIS PLUGIN DOING ? NO IDEA !!!
# RUN wget http://build.geonode.org/geoserver/latest/geonode-geoserver-ext-2.12.x-geoserver-plugin.zip
# RUN unzip geonode-geoserver-ext-2.12.x-geoserver-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/
# RUN rm geonode-geoserver-ext-2.12.x-geoserver-plugin.zip

RUN echo "Download authkey module"
RUN wget http://ares.boundlessgeo.com/geoserver/2.12.x/community-2017-11-24/geoserver-2.12-SNAPSHOT-authkey-plugin.zip
RUN unzip -n geoserver-2.12-SNAPSHOT-authkey-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/
RUN rm geoserver-2.12-SNAPSHOT-authkey-plugin.zip
# RUN echo "Download oauth2-geonode module"
# RUN wget http://ares.boundlessgeo.com/geoserver/2.12.x/community-2017-11-24/geoserver-2.12-SNAPSHOT-sec-oauth2-geonode-plugin.zip
# RUN unzip -n geoserver-2.12-SNAPSHOT-sec-oauth2-geonode-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/
# RUN rm geoserver-2.12-SNAPSHOT-sec-oauth2-geonode-plugin.zip

# # Add initial geodatadir (adapted from http://build.geonode.org/geoserver/latest/data-2.12.x.zip)
ADD geodatadir-init /geodatadir-init

WORKDIR /geoserver-2.12.1/

# Export ports
EXPOSE 8080

# Run geoserver
ADD docker-entrypoint.sh docker-entrypoint.sh 
ENTRYPOINT ["./docker-entrypoint.sh"]
RUN chmod +x docker-entrypoint.sh
