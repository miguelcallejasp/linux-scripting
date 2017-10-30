#!/bin/bash

docker-compose -f docker-compose.yml stop mysql
rm -rf data/mysql
docker-compose -f docker-compose.yml up -d mysql
