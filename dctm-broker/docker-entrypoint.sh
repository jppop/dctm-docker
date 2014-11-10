#!/bin/sh

echo "Current User: $(id -un)"

. ${DM_HOME}/bin/dm_set_server_env.sh

if [ -d "${DOCUMENTUM_LOG}" ]; then
  TEELOG="| tee -a ${DOCUMENTUM_LOG}/broker.out"
else
  TEELOG=
fi

exec $DM_HOME/bin/dmdocbroker -port 1489 -init_file ${DOCUMENTUM}/dba/DctmBroker.ini $@ 2>&1
