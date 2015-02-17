#!/bin/sh

repo=${1:-devbox}
export REPOSITORY_NAME $repo

docker run -dP --name dbora -h dbora oracle-xe
#docker run -dP --name broker -h broker dctm-broker
docker run -dP -p 1489:1489 -p 49000:49000 --name dctm-cs -h dctm-cs --link dbora:dbora dctm-cs --repository-name $repo