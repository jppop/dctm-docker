FROM tomcat:7

MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

# copy BAM war
COPY bundles/bam-server.war ${CATALINA_HOME}/webapps/

# the entrypoint (wrap catalina script)
COPY bundles/entrypoint.sh ${CATALINA_HOME}/docker-entrypoint.sh

RUN chmod a+x ${CATALINA_HOME}/docker-entrypoint.sh \
 && chmod a+x ${CATALINA_HOME}/bin/make-dfc.properties

# tomcat tuning
ENV CUSTOM_CATALINA_OPTS="-server -Xms512m -Xmx1024m -DMaxPermSize=128 -XX:+UseParallelOldGC" \
    CUSTOM_JAVA_OPTS="-Ddfc.properties.file=${CATALINA_HOME}/conf/dfc.properties -Dbam.properties=${catalina_home}/conf/bam.properties -Dcatalina.logdir=${CATALINA_HOME}/log -Dlog4j.properties=${CATALINA_HOME}/conf/log4j.xml"

# ovveride some tomcat configuration web.xml
COPY bundles/tomcat-conf/*.* ${CATALINA_HOME}/conf/

ENV REPOSITORY_NAME devbox
ENV REPOSITORY_USER dmadmin
ENV REPOSITORY_PWD dmadmin
ENV REGISTRY_NAME devbox
ENV REGISTRY_USER dm_bof_registry
ENV REGISTRY_CRYPTPWD AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv
ENV REGISTRY_PWD dm_bof_registry

ENV BAM_USER bamdbo
ENV BAM_PWD bamdbo

WORKDIR ${CATALINA_HOME}
# FIXME: can't use variable in ENTRYPOINT directive
ENTRYPOINT [ "./docker-entrypoint.sh", "catalina.sh", "run" ]
CMD ["catalina.sh", "run"]
