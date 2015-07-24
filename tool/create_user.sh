#!/bin/bash
set -x
set -e

if ! grep -q sieve-vacation-manager /etc/passwd; then
    sudo groupadd --system sieve-vacation-manager
    sudo useradd --system -c "Sieve vacation manager" -m -g sieve-vacation-manager sieve-vacation-manager
fi
