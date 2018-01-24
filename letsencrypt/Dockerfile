FROM python:2.7.13-alpine3.6
 
# 1-2. Install system dependencies
RUN apk add --no-cache openssl && \
    apk add --no-cache certbot --repository http://dl-3.alpinelinux.org/alpine/edge/testing/

# TODO: move to top
RUN apk add --no-cache curl

# The entrypoint creates the certificate
ADD docker-entrypoint.sh docker-entrypoint.sh 
ENTRYPOINT ["./docker-entrypoint.sh"]
RUN chmod +x docker-entrypoint.sh

# We expose port 80 to use certbox standalone
EXPOSE 80

# We run cron in foreground to update the certificates
CMD ["/usr/sbin/crond", "-f"]
