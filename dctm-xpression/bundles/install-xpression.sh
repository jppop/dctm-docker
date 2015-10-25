#!/bin/bash

die() {
# display an error message ($1) and exit with a return code ($2)
	echo `basename $0`: ERROR: $1 1>&2
	exit $2
}

OPTS=`getopt -o d -l dctm -- "$@"`
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

# default values
installDfc='false'
while true ; do
    case "$1" in
        --dctm|-d) installDfc='true'; shift 1;;
        --) shift; break;;
    esac
done

echo "Copying DFC.."
tar -xf /bundles/dfc-jars.7.1.tar -C ${DOCUMENTUM_SHARED}
DFC_DATA_DIR=${DOCUMENTUM_SHARED}/data
DFC_CONFIG_DIR=${DOCUMENTUM_SHARED}/config
DFC_ROOT_DIR=${DOCUMENTUM_SHARED}
mkdir ${DFC_CONFIG_DIR} ${DFC_DATA_DIR}

cat > ${DFC_CONFIG_DIR}/dfc.properties << __EOF__
dfc.name=xpression
dfc.data.dir=${DFC_DATA_DIR}
dfc.tokenstorage.enable=false
dfc.docbroker.host[0]=${DOCBROKER_ADR:-$DCTM_CS_PORT_1489_TCP_ADDR}
dfc.docbroker.port[0]=${DOCBROKER_PORT:-$DCTM_CS_PORT_1489_TCP_PORT}
dfc.session.secure_connect_default=try_native_first
dfc.globalregistry.repository=${REPOSITORY_NAME:-devbox}
dfc.globalregistry.username=${REGISTRY_USER:-dm_bof_registry}
dfc.globalregistry.password=${REGISTRY_CRYPTPWD:-AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv}
dfc.session.allow_trusted_login = false
__EOF__

# Workaraound: XPRS failed to create the dfc keystore the firstime it's started.
# So, create one
java -cp ${DOCUMENTUM_SHARED}/dctm.jar:${DOCUMENTUM_SHARED}/config \
 com.documentum.fc.tools.DqlTool -dfc \
 -docbase ${REPOSITORY_NAME:-devbox} -username dmadmin -password dmadmin \
 "select * from dm_server_config"

if [ $installDfc = 'false' ]; then
	unset DFC_CONFIG_DIR
	unset DFC_ROOT_DIR
fi

echo "Getting installer and ear..."
mkdir ${XPRESS_HOME}/setup
pushd ${XPRESS_HOME}/setup

unzip -q /bundles/XP45SP1_B13_xPression_Server_Installer.zip -d ${XPRESS_HOME}/setup
# note: symlink seems to be not supported by the installer
cp /bundles/xPRS_EE4.5.1_P10.ear ${XPRESS_HOME}/setup/xPression.ear

echo "Starting installation.."
mkdir -p ${XPRESS_HOME}/jboss-7.1/standalone/deployments/xPression.ear
mkdir -p ${XPRESS_HOME}/dfc-config

cat > ${XPRESS_HOME}/setup/installer.properties <<EOF
COMPNAME=$(hostname)
USER_INSTALL_DIR=${XPRESS_HOME}
USER_INSTALL_DIR_REG=${XPRESS_HOME}
DEPLOY_MODE="Enterprise Edition",""
SERVER_TYPE=JBoss
APPSERVER_VERSION=JBoss 7.x
JBOSS_FLAG=true
WEBSERVER_START_MODE=server
JBOSS_VERSION=5.1.0
JBOSS_ROOT=${XPRESS_HOME}/jboss-7.1
JDK_ROOT=${JAVA_HOME}
USER_MAGIC_FOLDER_1=${XPRESS_HOME}/jboss-7.1/standalone/deployments/xPression.ear
USE_XPRESSION_EAR=true
USER_MAGIC_FOLDER_2=${XPRESS_HOME}/jboss-7.1/standalone/deployments
USER_MAGIC_FOLDER_7=${XPRESS_HOME}/jboss-7.1/modules/com
REVISE_EAR_FOLDER=${XPRESS_HOME}/jboss-7.1/standalone/deployments/xPression.ear
USE_REVISE_EAR=true
ECOR_EAR_FOLDER=${XPRESS_HOME}/jboss-7.1/standalone/deployments/xPression.ear
USE_ECOR_EAR=true
ADAPTER_EAR_FOLDER=${XPRESS_HOME}/jboss-7.1/standalone/deployments/xPression.ear
USE_ADAPTER_EAR=true
XFORM_EAR_FOLDER=${XPRESS_HOME}/jboss-7.1/standalone/deployments/xPression.ear
USE_XFORM_EAR=true
XCATALOG_EAR_FOLDER=${XPRESS_HOME}/jboss-7.1/standalone/deployments/xPression.ear
USE_XCATALOG_EAR=true
APPSERVER_PORT=8080
SUMMARY_PROT=8080
WAS_PORT=4447
SERVER_PROTOCOL=http
USE_PROXY=false
PROXY_SERVER_IP=
JAVAEDITOR_SPELLCHECK=novalue
SERVER_IP=$(hostname -f)
SERVER_NAME=BPI xPression
IS_DB2JCC_JAR=
DRIVER_PATH_NOFILE=/usr/lib/oracle/11.2/client64/lib
DB_JAR=ojdbc6.jar
DRIVER_PATH=/usr/lib/oracle/11.2/client64/libojdbc6.jar
DB_TYPE=Oracle
OS_BIT="","64-bit"
JDBC_JAR_DIR=${XPRESS_HOME}/jboss-7.1/modules/com/oracle/ojdbc6/main
JDBC_SERVER_NAME=dbora
JDBC_PORT_NUMBER=1521
JDBC_DATABASE_NAME=XE
JDBC_USER_NAME=${XPRESS_DBOUSER}
JDBC_USER_PASSWORD=${XPRESS_DBOPWD}
EMAIL_SERVERNAME=localhost
SEC_TYPE=Local
SetDocumentumClient_ROOT=${installDfc}
DocumentumConf_ROOT=${DFC_CONFIG_DIR}
DocumentumClient_ROOT=${DFC_ROOT_DIR}
COMMUNICATION_MODE=Local
CLUSTER_NAME=xPressionGroups
CURRENT_NODE_NAME=Node1
MULTICAST_ADDRESS=239.192.11.11
MULTICAST_PORT=9999
UNICAST_PORT=7800
UNICAST_MEMBERS=10.32.229.104[7800],10.32.229.105[7800]
Performance_Level=Medium
Performance_Initial=128
Performance_Maxium=512
EOF

java -jar ${XPRESS_HOME}/setup/xPression_Server_Installer.jar -i silent -f ${XPRESS_HOME}/setup/installer.properties

sudo chown root:root ${XPRESS_HOME}/Drivers/LinuxAuthUser
sudo chmod 4655      ${XPRESS_HOME}/Drivers/LinuxAuthUser

# add dfc jars
#tar -xf /bundles/dfc-jars.7.1.tar -C ${XPRESS_HOME}/jboss-7.1/modules/com/documentum/main
if [ $installDfc = 'true' ]; then
	cp ${DOCUMENTUM_SHARED}/dfc/*.jar ${XPRESS_HOME}/jboss-7.1/modules/com/documentum/main/
	# probably not necessary
	cat > ${XPRESS_HOME}/jboss-7.1/modules/com/documentum/main/dfc.properties <<EOF
#include ${DFC_CONFIG_DIR}/dfc.properties
EOF
fi

# copy jdbc driver (seems the installer does not copy it)
cp /usr/lib/oracle/11.2/client64/lib/ojdbc6.jar ${XPRESS_HOME}/jboss-7.1/modules/com/oracle/ojdbc6/main

# tell jboss to listen all network interfaces
sed -i.bck.0 -e 's/jboss.bind.address.management:127.0.0.1/jboss.bind.address.management:0.0.0.0/' \
  ${XPRESS_HOME}/jboss-7.1/standalone/configuration/xpression-standalone.xml
sed -i.bck.1 -e 's/jboss.bind.address:127.0.0.1/jboss.bind.address:0.0.0.0/' \
  ${XPRESS_HOME}/jboss-7.1/standalone/configuration/xpression-standalone.xml

# patch xPression with P10
mkdir ${XPRESS_HOME}/setup/p10 && cd ${XPRESS_HOME}/setup/p10
unzip -q /bundles/XP45SP1_P10_xPression_Server_Patch_Installer_64_Linux.zip
chmod a+x patch.bin

cat > patch.properties <<EOF
INSTALLER_UI=SILENT
USER_SELECTED_PATCH_ZIP_FILE=\"data.zip\"
common.installLocation=${XPRESS_HOME}
PROMPT_USER_CHOSEN_OPTION=0
USER_SELECTED_PATCH_ZIP_FILE=\"data.zip\"
EOF
./patch.bin LAX_VM $(which java) -f patch.properties

# create xPression data
/bundles/create-tables.sh

popd


