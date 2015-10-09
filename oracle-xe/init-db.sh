#!/bin/sh

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE

${ORACLE_HOME}/bin/sqlplus system/oracle@localhost << __EOF__
-- suppress password expiration
ALTER PROFILE "DEFAULT" LIMIT PASSWORD_VERIFY_FUNCTION NULL;
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
ALTER USER system IDENTIFIED BY oracle;
-- enable remote access
EXEC DBMS_XDB.SETLISTENERLOCALACCESS(FALSE);
quit;
/
__EOF__
