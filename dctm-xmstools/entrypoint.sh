#!/bin/sh

dockerUsage() {
    cat 2>&1 <<EOF
This container must be linked with a xms-agent (as 'xms') server.
Something like:
  docker run -it --rm --name xms-tools -h xms-tools --link xms:xms [-e XMSINIT=true] dctm-xmstools
EOF
  exit 2
}

# NEW: no more checked as the container can be used with any xMS Agent.
# check container links
#[ -z "${XMS_NAME}" ] && dockerUsage

xms_agent_host=$XMS_PORT_8080_TCP_ADDR
xms_agent_port=8080
[ -z "${USER_XMS_SERVER}" ] || xms_agent_host=$USER_XMS_SERVER
[ -z "${USER_XMSAGENT_PORT}" ] || xms_agent_port=$USER_XMSAGENT_PORT

cat << __EOF__ > ${XMSTOOL_HOME}/config/xms-server.properties
xms-server-host = ${xms_agent_host}
xms-server-port = ${xms_agent_port}
xms-server-schema = http
xms-server-context-path = xms-agent
__EOF__
echo "xms-server.properties:"
cat ${XMSTOOL_HOME}/config/xms-server.properties

if [ "${XMSINIT}" = "true" ]; then
	cd bin

	# set password
	printf "adminPass1\nadminPass1\nexit\n" | ./xms.sh

#	./xms.sh -u admin -p adminPass1 -f /bundles/init.script
	echo "Registering Docker Environnement Template..."
	./xms.sh -u admin -p adminPass1 -f /bundles/init-docker.script

	touch ${XMSTOOL_HOME}/config/.initialized
fi
exec "$@"
