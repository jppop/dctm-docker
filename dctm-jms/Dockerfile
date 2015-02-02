FROM dctm-base

MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

# disable ip checking
WORKDIR ${DOCUMENTUM_SHARED}/jboss7.1.1/server/DctmServer_MethodServer/deployments/ServerApps.ear/DmMethods.war
COPY DmMethods-web.xml /tmp/
RUN cp --backup=numbered /tmp/DmMethods-web.xml WEB-INF/web.xml \
 && chown dmadmin:dmadmin WEB-INF/web.xml

WORKDIR ${DOCUMENTUM_SHARED}/jboss7.1.1/server

# the entrypoint
COPY entrypoint.sh ${DOCUMENTUM_SHARED}/jboss7.1.1/server/docker-entrypoint.sh

RUN chmod a+x docker-entrypoint.sh \
 && chown dmadmin:dmadmin docker-entrypoint.sh
 
EXPOSE 9080

USER dmadmin

ENV REPOSITORY_NAME devbox

WORKDIR ${DOCUMENTUM_SHARED}/jboss7.1.1/server
ENTRYPOINT ["/opt/documentum/shared/jboss7.1.1/server/docker-entrypoint.sh"]
