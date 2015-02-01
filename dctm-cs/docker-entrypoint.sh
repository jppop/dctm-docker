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

env > /tmp/envA.out

REPOSITORY_NAME=${2:-devbox}

#REPOSITORY_ID=${3:-$RANDOM}
r=$(od -vAn -N3 -tu4 < /dev/urandom)
REPOSITORY_ID=${3:-$r}

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

if [ $REPOSITORY_NAME == "abitrandom" ]; then
    # generate a random repo name (prefix devbox and 4 alphanumeric chars)
    r=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
    REPOSITORY_NAME=devbox$r
fi

if [ ! -d ${DOCUMENTUM}/dba/config/${REPOSITORY_NAME} ]; then
    echo "Installing the repository $REPOSITORY_NAME ($REPOSITORY_ID)"
    # create the reponsfile
    cd ${DM_HOME}/install
    ./delete-schema.sh $REPOSITORY_NAME 2>&1 > delete-schema.out
    ./create-responsefile.sh $REPOSITORY_NAME $REPOSITORY_ID > $REPOSITORY_NAME-install.properties
    ./dm_launch_server_config_program.sh -f $REPOSITORY_NAME-install.properties
    echo "done"
    echo "Stopping the repository"
    ${DOCUMENTUM}/dba/dm_shutdown_${REPOSITORY_NAME}
fi

# Set the umask to zero as to not interfere with the server's creation
# of files/directories
umask 0
# Hard-code NLS_LANG environmental variable at startup to the format of 
# LANG_TERRITORY.CHARSET for Oracle.
NLS_LANG=AMERICAN_AMERICA.UTF8 export NLS_LANG
# Hard-code the LANG environment variable to ensure the server runs
# LANG_TERRITORY.CHARSET for Oracle.
NLS_LANG=AMERICAN_AMERICA.UTF8 export NLS_LANG
# Hard-code the LANG environment variable to ensure the server runs
# in the standard LANG locale.  Even when installed with the internationalization
# options the server expectes to run in the standard language environment.
LANG=C export LANG
# Start the server
logfile=${DOCUMENTUM}/dba/log/repository.log
touch $logfile
# link the repository log to the folder where it will forwarded to a centralized place (FUTURE: logstash)
sudo ln -s $logfile /var/log/forwarded-logs/repository.log

export REPOSITORY_NAME
function shutdown() {
  $DOCUMENTUM/dba/dm_shutdown_$REPOSITORY_NAME
}
trap shutdown SIGHUP SIGINT SIGTERM

env > /tmp/envB.out

echo "Starting the repository ${REPOSITORY_NAME}.."
${DM_HOME}/bin/documentum -docbase_name $REPOSITORY_NAME -security acl \
  -init_file $DOCUMENTUM/dba/config/$REPOSITORY_NAME/server.ini 2>&1 | tee -a ${DOCUMENTUM}/dba/log/repository.log


