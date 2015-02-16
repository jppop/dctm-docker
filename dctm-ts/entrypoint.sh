#!/bin/bash

dockerUsage() {
    cat 2>&1 <<EOF
This container must be linked with a content server (as 'dctm-cs') server.
Something like:
  docker run -dP --name ts -h ts --link dctm-cs:dctm-cs dctm-ts
EOF
  exit 2
}

# check container links
[ -z "${DCTM_CS_NAME}" ] && dockerUsage

repo=${REPOSITORY_NAME:-devbox}
user=${REPOSITORY_USER:-dmadmin}
passwd=${REPOSITORY_PWD:-dmadmin}

# Source the environment with the dm_set_server_env script
[ -z "$ORACLE_HOME" ] && export ORACLE_HOME=/usr/lib/oracle/11.2/client64
[ -z "$TNS_ADMIN" ] && export TNS_ADMIN=${DOCUMENTUM}/dba
setEnvScript=$DM_HOME/bin/dm_set_server_env.sh
[ -r $setEnvScript ] && source $setEnvScript


# append the registry information to the dfc.properties
if [ -z $(grep dfc.globalregistry.repository ${DOCUMENTUM_SHARED}/config/dfc.properties) ]; then
	cat >> ${DOCUMENTUM_SHARED}/config/dfc.properties <<__EOF__ 
dfc.docbroker.host[0]=${DOCBROKER_ADR:-$DCTM_CS_PORT_1489_TCP_ADDR}
dfc.docbroker.port[0]=${DOCBROKER_PORT:-$DCTM_CS_PORT_1489_TCP_PORT}
dfc.globalregistry.repository=${REGISTRY_NAME:-devbox}
dfc.globalregistry.username=${REGISTRY_USER:-dm_bof_registry}
dfc.globalregistry.password=${REGISTRY_CRYPTPWD:-AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv}
dfc.session.allow_trusted_login = true
dfc.name=jms
__EOF__
fi

echo "Waiting for the server availibility"

trap 'exit' SIGHUP SIGINT SIGTERM
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
echo "Content server alive."

if [ ! -f ${DM_HOME}/install/.ts-configured ]; then
	echo "Registering the repository ${REPOSITORY_NAME}.."
	cat > ${TS_HOME}/configurator/tsConfig.ini << __EOF__
[[COMMON]
SECURE.INSTALL_OWNER_PASSWORD=admin

[THUMBNAIL_SERVER]
DOCBASE=${REPOSITORY_NAME}
#SERVER=${REPOSITORY_NAME}
# Docbase User Info
DOCBASE_SUPERUSER=${REPOSITORY_USER:-dmadmin}
DOCBASE_SUPERUSER_PASSWORD=${REPOSITORY_PWD:-dmadmin}
DOMAIN=
__EOF__

	cd ${TS_HOME}/configurator
	./thumbServerLinuxConfigurator.bin -config ./tsConfig.ini -silent && \
		touch ${DM_HOME}/install/.ts-configured
	cd -
#	echo "stopping thunbnail server.."
#	${TS_HOME}/container/bin/shutdown.sh
	pid=$(ps aux | grep thumb | grep -v grep |  awk '{print $2}')
	[ -z "$pid" ] || kill -9 $pid
fi

cd ${TS_HOME}/container/bin
exec "$@"

