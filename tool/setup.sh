#!/bin/bash
set -x
set -e

sudo setenforce permissive

sudo yum install -y centos-release-SCL

sudo yum install -y \
    mysql-devel \
    mysql-libs \
    mariadb55-mariadb-devel \
    mariadb55-mariadb-server \
    httpd \
    httpd-devel \
    gcc \
    gcc-c++ \
    openssl-devel \
    zlib-devel \
    apr-devel \
    apr-util-devel \
    libcurl-devel \
    patch \
    git

sudo chkconfig httpd on

sudo su - sieve-vacation-manager << EOF
if test ! -d ~/.rbenv/.git; then
    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
fi
EOF

sudo -u sieve-vacation-manager -H bash -l -c '
if ! grep -q rbenv ~/.bashrc; then
cat <<EOF >> ~/.bashrc
export PATH="~/.rbenv/bin:\$PATH"
eval "\$(rbenv init -)"
source ~/.rbenv/completions/rbenv.bash
export RUBY_CONFIGURE_OPTS="--enable-shared --disable-install-doc"
EOF
fi'

sudo su - sieve-vacation-manager <<EOF
source ~/.bashrc
rbenv install 2.2.1
rbenv global 2.2.1
gem install --no-rdoc --no-ri bundler
gem install --no-rdoc --no-ri passenger
rbenv rehash
passenger-install-apache2-module --auto
cd ~/sieve-vacation-manager
bundle install --local --without="test development" --path vendor/bundle
bundle exec rake gettext RACK_ENV=production
EOF

sudo su - sieve-vacation-manager <<EOF
    passenger-install-apache2-module --snippet > passenger.conf
EOF

sudo bash -l -c 'cat /home/sieve-vacation-manager/passenger.conf > /etc/httpd/conf.d/passenger.conf'

if [ $? -ne 0 ]; then
    echo "Setup Completed!!"
fi
