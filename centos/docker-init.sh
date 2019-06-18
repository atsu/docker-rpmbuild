#!/bin/bash
# Copyright 2015-2016 jitakirin
# Modified by Setheck 1/03/2019
#
# This file is part of docker-rpmbuild.
#
# docker-rpmbuild is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# docker-rpmbuild is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with docker-rpmbuild.  If not, see <http://www.gnu.org/licenses/>.

function usage() {
  if [ -n "$1" ]; then
    echo -e "${RED}👉 $1${CLEAR}\n";
  fi
  echo "Typical usage is "
  echo "docker run [--rm] -v /path/to/source:/src -w /src rpmbuild -s SPECFILE [-a \"NAME;KEYFILE;PASSWORD\"] [-o OUTDIR]" >&2
  echo "Options: " >&2
  echo "  --sh         Drop to shell for debugging" >&2
  echo "  -s|--spec    Set spec file" >&2
  echo "  -o|--outdir  Set output directory, defaults to '.'" >&2
  echo "  -a|--sign    Set info for RPM signing, required to have 3 segments" >&2
  echo "               encased in quotes delimited by ';' ex: \"<Name>;<KeyFile>;<Password>\""
  echo "  -a2          Set info for (second) RPM signing, required to have 3 segments" >&2
  echo "               encased in quotes delimited by ';' ex: \"<Name>;<KeyFile>;<Password>\""
  echo "  -v, --verbose   Turn on verbose mode" >&2
  echo "  -h|--help    this help text." >&2
  echo "" >&2
  exit 2
}

function verifyOptions() {
    if [ -n "${SIGNATURE}" ] && [ ${#SIGNATURE[@]} -ne 3 ]; then
      echo -e "Signature is required to have 3 segments delimited by ';'" \
        "\"<Name>;<KeyFile>;<Password>\"" >&2
      exit 2
    fi

    if [ -n "${SIGNATURE2}" ] && [ ${#SIGNATURE2[@]} -ne 3 ]; then
      echo -e "Signature is required to have 3 segments delimited by ';'" \
        "\"<Name>;<KeyFile>;<Password>\"" >&2
      exit 2
    fi
}

function signrpm() {
  SIGN_NAME=$1
  SIGN_KEYFILE=$2
  SIGN_PASS=$3

  echo "Signing with $SIGN_NAME, $SIGN_KEYFILE, $SIGN_PASS"

  # if name, keyfile, and pass are provide, sign the rpms
  if [ -n "$SIGN_NAME" ] && [ -e "$SIGN_KEYFILE" ] && [ -n "$SIGN_PASS" ]; then
       # attempt to import the keyfile
       runuser rpmbuild -c "/usr/bin/gpg --import $SIGN_KEYFILE"
       #TODO: verify keyfile import success
       #for each RPM created, attempt to sign
       find ~rpmbuild/rpmbuild/{RPMS,SRPMS}/ -iname "*rpm" \
          -exec runuser -u rpmbuild /usr/bin/expect /usr/local/bin/docker-rpm-sign.sh {} "$SIGN_NAME" "$SIGN_PASS" \;
       # verify signature
       find ~rpmbuild/rpmbuild/{RPMS,SRPMS}/ -iname "*rpm" \
          -exec runuser -u rpmbuild /usr/local/bin/docker-rpm-verify.sh {} \; | grep -q 'FAILED'
       if [ $? -eq 0 ]; then
               echo "RPM verification failed."
               exit 1
       fi
  fi
}

DEBUG=false
BUILD=true
# parse params
while [[ "$#" > 0 ]]; do case $1 in
  --sh)         BUILD=false;shift;;
  -s|--spec)    SPEC="$2";shift;shift;;
  -o|--outdir)  OUTDIR="$2";shift;shift;;
  -a|--sign)    SIGNATURE=(${2//;/ });shift;shift;;
  -a2)          SIGNATURE2=(${2//;/ });shift;shift;;
  -v|--verbose) VERBOSE=1;shift;;
  -h|--help)    usage;;
  *) usage "Unknown parameter passed: $1"; shift; shift;;
esac; done

verifyOptions # Verify incoming values

OUTDIR="${OUTDIR:-$PWD}"

if ${DEBUG}; then
  SIGN_NAME=${SIGNATURE[0]}
  SIGN_KEYFILE=${SIGNATURE[1]}
  SIGN_PASS=${SIGNATURE[2]}

  SIGN2_NAME=${SIGNATURE2[0]}
  SIGN2_KEYFILE=${SIGNATURE2[1]}
  SIGN2_PASS=${SIGNATURE2[2]}

  echo "SPEC: ${SPEC}" \
   " OUTDIR: ${OUTDIR}" \
   " SIGN_NAME: ${SIGN_NAME}" \
   " SIGN_KEYFILE: ${SIGN_KEYFILE}" \
   " SIGN_PASS: ${SIGN_PASS}" >&2

  echo "SPEC: ${SPEC}" \
   " SIGN2_NAME: ${SIGN2_NAME}" \
   " SIGN2_KEYFILE: ${SIGN2_KEYFILE}" \
   " SIGN2_PASS: ${SIGN2_PASS}" >&2
fi

if [[ -z ${SPEC} || ! -e ${SPEC} ]]; then
  echo "Spec file not found! Cannot continue" >&2
  exit 2
fi

# pre-builddep hook for adding extra repos
if [[ -n ${PRE_BUILDDEP} ]]; then
  bash "${VERBOSE}" -c "${PRE_BUILDDEP}"
fi

# install build dependencies declared in the specfile
yum-builddep -y "${SPEC}"

# drop to the shell for debugging manually
if ! ${BUILD}; then
  exec "${SHELL:-/bin/bash}" -l
fi

# execute the build as rpmbuild user
runuser rpmbuild /usr/local/bin/docker-rpm-build.sh "$SPEC"

/usr/local/bin/docker-rpm-import.sh

signrpm ${SIGNATURE[0]}  ${SIGNATURE[1]}  ${SIGNATURE[2]}

# Clear imported signature
runuser rpmbuild -c "rm -rf /home/rpmbuild/.gnupg/"

signrpm ${SIGNATURE2[0]} ${SIGNATURE2[1]} ${SIGNATURE2[2]}

# copy the results back; done as root as rpmbuild most likely doesn't
# have permissions for OUTDIR; ensure ownership of output is consistent
# with source so that the caller of this image doesn't run into
# permission issues
mkdir -p "${OUTDIR}"
cp ${VERBOSE:+-v} -a --reflink=auto \
  ~rpmbuild/rpmbuild/{RPMS,SRPMS} "${OUTDIR}/"
TO_CHOWN=( "${OUTDIR}/"{RPMS,SRPMS} )
if [[ ${OUTDIR} != ${PWD} ]]; then
  TO_CHOWN=( "${OUTDIR}" )
fi
chown ${VERBOSE:+-v} -R --reference="${PWD}" "${TO_CHOWN[@]}"
