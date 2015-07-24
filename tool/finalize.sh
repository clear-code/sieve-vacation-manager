#!/bin/bash
set -x
set -e

sudo service httpd restart
sudo chmod 0705 /home/sieve-vacation-manager/
