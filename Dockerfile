# TODO : use python:2.7.13-alpine3.6 to make this lighter ( it is what we use for letsencryipt as well)
# But it seems it's not possible for now because alpine only has geos 3.6 which is not supported by django 1.8
# (probably because of https://code.djangoproject.com/ticket/28441)

FROM python:2.7.14-slim-stretch

# Install system dependencies
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
    apt-get install -y libxml2-dev libxslt-dev && \
    echo "Installing GeoIP dependencies" && \
    apt-get install -y geoip-bin geoip-database && \
    echo "Python server" && \
    pip install uwsgi && \
    echo "Removing build dependencies and cleaning up" && \
    # TODO : cleanup apt-get with something like apt-get -y --purge autoremove gcc make libc-dev musl-dev libpcre3 libpcre3-dev g++ && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf ~/.cache/pip

# Install python dependencies
RUN echo "Geonode python dependencies"
RUN pip install pygdal==$(gdal-config --version).*
RUN pip install celery==4.1.0 # see https://github.com/GeoNode/geonode/pull/3714
RUN pip install https://github.com/GeoNode/geonode/archive/4c41e0ddb80e2abc05ec61715b3a6373694c3523.zip # branch 2.7.x (future 2.8.1) 2018-05-21

# 5. Add the application
RUN mkdir /spcgeonode
WORKDIR /spcgeonode/
ADD requirements.txt /spcgeonode/requirements.txt
RUN pip install -r requirements.txt
ADD . /spcgeonode/
RUN chmod +x docker-entrypoint.sh

# Export ports
EXPOSE 8000

# Set environnment variables
ENV DJANGO_SETTINGS_MODULE=spcgeonode.settings
ENV DATABASE_URL=postgres://postgres:postgres@postgres:5432/postgres
ENV BROKER_URL=amqp://guest:guest@rabbitmq:5672/
ENV STATIC_ROOT=/spcgeonode-static/
ENV MEDIA_ROOT=/spcgeonode-media/
ENV STATIC_URL=/static/
ENV MEDIA_URL=/media/
ENV GEOSERVER_LOCATION=http://nginx/geoserver/
# this is set in settingy.py as we derive it from HTTPS_HOST/HTTP_HOST, since relative urls arent supported anymore in 2.8
# ENV GEOSERVER_PUBLIC_LOCATION=/geoserver/ # TODO : fix relative url support upstream
# TODO : we should probably remove this and set Celery to use JSON serialization instead of pickle
ENV C_FORCE_ROOT=True

# We provide no command or entrypoint as this image can be used to serve the django project or run celery tasks
