#!/bin/bash
set -x
set -e

sudo /etc/init.d/mariadb55-mysqld start
sudo su - sieve-vacation-manager << EOF
scl enable mariadb55 'mysql -uroot -e "source ~/sieve-vacation-manager/config/user.sql"'
cd ~/sieve-vacation-manager
RACK_ENV=production bundle exec rake db:setup
RACK_ENV=production bundle exec rake db:migrate
EOF

if [ $? -ne 0 ]; then
    echo "MySQL setup Completed!!"
fi
