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



### Required parameter - destination directory
#
DESTDIR="${1:-}"

if [ "$DESTDIR" == "" ]; then
    _error "Usage: $0 PATH-TO-DESTDIR"
fi
if [ ! -e $DESTDIR ]; then
    _error "Destination does not exist: $DESTDIR"
elif [ ! -d $DESTDIR ]; then
    _error "Destination is not a directory: $DESTDIR"
fi

# Strip the potential trailing slash
DESTDIR=`echo "$DESTDIR" | sed -e 's/\/$//'`

dateToday=`date '+%Y-%m-%d'`
_echo "Starting backup dilution on: $dateToday"



### Define retention/dilution policy
#
cutOffDates=(
    `date '+%Y-%m-%d' -d  '2 years  ago'`
    `date '+%Y-%m-%d' -d  '3 months ago'`
    `date '+%Y-%m-%d' -d '20 days   ago'`
)
# Retention patterns must be in sync with cutoff dates above
retentionPatterns=(
    "^$"                       # Keep nothing (if older than 2 years)
    "^[0-9]+-[0-9]+-01$"       # Keep backups with -01 in date (if older than 3 months)
    "^[0-9]+-[0-9]+-[0-2]1$"   # Keep backups with -01, -11, -21 in date (if older than 20 days)
)

for i in ${!cutOffDates[@]}; do
    _echo "Before date ${cutOffDates[$i]} retain backups matching ${retentionPatterns[$i]}"
done



### Run through existing daily backups, delete if necessary
#
for backupDate in `ls "$DESTDIR" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' | sort`; do

    for i in ${!cutOffDates[@]}; do
        if [[ "$backupDate" < "${cutOffDates[$i]}" ]]; then
            retentionPattern="${retentionPatterns[$i]}"
            if [[ $backupDate =~ $retentionPattern ]]; then
                echo "Backup day $backupDate - keeping."
            else
                echo "Backup day $backupDate - removing..."
                btrfs subvolume delete "$DESTDIR/$backupDate"
            fi
            continue 2 # Continue the _outer_ loop!
        fi
    done

    echo "Backup day $backupDate - keeping."
done



### All done
#
_echo "Backup dilution has been completed at `date`"
_echo
