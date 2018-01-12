# TODO : use python 2.7.13 as this is what we use for letsencryipt as well (so we have less to download)
FROM python:2.7.14-slim-stretch
# FROM python:3.6.3-slim-jessie

# 1. Install system dependencies
RUN apt-get update
RUN apt-get install -y gcc make libc-dev musl-dev libgeos-dev libpcre3 libpcre3-dev libgdal-dev g++

# 2. Install uwsgi
RUN pip install uwsgi

# 3. Manually install python gdal (for some reason pip install gdal doesn't work out of the box)
RUN CPLUS_INCLUDE_PATH=/usr/include/gdal C_INCLUDE_PATH=/usr/include/gdal pip install GDAL==2.0.1

# TODO : move this to top
RUN apt-get install -y curl

# 4. Install python dependencies
# TODO : remove git once we don't need git for pip installs anymore
RUN apt-get install -y git
ADD ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
RUN rm /requirements.txt


# 5. Add the application
RUN mkdir /spcgeonode
WORKDIR /spcgeonode/
ADD . /spcgeonode/

EXPOSE 8000
