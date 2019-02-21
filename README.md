puppet-role_nextcloud
=====================
Puppet role definition for deployment of naturalis content server.

Parameters
-------------
Sensible defaults for Naturalis in init.pp.

```
- enablessl                   Enable apache SSL modules, see SSL example
- docroot                     Documentroot, match location with 'docroot' part of the instances parameter
- mysql_root_password         Root password for mysql server
- mysql_nextcloud_user        Nextcloud database user
- mysql_nextcloud_password    Nextcloud database password
- cron                        Enable hourly cronjob for drupal installation. 
```


Classes
-------------
- role_nextcloud


Dependencies
-------------
- puppetlabs/mysql
- puppetlabs/apache2
- puppetlabs/concat
- puppetlabs/inifile
- voxpupuli/puppet-php
- voxpupuli/puppet-letsencrypt


Docker-compose
--------------

This puppet script configures a complete docker-compose setup for nextcloud. Which
consists of:

 - mariadb
 - redis
 - nextcloud
 - traefik

It is started using Foreman which creates:

 - .env file
 - docker-compose.yml
 - traefik.toml

The puppet script generates:

 - /data/database
 - /data/nextcloud
 - /data/files

Result
------
Working webserver with mysql and nextcloud installation with custom installation 
profile.  It is in production on https://files.museum.naturalis.nl

Limitations
-----------
This has been tested.

