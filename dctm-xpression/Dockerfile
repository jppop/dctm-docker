FROM base-centos6

MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

# JBoss app and console ports
EXPOSE 8080 9990 5678

RUN echo 'root:root' | chpasswd

RUN yum update -y && yum -y --noplugins groupinstall \
    base core compat-libraries

RUN yum -y --noplugins clean all

# set timezone
RUN mv /etc/localtime /etc/localtime.old; ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

# add our user and group first
RUN groupadd xpress && useradd -g xpress xpress
RUN echo xpress | passwd --stdin xpress
# add an user to be used by developpers
RUN useradd -g xpress xpression
RUN echo xpression | passwd --stdin xpression

RUN echo "xpress ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && echo "Defaults:xpress !requiretty" >> /etc/sudoers

ENV XPRESS_HOME /opt/xpression
ENV XPRESS_LOG /var/log/xpression

RUN mkdir -p ${XPRESS_HOME} ${XPRESS_LOG}

# installing oracle client
COPY ./bundles /bundles
RUN	rpm -ivh /bundles/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm ; \
	rpm -ivh /bundles/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm ; \
	rpm -ivh /bundles/oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm ; \
	[ -h /usr/bin/sqlplus ] || ln -s /usr/bin/sqlplus64 /usr/bin/sqlplus; \
	echo "/usr/lib/oracle/11.2/client64/lib" > /etc/ld.so.conf.d/oracle.conf && ldconfig

COPY tnsnames.ora $XPRESS_HOME/
RUN echo "export ORACLE_HOME=/usr/lib/oracle/11.2/client64" >> /etc/profile.d/xpress.sh ; \
    echo "export TNS_ADMIN=\${XPRESS_HOME}" >> /etc/profile.d/xpress.sh

# installing Oracle Java
##RUN cd /tmp \
## && curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm' \
##        -H 'Cookie: oraclelicense=accept-securebackup-cookie' \
## && rpm -i jdk-7u79-linux-x64.rpm \
## && rm jdk-7u79-linux-x64.rpm

RUN cd /tmp \
 && rpm -i /bundles/jdk-7u79-linux-x64.rpm \
 && echo Done

# installing JBoss 7.1
### && curl -LO http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.zip \
RUN cd ${XPRESS_HOME} \
 && unzip -q /bundles/jboss-as-7.1.1.Final.zip  \
 && mv jboss-as-7.1.1.Final jboss-7.1  \
 && rm -f jboss-as-7.1.1.Final.zip 

COPY /bundles/docker-entrypoint.sh ${XPRESS_HOME}/entrypoint.sh

RUN chmod -R a+r /bundles && chmod a+x /bundles/*.sh

RUN chown -R xpress:xpress ${XPRESS_HOME} ${XPRESS_LOG}

#VOLUME [ "/opt/xpression", "/var/log/xpression" ]
RUN ls -l ${XPRESS_HOME} ${XPRESS_LOG} /bundles

USER xpress
WORKDIR $XPRESS_HOME

ENV REPOSITORY_NAME devbox
ENV APPSRV_HOME ${XPRESS_HOME}/jboss-7.1
ENV JAVA_HOME /usr/java/jdk1.7.0_79

ENV XPRESS_DBOUSER xpressdbo
ENV XPRESS_DBOPWD xpressdbo

ENV DOCUMENTUM_SHARED /opt/documentum

RUN	sudo mkdir -p ${DOCUMENTUM_SHARED} \
 &&	sudo chown xpress:xpress ${DOCUMENTUM_SHARED}

RUN chmod a+x ${XPRESS_HOME}/entrypoint.sh
ENTRYPOINT ["/opt/xpression/entrypoint.sh" ]
