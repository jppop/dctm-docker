#!/bin/bash

BACKUP_PATH=/shared/backup

die() {
# display an error message ($1) and exit with a return code ($2)
	echo `basename $0`: ERROR: $1 1>&2
	exit $2
}

OPTS=`getopt -o u:d:t: -l user-name:,dump-file:tablespace: -- "$@"`
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

# default values
userName= dumpFile= tablespace=
while true ; do
    case "$1" in
        --user-name|-u) userName=$2; shift 2;;
        --dump-file|-d) dumpFile=$2; shift 2;;
        --tablespace|-t) tablespace=$2; shift 2;;
        --) shift; break;;
    esac
done

[ -z "${userName}" ] && die "User name not provided" 1
[ -z "${dumpFile}" ] && die "dumpFile not provided" 1
[ -r "${dumpFile}" ] || die "dumpFile not found" 1

timestamp=$(date +%Y%m%d-%H%M%S)
userBackupDir=$( cd "$( dirname "$dumpFile" )" && pwd )
userBackupName=${userName}_dir
dumpBasename=$(basename $dumpFile)

sqlplus -s system/oracle@localhost//XE <<EOF
CREATE OR REPLACE DIRECTORY $userBackupName AS '$userBackupDir';
GRANT READ, WRITE ON DIRECTORY $userBackupName TO $userName;
EOF

[ -z "$tablespace" ] && remapOpt= || remapOpt=REMAP_TABLESPACE=\($tablespace\)

impdp system/oracle@localhost//XE schemas=$userName directory=$userBackupName dumpfile=$dumpBasename logfile=impdp.log \
 TABLE_EXISTS_ACTION=replace "$remapOpt"
