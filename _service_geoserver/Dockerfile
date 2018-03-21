FROM openjdk:8-jre-alpine

# Install dependencies
RUN apk add --no-cache ca-certificates openssl curl postgresql-client fontconfig ttf-ubuntu-font-family
RUN update-ca-certificates

WORKDIR /

# Download Geoserver and related modules
# TODO : vendor a copy of SNAPSHOT releases as they will change over time
# TODO : [merge this into 1 layer
# VERIFY IF LAYER DOWNLOAD FROM GEONODE STILL WORKS AFTER MERGING, FOR SOME
# OBSCURE REASON IT DOES NOT HERE  (which is why I didn't merge in the first place),
# LOOKS LIKE FILE MODIFICATION DATE MAY PLAY SOME ROLE
# see http://osgeo-org.1560.x6.nabble.com/Exception-with-WFS-requests-tp5355049p5355173.html]
RUN echo "Download geoserver" && \
    wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.12.2/geoserver-2.12.2-bin.zip && \
    unzip geoserver-2.12.2-bin.zip && \
    rm geoserver-2.12.2-bin.zip
RUN echo "Download printing module" && \
    wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.12.2/extensions/geoserver-2.12.2-printing-plugin.zip && \
    unzip -o geoserver-2.12.2-printing-plugin.zip -d /geoserver-2.12.2/webapps/geoserver/WEB-INF/lib/ && \
    rm geoserver-2.12.2-printing-plugin.zip
RUN echo "Download geofence module" && \
    wget https://build.geoserver.org/geoserver/2.12.x/community-latest/geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip && \
    unzip -o geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip -d /geoserver-2.12.2/webapps/geoserver/WEB-INF/lib/ && \
    rm geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip
RUN echo "Download authkey module" && \
    wget https://build.geoserver.org/geoserver/2.12.x/community-latest/geoserver-2.12-SNAPSHOT-authkey-plugin.zip && \
    unzip -o geoserver-2.12-SNAPSHOT-authkey-plugin.zip -d /geoserver-2.12.2/webapps/geoserver/WEB-INF/lib/ && \
    rm geoserver-2.12-SNAPSHOT-authkey-plugin.zip


WORKDIR /geoserver-2.12.2/

# Add geodatadir override data (this will be copied over to the actual datadir in entrypoint)
ADD geodatadir-overrides /geodatadir-overrides

# Add the entrypoint
ADD docker-entrypoint.sh /docker-entrypoint.sh 
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# Add the healthcheck
HEALTHCHECK --interval=60s --timeout=10s --start-period=60s --retries=3 CMD ["curl", "--silent", "--write-out", "'HTTP CODE : %{http_code}\n'", "--output", "/dev/null", "http://127.0.0.1:8080/geoserver/web/"]

# Export ports
EXPOSE 8080

# Set environnment variables
ENV GEOSERVER_HOME=/geoserver-2.12.2
ENV GEOSERVER_DATA_DIR=/spcgeonode-geodatadir

# Run geoserver
CMD ["bin/startup.sh"]
