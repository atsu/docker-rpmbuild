#!/bin/sh
/usr/bin/rpm --import /keys/*
/usr/bin/rpmkeys -K $1
