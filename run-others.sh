#!/bin/bash

usage() {
    echo `basename $0`: ERROR: $* 1>&2
    cat 2>&1 <<EOF
usage: `basename $0` [--repo-name REPOSITORY_NAME] --host-ip host-ip
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
    OPTS=`getopt r:i:c:l "$*"`
else
    OPTS=`getopt -o r:i:c:l: -l repo-name:,host-ip:containers:less-containers -- "$@"`
fi
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

if [ -f .dctm-docker.env ]; then
    source .dctm-docker.env
fi

# default values
repo=$REPOSITORY_NAME
containers=extbroker,xplore,da,bam,bps,ts,apphost,xms
while true ; do
    case "$1" in
        --repo-name|-r) repo=$2; shift 2;;
        --host-ip|-i) HOST_IP=$2; shift 2;;
        --containers|-c) containers=$2; shift 2;;
        --less-containers|-l) containers=extbroker,xplore,bam,ts,apphost,xms; shift 1;;
        --) shift; break;;
    esac
done

[ -z "$repo" ]  && die "No repository name." 1
[ -z "$HOST_IP" ]  && die "No host ip." 1
[ -z "$containers" ]  && die "No containers." 1

DOCUMENTUM=/opt/documentum
DOCUMENTUM_SHARED=${DOCUMENTUM}/shared
DM_HOME=${DOCUMENTUM}/product/7.1

dctm_cs=$(docker inspect --format '{{ .Config.Env }}' dctm-cs | grep "REPOSITORY_NAME=$repo")
[ -z "$dctm_cs" ] && die "Container dctm-cs (with repo $repo) not found." 2
# try to check if dctm-xs finished the installation
marker=$(docker exec -it dctm-cs ls -a1 ${DM_HOME}/install/.stop-install)
[ -z "$marker" ]  && die "Seems dctm-cs installation not finished yet. Check the logs: docker logs -f dctm-cs" 3

function run() {
    container=$1
    case "$1" in
        extbroker) 
            echo "Run extborker"
            docker run -d -p 1589:1489 --name extbroker -h extbroker \
               --link dctm-cs:dctm-cs -e REPOSITORY_NAME=$repo -e HOST_IP=$HOST_IP dctm-broker
            ;;
        xplore)
            echo "Run xplore"
            docker run -dP -p 9300:9300 -p 9200:9200 --name xplore -h xplore -e REPOSITORY_NAME=$repo --link dctm-cs:dctm-cs dctm-xplore
            ;;
        da)
            echo "Run da"
            docker run -dP -it --name da -p 7002:8080 -e REPOSITORY_NAME=$repo --link dctm-cs:dctm-cs dctm-da
            ;;
        bam)
            echo "run bam"
            docker run -dP -p 8000:8080 --name bam -h bam -e REPOSITORY_NAME=$repo --link dctm-cs:dctm-cs --link dbora:dbora dctm-bam
            ;;
        bps)
            echo "run bps"
            docker run -dP -p 8010:8080 --name bps -h bps -e REPOSITORY_NAME=$repo --link dctm-cs:dctm-cs dctm-bps
            ;;
        ts)
            echo "run Thumnail Server"
            docker run -dP -p 8020:8080 --name ts -h ts -e REPOSITORY_NAME=$repo --link dctm-cs:dctm-cs dctm-ts dctm-ts
            ;;
        apphost)
            echo "run apphost"
            [ -d $HOME/ctsws-config ] && ctsOpt="-v $HOME/ctsws-config:/ctsws-config" || ctsOpt=
            docker run -dP -p 8040:8080 --name apphost -h apphost -e REPOSITORY_NAME=$repo -e MEM_XMSX=2048m \
             $ctsOpt --link dctm-cs:dctm-cs --link bam:bam dctm-apphost
            ;;
        xms)
            echo "run xms agent"
            docker run -dP -p 7000:8080 --name xms -h xms -e REPOSITORY_NAME=$repo --volumes-from dctm-xmsdata \
               --link dctm-cs:dctm-cs --link bam:bam --link xplore:xplore --link apphost:apphost dctm-xmsagent
            ;;
        xpress)
            echo "run xPression"
            docker run -dP -p 9070:8080 -p 9072:9990 -p 5678:5678 --name xpress -h xpress -e REPOSITORY_NAME=$repo --link dctm-cs:dctm-cs --link dbora:dbora dctm-xpression
            ;;
    esac
}
# let's go
containersArr=$(echo ${containers} | tr "," "\n")
for c in $containersArr
do
    run $c
done

echo "All services started."
echo "Wait for the end of xms start"
echo "using: docker logs -f xms"
