#!/bin/bash

if [ -z $JAVA_HOME ]; then
	echo "The JAVA_HOME environment variable is not defined correctly"
	echo "This environment variable is needed to run this program"
	exit 1
fi
ANT_HOME=./ant
PATH=${PATH}:${ANT_HOME}/bin
ant -f ./script/build.xml silent.install
