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
DESTINATION_UMASK=0007
DESTINATION_GROUP=backup



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



# Signal start time
DATE_TODAY=`date '+%Y-%m-%d'`
BACKUPDATE="$DATE_TODAY"
SUBVOLUME_NAME_INPROGRESS="$BACKUPDATE-inProgress"
SUBVOLUME_NAME_FINAL="$BACKUPDATE"
SUBVOLUME_PATH_INPROGRESS="$DESTDIR/$SUBVOLUME_NAME_INPROGRESS"
SUBVOLUME_PATH_FINAL="$DESTDIR/$SUBVOLUME_NAME_FINAL"
_echo "Starting backup for date: $BACKUPDATE"
_echo "Starting at:              `date`"



### Create a temporary subvolume
#
_echo -n "Finding the last complete backup... "
RES=`cd $DESTDIR && ls | grep -c . || true`
if [[ "$RES" == "0" ]] ; then
    _echo "no existing backups found."

    _echo "Creating a new temporary subvolume at $SUBVOLUME_PATH_INPROGRESS... "
    btrfs subvolume create $SUBVOLUME_PATH_INPROGRESS
    _echo "  Temporary subvolume created."

else
    LAST_COMPLETE_BACKUP_DATE=`cd $DESTDIR && ls | grep -Ev -- '-inProgress$' | tail -n1`
    _echo "$LAST_COMPLETE_BACKUP_DATE"

    if [[ "$LAST_COMPLETE_BACKUP_DATE" == "$DATE_TODAY" ]] ; then
        _echo "NOTICE: Last complete backup has been created earlier today, quitting."
        exit
    fi

    LAST_COMPLETE_SUBVOLUME_PATH="$DESTDIR/$LAST_COMPLETE_BACKUP_DATE"

    _echo "Snapshotting the last complete backup into a new temporary subvolume at $SUBVOLUME_PATH_INPROGRESS... "
    btrfs subvolume snapshot "$LAST_COMPLETE_SUBVOLUME_PATH" "$SUBVOLUME_PATH_INPROGRESS"
    _echo "  Temporary subvolume snapshot created."

fi



### rsync data into the temporary subvolume
#

# Files
for DATADIR in `ls /data | grep -E '[-](stg|prod)$'` ; do
    _echo "Backing up /data/$DATADIR:"
    rsync -avX --numeric-ids --delete /data/$DATADIR $SUBVOLUME_PATH_INPROGRESS/

    # Rsync does not transfer over the system.* attributes.
    # Keep this section in sync with aokranj/infrasutrcture/users/roles/app_user.
    setfacl -m u:backup:rx $SUBVOLUME_PATH_INPROGRESS/$DATADIR

    _echo "  Backing up of /data/$DATADIR complete."
done

# Db exports
_echo "Backing up /backup/db-export:"
rsync -avX --numeric-ids --delete /backup/db-export $SUBVOLUME_PATH_INPROGRESS/

# Rsync does not transfer over the system.* attributes.
# Keep this section in sync with aokranj/infrasutrcture/users/roles/app_user.
setfacl -m u:backup:rx $SUBVOLUME_PATH_INPROGRESS/db-export

_echo "  Backing up of /backup/db-export complete."



### Create the final (read-only) snapshot
#
_echo "Creating the final (read-only) subvolume at $SUBVOLUME_PATH_FINAL:"
btrfs subvolume snapshot -r "$SUBVOLUME_PATH_INPROGRESS" "$SUBVOLUME_PATH_FINAL"
_echo "  Final (read-only) subvolume created."



### Remove the temporary subvolume
#
_echo "Removing the temporary subvolume $SUBVOLUME_PATH_INPROGRESS"
btrfs subvolume delete "$SUBVOLUME_PATH_INPROGRESS"
_echo "  Temporary subvolume removed."



### All done
#
_echo "Backup has been completed at `date`"
_echo
