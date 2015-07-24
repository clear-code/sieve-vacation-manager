#!/bin/bash

#
# This file for Vagrant provisioning testing only.
#
set -x
set -e

sudo su - sieve-vacation-manager << EOF
export APPVERSION="0.0.1"
cp /vagrant/sieve-vacation-manager-\${APPVERSION}.tar.gz ~
tar zxvf sieve-vacation-manager-\${APPVERSION}.tar.gz
mv ~/sieve-vacation-manager-\${APPVERSION} ~/sieve-vacation-manager
cp /vagrant/user.sql ~/sieve-vacation-manager/config
cp /vagrant/settings.yml ~/sieve-vacation-manager/config
EOF
