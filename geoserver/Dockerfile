FROM java:8-jre-alpine

# Install dependencies
RUN apk update
RUN apk add ca-certificates
RUN update-ca-certificates
RUN apk add openssl

WORKDIR /

# Download geoserver
RUN wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.12.1/geoserver-2.12.1-bin.zip
RUN unzip geoserver-2.12.1-bin.zip
RUN rm geoserver-2.12.1-bin.zip

# Download printing module
RUN wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.12.1/extensions/geoserver-2.12.1-printing-plugin.zip
RUN unzip geoserver-2.12.1-printing-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/
RUN rm geoserver-2.12.1-printing-plugin.zip

# Download geonode module
RUN wget http://build.geonode.org/geoserver/latest/geonode-geoserver-ext-2.12.x-geoserver-plugin.zip
RUN unzip geonode-geoserver-ext-2.12.x-geoserver-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/
RUN rm geonode-geoserver-ext-2.12.x-geoserver-plugin.zip

# # Download oauth2 module
RUN wget http://ares.boundlessgeo.com/geoserver/2.12.x/community-2017-11-24/geoserver-2.12-SNAPSHOT-authkey-plugin.zip
# TODO : this wants to override, I guess it's safe not to ???
RUN unzip -n geoserver-2.12-SNAPSHOT-authkey-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/
RUN rm geoserver-2.12-SNAPSHOT-authkey-plugin.zip

# # Download oauth2-geonode module
RUN wget http://ares.boundlessgeo.com/geoserver/2.12.x/community-2017-11-24/geoserver-2.12-SNAPSHOT-sec-oauth2-geonode-plugin.zip
# TODO : this seems to override with some existing files, is it OK to override ???
RUN unzip -n geoserver-2.12-SNAPSHOT-sec-oauth2-geonode-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/
RUN rm geoserver-2.12-SNAPSHOT-sec-oauth2-geonode-plugin.zip

# # Download geofence module
RUN wget http://ares.boundlessgeo.com/geoserver/2.12.x/community-2017-11-24/geoserver-2.12-SNAPSHOT-geofence-plugin.zip
# TODO : this seems to override with some existing files, is it OK to override ???
RUN unzip -n geoserver-2.12-SNAPSHOT-geofence-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/
RUN rm geoserver-2.12-SNAPSHOT-geofence-plugin.zip

# # Download geofence module
RUN wget http://ares.boundlessgeo.com/geoserver/2.12.x/community-2017-11-24/geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip
# TODO : this seems to override with some existing files, is it OK to override ???
RUN unzip -n geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip -d /geoserver-2.12.1/webapps/geoserver/WEB-INF/lib/
RUN rm geoserver-2.12-SNAPSHOT-geofence-server-plugin.zip

# 

# Setup workdir

# Inject our specific customizations for security
# ADD web-inf/web.xml ./webapps/geoserver/WEB-INF/web.xml
# RUN cat ./etc/jetty.xml.extension >> 
# RUN cat ./etc/jetty.xml
# RUN rm etc/jetty.xml.extension

# Add the template geodatadir
# ADD geodatadir-template /geodatadir-template
# TODO : see if it's possible to start with less pregenerated files (only take what's really useful)
RUN wget http://build.geonode.org/geoserver/latest/data-2.12.x.zip

# ADD data-2.12.x.zip /data-2.12.x.zip

WORKDIR /geoserver-2.12.1/

# Export ports
EXPOSE 8080

# Run geoserver
ADD docker-entrypoint.sh docker-entrypoint.sh 
ENTRYPOINT ["./docker-entrypoint.sh"]

# ENV GEOSERVER_VERSION=2.9.x-oauth2
# ENV GEOSERVER_DATA_DIR="/geoserver_data/data"

# #
# # Download and install GeoServer
# #
# RUN cd /usr/local/tomcat/webapps \
#     && wget --progress=bar:force:noscroll http://build.geonode.org/geoserver/latest/geoserver-${GEOSERVER_VERSION}.war \
#     && unzip -q geoserver-${GEOSERVER_VERSION}.war -d geoserver \
#     && rm geoserver-${GEOSERVER_VERSION}.war \
#     && mkdir -p $GEOSERVER_DATA_DIR

# VOLUME $GEOSERVER_DATA_DIR

# # Set DOCKER_HOST address
# ARG DOCKER_HOST=${DOCKER_HOST}
# # for debugging
# RUN echo -n DOCKER_HOST=$DOCKER_HOST
# #
# ENV DOCKER_HOST ${DOCKER_HOST}
# # for debugging
# RUN echo -n DOCKER_HOST=$DOCKER_HOST

# ENV DOCKER_HOST_IP ${DOCKER_HOST_IP}
# RUN echo export DOCKER_HOST_IP=${DOCKER_HOST} | sed 's/tcp:\/\/\([^:]*\).*/\1/' >> /root/.bashrc

# # for debugging
# RUN echo -n DOCKER_HOST_IP=${DOCKER_HOST_IP}
# # ENV DOCKER_HOST_IP ${DOCKER_HOST_IP}
# # Set WEBSERVER public port
# ARG PUBLIC_PORT=${PUBLIC_PORT}
# # for debugging
# RUN echo -n PUBLIC_PORT=${PUBLIC_PORT}
# #
# ENV PUBLIC_PORT=${PUBLIC_PORT}
# # for debugging
# RUN echo -n PUBLIC_PORT=${PUBLIC_PORT}

# # set nginx base url for geoserver
# RUN echo export BASE_URL=http://${NGINX_HOST}:${NGINX_PORT}/ | sed 's/tcp:\/\/\([^:]*\).*/\1/' >> /root/.bashrc

# # copy the script and perform the change to config.xml
# RUN mkdir -p /usr/local/tomcat/tmp
# WORKDIR /usr/local/tomcat/tmp
# COPY set_geoserver_auth.sh /usr/local/tomcat/tmp
# RUN chmod +x /usr/local/tomcat/tmp/set_geoserver_auth.sh

# COPY setup_auth.sh /usr/local/tomcat/tmp
# RUN chmod +x /usr/local/tomcat/tmp/setup_auth.sh
# COPY entrypoint.sh /usr/local/tomcat/tmp/entrypoint.sh
# RUN chmod +x /usr/local/tomcat/tmp/entrypoint.sh
# CMD ["/usr/local/tomcat/tmp/entrypoint.sh"]