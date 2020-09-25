#!/usr/bin/env bats
#setup() {
#    docker pull "ghcr.io/atsu/rpmbuilder:centos6" >&2
#}

@test "centos 6 version is correct" {
  run docker run --entrypoint "cat" "ghcr.io/atsu/rpmbuilder:centos6" /etc/system-release
  [ $status -eq 0 ]
  [ "${lines[0]}" = "CentOS release 6.10 (Final)" ]
}
