FROM alexeiled/docker-oracle-xe-11g

EXPOSE 1521

COPY ./enable-remote-accesss.sh /tmp/enable-remote-accesss.sh
RUN chmod a+x /tmp/enable-remote-accesss.sh

CMD sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora; \
    service oracle-xe start; \
    /tmp/enable-remote-accesss.sh; \
    /usr/sbin/sshd -D
