#!/usr/bin/env bash

shopt -s extglob
set -o errtrace
set +o noclobber

export VERBOSE=1
export DEBUG=1
export NOOP=

whoami=$(whoami)

function log() # {{{
{
  printf "%b\n" "$*";
} # }}}

function debug() # {{{
{
  [[ ${DEBUG:-0} -eq 0 ]] || printf "[debug] $#: $*";
} # }}}

function verbose() # {{{
{
  [[ ${VERBOSE:-0} -eq 0 ]] || printf "$*\n";
} # }}}

function parse_args() # {{{
{
  flags=()

  while (( $# > 0 ))
  do
    arg="$1"
    shift
    case "$arg" in
      (--trace)
        set -o trace
	TRACE=1
	flags+=( "$arg" )
	;;
      (--noop)
        export NOOP=:
        ;;
      (--debug)
        export DEBUG=1
        flags+=( "$arg" )
        ;;
      (--quiet)
        export VERBOSE=0
        flags+=( "$arg" )
        ;;
      (--verbose)
        export VERBOSE=1
        flags+=( "$arg" )
        ;;
    esac
  done
} # }}}

# Main {{{
parse_args "$@"

echo "You need to be a sudoer and will have to enter your password once during this script."
[[ ! -z "$NOOP" ]] && echo "Running in dry mode (no command will be executed)"

# Loads the distro information
debug "Loading distribution information"
source /etc/*-release
debug "Done"

if [ "$ID" == "centos" ]; then
  echo "Running on $NAME release $VERSION"
  if [ "$VERSION_ID" == "7" ]; then
    if [ ! $(rpm -qa | grep docker) ]; then
      echo "Installing Docker"
      $NOOP sudo yum install docker
    fi

    if [ "$(systemctl is-enabled docker)" != 'enabled' ]; then
      echo "Enabling Docker service"
      $NOOP sudo systemctl enable docker
    fi

    if [ "$(systemctl is-active docker)" != 'active' ]; then
      echo "Starting Docker"
      $NOOP sudo systemctl start docker
    fi

    if [ -z "$(grep 'docker:.*:${whoami}' /etc/group)" ]; then
      echo "Adding user ${whoami} to group docker"
      sudo usermod -G docker ${whoami}
    fi
  fi
elif [ "$DISTRIB_ID" == 'Ubuntu' ]; then
  echo "Running on $DISTRIB_DESCRIPTION ($DISTRIB_CODENAME)"
  #if [ "$DISTRIB_RELEASE" == 
fi

if [ ! "$(sudo docker images | grep centos7)" ]; then
  echo "Pulling container images for CentOS"
  $NOOP sudo docker pull centos
fi

if [ ! "$(sudo docker images | grep 'gildas/puppetbase')" ]; then
  if [ "$(sudo docker search 'gildas/puppetbase')" ]; then
    echo "Pulling container images for Puppet Base from github.com/gildas"
    $NOOP sudo docker pull gildas/puppetbase
  else
    echo "Building container: puppetbase"
    $NOOP sudo docker build -t="gildas/puppetbase" .

    echo "Publishing container: puppetbase"
    $NOOP sudo docker push gildas/puppetbase
  fi
fi
# }}}
