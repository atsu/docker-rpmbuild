#!/usr/bin/env bats
#setup() {
#    docker pull "atsuio/rpmbuilder:centos8" >&2
#}

@test "centos 8 version is correct" {
  run docker run --entrypoint "cat" "atsuio/rpmbuilder:centos8" /etc/os-release
  [ $status -eq 0 ]
  [ "${lines[0]}" = 'NAME="CentOS Linux"' ]
  [ "${lines[1]}" = 'VERSION="8 (Core)"' ]
}