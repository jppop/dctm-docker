FROM centos:centos6
MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

#Helpful utils, but only sudo is required
#RUN yum -y install tar
#RUN yum -y install vim
#RUN yum -y install nc
RUN yum -y install sudo

######## JDK7

#Note that ADD uncompresses this tarball automatically
ADD jdk-7u72-linux-x64.tar.gz /opt
WORKDIR /opt/jdk1.7.0_72
RUN alternatives --install /usr/bin/java java /opt/jdk1.7.0_72/bin/java 1
RUN alternatives --install /usr/bin/jar jar /opt/jdk1.7.0_72/bin/jar 1
RUN alternatives --install /usr/bin/javac javac /opt/jdk1.7.0_72/bin/javac 1
RUN echo "JAVA_HOME=/opt/jdk1.7.0_72" >> /etc/environment

######## TOMCAT

#Note that ADD uncompresses this tarball automatically
ADD apache-tomcat-7.0.57.tar.gz /usr/share
ADD tomcat7 /etc/rc.d/init.d/
WORKDIR /usr/share/
RUN mv  apache-tomcat-7.0.57 tomcat7
RUN echo "JAVA_HOME=/opt/jdk1.7.0_72/" >> /etc/default/tomcat7
RUN groupadd tomcat
RUN useradd -s /bin/bash -g tomcat tomcat
RUN chown -Rf tomcat.tomcat /usr/share/tomcat7
EXPOSE 8080
