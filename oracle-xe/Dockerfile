FROM alexeiled/docker-oracle-xe-11g

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 1521
EXPOSE 22
EXPOSE 8080

COPY ./*.sh /u01/app/oracle/
RUN chmod a+x /u01/app/oracle/*.sh && chown oracle:dba /u01/app/oracle/*.sh

VOLUME /u01/app/oracle/oradata

CMD sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora; \
    service oracle-xe start; \
    su - oracle -c "/u01/app/oracle/init-db.sh" ; \
    su - oracle -c "/u01/app/oracle/tune-oracle.sh" ; \
    /usr/sbin/sshd -D
