#!/bin/bash

LOG_DIR=./logs
LOG_FILE=${LOG_DIR}/docker-build.log

[ -d "$LOG_DIR" ] || mkdir -p $LOG_DIR

usage() {
    echo `basename $0`: ERROR: $* 1>&2
    cat 2>&1 <<EOF
usage: `basename $0` [--image-list|-f filename]
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
    OPTS=`getopt f: "$*"`
else
    OPTS=`getopt -o f: -l image-list: -- "$@"`
fi
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

# default values
imagelist=images.lst
while true ; do
    case "$1" in
        --image-list|-f) imagelist=$2; shift 2;;
        --) shift; break;;
    esac
done

[ -z "$imagelist" ]  && die "No image list." 1
[ -r "$imagelist" ]  || die "file ${imagelist} not found." 1

touch $LOG_DIR/build-start
touch ${LOG_FILE}

for img in $(cat ${imagelist}); do
  if [[ "$img" == "#"* ]]; then
    echo "${img#\#} skipped"
  else
	echo "Building $img..."
	[ -w ${LOG_FILE} ] && logger -s "Starting build. Image: $img..." 2>> ${LOG_FILE}
	docker build -t $img $img/ 2>&1 | tee ${LOG_DIR}/docker-build-$img.log
	[ -w ${LOG_FILE} ] && logger -s "Done. Image: $img..." 2>> ${LOG_FILE}
  fi
done

touch $LOG_DIR/build-end
