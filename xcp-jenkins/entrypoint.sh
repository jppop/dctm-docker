#!/bin/sh

dockerUsage() {
    cat 2>&1 <<EOF
This container must be linked with a xms-agent (as 'xms') server.
Something like:
  docker run -it --rm --name xcp-ci -h xcp-ci --link xms:xms dctm-xmstools
EOF
  exit 2
}

# check container links
[ -z "${XMS_NAME}" ] && dockerUsage

cat << __EOF__ > ${XMSTOOL_HOME}/config/xms-server.properties
dfc.docbroker.host[0]=
dfc.docbroker.port[0]=${DOCBROKER_PORT:-$DCTM_CS_PORT_1489_TCP_PORT}
xms-server-host = ${XMS_PORT_8080_TCP_ADDR:-xms}
xms-server-port = ${XMS_PORT_8080_TCP_PORT:-8080}
xms-server-schema = http
xms-server-context-path = xms-agent
__EOF__

exec "$@"
