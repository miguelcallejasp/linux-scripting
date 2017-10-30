#!/bin/bash

SQLSERVER="147.75.69.178"
SQLUSER="sa"
SQLPASSWORD="control123!"
DATABASE="Fabrics"
NAME="backup3.bak"
WPATH="C:\backup\\`date +%Y%m%d%H%M%S`.bak"
FTPUSER=admin
PASSWD=control123!

sqlcmd -S ${SQLSERVER} -U ${SQLUSER} -P ${SQLPASSWORD} -q "BACKUP DATABASE [${DATABASE}] TO DISK ='${WPATH}'" <<EOF
QUIT
EOF
#Gettin all files recursive
wget -r ftp://admin:control123\!@${SQLSERVER}/
echo "
 verbose
 user admin control123!
 mdelete * -y
 quit" | ftp -n ${SQLSERVER}

cp -r ${SQLSERVER}/ /data/
rm -rf ${SQLSERVER}
