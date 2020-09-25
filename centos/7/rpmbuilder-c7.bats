#!/usr/bin/env bats
#setup() {
#    docker pull "ghcr.io/atsu/rpmbuilder:centos7" >&2
#}

@test "centos 7 version is correct" {
  run docker run --entrypoint "cat" "ghcr.io/atsu/rpmbuilder:centos7" /etc/os-release
  [ $status -eq 0 ]
  [ "${lines[0]}" = 'NAME="CentOS Linux"' ]
  [ "${lines[1]}" = 'VERSION="7 (Core)"' ]
}
