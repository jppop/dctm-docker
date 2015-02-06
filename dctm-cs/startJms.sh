#!/bin/bash

repo=${REPOSITORY_NAME:-devbox}
user=${REPOSITORY_USER:-dmadmin}
passwd=${REPOSITORY_PWD:-dmadmin}

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

cd ${JMS_HOME}
exec ./startMethodServer.sh
