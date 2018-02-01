FROM python:2.7.13-alpine3.6

# 1-2. Install system dependencies
# TODO : certboot seems to reinstall python (2.7.13-r1) instead of using installed 2.7.13, see if we can fix this
RUN apk add --no-cache openssl && \
    apk add --no-cache certbot


# Installing cronjobs
ADD crontab crontab
RUN /usr/bin/crontab crontab
RUN rm crontab

# The entrypoint creates the certificate
ADD docker-entrypoint.sh docker-entrypoint.sh 
ENTRYPOINT ["./docker-entrypoint.sh"]
RUN chmod +x docker-entrypoint.sh

# We expose port 80 to use certbox standalone
EXPOSE 80

# We run cron in foreground to update the certificates
CMD ["/usr/sbin/crond", "-f"]
