#!/bin/bash
# Created by Seth Thompson <seth@atsu.io>
#
# This will generate aws config file for travis ci
# for use with the awscli tool
AWS_CONFIG_FILE=$HOME/.aws/config
rm -f ${AWS_CONFIG_FILE}
mkdir -p $HOME/.aws

if [ -z "${ARTIFACTS_KEY}" ]; then
    echo "'ARTIFACTS_KEY' does not exist, please check the Travis Build configuration." >&2
    exit 1
fi

if [ -z "${ARTIFACTS_SECRET}" ]; then
    echo "'ARTIFACTS_SECRET' does not exist, please check the Travis Build configuration." >&2
    exit 1
fi

# Generate aws config file
echo "[default]" >> ${AWS_CONFIG_FILE}
echo "output = json" >> ${AWS_CONFIG_FILE}
echo "region = us-west-2" >> ${AWS_CONFIG_FILE}
echo "aws_access_key_id = ${ARTIFACTS_KEY}" >> ${AWS_CONFIG_FILE}
echo "aws_secret_access_key = ${ARTIFACTS_SECRET}" >> ${AWS_CONFIG_FILE}
exit 0