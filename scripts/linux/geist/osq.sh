#!/bin/bash

BASE="https://raw.githubusercontent.com/applied-cyber/ccdc/master/packages/linux/fleet-osquery"
OSQ="/tmp/fleet-osquery"

WGET="wget --no-check-certificate"
CURL="curl -k"
DNF="dnf -y install"
YUM="yum -y install"

echo "192.168.10.58 fleet.ccdc.local" >> /etc/hosts
if command -v apt >/dev/null; then
    export DEBIAN_FRONTEND=noninteractive
	$WGET $BASE.deb -O $OSQ.deb || $CURL $BASE.deb --output $OSQ.deb
	apt -yqq install $OSQ.deb
elif command -v dnf >/dev/null; then
	$WGET $BASE.rpm -O $OSQ.rpm || $CURL $BASE.rpm --output $OSQ.rpm
	$DNF python3-libselinux
    $DNF libselinux-python
    $DNF --nogpgcheck $OSQ.rpm
elif command -v yum >/dev/null; then
	$WGET $BASE.rpm -O $OSQ.rpm || $CURL $BASE.rpm --output $OSQ.rpm
	$YUM python3-libselinux
    $YUM libselinux-python
    $YUM --nogpgcheck $OSQ.rpm
fi