#!/bin/bash

REPOSITORY_NAME=$1
DBO=$(echo "$REPOSITORY_NAME" | tr '[:lower:]' '[:upper:]')

sqlplus -s system/oracle@XE <<__EOF__
spool /tmp/deleteViewCommand.sql
select 'drop view DEVBOX.'||view_name||';' from dba_views where owner = 'DEVBOX';
spool off
@/tmp/deleteViewCommand.sql
commit;
DROP TABLESPACE DM_devbox_docbase including contents;
DROP TABLESPACE DM_devbox_index including contents;
disconnect;
exit;
__EOF__
