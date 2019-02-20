# == Class: role_nextcloud
#
# Full description of class role_nextcloud here.
#
# === Authors
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
#

class role_nextcloud (
  $compose_version              = '1.17.1',
  $repo_ensure                  = 'present',
  $repo_dir                     = '/opt/nextcloud',
  $mysql_db                     = 'nextcloud',
  $mysql_host                   = 'db',
  $mysql_user                   = 'nextcloud_user',
  $mysql_password               = 'PASSWORD',
  $mysql_root_password          = 'ROOTPASSWORD',
  $composer_allow_superuser     = '1',
  $table_prefix                 = '',
  $protocol                     = 'http',
  $base_domain                  = '',
  $web_external_port            = '8080',
  $dev                          = '0',
  $manageenv                    = 'no',
  $enable_ssl                   = true,
  $letsencrypt_certs            = true,
  $traefik_whitelist            = false,
  $traefik_whitelist_array      = ['172.16.0.0/12'],
  $custom_ssl_certfile          = '/etc/ssl/customcert.pem',
  $custom_ssl_certkey           = '/etc/ssl/customkey.pem',
  $drupal_site_url_array        = ['content.museum.naturalis.nl','www.content.museum.naturalis.nl'],  # first site will be used for traefik certificate
#  $logrotate_hash               = { 'apache2'    => { 'log_path' => '/data/www/log/apache2',
#                                                      'post_rotate' => "(cd ${repo_dir}; docker-compose exec drupal service apache2 reload)",
#                                                      'extraline' => 'su root docker'},
#                                    'mysql'      => { 'log_path' => '/data/database/mysqllog',
#                                                      'post_rotate' => "(cd ${repo_dir}; docker-compose exec db mysqladmin flush-logs)",
#                                                      'extraline' => 'su root docker'}
#                                 },

# sensu check settings
  $checks_defaults    = {
    interval      => 600,
    occurrences   => 3,
    refresh       => 60,
    handlers      => ['default'],
    subscribers   => ['appserver'],
    standalone    => true },

){

  include 'docker'
  include 'stdlib'

  Exec {
    path => ['/usr/local/bin/','/usr/bin','/bin'],
    cwd  => $role_nextcloud::repo_dir,
  }

  file { ['/data','/data/database'] :
    ensure              => directory,
    owner               => 'root',
    group               => 'wheel',
    mode                => '0775',
    require             => Class['docker'],
  }

  file { $role_nextcloud::repo_dir:
    ensure              => directory,
    mode                => '0770',
  }


# define ssl certificate location
  if ( $letsencrypt_certs == true ) {
    $ssl_certfile = "/etc/letsencrypt/live/${drupal_site_url_array[0]}/fullchain.pem"
    $ssl_certkey = "/etc/letsencrypt/live/${drupal_site_url_array[0]}/privkey.pem"
  }else{
    $ssl_certfile = $custom_ssl_certfile
    $ssl_certkey = $custom_ssl_certkey
  }

 file { "${role_nextcloud::repo_dir}/traefik.toml" :
    ensure   => file,
    content  => template('role_nextcloud/traefik.toml.erb'),
    require  => File[$role_nextcloud::repo_dir],
    notify   => Exec['Restart traefik on change'],
  }

  file { "${role_nextcloud::repo_dir}/.env":
    ensure   => file,
    mode     => '0600',
    replace  => $role_nextcloud::manageenv,
    content  => template('role_nextcloud/env.erb'),
    require  => File['/opt/nextcloud/docker-compose.yml'],
    notify   => Exec['Restart containers on change'],
  }

  class {'docker::compose': 
    ensure      => present,
    version     => $role_nextcloud::compose_version,
    notify      => Exec['apt_update'],
    require     => File["${role_nextcloud::repo_dir}/.env"]
  }

  docker_network { 'web':
    ensure   => present,
  }

  ensure_packages(['git','python3'], { ensure => 'present' })

  docker_compose { "${role_nextcloud::repo_dir}/docker-compose.yml":
    ensure      => present,
    options     => "-p ${role_nextcloud::repo_dir} ",
    require     => [
      Vcsrepo[$role_nextcloud::repo_dir],
      Docker_network['default'],
      File["${role_nextcloud::repo_dir}/.env"]
    ]
  }

  exec { 'Pull containers' :
    command  => 'docker-compose pull',
    schedule => 'everyday',
  }

  exec { 'Up the containers to resolve updates' :
    command  => 'docker-compose up -d',
    schedule => 'everyday',
    require  => [
      Exec['Pull containers'],
      File[$role_nextcloud::repo_dir],
      Docker_network['web'],
      File["${role_nextcloud::repo_dir}/.env"]
    ]
  }

  exec {'Restart containers on change':
    refreshonly => true,
    command     => 'docker-compose up -d',
    require     => [
      File[$role_nextcloud::repo_dir],
      Docker_network['web'],
      File["${role_nextcloud::repo_dir}/.env"]
    ]
  }

  exec {'Restart traefik on change':
    refreshonly => true,
    command     => 'docker-compose restart traefik',
    require     => [
      File[$role_nextcloud::repo_dir],
      Docker_network['web'],
      File["${role_nextcloud::repo_dir}/.env"]
    ]
  }

  exec {'Start containers if none are running':
    command     => 'docker-compose up -d',
    onlyif      => 'docker-compose ps | wc -l | grep -c 2',
    require     => [
      File[$role_nextcloud::repo_dir],
      Docker_network['web'],
      File["${role_nextcloud::repo_dir}/.env"]
    ]
  }
  
  # deze gaat per dag 1 keer checken
  # je kan ook een range aan geven, bv tussen 7 en 9 's ochtends
  schedule { 'everyday':
     period  => daily,
     repeat  => 1,
     range => '5-7',
  }

#  create_resources('role_nextcloud::logrotate', $logrotate_hash)


# update when configured
#  if ( $role_nextcloud::updatesecurity == true ) or ( $role_nextcloud::updateall == true ) {
#      class { 'role_nextcloud::update':}
#    }

}
