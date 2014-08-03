class nginx {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  package { 'nginx':
    ensure  => latest,
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
    revision => 'fc610f495a26a78a4221ce662a81d486b4c4b70b',
    require  => Package['nginx'],
  } ->

  file { '/etc/nginx/h5bp':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    #target => '/opt/server-configs-nginx/h5bp',
  } ->

  exec { 'copy h5bp nginx config':
    command     => 'cp -r . /etc/nginx/h5bp/',
    cwd         => '/opt/server-configs-nginx/h5bp',
    path        => $::path,
    subscribe   => Vcsrepo['/opt/server-configs-nginx'],
    refreshonly => true,
  } ->

  exec { 'fix nginx static log':
    command     => 'sed -i "\,access_log logs/static.log;,d" expires.conf',
    cwd         => '/etc/nginx/h5bp/location',
    path        => $::path,
    subscribe   => Exec['copy h5bp nginx config'],
    refreshonly => true,
    notify      => Service['nginx'],
  } ->

  service { 'nginx':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    restart    => '/etc/init.d/nginx reload',
    require    => File['/var/log/nginx'],
  }
}
