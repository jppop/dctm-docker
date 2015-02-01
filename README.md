dctm-docker
===========

Documentum running in containers

ALPHA RELEASE

REMINDERS:

docker run -dP --name dbora -h dbora oracle-xe

docker run -dP --name broker -h broker dctm-broker

docker run -dP --name dctm-cs -h dctm-cs --link dbora:dbora --link broker:broker dctm-cs

docker run --rm -it --name da -p 8888:8080 --link broker:broker --link dctm-cs:dctm-cs dctm-da