#!/bin/sh

echo "Current User: $(id -un)"

. ${DM_HOME}/bin/dm_set_server_env.sh

exec $DM_HOME/bin/dmdocbroker -port 1489 -init_file ${DOCUMENTUM}/dba/DctmBroker.ini $@ 2>&1 \
      | tee ${DOCUMENTUM_LOG}/broker.out
