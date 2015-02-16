#!/bin/bash

dockerUsage() {
    cat 2>&1 <<EOF
This container must be linked with a cs (as 'dctm-cs') server.
Something like:
  docker run -dP --name xplore -h xplore --link dctm-cs:dctm-cs dctm-xplore
EOF
  exit 2
}

# check container links
[ -z "${DCTM_CS_NAME}" ] && dockerUsage

if [ ! -d ${XPLORE_HOME}/config ]; then
	cd /tmp/xplore-install/
	./xplore.sh
fi

cd ${XPLORE_HOME}/jboss7.1.1/server
./startPrimaryDsearch.sh > $XPLORE_LOGDIR/PrimaryDsearch.out &
exec ./startindexagent.sh | tee $XPLORE_LOGDIR/indexagent.out


