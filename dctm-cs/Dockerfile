FROM dctm-base

MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

# helper script used to create a response file
COPY create-responsefile.sh $DM_HOME/install/create-responsefile.sh
RUN chown dmadmin:dmadmin $DM_HOME/install/create-responsefile.sh; \
    chmod a+x $DM_HOME/install/create-responsefile.sh

# helper script to welcome world (make ACS and TS reachable from outside Docker)
COPY welcome-world.sh $DM_HOME/install/welcome-world.sh
RUN chown dmadmin:dmadmin $DM_HOME/install/welcome-world.sh; \
    chmod a+x $DM_HOME/install/welcome-world.sh

# helper script used to delete any previous installation
COPY delete-schema.sh $DM_HOME/install/delete-schema.sh
RUN chown dmadmin:dmadmin $DM_HOME/install/delete-schema.sh; \
    chmod a+x $DM_HOME/install/delete-schema.sh

# wrapper script starting JMS
COPY startJms.sh $DM_HOME/install/
RUN chown dmadmin:dmadmin $DM_HOME/install/startJms.sh; \
    chmod a+x $DM_HOME/install/startJms.sh

# installing oracle client
COPY ./bundles /bundles
RUN	rpm -ivh /bundles/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm ; \
	rpm -ivh /bundles/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm ; \
	rpm -ivh /bundles/oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm ; \
	[ -h /usr/bin/sqlplus ] || ln -s /usr/bin/sqlplus64 /usr/bin/sqlplus; \
	echo "/usr/lib/oracle/11.2/client64/lib" > /etc/ld.so.conf.d/oracle.conf && ldconfig

COPY tnsnames.ora $DOCUMENTUM/dba/
RUN chown dmadmin:dmadmin $DOCUMENTUM/dba/tnsnames.ora; \
    chmod a+r $DOCUMENTUM/dba/tnsnames.ora; \
    echo "export ORACLE_HOME=/usr/lib/oracle/11.2/client64" >> /etc/profile.d/documentum.sh ; \
    echo "export TNS_ADMIN=\${DOCUMENTUM}/dba" >> /etc/profile.d/documentum.sh

USER root
COPY docker-entrypoint.sh $DOCUMENTUM/entrypoint.sh
RUN chown dmadmin:dmadmin $DOCUMENTUM/entrypoint.sh \
 && chmod a+x $DOCUMENTUM/entrypoint.sh

RUN mv /bundles/isalive.sh ${DM_HOME}/bin/ \
 && chown dmadmin:dmadmin ${DM_HOME}/bin/isalive.sh \
 && chmod a+x ${DM_HOME}/bin/isalive.sh

RUN mv /bundles/broker-install.properties $DM_HOME/install/broker-install.properties \
 && chown dmadmin:dmadmin $DM_HOME/install/broker-install.properties \
 && chmod -R a+r /bundles

EXPOSE 1489 49000 49001
EXPOSE 9080
# Thumnail Server
EXPOSE 8080 8008

USER dmadmin
WORKDIR $DOCUMENTUM

ENV REPOSITORY_NAME devbox
ENV JMS_HOME ${DOCUMENTUM_SHARED}/jboss7.1.1/server

ENV BAM_USER bamdbo
ENV BAM_PWD bamdbo

RUN mv $DM_HOME/install/startJms.sh ${JMS_HOME}/startJms.sh

# install Connection Broker
RUN $DM_HOME/install/dm_launch_server_config_program.sh -f $DM_HOME/install/broker-install.properties

# installing Thumbnail Server
ENV TS_HOME ${DM_HOME}/thumbsrv
RUN mkdir /tmp/ts-install \
 && tar -xvf /bundles/Thumbnail_Server_7.1_linux.tar -C /tmp/ts-install \
 && cd /tmp/ts-install \
 && chmod u+x ./thumbserverLinuxSetup.bin \
 && ./thumbserverLinuxSetup.bin -config /bundles/tsInstall.ini -silent \
 && cat install.log \
 && echo "done"

ENTRYPOINT ["/opt/documentum/entrypoint.sh", "--repo-name=devbox" ]
#CMD ["--repo-name=devbox"]
##USER root
##CMD ["/usr/sbin/sshd", "-D"]
