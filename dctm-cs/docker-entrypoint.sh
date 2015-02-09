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

OPTS=`getopt -o r:i:b -l no-bpm,repo-name:,repo-id: -- "$@"`
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

# default values
REPOSITORY_ID=$(od -vAn -N3 -tu4 < /dev/urandom) INSTALL_BPM=1
while true ; do
    case "$1" in
        --repo-name|-r) REPOSITORY_NAME=$2; shift 2;;
        --repo-id|-i) REPOSITORY_ID=$2; shift 2;;
        --no-bpm|-b) INSTALL_BPM=0; shift ;;
        --) shift; break;;
    esac
done

if [ $REPOSITORY_NAME == "abitrandom" ]; then
    # generate a random repo name (prefix devbox and 4 alphanumeric chars)
    r=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
    REPOSITORY_NAME=devbox$r
fi

function installProcessEngine() {
  if [ ! -d ${JMS_HOME}/DctmServer_MethodServer/deployments/bpm.ear ]; then
    echo "Installing BPM application.."
    mkdir /tmp/ProcessEngine && cd /tmp/ProcessEngine
    tar -xvf /bundles/Process_Engine_linux.tar
    cat > pe-install.ini << __EOF__
[COMMON]
DCTM_LOCATION=$DOCUMENTUM

[DFC]
DOCBROKER_HOST=broker
DOCBROKER_PORT=1489

[APPSERVER]
USERNAME=dmadmin
SECURE.PASSWORD=dmadmin
SERVER_HTTP_PORT=9080

[PROCESS_ENGINE]
GLOBAL_REGISTRY_ADMIN_USER_NAME=dm_bof_registry
SECURE.GLOBAL_REGISTRY_ADMIN_PASSWORD=dm_bof_registry
GLOBAL_REGISTRY_ADMIN_DOMAIN=

__EOF__

    chmod u+x ./peSetup.bin
    ./peSetup.bin -f pe-install.ini -i silent
    cat logs/install.log
    cd -
    mv /tmp/ProcessEngine/logs ${DM_HOME}/install/logs/ProcessEngine
    rm -rf /tmp/ProcessEngine
  fi
}

if [ ! -d ${DOCUMENTUM}/dba/config/${REPOSITORY_NAME} ]; then
    echo "Installing the repository $REPOSITORY_NAME ($REPOSITORY_ID)"
    # create the reponse file
    cd ${DM_HOME}/install
    ./delete-schema.sh $REPOSITORY_NAME 2>&1 > delete-schema.out
    ./create-responsefile.sh $REPOSITORY_NAME $REPOSITORY_ID > $REPOSITORY_NAME-install.properties

    # launch the installer
    ./dm_launch_server_config_program.sh -f $REPOSITORY_NAME-install.properties
    echo "done"

    if [ $INSTALL_BPM -eq 1 ]; then
        installProcessEngine
    fi

    echo "Stopping the repository"
    ${DOCUMENTUM}/dba/dm_shutdown_${REPOSITORY_NAME}
fi

# Set the umask to zero as to not interfere with the server's creation
# of files/directories
umask 0
# Hard-code the LANG environment variable to ensure the server runs
# LANG_TERRITORY.CHARSET for Oracle.
NLS_LANG=AMERICAN_AMERICA.UTF8 export NLS_LANG
# Hard-code the LANG environment variable to ensure the server runs
# in the standard LANG locale.  Even when installed with the internationalization
# options the server expectes to run in the standard language environment.
LANG=C export LANG

# Start the server

export REPOSITORY_NAME JMS_HOME
function shutdown() {
  ${JMS_HOME}/stopMethodServer.sh
  $DOCUMENTUM/dba/dm_shutdown_$REPOSITORY_NAME
}
trap shutdown SIGHUP SIGINT SIGTERM

echo "Starting the repository ${REPOSITORY_NAME}.."

echo "+ starting jms in background.."
${JMS_HOME}/startJms.sh > ${DOCUMENTUM_LOG}/jms.out &

cd ${DM_HOME}/bin
./documentum -docbase_name $REPOSITORY_NAME -security acl \
  -init_file $DOCUMENTUM/dba/config/$REPOSITORY_NAME/server.ini 2>&1 | tee -a ${DOCUMENTUM_LOG}/repository.log


