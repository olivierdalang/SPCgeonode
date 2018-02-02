FROM python:2.7.13-alpine3.6

# 1-2. Install system dependencies
# TODO : certboot seems to reinstall python (2.7.13-r1) instead of using installed 2.7.13, see if we can fix this
RUN apk add --no-cache openssl && \
    apk add --no-cache certbot

# Installing scripts
ADD *.sh / 
RUN chmod +x *.sh

# Installing cronjobs
ADD crontab / 
RUN /usr/bin/crontab /crontab && \
    rm /crontab

# Setup the healthcheck
HEALTHCHECK --interval=60s --timeout=30s --start-period=60s --retries=3 CMD ["./docker-healthcheck.sh"]

# Setup the entrypoint
ENTRYPOINT ["./docker-entrypoint.sh"]

# We run cron in foreground to update the certificates
CMD /usr/sbin/crond -f
