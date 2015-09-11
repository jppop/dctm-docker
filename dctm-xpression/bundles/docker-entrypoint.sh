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
This container must be linked with the db (as 'dbora') and the cs (as dctm-cs) server.
Something like:
  docker run -dP --name xpress -h xpress --link dbora:dbora --link dctm-cs:dctm-cs xpress [--repo-name REPOSITORY_NAME]
EOF
  exit 2
}

die() {
# display an error message ($1) and exit with a return code ($2)
	echo `basename $0`: ERROR: $1 1>&2
	exit $2
}

# check container links
[ -z "${DBORA_NAME}" -o -z "${DCTM_CS_NAME}" ] && dockerUsage

if [ ! -f ${XPRESS_HOME}/xPressionVersion.properties ]; then
	# install xPression Server
	/bundles/install-xpression.sh
fi

DFC_DATA_DIR=${DOCUMENTUM_SHARED}/data
[ -d "${DFC_DATA_DIR}" ] || mkdir -p ${DFC_DATA_DIR}

cat > ${DOCUMENTUM_SHARED}/config/dfc.properties << __EOF__
dfc.name=xpression
dfc.data.dir=${DFC_DATA_DIR}
dfc.tokenstorage.enable=false
dfc.docbroker.host[0]=${DOCBROKER_ADR:-$DCTM_CS_PORT_1489_TCP_ADDR}
dfc.docbroker.port[0]=${DOCBROKER_PORT:-$DCTM_CS_PORT_1489_TCP_PORT}
dfc.session.secure_connect_default=try_native_first
dfc.globalregistry.repository=${REPOSITORY_NAME:-devbox}
dfc.globalregistry.username=${REGISTRY_USER:-dm_bof_registry}
dfc.globalregistry.password=${REGISTRY_CRYPTPWD:-AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv}
dfc.session.allow_trusted_login = false
__EOF__

. ~/.bash_profile
cd ${XPRESS_HOME}/jboss-7.1
exec bin/startxPressionServer.sh

