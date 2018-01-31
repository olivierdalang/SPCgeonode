# TODO : implement a dumper that does a postgres dump on a regular basis

FROM python:2.7.13-alpine3.6
 
# 1-2. Install system dependencies
# RUN apk add --no-cache openssl && \
#     apk add --no-cache certbot --repository http://dl-3.alpinelinux.org/alpine/edge/testing/
RUN apk add --no-cache postgresql

# TODO: move to top
# RUN apk add --no-cache curl

# The entrypoint creates the certificate
ADD crontab crontab 
RUN /usr/bin/crontab crontab
RUN rm crontab

# We run cron in foreground to update the certificates
CMD ["/usr/sbin/crond", "-f"]
