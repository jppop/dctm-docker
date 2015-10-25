# Documentum XMS tools 1.1
# Documentum is a registred trademark from EMC (http://www.emc.com/legal/emc-corporation-trademarks.htm)

#FROM dockerfile/java:oracle-java7
FROM java:7

ENV XMSTOOL_HOME /opt/xms-tools

COPY ./bundles /bundles
RUN mkdir ${XMSTOOL_HOME} \
 && unzip -q /bundles/xms-tools-1.2.zip -d ${XMSTOOL_HOME} \
 && cp /bundles/xms.sh ${XMSTOOL_HOME}/bin/ \
 && chmod a+x ${XMSTOOL_HOME}/bin/xms.sh \
 && cp /bundles/deploy.sh ${XMSTOOL_HOME}/bin/ \
 && chmod a+x ${XMSTOOL_HOME}/bin/deploy.sh

# the entrypoint
COPY entrypoint.sh ${XMSTOOL_HOME}/docker-entrypoint.sh
RUN chmod a+x ${XMSTOOL_HOME}/docker-entrypoint.sh

WORKDIR ${XMSTOOL_HOME}

RUN chmod a+x bin/xms.sh

ENTRYPOINT [ "./docker-entrypoint.sh" ]
CMD ["/bin/bash"]
