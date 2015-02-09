#!/bin/bash

if [ ! -d ${XPLORE_HOME}/config ]; then
	cd /tmp/xplore-install/
	./xplore.sh
fi

cd ${XPLORE_HOME}/jboss7.1.1/server
./startPrimaryDsearch.sh > $XPLORE_LOGDIR/PrimaryDsearch.out &
exec ./startindexagent.sh | tee $XPLORE_LOGDIR/indexagent.out


