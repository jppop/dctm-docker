#!/bin/bash

BACKUP_PATH=/shared/backup
[ -d $BACKUP_PATH ] || mkdir -p $BACKUP_PATH

rman target / <<EOF
configure retention policy to redundancy 1;
configure channel device type disk format "$BACKUP_PATH/%U" maxpiecesize 2 G;
shutdown immediate;
startup mount;
backup spfile;
backup as compressed backupset database;
alter database open;
delete noprompt obsolete;
list backup;
quit;
EOF
