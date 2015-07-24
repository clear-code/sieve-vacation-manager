#!/bin/bash
set -x
set -e

./setup.sh
./prepare_mariadb55-server.sh
./put_virtualhost_conf.sh
./finalize.sh
