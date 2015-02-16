#!/bin/sh

docker run -dP --name dbora -h dbora oracle-xe
#docker run -dP --name broker -h broker dctm-broker
docker run -dP --name dctm-cs -h dctm-cs --link dbora:dbora dctm-cs
