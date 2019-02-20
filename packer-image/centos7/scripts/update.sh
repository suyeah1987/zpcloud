#!/bin/bash -eux

UPGRADE=${CENTOS_UPGRADE:-no}

echo "* Updating from repositories"
cat > /etc/resolv.conf << EOF
nameserver 10.100.10.3
nameserver 10.100.10.4
options timeout:1 attempts:1
EOF
mkdir /etc/yum.repos.d/bak
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak
wget -O /etc/yum.repos.d/17usoft.repo http://mirrors.17usoft.com/.17usoft.repo
yum clean all
yum makecache

#yum -y update

if [ -z "${UPGRADE##*true*}" ] || [ -z "${UPGRADE##*1*}" ] || [ -z "${UPGRADE##*yes*}" ]; then
    echo "* Performing upgrade (all packages and kernel)"
    yum -y distro-sync
    yum -y upgrade
    reboot
    sleep 60
fi

