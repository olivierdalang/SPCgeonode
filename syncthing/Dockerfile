FROM python:2.7.13-alpine3.6

# 1-2. Install system dependencies
# notes : openssl is needed for wget (https) and gettext is needed for envsubst
# TODO : see if can avoid requiring python and pip bcrypt (a CLI tool to bcrypt, this is only needed to encrypt the Syncthing GUI password).
# Maybe apache-utils ? see https://unix.stackexchange.com/a/419855 
RUN apk add --no-cache openssl gettext && \
    apk add --no-cache --virtual BUILD-DEPS gcc linux-headers build-base libffi-dev && \
    pip install bcrypt && \
    apk del BUILD-DEPS

# 3. Install Syncthing
RUN wget https://github.com/syncthing/syncthing/releases/download/v0.14.43/syncthing-linux-amd64-v0.14.43.tar.gz && \
    tar xzf /syncthing-linux-amd64-v0.14.43.tar.gz && \
    rm /syncthing-linux-amd64-v0.14.43.tar.gz

# 4. Set the configuration
ADD config.xml.template /root/.config/syncthing/config.xml.template

# 5. Setup entrypoint (which adapts the config file to ENV vars)
ADD docker-entrypoint.sh docker-entrypoint.sh 
ENTRYPOINT ["./docker-entrypoint.sh"]
RUN chmod +x docker-entrypoint.sh

# 6. Run Syncthing
EXPOSE 8384 22000
CMD /syncthing-linux-amd64-v0.14.43/syncthing
