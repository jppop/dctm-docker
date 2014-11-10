#!/bin/sh
################## DOCUMENTUM SERVER STARTUP FILE ######################
#
# 1994-2012 EMC Corporation. All rights reserved
# Version 7.1 of the Documentum Server.
#
# A generated server startup script for a repository.
# This file was generated on Sun Nov 02 19:28:01 CET 2014 by user dmadmin.
#
check_connect_status() {
status=$1
if [  $status = 0 ] ; then
cat <<-END
***** Error: cannot start already-running - shut it down first
END
exit 1
fi
}
#
# Check process belongs to this docbase
#
ps -ef | grep 'documentum -docbase_name devbox' | grep -i 'init_file /opt/documentum/dba/config/devbox/server.ini' |grep -v grep > /dev/null
status=$?
check_connect_status $status START
# Next change directory to the bin directory for this release
DM_SERVER_VERSION=null
DM_HOME_CURRENT=/opt/documentum/product/7.1
DM_DBA=/opt/documentum/dba
logdir=$DM_DBA/log
cd $DM_HOME_CURRENT/bin
# Source the environment with the dm_set_server_env script
setEnvScript=$DM_HOME_CURRENT/bin/dm_set_server_env.sh
if [ -r $setEnvScript ] ; then
  . $setEnvScript
else
    echo "Warning: The dm_set_server_env.sh script could not be"
    echo "found. Since the dm_start_<docbase> script was not sourced with that script, "
    echo "please verify that you had set the required environment variables before "
    echo "executing dm_start_<docbase>."
fi

if [ ! -d $logdir ] ; then
  echo "$0: Fatal error: missing directory $logdir"
  echo "$0: Fatal error: launch aborted"
  exit 1
fi
logfile=$logdir/devbox.log
time=`date +%m.%d.%Y.%H.%M.%S`
if [ -f $logfile ] ; then
  mv $logfile $logfile.save.$time
fi
# Set the umask to zero as to not interfere with the server's creation
# of files/directories
umask 0
# Hard-code NLS_LANG environmental variable at startup to the format of 
# LANG_TERRITORY.CHARSET for Oracle.
NLS_LANG=AMERICAN_AMERICA.UTF8 export NLS_LANG
# Hard-code the LANG environment variable to ensure the server runs
# in the standard LANG locale.  Even when installed with the internationalization
# options the server expectes to run in the standard language environment.
LANG=C export LANG
# Start the server
echo starting Documentum server for repository: [devbox]
echo with server log: [$logfile]
./documentum -docbase_name devbox -security acl -init_file /opt/documentum/dba/config/devbox/server.ini $@ >> $logfile 2>&1 &
launch_pid=$!
echo server pid: $launch_pid
if [ ! -z "$DM_RETURN_PID_FILE" ] ; then # this is set by dm_configure and not needed otherwise
  echo $launch_pid > $DM_RETURN_PID_FILE
fi
if [ ! -z "$DM_RETURN_LOG_FILE" ] ; then # this is set by dm_configure and not needed otherwise
  echo $logfile > $DM_RETURN_LOG_FILE
fi
