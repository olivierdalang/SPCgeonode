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
ONBUILD ADD . /spcgeonode/
ONBUILD RUN chmod +x docker-entrypoint.sh


EXPOSE 8000
HEALTHCHECK NONE
ENTRYPOINT ["/spcgeonode/docker-entrypoint.sh"]
CMD ["uwsgi", "--chdir=/spcgeonode", "--module=spcgeonode.wsgi", "--socket=:8000", "--processes=5"]
