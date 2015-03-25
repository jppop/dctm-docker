#!/bin/sh

dockerUsage() {
    cat 2>&1 <<EOF
This container must be linked with a cs (as 'dctm-cs') server.
Something like:
  docker run -dP --name bps -h bps --link dctm-cs:dctm-cs bps
EOF
  exit 2
}

# check container links
 -z "${DCTM_CS_NAME}" ] && dockerUsage

CATALINA_OPTS="${CUSTOM_CATALINA_OPTS} ${CATALINA_OPTS}"
JAVA_OPTS="${CUSTOM_JAVA_OPTS} ${JAVA_OPTS}"
CATALINA_OUT="${CUSTOM_CATALINA_OUT}"

export CATALINA_OPTS JAVA_OPTS CATALINA_OUT

# configure dfc
DFC_DATADIR=${CATALINA_HOME}/temp/dfc
[ -d ${DFC_DATADIR} ] || mkdir -p ${DFC_DATADIR}

cat << __EOF__ >> ${CATALINA_HOME}/conf/dfc.properties
dfc.name=bps
dfc.data.dir=${DFC_DATADIR}
dfc.tokenstorage.enable=false
dfc.docbroker.host[0]=${DOCBROKER_ADR:-$DCTM_CS_PORT_1489_TCP_ADDR}
dfc.docbroker.port[0]=${DOCBROKER_PORT:-$DCTM_CS_PORT_1489_TCP_PORT}
dfc.session.secure_connect_default=try_native_first
dfc.globalregistry.repository=${REPOSITORY_NAME:-devbox}
dfc.globalregistry.username=${REGISTRY_USER:-dm_bof_registry}
dfc.globalregistry.password=${REGISTRY_CRYPTPWD:-AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv}
dfc.session.allow_trusted_login = false
__EOF__

echo "xcp.repository.name=${REPOSITORY_NAME}" > conf/deployment.properties

mkdir $CATALINA_HOME/msg-store

# create the BPS configuration file
cat << __EOF__ >> conf/bps_template.xml
<?xml version="1.0"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
     <polling_interval>300</polling_interval>
     <message_store_home_dir>${CATALINA_HOME}/msg-store</message_store_home_dir>
     <instance_name>bps1</instance_name>
     <ha_enabled>FALSE</ha_enabled>
     <config_properties>
       <property name="mail.imap.partialfetch" value="false"/>
       <property name="mail.debug" value="false"/>
      </config_properties>
     <connections>
         <docbase-connection>
             <docbase>${REPOSITORY_NAME}</docbase>
             <user>${REPOSITORY_USER}</user>
             <password>${REPOSITORY_PWD}</password>
             <domain/>
         </docbase-connection>
     </connections>
</config>
__EOF__

echo "DFC Config file:"
cat conf/dfc.properties

echo "Using CATALINA_OPTS:   ${CATALINA_OPTS}"
echo "Using JAVA_OPTS:       ${JAVA_OPTS}"
exec "$@"
