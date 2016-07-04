# Documentum Content Server 7.1 Patch 09
# Documentum is a registred trademark from EMC (http://www.emc.com/legal/emc-corporation-trademarks.htm)

##FROM centos:centos6
FROM base-centos6

MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

RUN mkdir /var/dctm-data /var/log/documentum \
 && chmod 1777 /var/dctm-data /var/log/documentum

VOLUME /var/dctm-data
VOLUME /var/log/documentum

RUN echo 'root:root' | chpasswd

RUN yum update -y && yum -y --noplugins groupinstall \
	base core compat-libraries

RUN yum -y --noplugins clean all

# set timezone
RUN mv /etc/localtime /etc/localtime.old; ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

# add our user and group first
RUN groupadd dmadmin && useradd -g dmadmin dmadmin
RUN echo dmadmin | passwd --stdin dmadmin

RUN echo "dmadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  && echo "Defaults:dmadmin !requiretty" >> /etc/sudoers

# Creating documentum directories
ENV DOCUMENTUM /opt/documentum
ENV DOCUMENTUM_SHARED ${DOCUMENTUM}/shared
ENV DM_HOME ${DOCUMENTUM}/product/7.1
ENV DOCUMENTUM_DATA /var/dctm-data
ENV DOCUMENTUM_LOG /var/log/documentum
RUN mkdir -p ${DM_HOME} ${DOCUMENTUM_SHARED}
RUN chown -R dmadmin:dmadmin ${DOCUMENTUM}

## FIXME: cannot use volumes since chown fails to change ownership (may be specific to OSX)
## see https://github.com/boot2docker/boot2docker/issues/581
## VOLUME [ "/var/log/documentum", "/var/dctm-data"]
## RUN ls -al /var/log/documentum /var/dctm-data
##RUN mkdir -p ${DOCUMENTUM_DATA} ${DOCUMENTUM_LOG}
##RUN chown -R dmadmin:dmadmin ${DOCUMENTUM_DATA} ${DOCUMENTUM_LOG}


RUN echo "dctm            49000/tcp               # documentum repository service" >> /etc/services \
 && echo "dctm_s          49001/tcp               # documentum repository service" >> /etc/services

RUN echo "#!/bin/sh" > /etc/profile.d/documentum.sh \
 && echo "export DOCUMENTUM=${DOCUMENTUM}" >> /etc/profile.d/documentum.sh \
 && echo "export DOCUMENTUM_SHARED=${DOCUMENTUM_SHARED}" >> /etc/profile.d/documentum.sh \
 && echo "export DM_HOME=${DM_HOME}" >> /etc/profile.d/documentum.sh \
 && echo "export DOCUMENTUM_DATA=${DOCUMENTUM_DATA}" >> /etc/profile.d/documentum.sh \
 && echo "export DOCUMENTUM_LOG=${DOCUMENTUM_LOG}" >> /etc/profile.d/documentum.sh \
 && chmod a+x /etc/profile.d/documentum.sh

COPY ./bundles /bundles
RUN chown -R dmadmin:dmadmin /bundles

# Installing content server
USER dmadmin

WORKDIR /tmp
RUN	mkdir cs-install \
 && cd cs-install \
 && tar -xf /bundles/Content_Server_7.1_linux64_oracle.tar \
 &&	chmod u+x serverSetup.bin \
 &&	./serverSetup.bin -f /bundles/cs-install.properties \
 && cp logs/install.log ${DOCUMENTUM_LOG}/cs-install.log \
 && cd .. \
 && rm -rf cs-install \
 && echo "done"

USER root
RUN JAVA_BINARY=`ls -1d $DOCUMENTUM_SHARED/java*/*/bin/java 2>/dev/null | head -1` \
 &&	JAVA_HOME=`dirname $JAVA_BINARY` \
 &&	JAVA_HOME=`dirname $JAVA_HOME` \
 && echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/profile.d/documentum.sh \
 && echo "export PATH=\${JAVA_HOME}/bin:\${PATH}" >> /etc/profile.d/documentum.sh \
 && echo "done"

# installing patch
USER dmadmin
WORKDIR /tmp
RUN mkdir patch-install \
 && cd patch-install \
 && tar -zxf /bundles/patch/CS_7.1.*.gz  \
 && source /etc/profile.d/documentum.sh \
 && chmod u+x ./patch.bin \
 && ./patch.bin LAX_VM $(which java) -f /bundles/patch/patch-install.properties \
 && cp logs/install.log ${DOCUMENTUM_LOG}/patch-install.log \
 && cd .. \
 && rm -rf patch-install \
 && echo "done"

RUN echo ". \$DM_HOME/bin/dm_set_server_env.sh" >> /home/dmadmin/.bash_profile

# fix an issue in dfc.properties (left by installer with an empty broker entry)
RUN cp --backup=numbered /bundles/dfc.properties ${DOCUMENTUM_SHARED}/config/

# add extra tools (ease dar deploying)
RUN chmod a+x /bundles/dar-tools/*.sh \
 && mv /bundles/dar-tools/*.* $DM_HOME/install/

USER root
WORKDIR /
CMD ["/usr/sbin/sshd", "-D"]
