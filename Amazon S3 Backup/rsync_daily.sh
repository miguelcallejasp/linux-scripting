#!/bin/sh
# ----------------------------------------------------------------------
# rotating-filesystem-snapshot utility: daily snapshots
# ----------------------------------------------------------------------
# intended to be run daily as a cron job when hourly.3 contains the
# ----------------------------------------------------------------------

#unset PATH

# ------------- system commands used by this script --------------------

DM=`date +%Y%m%d`                # Year Date and Month e.g. 20091123
ADMIN_EMAIL="cloudops@mail.com"
BACKUP_DIR="/backups/servers"
BACKUP_SCRIPT_DIR="/backups/script"
BACKUP_LOG_DIR="/backups/log"
BACKUP_LOG_DIR_SIZE="/backups/log/size"
SERVERLIST="mns_prod"

# ------------- the script itself --------------------------------------
# ------------- the script itself --------------------------------------
make_snapshot() {
  echo "--    $SERVER_FILE `date +%Y%m%d%H%M%S`" >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  echo "--    $SERVER_FILE `date +%Y%m%d%H%M%S`";
  mkdir -p $BACKUP_DIR/$SERVER_FILE

  echo "--    $SERVER_FILE    STEP 1 `date +%Y%m%d%H%M%S`" >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  echo "--    $SERVER_FILE    STEP 1 `date +%Y%m%d%H%M%S`";
  # step 1: delete the oldest snapshot, if it exists:
#  if [ -d $BACKUP_DIR/$SERVER_FILE/daily.1 ] ; then    \
#    rm -rf $BACKUP_DIR/$SERVER_FILE/daily.1 ;         \
#  fi ;
#  if [ -d $BACKUP_DIR/$SERVER_FILE/daily.0 ] ; then    \
#    cp -al $BACKUP_DIR/$SERVER_FILE/daily.0 $BACKUP_DIR/$SERVER_FILE/daily.1 ;       \
#  fi;

  echo "--    $SERVER_FILE    STEP 3 `date +%Y%m%d%H%M%S`" >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  echo "--    $SERVER_FILE    STEP 3 `date +%Y%m%d%H%M%S`";
  # step 3: make a hard-link-only (except for dirs) copy of the lastest snapshot,
  # if that exists
  rm -rf $BACKUP_DIR/$SERVER_FILE/daily.0/*;
  mkdir -p $BACKUP_DIR/$SERVER_FILE/daily.0/$SERVER_FILE;

  echo "--MYSQL    $SERVER_FILE -- 1 -- `date +%Y%m%d%H%M%S`" >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  echo "--MYSQL    $SERVER_FILE -- 1 -- `date +%Y%m%d%H%M%S`";
  #backup mysql
  mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD -h$HOST_MYSQL --add-drop-database --add-drop-table --hex-blob --databases $MYSQL_DB | gzip > $BACKUP_DIR/$SERVER_FILE/daily.0/$SERVER_FILE/riot_main_$SERVER_FILE_${DM}.sql.gz;
  echo "--  size Mysql riot_main : " >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  du -sch $BACKUP_DIR/$SERVER_FILE/daily.0/$SERVER_FILE/riot_main_$SERVER_FILE_${DM}.sql.gz >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  echo "--  size bytes Mysql riot_main : " >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  du -sb $BACKUP_DIR/$SERVER_FILE/daily.0/$SERVER_FILE/riot_main_$SERVER_FILE_${DM}.sql.gz >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  #Mongo Backup
  echo "-- $SERVER_FILE   STEP 2 `date +%Y%m%d%H%M%S`";
  echo "-- $SERVER_FILE   STEP 3 `date +%Y%m%d%H%M%S`" >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  mongodump --host $MONGO_HOST --port $MONGO_PORT --db $MONGO_DATABASE --username $MONGO_USERNAME --password $MONGO_PASSWORD --authenticationDatabase $MONGO_USERNAME --out $BACKUP_DIR/$SERVER_FILE/daily.0/$SERVER_FILE/mongodb_$SERVER_FILE_${DM};
  echo "-- ZISE BYTE:  $SERVER_FILE   AFTER MONGODUMP `date +%Y%m%d%H%M%S`" >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  du -sb $BACKUP_DIR/$SERVER_FILE/daily.0/$SERVER_FILE/mongodb_$SERVER_FILE_${DM} >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  du -sch $BACKUP_DIR/$SERVER_FILE/daily.0/$SERVER_FILE/mongodb_$SERVER_FILE_${DM} >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  #put list size mongo
  echo "-- ZISE BYTE:  $SERVER_FILE   AFTER MONGODUMP `date +%Y%m%d%H%M%S`" >> $BACKUP_LOG_DIR_SIZE/$SERVER_FILE.txt;
  du -sb $BACKUP_DIR/$SERVER_FILE/daily.0/$SERVER_FILE/mongodb_$SERVER_FILE_${DM} >> $BACKUP_LOG_DIR_SIZE/$SERVER_FILE.txt;
  cd $BACKUP_DIR/$SERVER_FILE/daily.0/$SERVER_FILE/;
  #echo "$DM,`gzip -dc riot_main_$SERVER_FILE_${DM}.sql.gz | wc -c`,`du -sb mongodb_$SERVER_FILE_${DM} | cut -f1`" >> $BACKUP_LOG_DIR_SIZE/mns-prod_bytes_7day.csv;
  echo "$DM,`du -sb mongodb_$SERVER_FILE_${DM} | cut -f1`" >> $BACKUP_LOG_DIR_SIZE/mns-prod_bytes_7day.csv;
#  tar -c --use-compress-program=pigz -vf mongodb_$SERVER_FILE_${DM}.tar.gz mongodb_$SERVER_FILE_${DM};
  tar -cv mongodb_$SERVER_FILE_${DM} |  pigz -1 -p 16 > mongodb_$SERVER_FILE_${DM}.tar.gz;
#  tar -czvf mongodb_$SERVER_FILE_${DM}.tar.gz mongodb_$SERVER_FILE_${DM};
#  rm -rf mongodb_$SERVER_FILE_${DM};
  echo "--    $SERVER_FILE    AFTER MONGODUMP `date +%Y%m%d%H%M%S`" >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  cd $BACKUP_DIR/$SERVER_FILE/daily.0/$SERVER_FILE/;
  s3cmd put riot_main_$SERVER_FILE_${DM}.sql.gz  s3://backup-mns/one_every_day_UTC/${DM}/;
  s3cmd --multipart-chunk-size-mb=180 put mongodb_$SERVER_FILE_${DM}.tar.gz  s3://backup-mns/one_every_day_UTC/${DM}/;
  s3cmd sync -P $BACKUP_LOG_DIR_SIZE/mns-prod_bytes_7day.csv s3://backup-mns/log_size_mns_bytes/
}

for SERVER_FILE in ${SERVERLIST} ;
do
  DATETIME=`date +%Y%m%d%H%M%S`

  echo "-- $SERVER_FILE `date +%Y%m%d%H%M%S`";
  echo " " >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  echo " " >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  echo -------------------------- >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  echo "-- $SERVER_FILE `date +%Y%m%d%H%M%S`" >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
  . ${BACKUP_SCRIPT_DIR}/${SERVER_FILE}.conf

  if [ $ENABLED = "true" ]; then
      make_snapshot
      sleep 10
  fi
  ENABLED=false;

done

df -h

echo "-- THE END `date +%Y%m%d%H%M%S`"
echo "[BACKUPSSUCCESSFULLY] ok, backups successfully: $SERVER_FILE" >> $BACKUP_LOG_DIR/${DM}_$SERVER_FILE.txt;
#/backups/script/1rsync_7days.sh
