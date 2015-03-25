FROM dctm-base

MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

# copy the BPM ear and the dars to be installed
COPY ./bundles /bundles
RUN chown -R dmadmin:dmadmin /bundles
# move the dar to usual location
RUN mv /bundles/BPM/dars/*.dar ${DM_HOME}/install/DARsInternal/

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

ENV JMS_HOME ${DOCUMENTUM_SHARED}/jboss7.1.1/server
ENV REPOSITORY_NAME devbox
ENV REGISTRY_USER dm_bof_registry
ENV REGISTRY_CRYPTPWD AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv
ENV REGISTRY_PWD dm_bof_registry

WORKDIR ${JMS_HOME}
ENTRYPOINT ["/opt/documentum/shared/jboss7.1.1/server/docker-entrypoint.sh"]
