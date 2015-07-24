#!/bin/bash
set -x
set -e

if test ! -f /etc/httpd/conf.d/virtualhost.conf; then
    sudo bash -l -c '
cat /home/sieve-vacation-manager/sieve-vacation-manager/tool/httpd_addtional_settings.conf > /etc/httpd/conf.d/virtualhost.conf
'
fi

if ! grep -q ja_JP.UTF8 /etc/sysconfig/httpd; then
    sudo bash -l -c 'echo HTTPD_LANG=ja_JP.UTF8 >> /etc/sysconfig/httpd'
fi

if [ $? -ne 0 ]; then
    echo "httpd setup Completed!!"
fi
