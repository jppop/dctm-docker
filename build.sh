#!/bin/bash

LOG_DIR=~/Library/Logs
LOG_FILE=${LOG_DIR}/docker-build.log

touch ${LOG_FILE}

for img in $(cat images.lst); do
	echo "Building $img..."
	[ -w ${LOG_FILE} ] && logger -s "Starting build. Image: $img..." 2>> ${LOG_FILE}
	docker build -t $img $img/ 2>&1 | tee ${LOG_DIR}/docker-build-$img.log
	[ -w ${LOG_FILE} ] && logger -s "Done. Image: $img..." 2>> ${LOG_FILE}
done
