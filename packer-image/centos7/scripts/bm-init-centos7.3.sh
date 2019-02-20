#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Mod_network_config(){
#edit network cfg
echo "#############################create ifcfg-XXX############################"
cat > /etc/sysconfig/network-scripts/ifcfg-em1<< EOF
DEVICE=em1
BOOTPROTO=dhcp
ONBOOT=yes
TYPE=Ethernet
NM_CONTROLLED=no
EOF
cat > /etc/sysconfig/network-scripts/ifcfg-em49<< EOF
DEVICE=em49
BOOTPROTO=dhcp
ONBOOT=yes
TYPE=Ethernet
NM_CONTROLLED=no
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
sed -i '6s/.*/GRUB_CMDLINE_LINUX="console=ttyS0 console=tty0 net.ifnames=0 biosdevname=1"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
}

Mod_ins_cloudinit(){
echo "######################################install cloud-init###########################/n"
wget -O /tmp/cloud-init-0.7.5-6.el7.x86_64.rpm http://download.tcwyun.com/images/packer/package/cloud-init-0.7.5-6.el7.x86_64.rpm
yum install  -y /tmp/cloud-init-0.7.5-6.el7.x86_64.rpm
}

Mod_ins_package(){
echo "#####################################install package###############################/n"
wget -O /tmp/kmod-megaraid_sas-07.700.52.00_el7.3-2.x86_64.rpm  http://download.tcwyun.com/images/packer/package/kmod-megaraid_sas-07.700.52.00_el7.3-2.x86_64.rpm
rpm -ivh /tmp/kmod-megaraid_sas-07.700.52.00_el7.3-2.x86_64.rpm
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

Mod_create_rscloudinit(){
echo "#############################create restart cloud-init shell###################"
cat > /home/centos/restart_cloudinit.sh  << EOF
#!/bin/bash
cloud-init  init --local
cloud-init  init
cloud-init modules --mode config
cloud-init modules --mode final
EOF
chmod +x /home/centos/restart_cloudinit.sh
}
Mod_clean_file(){
echo "#################################clean file###################################"
rm -f /usr/bin/bak.cloud-init
rm -f /etc/sysconfig/network-scripts/bak.ifup-eth
rm -f /etc/sysconfig/network-scripts/ifcfg-eth0
}

#################################main process##############################
Mod_network_config
Mod_edit_ssh
Mod_edit_postfix
Mod_edit_grub
Mod_ins_cloudinit
Mod_ins_package
Mod_replace_file
Mod_edit_passwd
Mod_edit_dracut
Mod_create_rscloudinit
Mod_clean_file
