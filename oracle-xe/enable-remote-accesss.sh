#!/bin/sh

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE

${ORACLE_HOME}/bin/sqlplus system/oracle@localhost << __EOF__
-- suppress password exipration
ALTER USER system IDENTIFIED BY oracle;
-- enable remote access
EXEC DBMS_XDB.SETLISTENERLOCALACCESS(FALSE);
quit;
/
__EOF__
