FROM alexeiled/docker-oracle-xe-11g

EXPOSE 1521

COPY ./*.sh $HOME
RUN chmod a+x $HOME/*.sh

VOLUME /u01/app/oracle/oradata

CMD sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora; \
    service oracle-xe start; \
    $HOME/init-db.sh; \
    /usr/sbin/sshd -D
