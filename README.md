puppet-role_nextcloud
===================

Puppet role definition for deployment of naturalis content server

Parameters
-------------
Sensible defaults for Naturalis in init.pp.
admin password will be reported during installation, when installation is done unattended then search in /var/log/syslog for the text:  Installation complete.  User name: admin  User password: <password here>

```
- configuredrupal             Main installation part, advised to be set to false after installation is complete. If set to true and a non working drupal installation is found ( for example due to incorrect module ) then a complete reinstallation of drupal including a complete db drop is initiated.
- enablessl                   Enable apache SSL modules, see SSL example
- docroot                     Documentroot, match location with 'docroot' part of the instances parameter
- mysql_root_password         Root password for mysql server
- mysql_nextcloud_user        Nextcloud database user
- mysql_nextcloud_password    Nextcloud database password
- cron                        Enable hourly cronjob for drupal installation. 
- php_memory_limit            Sets PHP memory limit
- php_ini_files               Array with ini files. Defaults are set for Ubuntu 14.04, do not set /etc/php.ini as this ini file will be created by default.
- instances                   Apache vhost configuration array
```


example ssl enabled virtual hosts with http to https redirect, see init.pp for 
more example values

```
role_drupal::instances:
site-with-ssl.drupalsites.nl: 
  serveraliases: "*.drupalsites.nl"
  serveradmin: webmaster@drupalsites.nl
  port: 443
  priority: 10
  directories: 
  - options: -Indexes +FollowSymLinks +MultiViews
    path: /var/www/drupal
    allow_override: All
  docroot: /var/www/sisdrupal
  ssl: true
site-without-ssl.drupalsites.nl: 
  rewrites: 
  - rewrite_rule: 
    - ^(.*)$ https://site-with-ssl.drupalsites.nl/$1 [R,L]
  serveraliases: "*.drupalsites.nl"
  serveradmin: webmaster@drupalsites.nl
  port: 80
  docroot: /var/www/drupal
  priority: 5
```


Classes
-------------
- role_nextcloud
- role_nextcloud::instances
- role_nextcloud::repo
- role_nextcloud::update
- role_nextcloud::configure
- role_nextcloud::drush
- role_nextcloud::install
- role_nextcloud::site
- role_nextcloud::ssl



Dependencies
-------------
- puppetlabs/mysql >= 3.11.0
- puppetlabs/apache2 >= 1.11.0
- puppetlabs/concat >= 2.2.0
- puppetlabs/inifile >= 1.6.0
- voxpupuli/puppet-php >= 4.0.0
- voxpupuli/puppet-letsencrypt >= 1.1.0


Puppet code
```
class { role_nextcloud: }
```
Result
-------------
Working webserver with mysql and nextcloud installation with custom installation 
profile. Additional module installation and hourly cronjobs are also 
installed by default.

Limitations
-------------
This module has not been tested yet.



