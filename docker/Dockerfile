FROM centos:latest
MAINTAINER "zack ramjan" <zack.hr@gREMOVEmail.com>
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
RUN yum -y install wget
#RUN cd /tmp;wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
#RUN rpm -ivh /tmp/epel-release-7-5.noarch.rpm
RUN yum -y install mariadb-server
RUN yum -y install mariadb
RUN yum -y install tomcat
RUN yum -y install git
RUN systemctl enable mariadb
RUN systemctl enable tomcat
ADD sql_setup.sh /sql_setup.sh
ADD dbdump_tcga.sql.gz /dbdump_tcga.sql.gz
RUN /bin/sh /sql_setup.sh
VOLUME [ "/sys/fs/cgroup" ]
VOLUME [ "/hostmount" ]
CMD ["/usr/sbin/init"]

#how i run:
#  docker run -ti -d -privileged --name=ecdp_docker -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 3306:3306 ecdp

#connect to live instance
#docker exec -it ecdp_docker /bin/bash

