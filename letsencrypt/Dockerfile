FROM alpine:3.5
 
RUN apk update
RUN apk add openssl
# TODO : this requires python 2.7.13-r0, maybe we could use same base image as Django to minimize downloads
RUN apk add certbot --repository http://dl-3.alpinelinux.org/alpine/edge/testing/


# The entrypoint creates the certificate
ADD docker-entrypoint.sh docker-entrypoint.sh 
ENTRYPOINT ["./docker-entrypoint.sh"]
RUN chmod +x docker-entrypoint.sh

# We run cron in foreground
CMD ["/usr/sbin/crond", "-f"]
