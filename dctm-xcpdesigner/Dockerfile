# Documentum xCP Designer
# Documentum is a registred trademark from EMC (http://www.emc.com/legal/emc-corporation-trademarks.htm)

FROM dctm-xmstools

# install maven
ENV MAVEN_VERSION 3.2.5

RUN curl -sSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/jre

ENV XCPDESIGNER_HOME /opt/xCPDesigner
ENV XCPDESIGNER_WORKSPACE /var/xcp-workspace

COPY ./bundles /bundles
RUN mkdir ${XCPDESIGNER_HOME} \
 && mkdir ${XCPDESIGNER_WORKSPACE} \
 && tar xf /bundles/xCPDesigner_linux64_2.1.tar -C /opt \
 && echo Done

# Install jenkins
RUN wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add - \
 && echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list \
 && apt-get update \
 && apt-get install -y jenkins

EXPOSE 8080

RUN mkdir /root/.m2
COPY settings.xml /root/.m2/
