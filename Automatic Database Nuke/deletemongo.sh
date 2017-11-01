#!/bin/bash

set -e
VIZIX_DATA_PATH=/opt/vizix/data

docker-compose stop mongo
rm -rf ${VIZIX_DATA_PATH}/mongo
docker-compose -f docker-compose-mongo.yml up -d
sleep 5

docker-compose -f docker-compose-mongo.yml exec -T mongosetup mongo admin \
  --eval "db.createUser({user:'admin', pwd:'control123!',roles:['userAdminAnyDatabase']});"
 
docker-compose -f docker-compose-mongo.yml exec -T mongosetup mongo admin -u "admin" -p "control123!" \
  --authenticationDatabase admin \
  --eval "db.createRole({role:'executeFunctions',privileges:[{resource:{anyResource:true},actions:['anyAction']}],roles:[]});db.grantRolesToUser('admin',[{ role: 'executeFunctions', db: 'admin' },{ role : 'readWrite', db : 'riot_main' }]);"


docker-compose -f docker-compose-mongo.yml stop mongosetup
docker-compose up -d mongo
