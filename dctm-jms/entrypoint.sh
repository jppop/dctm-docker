#!/bin/bash

repo=${REPOSITORY_NAME:-devbox}
user=${REPOSITORY_USER:-dmadmin}
passwd=${REPOSITORY_PWD:-dmadmin}

# Source the environment with the dm_set_server_env script
[ -z "$ORACLE_HOME" ] && export ORACLE_HOME=/usr/lib/oracle/11.2/client64
[ -z "$TNS_ADMIN" ] && export TNS_ADMIN=${DOCUMENTUM}/dba
setEnvScript=$DM_HOME/bin/dm_set_server_env.sh
[ -r $setEnvScript ] && source $setEnvScript

echo "Waiting for the server availibility"

trap 'exit' SIGHUP SIGINT SIGTERM
echo -n .
iapi -q ${repo} -U${user} -P${passwd}  2>&1 >/dev/null
status=$?
while [[ $status -ne 0 ]]; do
	sleep 5
	iapi -q ${repo} -U${user} -P${passwd} 2>&1 >/dev/null
	status=$?
	echo -n .
 done
echo .
trap - SIGHUP SIGINT SIGTERM
echo "Content server alive."

echo "Update server config"
ipaddr=$(hostname -I | tr -d ' ')
iapi ${repo} -U${user} -P${passwd} -e << __EOF__
retrieve,c,dm_acs_config
set,c,l,acs_base_url
http://${ipaddr}:9080/ACS/servlet/ACS
save,c,l
#
set,c,serverconfig,app_server_uri[0]
http://${ipaddr}:9080/DmMethods/servlet/DoMethod
set,c,serverconfig,app_server_uri[1]
http://${ipaddr}:9080/DmMail/servlet/DoMail
save,c,serverconfig
#
retrieve,c,dm_jms_config
set,c,l,object_name
JMS $(hostname):9080 for ${repo}
set,c,l,base_uri[0]
http://${ipaddr}:9080/DmMethods/servlet/DoMethod
set,c,l,base_uri[1]
http://${ipaddr}:9080/DmMail/servlet/DoMail
save,c,l

reinit,c,
__EOF__

exec ./startMethodServer.sh
