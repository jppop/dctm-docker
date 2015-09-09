#!/bin/bash

pushd $XPRESS_HOME/setup

BUNDLES=/bundles

export TNS_ADMIN=${XPRESS_HOME}

# get default data file location
sysdbf=`sqlplus -s system/oracle@xe <<EOF
set heading off
select file_name from DBA_DATA_FILES where TABLESPACE_NAME='SYSTEM';
exit
EOF
`
[ -z "${sysdbf}" ] && dbfpath=$(dirname $sysdbf)
[ -z "${dbfpath}" ] && dbfpath=/u01/app/oracle/oradata/XE

echo "Creating xPression DB owner.."
dboName=${XPRESS_DBOUSER:-xpressdbo}
dboPwd=${XPRESS_DBOPWD:-xpressdbo}

sqlplus -s system/oracle@xe <<EOF

DROP USER ${dboName} CASCADE;
ALTER TABLESPACE xpression OFFLINE;
DROP TABLESPACE xpression INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE xpression
DATAFILE
'${dbfpath}/xpression.dbf'
SIZE 20M REUSE;

ALTER DATABASE
DATAFILE
'${dbfpath}/xpression.dbf'
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

create user ${dboName} identified by ${dboPwd} default tablespace
   xpression temporary tablespace TEMP;
grant connect, resource, create view, create sequence to ${dboName};
exit;
EOF

echo "Creating xPression tables.."
unzip -q $BUNDLES/XP45SP1_B13_cr_scripts -d dbscripts
cd dbscripts
echo "exit;" >> Ora_install.sql
sqlplus -s ${dboName}/${dboPwd}@xe @Ora_install.sql
echo "exit;" >> Ora_basicdata.sql
sqlplus -s ${dboName}/${dboPwd}@xe @Ora_basicdata.sql
cp -r $BUNDLES/CRUpgrade/*.sql .
echo "exit;" >> Ora_4.5SP1_Patch1.sql
sqlplus -s ${dboName}/${dboPwd}@xe @Ora_4.5SP1_Patch1.sql
echo "exit;" >> Ora_4.5SP1_Patch3.sql
sqlplus -s ${dboName}/${dboPwd}@xe @Ora_4.5SP1_Patch3.sql
echo "exit;" >> Ora_4.5SP1_Patch10.sql
sqlplus -s ${dboName}/${dboPwd}@xe @Ora_4.5SP1_Patch10.sql
cd ..

touch ${XPRESS_HOME}/.db.done

popd
