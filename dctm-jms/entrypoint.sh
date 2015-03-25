#!/bin/bash

repo=${REPOSITORY_NAME:-devbox}
user=${REPOSITORY_USER:-dmadmin}
passwd=${REPOSITORY_PWD:-dmadmin}

# Source the environment with the dm_set_server_env script
[ -z "$ORACLE_HOME" ] && export ORACLE_HOME=/usr/lib/oracle/11.2/client64
[ -z "$TNS_ADMIN" ] && export TNS_ADMIN=${DOCUMENTUM}/dba
setEnvScript=$DM_HOME/bin/dm_set_server_env.sh
[ -r $setEnvScript ] && source $setEnvScript


# append the registry information to the dfc.properties
if [ -z $(grep dfc.globalregistry.repository ${DOCUMENTUM_SHARED}/config/dfc.properties) ]; then
	cat >> ${DOCUMENTUM_SHARED}/config/dfc.properties <<__EOF__ 
dfc.globalregistry.repository=${REPOSITORY_NAME:-devbox}
dfc.globalregistry.username=${REGISTRY_USER:-dm_bof_registry}
dfc.globalregistry.password=${REGISTRY_CRYPTPWD:-AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv}
dfc.session.allow_trusted_login = true
dfc.name=jms
__EOF__
fi

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

if [ ! -d ${JMS_HOME}/DctmServer_MethodServer/deployments/bpm.ear ]; then
	echo "Installing BPM application.."
	mkdir /tmp/ProcessEngine && cd /tmp/ProcessEngine
	tar -xvf /bundles/BPM/Process_Engine_linux.tar
#	cp /bundles/BPM/pe-install.ini
	cat > pe-install.ini << __EOF__
[COMMON]
DCTM_LOCATION=$DOCUMENTUM

[DFC]
DOCBROKER_HOST=broker
DOCBROKER_PORT=1489

[APPSERVER]
USERNAME=dmadmin
SECURE.PASSWORD=dmadmin
SERVER_HTTP_PORT=9080

[PROCESS_ENGINE]
GLOBAL_REGISTRY_ADMIN_USER_NAME=${REGISTRY_USER}
SECURE.GLOBAL_REGISTRY_ADMIN_PASSWORD=${REGISTRY_PWD}
GLOBAL_REGISTRY_ADMIN_DOMAIN=

__EOF__

	chmod u+x ./peSetup.bin
	./peSetup.bin -f pe-install.ini -i silent
	cat logs/install.log

	# disable ip checking
	cp --backup=numbered /bundles/BPM/bpm-web.xml \
		${JMS_HOME}/DctmServer_MethodServer/deployments/bpm.ear/bpm.war/WEB-INF/web.xml
	cd -
fi

if [ -f ${DM_HOME}/install/.bpm.dar.installed ]; then
	echo "Installing dars.."
	cd ${DM_HOME}/install
	for dar in TCMReferenceProject.dar Forms.dar CollaborationServices.dar xcp.dar BPM.dar DcsAttachment.dar; do
	  ./dar-deploy.sh -r ${REPOSITORY_NAME} -u ${REGISTRY_USER} -p ${REGISTRY_PWD} -d $dar
	done
	touch ${DM_HOME}/install/.bpm.dar.installed
fi

echo "Update server, jms and acs config with the hostname ip address"
ipaddr=$(hostname -I | tr -d ' ')

iapi ${repo} -U${user} -P${passwd} -e << __EOF__
retrieve,c,dm_acs_config
set,c,l,acs_base_url
http://${ipaddr}:9080/ACS/servlet/ACS
save,c,l
# update server config
set,c,serverconfig,app_server_name[0]
do_method
set,c,serverconfig,app_server_name[1]
do_mail
set,c,serverconfig,app_server_name[2]
do_bpm
set,c,serverconfig,app_server_uri[0]
http://${ipaddr}:9080/DmMethods/servlet/DoMethod
set,c,serverconfig,app_server_uri[1]
http://${ipaddr}:9080/DmMail/servlet/DoMail
set,c,serverconfig,app_server_uri[2]
http://${ipaddr}:9080/bpm/servlet/DoMethod
save,c,serverconfig
#
retrieve,c,dm_jms_config
set,c,l,object_name
JMS $(hostname):9080 for ${repo}
set,c,l,servlet_name[0]
dm_method
set,c,l,servlet_name[1]
dm_mail
set,c,l,servlet_name[2]
dm_bpm
set,c,l,base_uri[0]
http://${ipaddr}:9080/DmMethods/servlet/DoMethod
set,c,l,base_uri[1]
http://${ipaddr}:9080/DmMail/servlet/DoMail
set,c,l,base_uri[2]
http://${ipaddr}:9080/bpm/servlet/DoMethod
set,c,l,supported_protocol[0]
http
set,c,l,supported_protocol[1]
http
set,c,l,supported_protocol[2]
http
save,c,l

reinit,c,
__EOF__

cd ${JMS_HOME}
exec ./startMethodServer.sh
