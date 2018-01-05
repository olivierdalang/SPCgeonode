rem TODO : supprimer ca
start "SPCNode Django Docker Log" cmd "/C docker logs spcnode_django_1 -f && echo '---TERMINATED---' && timeout 10"
start "SPCNode Nginx Docker Log" cmd "/C docker logs spcnode_nginx_1 -f && echo '---TERMINATED---' && timeout 10"
start "SPCNode Geoserver Docker Log" cmd "/C docker logs spcnode_geoserver_1 -f && echo '---TERMINATED---' && timeout 10"
start "SPCNode Postgres Docker Log" cmd "/C docker logs spcnode_postgres_1 -f && echo '---TERMINATED---' && timeout 10"
