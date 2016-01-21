#!/bin/sh

user=$(id -un)
pwd=trustme

iapi $1 -U${user} -P${passwd} <<EOF
?,c,EXECUTE list_sessions
quit
EOF
