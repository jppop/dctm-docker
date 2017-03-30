FROM wnameless/oracle-xe-11g

RUN echo 'root:root' | chpasswd

COPY ./*.sh /u01/app/oracle/
RUN chmod a+x /u01/app/oracle/*.sh && chown oracle:dba /u01/app/oracle/*.sh

ADD init-db.sh /docker-entrypoint-initdb.d/
ADD tune-oracle.sh /docker-entrypoint-initdb.d/
