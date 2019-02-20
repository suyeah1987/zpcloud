#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Mod_network_config(){
#edit network cfg
echo "#############################create ifcfg-XXX############################"
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="yes"
PEERDNS="yes"
IPV6INIT="no"
PERSISTENT_DHCLIENT="1"
EOF

cat > /etc/resolv.conf << EOF
nameserver 10.100.10.3
nameserver 10.100.10.4
options timeout:1 attempts:1
EOF
ip a
systemctl stop NetworkManager
systemctl disable NetworkManager
}

Mod_edit_ssh(){
echo "#################################mkdir .ssh#################################/n"
mkdir /home/centos/.ssh
mkdir /root/.ssh
}

Mod_edit_postfix(){
echo "#################################edit postfix###############################/n"
sed -i 's/#inet_interfaces = all/inet_interfaces = all/g' /etc/postfix/main.cf
sed -i 's/inet_protocols = all/inet_protocols = ipv4/g' /etc/postfix/main.cf
}

Mod_edit_grub(){
echo "#####################################update grub##############################/n"
sed -i '6s/.*/GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0 net.ifnames=0 biosdevname=1"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
}

Mod_edit_cloudinit(){
echo "######################################edit cloud-init###########################/n"
sed -i 's/disable_root: 1/disable_root: 0/' /etc/cloud/cloud.cfg
sed -i 's/ssh_pwauth:   0/ssh_pwauth:   1/' /etc/cloud/cloud.cfg
sed -i 's/name: fedora/name: centos/' /etc/cloud/cloud.cfg
sed -i 's/gecos: Fedora Cloud User/gecos: Cloud User/' /etc/cloud/cloud.cfg
sed -i 's/distro: fedora/distro: rhel/' /etc/cloud/cloud.cfg
}

Mod_sshd_permission(){
echo "###################################sshd permissions################################/n"
chown centos:centos /home/centos/.ssh
sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service sshd restart
}


Mod_replace_file(){
echo "#######################################update ifcfg-eth and cloud-init#####################/n"
mv /etc/sysconfig/network-scripts/ifup-eth /etc/sysconfig/network-scripts/bak.ifup-eth
mv /usr/bin/cloud-init /usr/bin/bak.cloud-init
wget -O /etc/sysconfig/network-scripts/ifup-eth http://download.tcwyun.com/images/packer/packer_file/ifup-eth
wget -O /usr/bin/cloud-init http://download.tcwyun.com/images/packer/packer_file/cloud-init
chmod 777 /usr/bin/cloud-init
chmod 777 /etc/sysconfig/network-scripts/ifup-eth

}

Mod_edit_passwd(){
echo "############################update passwd##################################"
echo 'password01!'| passwd --stdin root
}

Mod_edit_dracut(){
echo "##################################exec dracut#################################"
dracut -N --force
}

Mod_ins_tensorflow(){
echo "####################################install tensorflow##################################"
yum install zlib* -y
yum install readline* -y
yum install openssl* -y
yum install gcc* -y;
wget -O /opt/Python-3.6.1.tgz http://download.tcwyun.com/images/packer/package/Python-3.6.1.tgz
wget -O /opt/numpy-1.13.3-cp36-cp36m-manylinux1_x86_64.whl http://download.tcwyun.com/images/packer/package/numpy-1.13.3-cp36-cp36m-manylinux1_x86_64.whl
wget -O /opt/tensorflow-1.3.0-cp36-cp36m-manylinux1_x86_64.whl http://download.tcwyun.com/images/packer/package/tensorflow-1.3.0-cp36-cp36m-manylinux1_x86_64.whl
cd /opt/
tar zxvf Python-3.6.1.tgz
cd Python-3.6.1
./configure
make && make install
sleep 15
pip3 install /opt/numpy-1.13.3-cp36-cp36m-manylinux1_x86_64.whl
pip3 install /opt/tensorflow-1.3.0-cp36-cp36m-manylinux1_x86_64.whl
pip3 install beautifulsoup4
pip3 install captcha
pip3 install objgraph
pip3 install memory_profiler
}


#################################main process##############################
Mod_network_config
Mod_edit_ssh
Mod_ins_tensorflow
#Mod_edit_postfix
#Mod_edit_grub
Mod_edit_cloudinit
Mod_sshd_permission
#Mod_replace_file
Mod_edit_passwd
#Mod_edit_dracut
