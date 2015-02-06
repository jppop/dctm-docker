FROM dctm-base

MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

COPY ./bundles /bundles
RUN chown -R dmadmin:dmadmin /bundles

COPY entrypoint.sh ${DOCUMENTUM}/docker-entrypoint.sh
RUN chown dmadmin:dmadmin ${DOCUMENTUM}/docker-entrypoint.sh \
 && chmod a+x ${DOCUMENTUM}/docker-entrypoint.sh

EXPOSE 8080 8008

USER dmadmin

ENV REPOSITORY_NAME devbox
ENV REGISTRY_NAME devbox
ENV REGISTRY_USER dm_bof_registry
ENV REGISTRY_CRYPTPWD AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv
ENV REGISTRY_PWD dm_bof_registry
ENV TS_HOME ${DM_HOME}/thumbsrv

RUN mkdir /tmp/ts-install \
 && tar -xvf /bundles/Thumbnail_Server_7.1_linux.tar -C /tmp/ts-install \
 && cd /tmp/ts-install \
 && chmod u+x ./thumbserverLinuxSetup.bin \
 && ./thumbserverLinuxSetup.bin -config /bundles/tsInstall.ini -silent \
 && cat install.log \
 && echo "done"

WORKDIR ${DOCUMENTUM}
# FIXME: can't use variable in ENTRYPOINT directive
ENTRYPOINT [ "./docker-entrypoint.sh", "./catalina.sh", "run" ]
CMD ["./catalina.sh", "run"]
