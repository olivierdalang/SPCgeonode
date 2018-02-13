# TODO : use python:2.7.13-alpine3.6 to make this lighter ( it is what we use for letsencryipt as well)
# But it seems it's not possible for now because alpine only has geos 3.6 which is not supported by django 1.8
# (probably because of https://code.djangoproject.com/ticket/28441)

FROM olivierdalang/spcgeonode:django-0.0.16

RUN apt-get update
RUN apt-get install -y git

ADD ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
RUN rm /requirements.txt

# 5. Add the application
# RUN mkdir /spcgeonode
# WORKDIR /spcgeonode/
ADD . /spcgeonode/
RUN chmod +x docker-entrypoint.sh


EXPOSE 8000

# We provide no command or entrypoint as this image can be used to serve the django project or run celery tasks
