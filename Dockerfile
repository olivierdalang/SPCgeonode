# TODO : use python:2.7.13-alpine3.6 to make this lighter ( it is what we use for letsencryipt as well)
# But it seems it's not possible for now because alpine only has geos 3.6 which is not supported by django 1.8
# (probably because of https://code.djangoproject.com/ticket/28441)

FROM python:2.7.14-slim-stretch

# 2-3. Install dependencies
ADD ./requirements.txt /requirements.txt
RUN echo "Updating apt-get" && \
    apt-get update && \
    echo "Installing build dependencies" && \
    apt-get install -y gcc make libc-dev musl-dev libpcre3 libpcre3-dev g++ && \
    echo "Installing Pillow dependencies" && \
    # RUN apt-get install -y NOTHING ?? It was probably added in other packages... ALPINE needed jpeg-dev zlib-dev && \
    echo "Installing GDAL dependencies" && \
    apt-get install -y libgeos-dev libgdal-dev && \
    echo "Installing Psycopg2 dependencies" && \
    # RUN apt-get install -y NOTHING ?? It was probably added in other packages... ALPINE needed postgresql-dev && \
    echo "Installing other dependencies" && \
    # RUN apt-get install -y NOTHING ?? It was probably added in other packages... ALPINE needed libxml2-dev libxslt-dev && \
    echo "Python server" && \
    pip install uwsgi && \
    echo "Geonode python dependencies" && \
    LIBRARY_PATH=/lib:/usr/lib CPLUS_INCLUDE_PATH=/usr/include/gdal C_INCLUDE_PATH=/usr/include/gdal pip install -r /requirements.txt && \
    echo "Removing build dependencies and cleaning up" && \
    # TODO : cleanup apt-get with something like apt-get -y --purge autoremove gcc make libc-dev musl-dev libpcre3 libpcre3-dev g++ && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf ~/.cache/pip && \
    rm /requirements.txt

# 5. Add the application
RUN mkdir /spcgeonode
WORKDIR /spcgeonode/
ADD . /spcgeonode/
RUN chmod +x docker-entrypoint.sh

# Export ports
EXPOSE 8000

# Set environnment variables
ENV SITEURL=/
ENV GEOSERVER_PUBLIC_LOCATION=/geoserver/
ENV DJANGO_SETTINGS_MODULE=spcgeonode.settings
ENV DATABASE_URL=postgres://postgres:postgres@postgres:5432/postgres
ENV BROKER_URL=amqp://guest:guest@rabbitmq:5672/
ENV STATIC_ROOT=/spcgeonode-static/
ENV MEDIA_ROOT=/spcgeonode-media/
ENV STATIC_URL=/static/
ENV MEDIA_URL=/media/
ENV GEOSERVER_LOCATION=http://nginx/geoserver/
# TODO : we should probably remove this and set Celery to use JSON serialization instead of pickle
ENV C_FORCE_ROOT=True

# We provide no command or entrypoint as this image can be used to serve the django project or run celery tasks
