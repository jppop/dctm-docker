FROM base-centos6

MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

# A volume to be ready to forward logs (future use)
VOLUME /forwarded-logs

# add our user and group first
RUN groupadd xplore && useradd -g xplore xplore
RUN echo xplore | passwd --stdin xplore

RUN echo "xplore ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY ./bundles /bundles
RUN chown -R xplore:xplore /bundles

RUN yum update -y \
 && yum -y --noplugins install wget

RUN yum -y --noplugins clean all

## && curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u75-b13/jdk-7u75-linux-x64.rpm' \
## 		-H 'Cookie: oraclelicense=accept-securebackup-cookie' \
## && rpm -i jdk-7u75-linux-x64.rpm \
## && rm jdk-7u75-linux-x64.rpm \
## && echo "done"

 RUN cd /tmp \
  && rpm -i /bundles/jdk-7u79-linux-x64.rpm \
  && echo "done"

RUN mkdir -p /tmp/xplore-install/setup

# unpack installer
RUN tar -xf /bundles/xPlore_1.4_linux-x64.tar -C /tmp/xplore-install/setup \
 && chmod u+x /tmp/xplore-install/setup/setup.bin \
 && echo "done"

# copy silent install tools
RUN mv /bundles/silent-install/* /tmp/xplore-install/ \
 && chmod a+x /tmp/xplore-install/xplore.sh \
 && echo "done"

# get ant (needed for the silent install)
ENV ANT_VERSION=1.9.6
### curl -LO "http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.zip"
### curl -LO 'http://downloads.sourceforge.net/project/ant-contrib/ant-contrib/1.0b3/ant-contrib-1.0b3-bin.tar.gz'
RUN cd /tmp \
  && unzip /bundles/apache-ant-${ANT_VERSION}-bin.zip \
  && mv ./apache-ant-${ANT_VERSION} ./xplore-install/ant \
  && tar -xzvf /bundles/ant-contrib-1.0b3-bin.tar.gz -C ./xplore-install/ant/lib/ --strip 1 ant-contrib/ant-contrib-1.0b3.jar \
  && echo "done"

RUN chown -R xplore:xplore /tmp/xplore-install \
 && echo "done"

RUN mkdir -p /opt/xplore \
 && chown -R xplore:xplore /opt/xplore \
 && mkdir -p /var/ess && chown -R xplore:xplore /var/ess \
 && mkdir -p /var/log/xplore && chown -R xplore:xplore /var/log/xplore \
 && mkdir -p /etc/ess && chown -R xplore:xplore /etc/ess \
 && echo "done"

COPY entrypoint.sh /opt/xplore/docker-entrypoint.sh
RUN chown xplore:xplore /opt/xplore/docker-entrypoint.sh \
 && chmod a+x /opt/xplore/docker-entrypoint.sh

EXPOSE 9300 9200 9205 9500 9530 9531 9521 9522 9600

USER xplore

ENV XPLORE_HOME /opt/xplore
ENV XPLORE_LOGDIR /var/log/xplore
ENV REPOSITORY_NAME devbox
ENV REPOSITORY_XPLORE_USER dmadmin
ENV REPOSITORY_XPLORE_PWD dmadmin
ENV REGISTRY_USER dm_bof_registry
ENV REGISTRY_CRYPTPWD AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv
ENV REGISTRY_PWD dm_bof_registry
ENV JAVA_HOME /usr/java/jdk1.7.0_79

WORKDIR ${XPLORE_HOME}
# FIXME: can't use variable in ENTRYPOINT directive
ENTRYPOINT [ "./docker-entrypoint.sh" ]
