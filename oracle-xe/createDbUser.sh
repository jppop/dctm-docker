#!/bin/bash

die() {
# display an error message ($1) and exit with a return code ($2)
	echo `basename $0`: ERROR: $1 1>&2
	exit $2
}

currentdir=$(pwd)

OPTS=`getopt -o u:p:t: -l user-name:,pwd:,tbs-name: -- "$@"`
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

# default values
userName= userPwd= tablespace=
forbroker='false'
while true ; do
    case "$1" in
        --user-name|-u) userName=$2; shift 2;;
        --pwd|-p) userPwd=$2; shift 2;;
        --tbs-name|-t) tablespace=$2; shift 2;;
        --) shift; break;;
    esac
done

[ -z "${userName}" ] && die "User name not provided" 1
[ -z "${userPwd}" ] && userPwd=${userName}
[ -z "${tablespace}" ] && tablespace=${userName}

# get default data file location
sysdbf=`sqlplus -s / as sysdba <<EOF
set heading off
select file_name from DBA_DATA_FILES where TABLESPACE_NAME='SYSTEM';
exit
EOF
`
[ -z "${sysdbf}" ] || dbfpath=$(dirname $sysdbf)
[ -z "${dbfpath}" ] && dbfpath=/u01/app/oracle/oradata/XE

echo "Creating ${userName} user.."
echo " + Tablespace will be located into: $dbfpath"

sqlplus -s / as sysdba << EOF 2>&1 >/dev/null

DROP USER ${userName} CASCADE;
ALTER TABLESPACE ${tablespace} OFFLINE;
DROP TABLESPACE ${tablespace} INCLUDING CONTENTS AND DATAFILES;
EOF

sqlplus -s / as sysdba << EOF
CREATE TABLESPACE ${tablespace}
DATAFILE
'${dbfpath}/${tablespace}.dbf'
SIZE 20M REUSE;

ALTER DATABASE
DATAFILE
'${dbfpath}/${tablespace}.dbf'
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

create user ${userName} identified by ${userPwd} default tablespace
   ${tablespace} temporary tablespace TEMP;
grant connect, resource, create view, create sequence to ${userName};
exit;
EOF
