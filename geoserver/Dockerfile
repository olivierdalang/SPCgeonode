FROM java:8-jre-alpine

# Install dependencies
RUN apk add --no-cache ca-certificates openssl
RUN update-ca-certificates

WORKDIR /

# Download Geoserver and related modules
RUN echo "Download geoserver" && \
    wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.12.1/geoserver-2.12.1-bin.zip && \
    unzip geoserver-2.12.1-bin.zip && \
    rm geoserver-2.12.1-bin.zip && \
    echo "Download printing module" && \
    wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.12.1/extensions/geoserver-2.12.1-printing-plugin.zip && \
    unzip geoserver-2.12.1-printing-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/ && \
    rm geoserver-2.12.1-printing-plugin.zip && \
    echo "Download geonode module" && \
    wget http://build.geonode.org/geoserver/latest/geonode-geoserver-ext-2.12.x-geoserver-plugin.zip && \
    unzip geonode-geoserver-ext-2.12.x-geoserver-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/ && \
    rm geonode-geoserver-ext-2.12.x-geoserver-plugin.zip && \
    echo "Download oauth2 module" && \
    wget http://ares.boundlessgeo.com/geoserver/2.12.x/community-2017-11-24/geoserver-2.12-SNAPSHOT-authkey-plugin.zip && \
    unzip -n geoserver-2.12-SNAPSHOT-authkey-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/ && \
    rm geoserver-2.12-SNAPSHOT-authkey-plugin.zip && \
    echo "Download oauth2-geonode module" && \
    wget http://ares.boundlessgeo.com/geoserver/2.12.x/community-2017-11-24/geoserver-2.12-SNAPSHOT-sec-oauth2-geonode-plugin.zip && \
    unzip -n geoserver-2.12-SNAPSHOT-sec-oauth2-geonode-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/ && \
    rm geoserver-2.12-SNAPSHOT-sec-oauth2-geonode-plugin.zip && \
    echo "Download geofence module" && \
    wget http://ares.boundlessgeo.com/geoserver/2.12.x/community-2017-11-24/geoserver-2.12-SNAPSHOT-geofence-plugin.zip && \
    unzip -n geoserver-2.12-SNAPSHOT-geofence-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/ && \
    rm geoserver-2.12-SNAPSHOT-geofence-plugin.zip && \
    echo "Download geofence module" && \
    wget http://ares.boundlessgeo.com/geoserver/2.12.x/community-2017-11-24/geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip && \
    unzip -n geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/ && \
    rm geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip

# # Add initial geodatadir (adapted from http://build.geonode.org/geoserver/latest/data-2.12.x.zip)
ADD geodatadir-init /geodatadir-init

WORKDIR /geoserver-2.12.1/

# Export ports
EXPOSE 8080

# Run geoserver
ADD docker-entrypoint.sh docker-entrypoint.sh 
ENTRYPOINT ["./docker-entrypoint.sh"]
RUN chmod +x docker-entrypoint.sh
