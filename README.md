docker-nextcloud
=====================
docker-compose definition for deployment of nextcloud

Docker-compose
--------------

This puppet script configures a complete docker-compose setup for a ipt server.
Which consists of:

 - mariadb
 - nextcloud
 - redis
 - traefik

It is started using Foreman which creates:

 - .env file
 - traefik.toml

The puppet script generates:

running docker-compose project

Result
------
Workin nextcloud server

Limitations
-----------
This has been tested.
