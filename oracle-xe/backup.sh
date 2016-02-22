#!/bin/bash

BACKUP_PATH=/shared/backup

die() {
# display an error message ($1) and exit with a return code ($2)
	echo `basename $0`: ERROR: $1 1>&2
	exit $2
}

OPTS=`getopt -o u:d: -l user-name:,backup-dir: -- "$@"`
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

# default values
userName= backupDir=$BACKUP_PATH
while true ; do
    case "$1" in
        --user-name|-u) userName=$2; shift 2;;
        --backup-dir|-d) backupDir=$2; shift 2;;
        --) shift; break;;
    esac
done

[ -z "${userName}" ] && die "User name not provided" 1

timestamp=$(date +%Y%m%d-%H%M%S)
userBackupDir=$backupDir/$userName/$timestamp
[ -d $userBackupDir ] || mkdir -p $userBackupDir
userBackupName=${userName}_dir

sqlplus -s system/oracle@localhost//XE <<EOF
CREATE OR REPLACE DIRECTORY $userBackupName AS '$userBackupDir';
GRANT READ, WRITE ON DIRECTORY $userBackupName TO $userName;
EOF

expdp system/oracle@localhost//XE schemas=$userName directory=$userBackupName dumpfile=${userName}.dmp logfile=expdp.log
