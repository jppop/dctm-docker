#!/bin/bash

REPOSITORY=$1
USERNAME=$2
[ -z "$USERNAME" ] && USERNAME=`whoami`

# under Cygwin, use iapi32.exe
IAPI=${DM_HOME}/bin/iapi

exitOnError() {
# display an error message ($1) and exit with a return code ($2)
	echo `basename $0`: ERROR: $1 1>&2
	exit $2
}

dbo=`${IAPI} ${REPOSITORY} -U${USERNAME} -P -e << EOF | grep owner_name |  awk -F': ' '{ print $2 }'
fetch,c,serverconfig
dump,c,l
exit
EOF`

cat << !EOF
<?xml version="1.0" encoding="ASCII"?>
<installparam:InputFile xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:installparam="installparam">
  <parameter key="dmadmin" value="${USERNAME}"/>
  <parameter key="documentum" value="${dbo}"/>
</installparam:InputFile>
!EOF


