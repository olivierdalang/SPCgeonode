# TODO : start from alpine (but dropbox doesn't seem to work :/ )
# FROM python:2.7-slim-stretch
FROM python:2.7.13-alpine3.6
 
# 1-2. Install system dependencies
RUN apk add --no-cache openssl && \
    apk add --no-cache certbot --repository http://dl-3.alpinelinux.org/alpine/edge/testing/


# RUN mkdir /dropbox-bin/
# WORKDIR /root/

# DOWNLOAD DROPBOX DAEMON
# RUN cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
# RUN chmod 777 -R .dropbox-dist
# RUN ~/.dropbox-dist/dropboxd

# RUN ls -al

# RUN .dropbox-dist/dropboxd --help

# # INSTALL DROPBOX PYTHON CONTROLLER

# RUN wget -O dropbox.py "https://www.dropbox.com/download?dl=packages/dropbox.py"
# RUN chmod +x dropbox.py
# RUN ./dropbox.py


RUN wget https://github.com/syncthing/syncthing/releases/download/v0.14.43/syncthing-linux-amd64-v0.14.43.tar.gz
RUN tar xzf /syncthing-linux-amd64-v0.14.43.tar.gz
RUN mv /syncthing-linux-amd64-v0.14.43 /syncthing
RUN rm /syncthing-linux-amd64-v0.14.43.tar.gz

# TODO : move to top
# This installs envsubst
# TODO : combine and remove afterwards
# RUN apk add --no-cache --virtual .BUILD-DEPS build-base linux-headers
RUN apk add --no-cache gettext
RUN apk add --no-cache gcc
RUN apk add --no-cache linux-headers
RUN apk add --no-cache build-base
RUN apk add --no-cache libffi-dev
RUN pip install bcrypt

ADD config.xml.template /root/.config/syncthing/config.xml.template

# RUN mkdir /backups
# RUN ln -s /spcgeonode-geodatadir /backups/geodatadir
# RUN ln -s /spcgeonode-media /backups/media

EXPOSE 8384 22000

ADD docker-entrypoint.sh docker-entrypoint.sh 
ENTRYPOINT ["./docker-entrypoint.sh"]
RUN chmod +x docker-entrypoint.sh

CMD /syncthing/syncthing

# TODO : IMPLEMENT

# This doesn't do anything yet. It should launch a service to backup to some cloud somewhere... (resilio, dropbox, amazon, or whatever ?)

# Install the cron jobs
# ADD crontab ./crontab
# RUN /usr/bin/crontab ./crontab
# RUN rm ./crontab

# # Add entypoint
# ADD docker-entrypoint.sh docker-entrypoint.sh 
# ENTRYPOINT ["./docker-entrypoint.sh"]
# RUN chmod +x docker-entrypoint.sh


# CMD [".dropbox-dist/dropboxd", "--help"]
# CMD ["sleep", "3600s"]
# CMD ["/usr/sbin/crond", "-f"]


# We run cron in foreground to update the certificates


