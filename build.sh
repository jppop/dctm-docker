#!/bin/bash

docker build -t base-centos6 base-centos6/
docker build -t oracle-xe oracle-xe/
docker build -t dctm-base dctm-base/
docker build -t dctm-broker dctm-broker/
docker build -t dctm-cs dctm-cs/
docker build -t dctm-da dctm-da/
docker build -t dctm-ts dctm-ts/
docker build -t dctm-xplore dctm-xplore/
