FROM dctm-base

# helper script used to create a response file
COPY create-responsefile.sh $DM_HOME/install/create-responsefile.sh
RUN chown dmadmin:dmadmin $DM_HOME/install/create-responsefile.sh; \
    chmod a+x $DM_HOME/install/create-responsefile.sh

# helper script used to delete any previous installation
COPY delete-schema.sh $DM_HOME/install/delete-schema.sh
RUN chown dmadmin:dmadmin $DM_HOME/install/delete-schema.sh; \
    chmod a+x $DM_HOME/install/delete-schema.sh

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
RUN chown dmadmin:dmadmin $DOCUMENTUM/entrypoint.sh; \
    chmod a+x $DOCUMENTUM/entrypoint.sh

EXPOSE 49000 49001

USER dmadmin
WORKDIR $DOCUMENTUM

ENV REPOSITORY_NAME devbox

ENTRYPOINT ["/opt/documentum/entrypoint.sh", "--repo-name=devbox" ]
CMD ["--repo-name=devbox"]
##USER root
##CMD ["/usr/sbin/sshd", "-D"]
