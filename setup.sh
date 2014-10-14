#!/usr/bin/env bash

echo "You need to be a sudoer and will have to enter your password once during this script."

if [ ! $(rpm -qa | grep docker) ]; then
  echo "Installing Docker"
  sudo yum install docker
fi

if [ "$(systemctl is-enabled docker)" -ne ' enabled' ]; then
  echo "Enabling Docker service"
  sudo systemctl enable docker
fi

if [ "$(systemctl is-active docker)" -ne ' active' ]; then
  echo "Starting Docker"
  sudo systemctl start docker
fi

if [ ! "$(sudo docker images | grep centos7)" ]; then
  echo "Puller container images for CentOS"
  sudo docker pull centos
fi

if [ ! "$(sudo docker images | grep 'gildas/puppetbase')" ]; then
  if [ "$(sudo docker search 'gildas/puppetbase')" ]; then
    echo "Pulling container images for Puppet Base from github.com/gildas"
    sudo docker pull gildas/puppetbase
  else
    echo "Building container: puppetbase"
    sudo docker build -t="gildas/puppetbase" .

    echo "Publishing container: puppetbase"
    sudo docker push gildas/puppetbase
  fi
fi

