FROM nginx:1.13.7-alpine

RUN apk update
RUN apk add inotify-tools

COPY nginx.conf /etc/nginx/nginx.conf
COPY spcgeonode.conf /etc/nginx/spcgeonode.conf

ADD docker-autoreload.sh docker-autoreload.sh 
ADD docker-entrypoint.sh docker-entrypoint.sh 
ENTRYPOINT ["./docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]