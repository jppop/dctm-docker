#!/bin/bash

usage() {
    echo `basename $0`: ERROR: $* 1>&2
    cat 2>&1 <<EOF
usage: `basename $0` [--repo-name REPOSITORY_NAME] [--repo-id REPOSITORY_ID]
EOF
    exit 1
}

dockerUsage() {
    cat 2>&1 <<EOF
This container must be linked with a broker (as 'broker') and a db (as 'dbora') server.
Something like:
  docker run -dP --name dctm-cs -h dctm-cs --link dbora:dbora --link broker:broker dctm-cs
EOF
  exit 2
}

die() {
# display an error message ($1) and exit with a return code ($2)
	echo `basename $0`: ERROR: $1 1>&2
	exit $2
}

# check container links
[ -z "${BROKER_NAME}" -o -z "${DBORA_NAME}" ] && dockerUsage

# Source the environment with the dm_set_server_env script
[ -z "$ORACLE_HOME" ] && export ORACLE_HOME=/usr/lib/oracle/11.2/client64
[ -z "$TNS_ADMIN" ] && export TNS_ADMIN=${DOCUMENTUM}/dba
setEnvScript=$DM_HOME/bin/dm_set_server_env.sh
[ -r $setEnvScript ] && source $setEnvScript

REPOSITORY_NAME=${2:-myrepo}
REPOSITORY_ID=${3:-$RANDOM}

OPTS=`getopt -o r:i: -l repo-name:,repo-id: -- "$@"`
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

while true ; do
    case "$1" in
        --repo-name) REPOSITORY_NAME=$2; shift 2;;
        --repo-id) REPOSITORY_ID=$2; shift 2;;
        --) shift; break;;
    esac
done

if [ ! -d ${DOCUMENTUM}/dba/config/${REPOSITORY_NAME} ]; then
    echo "Installing the repository $REPOSITORY_NAME ($REPOSITORY_ID)"
    # create the reponsfile
    cd ${DM_HOME}/install
    ./delete-schema.sh $REPOSITORY_NAME
    ./create-responsefile.sh $REPOSITORY_NAME $REPOSITORY_ID > $REPOSITORY_NAME-install.properties
    ./dm_launch_server_config_program.sh -f $REPOSITORY_NAME-install.properties
    echo "done"
fi

# TODO: start the repo here
while :
do
    echo $(date)
    sleep 10
done
