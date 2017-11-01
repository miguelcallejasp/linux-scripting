#!/bin/bash

set -e
VIZIX_DATA_PATH=/opt/vizix/data

docker-compose -f docker-compose.yml stop mysql
rm -rf ${VIZIX_DATA_PATH}/mysql
docker-compose -f docker-compose.yml up -d mysql
