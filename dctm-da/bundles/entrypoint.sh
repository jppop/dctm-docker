#!/bin/sh

dockerUsage() {
    cat 2>&1 <<EOF
This container must be linked with a broker (as 'broker') server.
Something like:
  docker run -dP --name dctm-da -h dctm-da --link broker:broker dctm-da
EOF
  exit 2
}

# check container links
[ -z "${BROKER_NAME}" ] && dockerUsage

CATALINA_OPTS="${CUSTOM_CATALINA_OPTS} ${CATALINA_OPTS}"
JAVA_OPTS="${CUSTOM_JAVA_OPTS} ${JAVA_OPTS}"

export CATALINA_OPTS JAVA_OPTS

# configure dfc
./bin/make-dfc.properties > conf/dfc.properties

echo "DFC Config file:"
cat conf/dfc.properties

echo "Using CATALINA_OPTS:   ${CATALINA_OPTS}"
echo "Using JAVA_OPTS:       ${JAVA_OPTS}"
exec "$@"
