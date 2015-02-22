#!/bin/sh

# run xms-tools container with home directory as /shared mountpoint
docker run -it --rm --name xms-tools -h xms-tools --link xms:xms -v ${HOME}:/shared dctm-xmstools bash