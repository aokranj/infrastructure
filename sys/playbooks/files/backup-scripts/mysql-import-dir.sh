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



### Required parameter - source directory
#
SRCDIR="${1:-}"

if [ "$SRCDIR" == "" ]; then
    _error "Usage: $0 PATH-TO-SRCDIR"
fi
if [ ! -d $SRCDIR ]; then
    _error "Destination is not a directory: $SRCDIR"
fi

# Strip the potential trailing slash
SRCDIR=`echo "$SRCDIR" | sed -e 's/\/$//'`




### Configuration defaults
#
MYSQL_CLI="mysql"
MYSQLCMD="$MYSQL_CLI"



# Signal start time
_echo "Starting import at `date`"



# Get list of files to work with (database dumps)
_echo "Finding all *.sql files in $SRCDIR"
FILES=`cd $SRCDIR && ls *.sql`



# Loop through those files
for FILE in $FILES; do
    _echo -n "  Importing file $FILE... "

    # Get database name
    DB=`echo "$FILE" | sed -e 's/\.sql//'`
    _echo -n "db $DB... "

    # Check if database exists and drop it
    RES=`echo "SHOW DATABASES" | $MYSQLCMD --skip-column-names | grep -c "^$DB\$"` || true
    if [ "$RES" == "1" ]; then
        echo -n "database exists - dropping... "
        RES=`echo "set FOREIGN_KEY_CHECKS=0; DROP DATABASE $DB" | $MYSQLCMD`
    elif [ "$RES" == "0" ]; then
        # alles gut
        echo -n ""
    else
        echo "ERROR: Unexpected result: $RES"
        exit 1
    fi

    # Create database
    echo -n "creating... "
    RES=`echo "CREATE DATABASE $DB" | $MYSQLCMD`

    # Import
    echo -n "importing... "
    cat $SRCDIR/$FILE | $MYSQLCMD --database $DB
    _echo "done."
done



# Signal end time
_echo "Import completed at `date`"
_echo
