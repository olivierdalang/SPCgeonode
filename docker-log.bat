rem TODO : supprimer ca
start "spcgeonode Django Docker Log" cmd "/C docker logs spcgeonode_django_1 -f && echo '---TERMINATED---' && timeout 30"
start "spcgeonode Nginx Docker Log" cmd "/C docker logs spcgeonode_nginx_1 -f && echo '---TERMINATED---' && timeout 30"
start "spcgeonode Geoserver Docker Log" cmd "/C docker logs spcgeonode_geoserver_1 -f && echo '---TERMINATED---' && timeout 30"
start "spcgeonode Postgres Docker Log" cmd "/C docker logs spcgeonode_postgres_1 -f && echo '---TERMINATED---' && timeout 30"
start "spcgeonode Celery Docker Log" cmd "/C docker logs spcgeonode_celery_1 -f && echo '---TERMINATED---' && timeout 30"
start "spcgeonode RabbitMQ Docker Log" cmd "/C docker logs spcgeonode_rabbitmq_1 -f && echo '---TERMINATED---' && timeout 30"
