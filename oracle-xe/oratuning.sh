#!/bin/sh

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
${ORACLE_HOME}/bin/sqlplus system/oracle@localhost << __EOF__
alter system set sessions=300 scope=spfile;
alter system set processes=300 scope=spfile;
shutdown immediate;
exit
__EOF__
