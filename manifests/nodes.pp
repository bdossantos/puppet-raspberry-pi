node base {
  include nginx
  $lsbdistcodename = 'wheezy'

  package { ['wget', 'curl', 'tar', 'sudo', 'ruby', 'rsync', ]:
    ensure => present,
  }

  class { 'ntp':
    restrict => ['127.0.0.1', ],
  }

  class { 'locales':
    autoupgrade     => true,
    default_locale  => 'en_US.UTF-8',
    locales         => [
      'en_US.UTF-8 UTF-8',
      'en_US ISO-8859-1',
    ],
  }

  ramdisk { 'tmp dir':
    ensure  => present,
    path    => '/tmp',
    atboot  => true,
    size    => '64M',
    mode    => '1777',
    owner   => 'root',
    group   => 'root',
  }

  ramdisk { 'log':
    ensure  => present,
    path    => '/var/log',
    atboot  => true,
    size    => '128M',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }

  file { '/var/log.hd':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  package { 'fail2ban':
    ensure => latest,
  } ->

  file { '/var/log/fail2ban':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  } ->

  service { 'fail2ban':
    ensure      => running,
    hasstatus   => true,
    hasrestart  => true,
  }

  cron { 'save log to hd':
    command => '/usr/bin/rsync -za --delete /var/log/ /var/log.hd/',
    user    => 'root',
    special => 'daily',
    require => Package['rsync'],
  }

  cron { 'restore hd log to tmpfs':
    command => '/usr/bin/rsync -za --delete /var/log.hd/ /var/log/',
    user    => 'root',
    special => 'reboot',
    require => Package['rsync'],
  }
}

node default inherits base {}
