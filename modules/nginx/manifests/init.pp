class nginx {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  apt::source { 'nginx':
    location => 'http://nginx.org/packages/debian/',
    release  => 'wheezy',
    repos    => 'nginx',
  } ->

  apt::key { 'nginx':
    key_source => 'http://nginx.org/keys/nginx_signing.key',
  } ->

  package { 'nginx':
    ensure  => latest,
    #require => Apt::source['nginx'],
  } ->

  file { '/var/log/nginx':
    ensure => directory,
  } ->

  file { '/etc/nginx/sites-enabled/default':
    ensure => absent,
  } ->

  file { '/etc/nginx/nginx.conf':
    ensure => file,
    source => 'puppet:///modules/nginx/etc/nginx/nginx.conf',
    notify => Service['nginx'],
  }

  file { '/etc/nginx/sites-enabled':
    ensure  => directory,
    source  => 'puppet:///modules/nginx/etc/nginx/sites-enabled',
    purge   => true,
    recurse => true,
  }

  file { '/usr/share/nginx/www/index.html':
    ensure  => file,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0444',
    content => '',
  }

  file { '/srv/http':
    ensure => directory,
  }

  vcsrepo { '/opt/server-configs-nginx':
    ensure   => latest,
    provider => 'git',
    source   => 'https://github.com/h5bp/server-configs-nginx.git',
    revision => 'master',
    require  => Package['nginx'],
  } ->

  file { '/etc/nginx/h5bp':
    ensure => link,
    target => '/opt/server-configs-nginx/h5bp',
  }

  service { 'nginx':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    restart    => '/etc/init.d/nginx reload',
    require    => File['/var/log/nginx'],
  }
}
