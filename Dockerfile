FROM centos:centos7
MAINTAINER Gildas Cherruel "gildas.cherruel@inin.com"

RUN yum --assumeyes update
RUN yum --assumeyes install git wget
RUN yum --assumeyes install puppet rubygems
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
