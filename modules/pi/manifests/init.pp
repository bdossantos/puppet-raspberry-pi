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
}
