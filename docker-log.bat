start "SPCNode Django Docker Log" cmd /C docker logs spcnode_django_1 -f
start "SPCNode Nginx Docker Log" cmd /C docker logs spcnode_nginx_1 -f
start "SPCNode Geoserver Docker Log" cmd /C docker logs spcnode_geoserver_1 -f
start "SPCNode Postgres Docker Log" cmd /C docker logs spcnode_postgres_1 -f
