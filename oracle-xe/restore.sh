#!/bin/bash

rman target / << EOF
shutdown immediate;
startup mount;
restore database;
recover database;
alter database open resetlogs;
EOF
