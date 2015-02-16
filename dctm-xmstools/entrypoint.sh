#!/bin/sh

dockerUsage() {
    cat 2>&1 <<EOF
This container must be linked with a xms-agent (as 'xms') server.
Something like:
  docker run -it --rm --name xms-tools -h xms-tools --link xms:xms [-e XMSINIT=true] dctm-xmstools
EOF
  exit 2
}

# check container links
[ -z "${XMS_NAME}" ] && dockerUsage

cat << __EOF__ > ${XMSTOOL_HOME}/config/xms-server.properties
xms-server-host = xms
xms-server-port = 8080
xms-server-schema = http
xms-server-context-path = xms-agent
__EOF__

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
