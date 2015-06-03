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

# load environnment variables
if [ -f .dctm-docker.env ]; then
    source .dctm-docker.env
fi

os=$(uname -s)
if [ "$os" = "Darwin" ]; then
    OPTS=`getopt r: "$*"`
else
    OPTS=`getopt -o r: -l repo-name: -- "$@"`
fi
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

# default values
repo=$REPOSITORY_NAME
while true ; do
    case "$1" in
        --repo-name|-r) repo=$2; shift 2;;
        --) shift; break;;
    esac
done

[ -z "$repo" ]  && die "No repository name." 1
export REPOSITORY_NAME=$repo


[ -n "$CTS_HOST" -a -n "$CTS_IP" ] && ctsOpt="--add-host $CTS_HOST:$CTS_IP" || ctsOpt=
[ -n "$xPRESSION_HOST" -a -n "$xPRESSION_IP" ] && xPressOpt="--add-host $xPRESSION_HOST:$xPRESSION_IP" || xPressOpt=

docker create --name dctm-xmsdata dctm-xmsdata
docker run -dP --name dbora -h dbora oracle-xe
#docker run -dP --name broker -h broker dctm-broker
docker run -dP -p 1489:1489 -p 49000:49000 -p 9080:9080 --name dctm-cs -h dctm-cs --link dbora:dbora \
	$ctsOpt $xPressOpt dctm-cs --repo-name $repo
docker logs -f dctm-cs
