#!/bin/bash



### Shell config
#
#set -e   # Must not be set, or else one failed command will prevent further processin
#
set -u



### Script "config"
#
TIMESTAMP=`date +%H-%M`
TARGETDIR="/var/log/status"



### Make sure the target directory exists
#
mkdir -p $TARGETDIR



### Log statuses
#

# Processes
top -n1 -b -c   >  $TARGETDIR/top-$TIMESTAMP
ps auxf         >  $TARGETDIR/ps-$TIMESTAMP

# IO status
iotop -n2 -b -o >  $TARGETDIR/iotop-$TIMESTAMP

# MySQL/MariaDB status
echo 'SHOW FULL PROCESSLIST' | mysql --defaults-file=/root/.my.cnf.status-logger > $TARGETDIR/mysql-$TIMESTAMP

# Apache HTTPD status
STATUSURL="https://stg.aokranj.com/sys/server-status"
curl -s $STATUSURL | lynx -stdin -dump -width=256 > $TARGETDIR/apache-devstg-$TIMESTAMP

#STATUSURL="https://www.aokranj.com/sys/server-status"
STATUSURL="https://www.pdkranj.si/sys/server-status"
curl -s $STATUSURL | lynx -stdin -dump -width=256 > $TARGETDIR/apache-prod-$TIMESTAMP
