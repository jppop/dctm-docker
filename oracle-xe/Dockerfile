FROM alexeiled/docker-oracle-xe-11g

EXPOSE 1521

COPY ./*.sh /u01/app/oracle/
RUN chmod a+x /u01/app/oracle/*.sh && chown oracle:dba /u01/app/oracle/*.sh

VOLUME /u01/app/oracle/oradata

CMD sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora; \
    service oracle-xe start; \
    su - oracle -c "/u01/app/oracle/init-db.sh" ; \
    su - oracle -c "/u01/app/oracle/tune-oracle.sh" ; \
    /usr/sbin/sshd -D
