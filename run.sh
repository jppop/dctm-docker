#!/bin/sh

repo=${1:-devbox}
export REPOSITORY_NAME=$repo

echo "export REPOSITORY_NAME=$repo" > ~/.repo_profile

docker create --name dctm-xmsdata dctm-xmsdata
docker run -dP --name dbora -h dbora oracle-xe
#docker run -dP --name broker -h broker dctm-broker
docker run -dP -p 1489:1489 -p 49000:49000 --name dctm-cs -h dctm-cs --link dbora:dbora dctm-cs --repo-name $repo
docker logs -f dctm-cs
