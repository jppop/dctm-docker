# Documentum xCP Designer
# Documentum is a registred trademark from EMC (http://www.emc.com/legal/emc-corporation-trademarks.htm)

FROM jenkins

USER root

ENV BUNDLES_DIR /bundles
COPY ./bundles ${BUNDLES_DIR}
RUN chmod -R a+r ${BUNDLES_DIR}

ENV XMSTOOL_HOME /opt/xms-tools

RUN mkdir ${XMSTOOL_HOME} \
 && unzip -q ${BUNDLES_DIR}/xms-tools-1.2.zip -d ${XMSTOOL_HOME} \
 && cp ${BUNDLES_DIR}/xms.sh ${XMSTOOL_HOME}/bin/ \
 && chmod a+x ${XMSTOOL_HOME}/bin/xms.sh

ENV XCPDESIGNER_HOME /opt/xCPDesigner
ENV XCPDESIGNER_WORKSPACE /var/xcp-workspace

RUN mkdir ${XCPDESIGNER_HOME} \
 && mkdir ${XCPDESIGNER_WORKSPACE} \
 && tar xf ${BUNDLES_DIR}/xCPDesigner_linux64_2.1.tar -C /opt \
 && echo Done

# cannot use JENKINS_HOME since the chown fails
RUN mkdir ${XCPDESIGNER_HOME}/.m2
COPY settings.xml ${XCPDESIGNER_HOME}/.m2/

# the entrypoint
COPY entrypoint.sh /docker-entrypoint.sh
RUN chmod a+x /docker-entrypoint.sh

RUN chown -R jenkins ${XMSTOOL_HOME} ${XCPDESIGNER_HOME} ${XCPDESIGNER_WORKSPACE} \
		/docker-entrypoint.sh

COPY ${BUNDLES_DIR}/plugins.txt /usr/share/jenkins/ref/
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt

USER jenkins

WORKDIR ${JENKINS_HOME}
ENTRYPOINT [ "/docker-entrypoint.sh", "/bin/tini", "--", "/usr/local/bin/jenkins.sh" ]
