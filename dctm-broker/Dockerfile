FROM dctm-base

COPY install.properties $DM_HOME/install/broker-install.properties
RUN chown dmadmin:dmadmin $DM_HOME/install/broker-install.properties

USER dmadmin

RUN $DM_HOME/install/dm_launch_server_config_program.sh -f $DM_HOME/install/broker-install.properties

WORKDIR $DOCUMENTUM

USER root
COPY docker-entrypoint.sh $DOCUMENTUM/entrypoint.sh
RUN chown dmadmin:dmadmin $DOCUMENTUM/entrypoint.sh \
 && chmod a+x $DOCUMENTUM/entrypoint.sh

EXPOSE 1489

USER dmadmin

ENV REPOSITORY_NAME devbox

ENTRYPOINT ["/opt/documentum/entrypoint.sh"]
