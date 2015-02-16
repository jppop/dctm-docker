#!/bin/bash

LOG_DIR=./logs
LOG_FILE=${LOG_DIR}/docker-build.log

[ -d "$LOG_DIR" ] || mkdir -p $LOG_DIR
touch ${LOG_FILE}

for img in $(cat images.lst); do
  if [[ "$img" == "#"* ]]; then
    echo "${img#\#} skipped"
  else
	echo "Building $img..."
	[ -w ${LOG_FILE} ] && logger -s "Starting build. Image: $img..." 2>> ${LOG_FILE}
	docker build -t $img $img/ 2>&1 | tee ${LOG_DIR}/docker-build-$img.log
	[ -w ${LOG_FILE} ] && logger -s "Done. Image: $img..." 2>> ${LOG_FILE}
  fi
done
