#!/bin/sh

repo=${REPOSITORY_NAME:-devbox}
user=${REPOSITORY_USER:-dmadmin}
passwd=${REPOSITORY_PWD:-dmadmin}

dockerUsage() {
    cat 2>&1 <<EOF
This container must be linked with a content server (as 'dctm-cs') server.
Something like:
  docker run -d -p 1589:1489 --name extbroker -h extbroker --link dctm-cs:dctm-cs -e HOST_IP=192.168.59.103 dctm-broker
EOF
  exit 2
}

# check container links
[ -z "${DCTM_CS_NAME}" -o -z "${HOST_IP}" ] && dockerUsage

. ${DM_HOME}/bin/dm_set_server_env.sh

cat << __EOF__ > ${DOCUMENTUM_SHARED}/config/dfc.properties
dfc.data.dir=/opt/documentum/shared
dfc.tokenstorage.dir=/opt/documentum/shared/apptoken
dfc.tokenstorage.enable=false
dfc.session.secure_connect_default=try_native_first
dfc.docbroker.host[0]=${DCTM_CS_PORT_1489_TCP_ADDR}
dfc.docbroker.port[0]=${DCTM_CS_PORT_1489_TCP_PORT}
dfc.session.secure_connect_default=try_native_first
__EOF__

# add translation info
if [ -z $(grep TRANSLATION ${DOCUMENTUM}/dba/DctmBroker.ini) ]; then
	cat >> ${DOCUMENTUM}/dba/DctmBroker.ini << __EOF__ 
[TRANSLATION]
host=${HOST_IP}=${DCTM_CS_PORT_49000_TCP_ADDR}
__EOF__
else
	sed -i "s/^host=.*$/host=${HOST_IP}=${DCTM_CS_PORT_49000_TCP_ADDR}/" ${DOCUMENTUM}/dba/DctmBroker.ini
fi

# tell the content server to project its information to us
(
	# wait the broker has started
	pid=$(ps -A -o pid,cmd|grep 'dmdocbroker -port' | grep -v grep | awk '{print $1}')
	while [ -z "$pid" ]; do
		sleep 5
		pid=$(ps -A -o pid,cmd|grep 'dmdocbroker -port' | grep -v grep | awk '{print $1}')
	done

	# wait for the repository
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

	iapi ${repo} -U${user} -P${passwd} -e << __EOF__
fetch,c,serverconfig
set,c,l,projection_targets
$(hostname -i)
set,c,l,projection_proxval
10
set,c,l,projection_ports
1489
set,c,l,projection_notes
External broker
set,c,l,projection_enable
T
reinit,c
save,c,l
__EOF__

	echo "Project target updated"
) &

exec $DM_HOME/bin/dmdocbroker -port 1489 -init_file ${DOCUMENTUM}/dba/DctmBroker.ini $@ 2>&1 \
      | tee ${DOCUMENTUM_LOG}/broker.out
