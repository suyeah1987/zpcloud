#!/bin/bash -eux

DATASOURCE_LIST="ConfigDrive, Openstack, None"
# Comma list of choices: 
#    NoCloud: Reads info from /var/lib/cloud/seed only, 
#    ConfigDrive: Reads data from Openstack Config Drive, 
#    OpenNebula: read from OpenNebula context disk, 
#    Azure: read from MS Azure cdrom. Requires walinux-agent, 
#    AltCloud: config disks for RHEVm and vSphere, 
#    OVF: Reads data from OVF Transports, 
#    MAAS: Reads data from Ubuntu MAAS, 
#    GCE: google compute metadata service, 
#    OpenStack: native openstack metadata service, 
#    CloudSigma: metadata over serial for cloudsigma.com, 
#    Ec2: reads data from EC2 Metadata service, 
#    CloudStack: Read from CloudStack metadata service, 
#    None: Failsafe datasource

### Install repo
echo "* Installing EPEL repository for cloud-init"
#rpm -Uvh https://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
#yum install -y epel-release

### Install packages
echo "* Installing cloud-init"
#yum install -y cloud-init cloud-utils-growpart
#yum install -y cloud-init cloud-utils-growpart
