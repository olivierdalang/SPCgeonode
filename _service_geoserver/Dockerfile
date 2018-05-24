FROM openjdk:8-jre-alpine

# Install dependencies
RUN apk add --no-cache ca-certificates openssl curl postgresql-client fontconfig ttf-ubuntu-font-family
RUN update-ca-certificates

WORKDIR /

# Download Geoserver
# we first download vanilla geoserver, as it comes with preset jetty and launch scripts
# then we replace it with the geonode build
# TODO : this is a bit dirty..... can't we stat from vanilla Geoserver ?
# TODO : merge into on step
RUN echo "Download geoserver for geonode" && \
    wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.12.2/geoserver-2.12.2-bin.zip && \
    wget http://build.geonode.org/geoserver/latest/geoserver-2.12.2.war && \
    unzip geoserver-2.12.2-bin.zip && \
    rm /geoserver-2.12.2-bin.zip && \
    rm /geoserver-2.12.2/webapps/geoserver/* -rf && \
    unzip -o geoserver-2.12.2.war -d /geoserver-2.12.2/webapps/geoserver/ && \
    rm /geoserver-2.12.2.war

# Download initial data dir
RUN wget http://build.geonode.org/geoserver/latest/data-2.12.x.zip
RUN unzip /data-2.12.x.zip
RUN ls /data

WORKDIR /geoserver-2.12.2/

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
