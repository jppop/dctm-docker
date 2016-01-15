#!/bin/sh

repo=${REPOSITORY_NAME:-devbox}
user=${REPOSITORY_USER:-dmadmin}
passwd=${REPOSITORY_PWD:-dmadmin}

echo "Waiting for the repository $repo availibility"

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

hostIp=${HOST_IP:-localhost}
tsPort=${TS_PORT:-8020}

idql ${repo} -U${user} -P${passwd} -e 2>&1 << EOF
echo "Updating Thumbnail Server base url"
update dm_filestore objects
set base_url = 'http://${hostIp}:${tsPort}/thumbsrv/getThumbnail?'
where name = 'thumbnail_store_01';
go
exit
EOF
