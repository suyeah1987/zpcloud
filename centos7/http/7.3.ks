# CentOS 7.x kickstart file - ks7.cfg
#
# For more information on kickstart syntax and commands, refer to the
# CentOS Installation Guide:
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Installation_Guide/sect-kickstart-syntax.html
#
# For testing, you can fire up a local http server temporarily.
# cd to the directory where this ks.cfg file resides and run the following:
#    $ python -m SimpleHTTPServer
# You don't have to restart the server every time you make changes.  Python
# will reload the file from disk every time.  As long as you save your changes
# they will be reflected in the next HTTP download.  Then to test with
# a PXE boot server, enter the following on the PXE boot prompt:
#    > linux text ks=http://<your_ip>:8000/ks.cfg

# Required settings
lang en_US.UTF-8
keyboard us
rootpw password01!
authconfig --enableshadow --enablemd5
rootpw centos
user --name=centos --plaintext --password centos

timezone --utc Asia/Shanghai
# Optional settings
install
cdrom
unsupported_hardware
network --device eth0 --bootproto=dhcp
firewall --disabled
selinux --disabled
# The biosdevname and ifnames options ensure we get "eth0" as our interface
# even in environments like virtualbox that emulate a real NW card
bootloader --location=mbr --driveorder=vda --append="rhgb quiet"
#zerombr
#clearpart --all --initlabel
part biosboot --fstype=biosboot --size=1
part /boot --fstype ext4 --size=2000 --ondisk=vda
#part / --fstype ext4 --grow --size=9912 --ondisk=vda
part pv.01 --size=1 --grow --ondisk=vda
volgroup system pv.01

logvol / --fstype ext4 --name=root --vgname=system --size=7912

#firstboot --disabled
reboot

%pre
clearpart -all
#/usr/sbin/parted -script /dev/vda mklabel
/usr/sbin/parted -s /dev/vda mklabel gpt
%end

%packages --nobase --ignoremissing --excludedocs
# vagrant needs this to copy initial files via scp
@network-tools
@base
gcc-c++
libpng-devel
ntp
parted
vim-enhanced
net-snmp-utils
net-snmp-libs
net-snmp
openssl
openssl-devel
sysstat
lrzsz
dos2unix
telnet
tree
psmisc
openssh-clients
# Prerequisites for installing VMware Tools or VirtualBox guest additions.
# Put in kickstart to ensure first version installed is from install disk,
# not latest from a mirror.
kernel-headers
kernel-devel
gcc
make
perl
curl
wget
bzip2
dkms
patch
net-tools
git
# Core selinux dependencies installed on 7.x, no need to specify
# Other stuff
sudo
nfs-utils
-fprintd-pam
-intltool

# Microcode updates cannot work in a VM
-microcode_ctl
# unnecessary firmware
-aic94xx-firmware
-alsa-firmware
-alsa-tools-firmware
-atmel-firmware
-b43-openfwwf
-bfa-firmware
-ipw*-firmware
-irqbalance
-ivtv-firmware
-iwl*-firmware
-libertas-usb8388-firmware
-ql*-firmware
-rt61pci-firmware
-rt73usb-firmware
-xorg-x11-drv-ati-firmware
-zd1211-firmware
# Don't build rescue initramfs
#-dracut-config-rescue
%end

%post
# Lock root account
passwd -l root

# Configure user in sudoers and remove root password
echo "centos ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/centos
chmod 0440 /etc/sudoers.d/centos
sed -i "s/^\(.*requiretty\)$/#\1/" /etc/sudoers

# keep proxy settings through sudo
echo 'Defaults env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY NO_PROXY"' >> /etc/sudoers
%end
