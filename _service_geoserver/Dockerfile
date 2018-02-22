FROM java:8-jre-alpine

# Install dependencies
RUN apk add --no-cache ca-certificates openssl curl
RUN update-ca-certificates

WORKDIR /

# Download Geoserver and related modules
# TODO : get a copy of SNAPSHOT releases as they will change over time
RUN echo "Download geoserver" && \
    wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.12.2/geoserver-2.12.2-bin.zip && \
    unzip geoserver-2.12.2-bin.zip && \
    rm geoserver-2.12.2-bin.zip && \
    echo "Download printing module" && \
    wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.12.2/extensions/geoserver-2.12.2-printing-plugin.zip && \
    unzip -n geoserver-2.12.2-printing-plugin.zip -d /geoserver-2.12.2/webapps/geoserver/WEB-INF/lib/ && \
    rm geoserver-2.12.2-printing-plugin.zip  && \
    echo "Download geofence module" && \
    wget https://build.geoserver.org/geoserver/2.12.x/community-latest/geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip && \
    unzip -n geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip -d /geoserver-2.12.2/webapps/geoserver/WEB-INF/lib/ && \
    rm geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip && \
    echo "Download authkey module" && \
    wget https://build.geoserver.org/geoserver/2.12.x/community-latest/geoserver-2.12-SNAPSHOT-authkey-plugin.zip && \
    unzip -n geoserver-2.12-SNAPSHOT-authkey-plugin.zip -d /geoserver-2.12.2/webapps/geoserver/WEB-INF/lib/ && \
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

# Run geoserver
CMD ["bin/startup.sh"]
