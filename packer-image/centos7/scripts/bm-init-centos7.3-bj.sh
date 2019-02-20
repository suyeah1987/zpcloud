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
echo "##################################update kernel##############################/n"
wget http://download.tcwyun.com/images/packer/kernel-ml-4.11.1-1.el7.elrepo.x86_64.rpm
rpm -ivh kernel-ml-4.11.1-1.el7.elrepo.x86_64.rpm
grub2-set-default "CentOS Linux (4.11.1-1.el7.elrepo.x86_64) 7 (Core)"
grub2-mkconfig -o /boot/grub2/grub.cfg
package-cleanup --oldkernels --count=1 -y
sed -i 's/CentOS/DaokeOS/g' /etc/centos-release /etc/redhat-release
sed -i 's;\\S;Daoke Linux release 7.4.1708 (Core);g' /etc/issue*
echo "#########  Welcome to  DaokeOS 7.4  ##########" > /etc/motd
sed -i 's/CentOS/DaokeOS/g' /etc/grub2.cfg
}
Mod_crash_dump(){
yum install -y kexec-tools.x86_64
yum install -y crash.x86_64
systemctl start kdump.service
systemctl enable kdump.service
wget -O /tmp/kernel-debuginfo-common-x86_64-2.6.32-696.el6.x86_64.rpm http://docker.17usoft.com/download/rpmdocker/kernel-debuginfo-common-x86_64-2.6.32-696.el6.x86_64.rpm
rpm -ivh /tmp/kernel-debuginfo-common-x86_64-2.6.32-696.el6.x86_64.rpm
wget -O /tmp/kernel-debuginfo-2.6.32-696.el6.x86_64.rpm http://docker.17usoft.com/download/rpmdocker/kernel-debuginfo-2.6.32-696.el6.x86_64.rpm
rpm -ivh /tmp/kernel-debuginfo-2.6.32-696.el6.x86_64.rpm
}
Mod_ins_chrony(){
yum install -y chrony
cat << EOF > /etc/chrony.conf
# 使用上层的internet ntp服务器
server ntp.17usoft.com iburst
server ntpxdl.tcwyun.com iburst
server time1.aliyun.com iburst
server time2.aliyun.com iburst
server time3.aliyun.com iburst
server time4.aliyun.com iburst
server time5.aliyun.com iburst
stratumweight 0
driftfile /var/lib/chrony/drift
rtcsync
makestep 10 3
bindcmdaddress 127.0.0.1
bindcmdaddress ::1
keyfile /etc/chrony.keys
commandkey 1
generatecommandkey
noclientlog
logchange 0.5
logdir /var/log/chrony
EOF
systemctl stop ntpd
systemctl disable ntpd
systemctl start chronyd.service
systemctl enable chronyd.service
systemctl restart chronyd.service
hwclock -w
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
wget -O /tmp/cloud-init-0.7.5-6.el7.x86_64.rpm http://download.tcwyun.com/images/packer/package/cloud-init-0.7.5-6.el7.x86_64.rpm
yum install  -y /tmp/cloud-init-0.7.5-6.el7.x86_64.rpm
cat <<EOF > /etc/cloud/cloud.cfg
users:
 - default

disable_root: 0
ssh_pwauth:   1

locale_configfile: /etc/sysconfig/i18n
mount_default_fields: [~, ~, 'auto', 'defaults,nofail', '0', '2']
resize_rootfs_tmp: /dev
ssh_deletekeys:   0
ssh_genkeytypes:  ~
syslog_fix_perms: ~

cloud_init_modules:
 - migrator
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - rsyslog
 - users-groups
 - ssh
 - resolve-conf

 - disable-ec2-metadata
 - runcmd

cloud_final_modules:
 - rightscale_userdata
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message

system_info:
  default_user:
    name: centos
    lock_passwd: true
    gecos: Cloud User
    groups: [wheel, adm, systemd-journal]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
  distro: rhel
  paths:
    cloud_dir: /var/lib/cloud
    templates_dir: /etc/cloud/templates
  ssh_svcname: sshd

# vim:syntax=yaml
EOF
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
Mod_set_sysparam(){
echo "#################################set_params###################################"


echo "export TMOUT=600" >> /etc/profile
sed -i 's/kernel.msgmnb = 65536/kernel.msgmnb = 65535/g' /etc/sysctl.conf
echo 'kernel.core_pattern= /home/corefile/core-%e-%p-%t'>> /etc/sysctl.conf
wget -P /tmp http://download.tcwyun.com/contiv/centos6_network_config/manage.py
}
Mod_add_user(){
groupadd work
useradd -d /home/work work -g work; echo 'work' | passwd --stdin work

}
Mod_install(){

echo "#################################mod install###################################"
yum -y install nscd
yum -y install sendmail
yum -y install sysstat
yum -y install irqbalance
yum install OpenIPMI OpenIPMI-devel OpenIPMI-tools -y
yum -y install bind
yum -y install sos
yum -y remove biosdevname
wget -P /tmp http://download.tcwyun.com/patch/package/biosdevname-0.6.2-1.el6.x86_64.rpm
rpm -ivh /tmp/biosdevname-0.6.2-1.el6.x86_64.rpm
#puppet install
yum install ruby-devel rubygems -y
cd /tmp/ && wget http://opsource.corp.elong.com/docs/facter-1.7.4.tar.gz && tar -zxf facter-1.7.4.tar.gz && ruby /tmp/facter-1.7.4/install.rb && rm -fr /tmp/facter-1.7.4.tar.gz && rm -fr /tmp/facter-1.7.4
ln -s /usr/bin/facter /usr/local/bin/facter
cd /tmp/ && wget http://opsource.corp.elong.com/software/puppet/puppet-3.3.2.tar.gz && tar -zxf puppet-3.3.2.tar.gz  && ruby /tmp/puppet-3.3.2/install.rb && rm -fr /tmp/puppet-3.3.2.tar.gz && rm -fr /tmp/puppet-3.3.2
cd /tmp/ && wget http://opsource.corp.elong.com/aoao/package/json-1.8.1.gem && gem install json-1.8.1.gem && rm -fr /tmp/json-1.8.1.gem

#安装open-falcon
#二中心:
mkdir /home/work/openfalcon && cd /home/work/openfalcon && wget http://192.168.96.10/agent/open-falcon/erzhongxin/falcon_agent_bjx.tar.gz >/dev/null 2>&1 && tar -xf falcon_agent_bjx.tar.gz && cd /home/work/openfalcon/falcon-agent && ./control start
echo "/home/work/openfalcon/falcon-agent/control start" >> /etc/rc.local
echo "*/5 * * * * /home/work/openfalcon/falcon-agent/control start" >> /var/spool/cron/root

#安装crux_agent
kill -9 `ps -ef|grep crux | awk 'NR=1{print $2}'`
rpm -ivh http://192.168.96.10/agent/aosagent/crux_agent-4.5.9-1.x86_64.rpm > /dev/null 2>&1
#安装cetus_agent
#pm -ivh http://192.168.96.10/agent/aosagent/cetus_agent-3.5.2-1.x86_64.rpm > /dev/null 2>&1
}

#################################main process##############################
Mod_network_config
Mod_add_user
Mod_edit_ssh
Mod_edit_postfix
#Mod_update_kernel
Mod_crash_dump
Mod_ins_chrony
Mod_edit_grub
Mod_ins_cloudinit
Mod_replace_file
Mod_edit_passwd
Mod_edit_dracut
Mod_create_rscloudinit
Mod_set_sysparam
Mod_install
Mod_clean_file
