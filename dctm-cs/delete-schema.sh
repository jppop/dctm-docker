#!/bin/bash

REPOSITORY_NAME=${1:-myrepo}
DBO=$(echo "$REPOSITORY_NAME" | tr '[:lower:]' '[:upper:]')

SQLPLUS_SETTINGS="SET PAGESIZE 1000 LINESIZE 500 ECHO OFF TRIMS ON TAB OFF FEEDBACK OFF HEADING OFF"

sqlplus -s system/oracle@XE <<__EOF__
${SQLPLUS_SETTINGS}
spool /tmp/deleteViewCommand.sql
select 'drop view ${DBO}.'||view_name||';' from dba_views where owner = '${DBO}';
spool off
@/tmp/deleteViewCommand.sql
commit;
SET ECHO ON
SET FEEDBACK ON
DROP TABLESPACE DM_${REPOSITORY_NAME}_docbase including contents;
DROP TABLESPACE DM_${REPOSITORY_NAME}_index including contents;
DROP USER ${DBO} cascade;
disconnect;
exit;
__EOF__
