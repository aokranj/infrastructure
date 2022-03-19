#!/bin/bash
#
# This file is managed via Ansible.
# The canonical version of this file is stored in the https://github.com/aokranj/infrastructure repository.
#



### Configure shell
#
set -e
set -u
set -o pipefail



### Echo and error handling methods
#
_echo() {
    if [ "${1:-}" == "-n" ]; then 
        echo -n "$2"
    else
        if [ "${1:-}" == "" ]; then 
            echo
        else
            echo "$1"
        fi
    fi
}

_error() {
    echo "ERROR: $1"
    exit 1
}



### Configuration defaults
#
# Program paths, options, credentials file to use, etc.
# Backup user requires privileges: SELECT, RELOAD, SHOW_DB, LOCK_TABLES, SHOW_VIEW
MYSQL="mysql"
MYSQLDUMP="mysqldump"
MYSQLDUMP_OPTS="--force --add-locks --disable-keys --extended-insert --quote-names --routines --single-transaction --triggers"
MYCNF=`dirname $0`/mysql-export-all.cnf

# First INCLUDE_DBS is evaluated, then included DBS are run through EXCLUDE_DBS
# By default, include all databases and only exclude information_schema and test*
INCLUDE_DBS_REGEX="^.+\$"
EXCLUDE_DBS_REGEX="^(information_schema|performance_schema|test.*)\$"

DESTINATION_UMASK=0027
DESTINATION_GROUP=backup



### Required parameter - destination directory
#
DESTDIR="${1:-}"

if [ "$DESTDIR" == "" ]; then
    _error "Usage: $0 PATH-TO-DESTDIR"
fi
if [ ! -e $DESTDIR ]; then
    umask $DESTINATION_UMASK
    mkdir -p $DESTDIR
    chgrp $DESTINATION_GROUP $DESTDIR
elif [ ! -d $DESTDIR ]; then
    _error "Destination is not a directory: $DESTDIR"
fi

# Strip the potential trailing slash
DESTDIR=`echo "$DESTDIR" | sed -e 's/\/$//'`



# Signal start time
_echo "Starting dump at `date`"



# Remove old backup
_echo -n "Removing old dumps... "
rm -f $DESTDIR/*.sql.gz
_echo "done."
_echo



# Get database list
DBS_ALL=`echo 'SHOW DATABASES' | $MYSQL --defaults-file=$MYCNF -Bs`;

# Parse which DBS are included
DBS_INCLUDED=""
for DB in $DBS_ALL; do
    if ! [[ $DB =~ $INCLUDE_DBS_REGEX ]]; then
        _echo "Not including database:         $DB"
        continue
    fi
    DBS_INCLUDED="$DBS_INCLUDED $DB"
    _echo "Including database (for now):   $DB"
done

# Parse which DBS are EXCLUDED
DBS=""
for DB in $DBS_INCLUDED; do
    if [[ $DB =~ $EXCLUDE_DBS_REGEX ]]; then
        _echo "Excluding database:             $DB"
        continue
    fi
    DBS="$DBS $DB"
done
_echo "Every database that has not been explicitly excluded will be dumped."
_echo



# Loop trough DBS and dump
for DB in $DBS; do

    # What destination will it end in?
    DESTFILE=$DESTDIR/$DB.sql.gz

    # Dump it
    _echo -n "DUMP: $DB... "
    umask $DESTINATION_UMASK
    touch $DESTFILE
    chgrp $DESTINATION_GROUP $DESTFILE

    EXPORT_MYSQL_EVENTS_OPTION=""
    if [ "$DB" == "mysql" ]; then
        EXPORT_MYSQL_EVENTS_OPTION="--events"
    fi

    # The `grep -v` modifier is here to make the dump files be identical if dumped database has not been changed.
    # This helps with incremental backups (the file is potentially not transferred in its entirety).
    $MYSQLDUMP --defaults-file=$MYCNF $MYSQLDUMP_OPTS $EXPORT_MYSQL_EVENTS_OPTION $DB | LANG=C grep -v '^-- Dump completed on ' | gzip -c >> $DESTFILE

    _echo "done."
done



# Signal end time
_echo "Dump has been completed at `date`"
_echo
