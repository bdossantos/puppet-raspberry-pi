class pi {
  $node_version = 'v0.10.22'

  package { ['wget', 'curl', 'tar', 'sudo', 'ruby', 'rsync', ]:
    ensure => present,
  }

  exec { 'node.js':
    command => "wget http://nodejs.org/dist/${node_version}/node-${node_version}-linux-arm-pi.tar.gz && \
                tar -xvzf node-v${node_version}.tar.gz",
    cwd     => '/usr/local/src',
    creates => "/usr/local/src/node-v${node_version}",
  } ->

  file { 'symlink node.js':
    ensure      => link,
    source      => "/usr/local/src/node-${node_version}/bin/node",
    destination => '/usr/local/bin/node',
  }

  file { 'symlink npm':
    ensure      => link,
    source      => "/usr/local/src/node-v${node_version}/bin/npm",
    destination => '/usr/local/bin/npm',
  }

  file { '/var/log.hd':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0744',
  }

  mount { '/var/log':
    ensure  => mounted,
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => "size=256M,mode=0744,uid=root,gid=root",
    atboot  => true,
  }

  cron { 'restore log.hd at boot':
    command => 'rsync -za /var/log.hd /var/log'
  }

  cron { 'sync log to hd':
    command => 'nice -n 15 ionice -c 3 rsync -za /var/log /var/log.hd',
  }
}
