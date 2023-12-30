#!/bin/bash
export PATH=~/bin:~/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

######################################
#   脚本名:   tcp_tsunami.sh
#   用途:     替换BBR可用内核和安装BBR
#   制作时间: 2018-6-17 9:45	
#
#		作者：by 西门信
######################################

OSPATH="/etc/os-release /etc/lsb-release /etc/centos-release /etc/system-release"
OS="CentOS Ubuntu Debian"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLIE="\033[34m"
PINK="\033[35m"
PLAIN="\033[0m"

function menu(){
	echo "		菜单"
	echo ---------------------------------------
	echo
	echo "	1、替换内核"
	echo "	2、安装BBR"
	echo "	q、退出"
	echo
	run_state
	echo
	echo ---------------------------------------
	echo -n "请选择:"
	read -e  option
	case $option in
		1) swap_kernel;;
		2) install_bbr;;
		q|Q) exit 0;;
		*) echo 输入有误&&back_menu;;
	esac
}

function back_menu(){
	echo -n "回车返回菜单"
	read -e 
	clear
	menu
}

# 检查系统
for i in $OSPATH
do
	if [ ! -e $i ];then
		continue;
	fi
	for j in $OS
	do
		if [ ! -z "$OSED" ];then
			break;
		elif [ ! -z "$(grep "$j" $i)" ];then
			OSED=$j
		fi
	done
done

release6=$([ -e /etc/centos-release ] && grep "CentOS.* 6\.[0-9]" /etc/centos-release)
release7=$([ -e /etc/centos-release ] && grep "CentOS.* 7\.[0-9]" /etc/centos-release)
if [ ! -z "$release6" ];then
	release="el6"
	version=6
elif [ ! -z "$release7" ];then
	release="el7"
	version=7
fi

echo "当前系统:$OSED$version"
sleep 2
clear
# 检查系统

function swap_kernel(){
	if [ "$OSED" == "CentOS" ];then
		centos_swap_kernel
	elif [ "$OSED" == "Ubuntu" ] || [ "$OSED" == "Debian" ];then
		ubuntu_debian_swap_kernel
	fi
}

# 替换centos6或centos7内核
function centos_swap_kernel(){
	bit=$(uname -m)
	if [ "$(uname -r)" == "4.13.10-1.$release.elrepo.$bit" ];then
		echo "你的内核已符合要求，无需替换!"
		back_menu
	fi
	if [ ! -e "/Packages" ];then
		mkdir /Packages
	fi
	downloadurl="http://mirror.rc.usf.edu/compute_lock/elrepo/kernel/$release/$bit/RPMS/"
	rpms="kernel-ml-4.13.10-1.$release.elrepo.$bit.rpm kernel-ml-devel-4.13.10-1.$release.elrepo.$bit.rpm kernel-ml-headers-4.13.10-1.$release.elrepo.$bit.rpm"
	for i in $rpms
	do
		wget $downloadurl$i -O /Packages/$i
	done
	yum remove -y glibc-headers
	rpm -e $(rpm -qa | grep kernel | grep -v kernel-ml)
	yum install -y perl
	for i in $rpms
	do
		rpm -ivh /Packages/$i
	done
	yum install -y glibc-headers glibc-devel gcc
	if [ $version == 6 ];then
		sed -i "s/^default=[0-9]/default=0/g" /boot/grub/grub.conf
	elif [ $version == 7 ];then
		grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-set-default 0
	else
		echo "未知错误,替换失败！"
		return 2
	fi
	if [ $? != 0 ];then
		echo "未知错误,替换失败！"
		return 2
	fi
	if [ ! -z "$(rpm -qa | grep "kernel-ml-4.13.10-1.$release.elrepo.$bit")" ];then
		echo
		echo 换内核成功，请重启系统！
		echo
		back_menu
	else
		echo
		echo 换内核失败，请检查依赖关系后在/Packages目录手动替换内核...
		echo
		back_menu
	fi
}

function ubuntu_debian_swap_kernel(){
	Bit=$(getconf WORD_BIT)
	if [ $Bit == 32 ] || [ $Bit == 64 ];then
		bit="amd64"
	else
		bit=$(uname -m)
	fi
	if [ "$(uname -r)" == "4.13.0-17-generic" ];then
		echo "你的内核已符合要求，无需替换!"
		back_menu
	fi
	if [ ! -e /Packages ];then
		mkdir /Packages
	fi
	apt-get update
	apt-get install -y libssl1.0.0
	downloadurl="http://kr.archive.ubuntu.com/ubuntu/pool/main/l/linux/"
	debs="linux-image-4.13.0-17-generic_4.13.0-17.20_$bit.deb linux-headers-4.13.0-17_4.13.0-17.20_all.deb linux-headers-4.13.0-17-generic_4.13.0-17.20_$bit.deb"
	for i in $debs
	do
		wget $downloadurl$i -O /Packages/$i
		dpkg -i /Packages/$i
	done
	installed=$(dpkg -l | egrep "linux-image-4.13.0-17-generic")
	installed_headers=$(dpkg -l | egrep "linux-headers-4.13.0-17")
	if [ ! -z "$installed" ] && [ ! -z "$installed_headers" ];then
		echo 内核安装成功
	else
		echo 内核安装失败
		exit;
	fi
	echo 正在卸载旧内核
	rekernel=$(dpkg -l | egrep "linux-image|linux-headers" | egrep -v "linux-image-4.13.0-17-generic|linux-headers-4.13.0-17" | awk '{printf("%s ", $2)}')
	apt-get purge -y $rekernel
	update-grub
	echo 替换完成，请重启系统
	back_menu
}

function install_bbr(){
	if [ "$OSED" == "CentOS" ];then
		centos_install_bbr
	elif [ "$OSED" == "Ubuntu" ] || [ "$OSED" == "Debian" ];then
		ubuntu_debian_install_bbr
	fi
}

# centos安装BBR
function centos_install_bbr(){
	bit=$(uname -m)
	if [ "$(uname -r)" != "4.13.10-1.$release.elrepo.$bit" ];then
		echo "请替换BBR可用内核重启后再安装BBR!"
		back_menu
	fi
	run_check
	[[ ! -z "$isrun" ]] && echo 魔改BBR正在运行中，无需安装啦！ && back_menu;
	yum update -y
	yum groupremove -y "Development Tools"
	yum groupinstall -y "Development Tools"
	yum install -y git zip unzip
	rm -rf tcp_tsunami
	git clone https://github.com/liberal-boy/tcp_tsunami
	cd tcp_tsunami
	echo "obj-m:=tcp_tsunami.o" > Makefile
	make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc
	insmod tcp_tsunami.ko
	cp -rf ./tcp_tsunami.ko /lib/modules/$(uname -r)/kernel/net/ipv4
	depmod -a
	modprobe tcp_tsunami
	bbr_sysctl=$(egrep "net.core.default_qdisc=fq|net.ipv4.tcp_congestion_control=tsunami" /etc/sysctl.conf)
	if [ -z "$bbr_sysctl" ];then
		echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
		echo "net.ipv4.tcp_congestion_control=tsunami" >> /etc/sysctl.conf
	fi
	sysctl -p
	run_check
	if [ ! -z "$isrun" ];then
		echo && echo "安装成功!" && echo
	else
		echo && echo "安装失败!" && echo
	fi
	back_menu
}

# ubuntu or debian安装BBR
function ubuntu_debian_install_bbr(){
	if [ "$(uname -r)" != "4.13.0-17-generic" ];then
		echo "请替换BBR可用内核重启后再安装BBR!"
		back_menu
	fi
	run_check
	[[ ! -z "$isrun" ]] && echo 魔改BBR正在运行中，无需安装啦！ && back_menu;
	apt-get update
	apt-get install -y build-essential
	apt-get install -y git zip unzip
	rm -rf tcp_tsunami
	git clone https://github.com/liberal-boy/tcp_tsunami
	cd tcp_tsunami
	echo "obj-m:=tcp_tsunami.o" > Makefile
	make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc
	insmod tcp_tsunami.ko
	cp -rf ./tcp_tsunami.ko /lib/modules/$(uname -r)/kernel/net/ipv4
	depmod -a
	modprobe tcp_tsunami
	bbr_sysctl=$(egrep "net.core.default_qdisc=fq|net.ipv4.tcp_congestion_control=tsunami" /etc/sysctl.conf)
	if [ -z "$bbr_sysctl" ];then
		echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
		echo "net.ipv4.tcp_congestion_control=tsunami" >> /etc/sysctl.conf
	fi
	sysctl -p
	run_check
	if [ ! -z "$isrun" ];then
		echo && echo "安装成功!" && echo
	else
		echo && echo "安装失败!" && echo
	fi
	back_menu
}

# 检查BBR运行状态

function run_check(){
	isrun=$(lsmod | egrep "tcp_tsunami")
}

function run_state(){
	run_check
	if [ ! -z "$isrun" ];then
		echo -e "	BBR运行状态：[ $GREEN ok $PLAIN ]"
	else
		echo -e "	BBR运行状态：[ ${RED}fail$PLAIN ]"
	fi
}

if [ $UID != 0 ] || [ $USER != root ];then
	echo "请在超级管理员权限下运行此脚本"
	exit;
fi

menu
