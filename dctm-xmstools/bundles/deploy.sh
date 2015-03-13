#!/bin/sh

usage() {
    echo `basename $0`: ERROR: $* 1>&2
    cat 2>&1 <<EOF
usage: `basename $0` --war-file warfile --configuration-file configuration
EOF
    exit 1
}

die() {
# display an error message ($1) and exit with a return code ($2)
	echo `basename $0`: ERROR: $1 1>&2
	exit $2
}

OPTS=`getopt -o e:xd:w:c: -l environment:,xplore-idx,deployment-method:,war-file:,configuration-file: -- "$@"`
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

# default values
environment=DEV-DX xploreindexing='true' deployment=full warfile= configuration=
while true ; do
    case "$1" in
        --environment|-e) environment=$2; shift 2;;
        --xplore-idx|-x) xploreindexing='false'; shift;;
        --deployment-method|-d) deployment=$2; shift 2;;
        --war-file|-w) warfile=$2; shift 2;;
        --configuration-file|-c) configuration=$2; shift 2;;
        --) shift; break;;
    esac
done

[ -z "$warfile" ] && usage
[ -z "$configuration" ] && usage

scriptfile="/tmp/$(basename $0).$$.script"
cat << EOF > $scriptfile
deploy-xcp-application --environment ${environment} --xploreindexing ${xploreindexing} --deployment-method ${deployment} --war-file ${warfile} --configuration-file ${configuration}
exit
EOF

./xms.sh -u admin -p adminPass1 -f $scriptfile

rm $scriptfile

