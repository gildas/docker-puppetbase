FROM centos:centos7
MAINTAINER Gildas Cherruel "gildas.cherruel@inin.com"

RUN yum --assumeyes update
RUN yum --assumeyes install git wget
RUN yum --assumeyes install rubygems
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN gem install puppet librarian-puppet