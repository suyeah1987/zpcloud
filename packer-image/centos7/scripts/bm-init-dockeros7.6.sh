#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Mod_network_config(){
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

Mod_update_kernel(){
yum install -y htop vim nano
echo "##################################update kernel##############################/n"
wget http://10.100.189.39/image/kernel/kernel-lt-4.4.170-1.el7.elrepo.x86_64.rpm
rpm -ivh kernel-lt-4.4.170-1.el7.elrepo.x86_64.rpm
grub2-set-default "CentOS Linux (4.4.170-1.el7.elrepo.x86_64) 7 (Core)"
}

Mod_edit_grub(){
echo "#####################################update grub##############################/n"
sed -i '6s/.*/GRUB_CMDLINE_LINUX="console=ttyS0 console=tty0 net.ifnames=0 biosdevname=1 numa=off crashkernel=512M"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
chmod 777 /boot/grub2/grub.cfg
sed -i '/vmlinuz-0-rescue/s/$/&rd.break/' /boot/grub2/grub.cfg
chmod 644 /boot/grub2/grub.cfg
}

Mod_ins_cloudinit(){
echo "######################################install cloud-init###########################/n"
wget -O /root/redis5.zip http://10.100.189.39/image/kernel/redis5.zip
yum install -y cloud-init
}

Mod_replace_file(){
echo "#######################################update ifcfg-eth and cloud-init#####################/n"
mv /etc/sysconfig/network-scripts/ifup-eth /etc/sysconfig/network-scripts/bak.ifup-eth
wget -O /etc/sysconfig/network-scripts/ifup-eth http://download.tcwyun.com/images/packer/packer_file/ifup-eth
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
rm -f /etc/sysconfig/network-scripts/bak.ifup-eth
rm -f /etc/sysconfig/network-scripts/ifcfg-eth0
rm -f /home/centos/kernel-ml-4.11.1-1.el7.elrepo.x86_64.rpm
}

#################################main process##############################
Mod_network_config
Mod_edit_ssh
Mod_edit_postfix
Mod_update_kernel
Mod_crash_dump
Mod_edit_grub
Mod_ins_cloudinit
Mod_replace_file
Mod_edit_passwd
Mod_edit_dracut
Mod_create_rscloudinit
Mod_clean_file
