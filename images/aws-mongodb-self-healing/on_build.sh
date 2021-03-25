#!/usr/bin/env bash

set -e

wget -qO - https://www.mongodb.org/static/pgp/server-3.6.asc | apt-key add -
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/3.6 multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-3.6.list

apt-get update && apt-get install -y \
    awscli \
    mongodb-org=3.6.23 \
    mongodb-org-server=3.6.23 \
    mongodb-org-shell=3.6.23 \
    mongodb-org-mongos=3.6.23 \
    mongodb-org-tools=3.6.23
