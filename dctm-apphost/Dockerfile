FROM andrefernandes/docker-tomcat7

MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

VOLUME /var/log/tomcat
ENV LOGDIR /var/log/tomcat

#VOLUME /var/xms
#ENV XMS_DATA_DIR /var/xms

EXPOSE 8443

# the entrypoint (wrap catalina script)
COPY bundles/entrypoint.sh ${CATALINA_HOME}/docker-entrypoint.sh

RUN chmod a+x ${CATALINA_HOME}/docker-entrypoint.sh

# tomcat tuning
ENV CUSTOM_CATALINA_OPTS=""
ENV CUSTOM_JAVA_OPTS="-server -Xms512m -XX:MaxPermSize=512m -XX:+UseParallelOldGC \
-XX:+CMSClassUnloadingEnabled -XX:+CMSPermGenSweepingEnabled \
-Djava.security.egd=file:/dev/./urandom -Ddfc.properties.file=${CATALINA_HOME}/conf/dfc.properties \
-Dcatalina.logdir=${LOGDIR} -Dlog4j.configuration=file:${CATALINA_HOME}/conf/log4j.xml"
ENV CUSTOM_CATALINA_OUT ${LOGDIR}/catalina.out

# ovveride some tomcat configuration web.xml
COPY bundles/tomcat-conf/*.* ${CATALINA_HOME}/conf/

VOLUME /etc/tomcat

# extra config for CTS
RUN mkdir -p ${CATALINA_HOME}/conf/ctsws-config
COPY bundles/tomcat-conf/ctsws-config/*.* ${CATALINA_HOME}/conf/ctsws-config/

ENV REPOSITORY_NAME devbox
ENV REPOSITORY_USER dmadmin
ENV REPOSITORY_PWD dmadmin
ENV REGISTRY_USER dm_bof_registry
ENV REGISTRY_CRYPTPWD AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv
ENV REGISTRY_PWD dm_bof_registry

WORKDIR ${CATALINA_HOME}
# FIXME: can't use variable in ENTRYPOINT directive
ENTRYPOINT [ "./docker-entrypoint.sh", "bin/catalina.sh", "run" ]
CMD ["bin/catalina.sh", "run"]
