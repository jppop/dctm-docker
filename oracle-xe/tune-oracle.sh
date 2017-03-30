#!/bin/sh

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE

if [ ! -f ${ORACLE_HOME}/.tuned ]; then
	${ORACLE_HOME}/bin/sqlplus / as sysdba << __EOF__
alter system set sessions=300 scope=spfile;
alter system set processes=300 scope=spfile;
alter system set open_cursors=500 scope=both;
shutdown immediate;
exit
__EOF__

	${ORACLE_HOME}/bin/sqlplus / as sysdba << __EOF__
startup;
exit
__EOF__
	touch ${ORACLE_HOME}/.tuned
fi
