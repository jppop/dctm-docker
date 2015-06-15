#!/bin/sh

usage() {
    echo `basename $0`: ERROR: $* 1>&2
    cat 2>&1 <<EOF
usage: `basename $0` [--xms-server|-s host] [--xms-port|-p port]
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
    OPTS=`getopt s:p:b: "$*"`
else
    OPTS=`getopt -o s:p:b: -l xms-server:,xms-port:,base-dir: -- "$@"`
fi
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

# default values
xms_server=xms xms_port=8080 basedir=${HOME}
linkOpt="--link xms:xms"
while true ; do
    case "$1" in
        --xms-server|-s) xms_server=$2; linkOpt=; shift 2;;
        --xms-port|-p) xms_port=$2; linkOpt=; shift 2;;
        --base-dir|-b) basedir=$2; shift 2;;
        --) shift; break;;
        *) break;
    esac
done

# run xms-tools container with home directory as /shared mountpoint
#docker run -it --rm --name designer -h designer ${linkOpt} -v ${basedir}:/shared \
#	-e XMS_SERVER=${xms_server} -e XMS_PORT=${xms_port} dctm-xcpdesigner bash

docker run -it --name designer -h designer ${linkOpt} -v ${basedir}:/shared \
    -e XMS_SERVER=${xms_server} -e XMS_PORT=${xms_port} dctm-xcpdesigner /shared/build-xcpapp.sh
docker logs designer > tmp/build-$$.log
docker rm designer 2>&1 >/dev/null
