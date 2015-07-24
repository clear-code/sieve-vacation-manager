#!/bin/bash

#
# This file for Vagrant provisioning testing only.
#
set -x
set -e

export APPVERSION="0.0.1"
cp ../sieve-vacation-manager-${APPVERSION}.tar.gz .
cp ../config/user.sql.sample user.sql
cp ../config/settings.yml.sample settings.yml
