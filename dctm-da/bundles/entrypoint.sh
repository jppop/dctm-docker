#!/bin/sh

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
