FROM python:2.7.14-slim-stretch
# FROM python:3.6.3-slim-jessie

# 1. Install system dependencies
RUN apt-get update
RUN apt-get install -y gcc make libc-dev musl-dev libgeos-dev libpcre3 libpcre3-dev libgdal-dev g++

# 2. Install uwsgi
RUN pip install uwsgi

# 3. Manually install python gdal (for some reason pip install gdal doesn't work out of the box)
RUN CPLUS_INCLUDE_PATH=/usr/include/gdal C_INCLUDE_PATH=/usr/include/gdal pip install GDAL==2.0.1

# 4. Install python dependencies
ADD ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
RUN rm /requirements.txt

# 5. Add the application
RUN mkdir /spcnode
WORKDIR /spcnode/
ADD . /spcnode/

EXPOSE 8000
