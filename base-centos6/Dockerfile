FROM centos:centos6

MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

ENV TIMEZONE Europe/Paris
RUN echo ZONE="$TIMEZONE" > /etc/sysconfig/clock && \
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

ENV TIMEZONE Europe/Paris
RUN echo ZONE="$TIMEZONE" > /etc/sysconfig/clock && \
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

RUN yum update -y \
 && yum install -y openssh-server \
                   tar sudo which tar zip unzip telnet install wget gettext bc passwd

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd

# generate ssh key
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN sed -ri 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd
RUN mkdir -p /root/.ssh && chown root.root /root && chmod 700 /root/.ssh

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# break nsenter (actually docker-enter.sh)
#ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

ENV LANG en_US.utf8
ENV LANG_ALL en_US.utf8

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
