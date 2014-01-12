# Puppet Raspberry Pi

Setup my Raspberry Pi with Puppet.

## Installation

```
git clone https://github.com/bdossantos/puppet-raspberry-pi
cd puppet-raspberry-pi
bundle install
librarian-puppet install
sudo FACTER_lsbdistcodename=wheezy \
puppet apply manifests/nodes.pp --modulepath=./modules/
```
