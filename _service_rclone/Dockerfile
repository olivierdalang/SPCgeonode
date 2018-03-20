FROM alpine:3.6

# 1-2. Install system dependencies
# notes : openssl is needed for wget (https)
# TODO : see if can avoid requiring python and pip bcrypt (a CLI tool to bcrypt, this is only needed to encrypt the Syncthing GUI password).
# Maybe apache-utils ? see https://unix.stackexchange.com/a/419855 
RUN apk add --no-cache openssl

# 3. Install Rclone
RUN wget https://downloads.rclone.org/v1.39/rclone-v1.39-linux-amd64.zip && \
    unzip /rclone-v1.39-linux-amd64.zip && \
    rm /rclone-v1.39-linux-amd64.zip && \
    mv /rclone-v1.39-linux-amd64/rclone /usr/bin

# TODO : move to top (for envsubst)
RUN apk add --no-cache gettext
RUN apk add --no-cache ca-certificates openssl
RUN update-ca-certificates

ADD rclone.conf.template /root/rclone.conf.template
ADD sync.sh /root/sync.sh
RUN chmod +x /root/sync.sh

ADD docker-entrypoint.sh docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh

# The entrypoint creates the certificate
ADD crontab crontab 
RUN /usr/bin/crontab crontab
RUN rm crontab

# We run cron in foreground to update the certificates
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/crond", "-f"]
