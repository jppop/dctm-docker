FROM tomcat:7

MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

VOLUME /var/log/tomcat
ENV LOGDIR /var/log/tomcat

# copy BPS war
COPY bundles/bps.war ${CATALINA_HOME}/webapps/

# the entrypoint (wrap catalina script)
COPY bundles/entrypoint.sh ${CATALINA_HOME}/docker-entrypoint.sh

RUN chmod a+x ${CATALINA_HOME}/docker-entrypoint.sh

# tomcat tuning
ENV CUSTOM_CATALINA_OPTS="" \
    CUSTOM_JAVA_OPTS="-server -Xms512m -Xmx1024m -XX:MaxPermSize=256m -XX:+UseParallelOldGC -Ddfc.properties.file=${CATALINA_HOME}/conf/dfc.properties -Dcatalina.logdir=${LOGDIR} -Dlog4j.properties=${CATALINA_HOME}/conf/log4j.xml"
ENV CUSTOM_CATALINA_OUT ${LOGDIR}/catalina.out

# ovveride some tomcat configuration web.xml
COPY bundles/tomcat-conf/*.* ${CATALINA_HOME}/conf/

ENV REPOSITORY_NAME devbox
ENV REPOSITORY_USER dmadmin
ENV REPOSITORY_PWD dmadmin
ENV REGISTRY_USER dm_bof_registry
ENV REGISTRY_CRYPTPWD AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv
ENV REGISTRY_PWD dm_bof_registry

WORKDIR ${CATALINA_HOME}
# FIXME: can't use variable in ENTRYPOINT directive
ENTRYPOINT [ "./docker-entrypoint.sh", "catalina.sh", "run" ]
CMD ["catalina.sh", "run"]
