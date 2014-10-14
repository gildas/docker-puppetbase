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

function error() # {{{
{
  echo >&2 "$@"
} # }}}

function has_application() # {{{
{
  command -v "$@" > /dev/null 2>&1
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

case "$(uname -m)" in
  *64) ;;
  *)
    error 'This operating system is not a 64 bit platform'
    error 'Docker currently support only 64 bit platforms'
    exit 1
    ;;
esac

echo "You need to be a sudoer and will have to enter your password once during this script."
[[ ! -z "$NOOP" ]] && echo "Running in dry mode (no command will be executed)"

# Loads the distro information
debug "Loading distribution information"
source /etc/os-release
[[ -r /etc/lsb-release ]] && source /etc/lsb-release
echo "Running on $NAME release $VERSION"
debug "Done"

if has_application docker || has_application lxc-docker ; then
  echo "Docker is already installed on this system"
else
  if [ "$ID" == "centos" ]; then
    if [ "$VERSION_ID" == "7" ]; then
      if [ ! $(rpm -qa | grep docker) ]; then
        echo "Installing Docker"
        $NOOP sudo yum update
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
    else
      echo "We are very sorry, but we cannot complete the automatic installation as this version of $NAME is not yet supported."
      exit 1
    fi
  elif [ "$ID" == 'ubuntu' ]; then
    if [ "$VERSION_ID" == '14.04' ]; then
      echo "Installing Docker"
      $NOOP sudo apt-get --assume-yes update
      $NOOP sudo apt-get --assume-yes install docker.io
      $NOOP sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker

      if [ "$(systemctl is-enabled docker)" != 'enabled' ]; then
        echo "Enabling Docker service"
        $NOOP sudo update-rc.d docker.io defaults
      fi

      if [ -z "$(service docker.io status | grep running)" ]; then
        echo "Starting Docker"
        $NOOP sudo service docker.io start
      fi
    else
      echo "We are very sorry, but we cannot complete the automatic installation as this version of $NAME is not yet supported."
      exit 1
    fi
  else 
    echo "We are very sorry, but we cannot complete the automatic installation as this operating system is not yet supported."
    exit 1
  fi
fi

if [ -z "$(grep 'docker:.*:${whoami}' /etc/group)" ]; then
  echo "Adding user ${whoami} to group docker"
  $NOOP sudo usermod -aG docker ${whoami}
fi

exit 0

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
