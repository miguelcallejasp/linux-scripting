DM=`date +%Y%m%d%H%M%S`
TYPE=daily
BACKUP_DIR=/backups/bkp/$TYPE
mkdir -p $BACKUP_DIR

MYSQL_USER=mns
MYSQL_PASSWORD=*******
MYSQL_DB=riot_main
HOST_MYSQL=mnsdb.clu*******ha.eu-west-1.rds.amazonaws.com

MONGODUMP_PATH=/usr/bin/mongodump
MONGO_HOST=10.0.1.131
MONGO_PORT=27017
MONGO_DATABASE=riot_main
MONGO_USERNAME=admin
MONGO_PASSWORD=ctj2pzhrEe******

rm -rf $BACKUP_DIR/*

mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD -h$HOST_MYSQL --add-drop-database --add-drop-table --hex-blob --databases $MYSQL_DB | gzip > $BACKUP_DIR/mysql_${DM}.sql.gz

mongodump --host $MONGO_HOST --port $MONGO_PORT --db $MONGO_DATABASE --username $MONGO_USERNAME --password $MONGO_PASSWORD --authenticationDatabase $MONGO_USERNAME --out $BACKUP_DIR/mongodb_${DM}
cd $BACKUP_DIR/
tar -czvf $BACKUP_DIR/mongodb_${DM}.tar.gz mongodb_${DM}

s3cmd put $BACKUP_DIR/mysql_${DM}.sql.gz s3://backup-mns/phase2/daily/$TYPE/${DM}/
s3cmd --multipart-chunk-size-mb=180 put $BACKUP_DIR/mongodb_${DM}.tar.gz s3://backup-mns/phase2/daily/$TYPE/${DM}/
