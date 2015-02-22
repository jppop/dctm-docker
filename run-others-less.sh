#!/bin/sh

usage() {
    echo `basename $0`: ERROR: $* 1>&2
    cat 2>&1 <<EOF
usage: `basename $0` [--repo-name REPOSITORY_NAME] --repo-id host-ip
where
repo-name the name of the repository. Default from the REPOSITORY_NAME variable.
host-ip   is the ip address of the host
EOF
    exit 1
}

die() {
# display an error message ($1) and exit with a return code ($2)
	echo `basename $0`: ERROR: $1 1>&2
	exit $2
}

os=$(uname -s)
if [ "$os" = "Darwin" ]; then
    OPTS=`getopt r:i: "$*"`
else
    OPTS=`getopt -o r:i: -l repo-name:,host-ip: -- "$@"`
fi
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

# default values
repo=${REPOSITORY_NAME} HOST_IP=
while true ; do
    case "$1" in
        --repo-name|-r) repo=$2; shift 2;;
        --host-ip|-i) HOST_IP=$2; shift 2;;
        --) shift; break;;
        *) break;
    esac
done

[ -z "$repo" ]  && die "No repository name." 1
[ -z "$HOST_IP" ]  && die "No host ip." 1

container=$(docker ps --no-trunc -a --filter status=running | grep "dctm-cs:.*repo-name=$repo")
[ -z "$container" ]  && die "Container dctm-cs (with repo $repo) not found." 2

DOCUMENTUM=/opt/documentum
DOCUMENTUM_SHARED=${DOCUMENTUM}/shared
DM_HOME=${DOCUMENTUM}/product/7.1

# try to check if dctm-xs finished the installation
marker=$(docker exec -it dctm-cs ls -1 ${DM_HOME}/install/.stop-install)
[ -z "$marker" ]  && die "Seems dctm-cs installation not finished yet. Check the logs: docker logs -f dctm-cs" 3

# let's go
echo "Run extborker"
docker run -d -p 1589:1489 --name extbroker -h extbroker \
   --link dctm-cs:dctm-cs -e REPOSITORY_NAME=$repo -e HOST_IP=$HOST_IP dctm-broker
echo "Run xplore"
docker run -dP --name xplore -h xplore -e REPOSITORY_NAME=$repo --link dctm-cs:dctm-cs dctm-xplore
#echo "Run da"
#docker run -dP -it --name da -p 7002:8080 -e REPOSITORY_NAME=$repo --link dctm-cs:dctm-cs dctm-da
echo "run bam"
docker run -dP -p 8000:8080 --name bam -h bam -e REPOSITORY_NAME=$repo --link dctm-cs:dctm-cs --link dbora:dbora dctm-bam
#echo "run bps"
#docker run -dP -p 8010:8080 --name bps -h bps -e REPOSITORY_NAME=$repo --link dctm-cs:dctm-cs dctm-bps
echo "run Thumnail Server"
docker run -dP -p 8020:8080 --name ts -h ts -e REPOSITORY_NAME=$repo --link dctm-cs:dctm-cs dctm-ts dctm-ts
echo "run apphost"
docker run -dP -p 8040:8080 --name apphost -h apphost -e REPOSITORY_NAME=$repo --link dctm-cs:dctm-cs dctm-apphost
echo "run xms agent"
docker run -dP -p 7000:8080 --name xms -h xms -e REPOSITORY_NAME=$repo --volumes-from dctm-xmsdata \
   --link dctm-cs:dctm-cs --link bam:bam --link xplore:xplore --link apphost:apphost dctm-xmsagent

echo "All services started."
echo "Wait for the end of xms start"
docker logs -f xms
