#!/bin/sh

dockerUsage() {
    cat 2>&1 <<EOF
This container must be linked with the cs (as 'dctm-cs') and bam (as bam) servers.
Something like:
  docker run -dP --name apphost -h xms --link dctm-cs:dctm-cs --link bam:bam dctm-apphost
EOF
  exit 2
}

# check container links
[ -z "${DCTM_CS_NAME}" -o -z "${BAM_NAME}" ] && dockerUsage

[ -z "$MEM_XMSX" ] && MEM_XMSX=1024m

echo CATALINA_OPTS=\"${CUSTOM_CATALINA_OPTS} -Xmx${MEM_XMSX} ${CATALINA_OPTS}\" > ${CATALINA_HOME}/bin/setenv.sh
echo JAVA_OPTS=\"${CUSTOM_JAVA_OPTS} ${JAVA_OPTS}\" >> ${CATALINA_HOME}/bin/setenv.sh
echo CATALINA_OUT=\"${CUSTOM_CATALINA_OUT}\" >> ${CATALINA_HOME}/bin/setenv.sh
cat ${CATALINA_HOME}/bin/setenv.sh

# configure dfc
DFC_DATADIR=${CATALINA_HOME}/temp/dfc
[ -d ${DFC_DATADIR} ] || mkdir -p ${DFC_DATADIR}

cat << __EOF__ > ${CATALINA_HOME}/conf/dfc.properties
dfc.name=apphost
dfc.data.dir=${DFC_DATADIR}
dfc.tokenstorage.enable=false
dfc.docbroker.host[0]=${DOCBROKER_ADR:-$DCTM_CS_PORT_1489_TCP_ADDR}
dfc.docbroker.port[0]=${DOCBROKER_PORT:-$DCTM_CS_PORT_1489_TCP_PORT}
dfc.session.secure_connect_default=try_native_first
dfc.globalregistry.repository=${REGISTRY_NAME:-devbox}
dfc.globalregistry.username=${REGISTRY_USER:-dm_bof_registry}
dfc.globalregistry.password=${REGISTRY_CRYPTPWD:-AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv}
dfc.session.allow_trusted_login = false
__EOF__

echo "xcp.repository.name=${REPOSITORY_NAME}" > conf/deployment.properties

echo "DFC Config file:"
cat conf/dfc.properties

echo "Using CATALINA_OPTS:   ${CATALINA_OPTS}"
echo "Using JAVA_OPTS:       ${JAVA_OPTS}"
exec "$@"
