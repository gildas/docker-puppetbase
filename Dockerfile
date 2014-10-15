FROM centos:centos7
MAINTAINER Gildas Cherruel "gildas.cherruel@inin.com"

# This will tell systemd it is running in a container
#ENV container docker

RUN yum --assumeyes update ; yum clean all
#RUN yum --assumeyes erase fakesystemd
#RUN yum --assumeyes install systemd ; yum clean all ; \
#    rm -f /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles=setup.service \
#          /lib/systemd/system/multi-user.target.wants/* \
#          /lib/systemd/system/local-fs.target.wants/* \
#          /lib/systemd/system/sockets.target.wants/{*udev*,*initctl*} \
#          /lib/systemd/system/basic.target.wants/* \
#          /lib/systemd/system/anaconda.target.wants/* \
#          /etc/systemd/system/*.wants/*
RUN yum --assumeyes install git wget
RUN rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
RUN yum --assumeyes install puppet
RUN yum --assumeyes install rubygems

#VOLUME [ "/sys/fs/cgroup" ]
# Adding this to your container will start systemd and control services
#CMD [ "/usr/sbin/init" ]
