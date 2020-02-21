#!/bin/bash

readonly DOCKER_J2CLI_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# docker-j2cli
function docker-j2cli () {
  local command="docker run --rm -it -e TZ=Europe/Vienna -v $(pwd):/mnt gepardec/j2cli"
  echo "+ ${command} $@" && ${command} $@
}
readonly -f docker-j2cli
[ "$?" -eq "0" ] || return $?

# docker-j2cli-build
function docker-j2cli-build () {
  local command="docker build -t gepardec/j2cli $@ ${DOCKER_J2CLI_HOME}"
  echo "+ ${command}" && ${command}
}
readonly -f docker-j2cli-build
[ "$?" -eq "0" ] || return $?