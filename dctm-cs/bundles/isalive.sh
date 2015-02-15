#!/bin/bash

usage() {
    echo `basename $0`: ERROR: $* 1>&2
    cat 2>&1 <<EOF
usage: `basename $0` [--repository|-r REPOSITORY_NAME] [--username|-u username] [--password|-p pwd]

default repository: ${REPOSITORY_NAME}
EOF
    exit 1
}

ie() {
# display an error message ($1) and exit with a return code ($2)
	echo `basename $0`: ERROR: $1 1>&2
	exit $2
}

OPTS=`getopt -o r:u:p -l repository,username:,password:,help -- "$@"`
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

# default values
repo=${REPOSITORY_NAME} user=$(id -un) passwd=
while true ; do
    case "$1" in
        --repository|-r) repo=$2; shift 2;;
        --username|-u) username=$2; shift 2;;
        --password|-p) passwd=$2; shift 2;;
		--help) usage;;
        --) shift; break;;
    esac
done
[ -z "$user" ] && user=$(id -un)

# Source the environment with the dm_set_server_env script
[ -z "$ORACLE_HOME" ] && export ORACLE_HOME=/usr/lib/oracle/11.2/client64
[ -z "$TNS_ADMIN" ] && export TNS_ADMIN=${DOCUMENTUM}/dba
setEnvScript=$DM_HOME/bin/dm_set_server_env.sh
[ -r $setEnvScript ] && source $setEnvScript

echo "Waiting for the server availibility"

trap 'exit 1' SIGHUP SIGINT SIGTERM
echo -n .
iapi -q ${repo} -U${user} -P${passwd}  2>&1 >/dev/null
status=$?
while [[ $status -ne 0 ]]; do
	sleep 5
	iapi -q ${repo} -U${user} -P${passwd} 2>&1 >/dev/null
	status=$?
	echo -n .
 done
echo .
trap - SIGHUP SIGINT SIGTERM
exit $status