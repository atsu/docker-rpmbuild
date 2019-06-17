#!/bin/sh
/usr/bin/rpmkeys -K $1 | grep -q 'NOT OK'
if [ $? -eq 0 ]; then
	echo 'FAILED to verify RPM package'
	exit 1
fi
/usr/bin/rpmkeys -K $1 | grep -q -v 'pgp'
if [ $? -ne 1 ]; then
	echo 'FAILED to verify RPM signature'
	exit 1
fi
