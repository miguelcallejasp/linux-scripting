#!/bin/bash

echo "Restoring Databases"
sleep 1
echo "Deleting Mongo database and creating a clean one"
./deletemongo.sh
echo "Deleting MySQL database and creating a clean one"
./deletemysql.sh

echo "Deleting Zookeeper and Kafka data"
ls -l data/
docker-compose stop hazelcast
docker-compose up -d hazelcast
docker-compose logs -f --tail 200 mongo mysql hazelcast
