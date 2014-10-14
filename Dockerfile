FROM centos:centos7
MAINTAINER Gildas Cherruel "gildas.cherruel@inin.com"

RUN yum --assumeyes update
RUN yum --assumeyes install git wget
RUN rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
RUN yum --assumeyes install puppet
RUN yum --assumeyes install rubygems
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
