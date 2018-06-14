#!/bin/bash

OSPATH="/etc/os-release /etc/lsb-release /etc/centos-release /etc/system-release"
OS="CentOS Ubuntu Debian"

function menu(){
	echo "		菜单"
	echo ---------------------------------------

	echo "	1、替换内核"
	echo "	2、安装BBR"
	echo "	q、退出"

	echo ---------------------------------------
	echo -n "请选择:"
	read option
	case $option in
		1) swap_kernel;;
		2) install_bbr;;
		q|Q) exit 0;;
		*) echo 输入有误&&back_menu;;
	esac
}

function back_menu(){
	echo -n "回车返回菜单"
	read
	clear
	menu
}

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

bit=$(uname -m)

function swap_kernel(){
	if [ "$OSED" == "CentOS" ];then
		centos_swap_kernel
	elif [ "$OSED" == "Ubuntu" ] || [ "$OSED" == "Debian" ];then
		ubuntu_debian_swap_kernel
	fi
}

function centos_swap_kernel(){
	release6=$(grep "CentOS.* 6\.[0-9]" /etc/centos-release)
	release7=$(grep "CentOS.* 7\.[0-9]" /etc/centos-release)
	if [ ! -z "$release6" ];then
		release="el6"
	elif [ ! -z "$release7" ];then
		release="el7"
	else
		echo "不支持的发行版本..."
		return 1
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
	if [ $? != 0];then
		echo "未知错误"
	fi
	rpm -e $(rpm -qa | grep "kernel-headers")
	if [ $? != 0];then
		echo "未知错误"
	fi
	rpm -ivh /Packages/*rpm
	if [ $? != 0];then
		echo "未知错误,替换失败！"
		return 1
	fi
	yum install -y glibc-headers
	if [ $? != 0 ];then
		echo "未知错误"
	fi
	grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-set-default 0
	if [ $? != 0 ];then
		echo "未知错误,替换失败！"
		return 1
	fi
	echo 换内核成功，请重启系统！
}

function ubuntu_debian_swap_kernel(){
	echo 乌班图和德班版本正在制作中...
	back_menu
}

function install_bbr(){
	if [ "$OSED" == "CentOS" ];then
		centos_install_bbr
	elif [ "$OSED" == "Ubuntu" ] || [ "$OSED" == "Debian" ];then
		ubuntu_debian_install_bbr
	fi
}

function centos_install_bbr(){
	yum groupinstall -y "Development"
	yum install -y git
	git clone https://github.com/liberal-boy/tcp_tsunami
	cd tcp_tsunami
	echo "obj-m:=tcp_tsunami.o" > Makefile
	make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc
	insmod tcp_tsunami.ko
	cp -rf ./tcp_tsunami.ko /lib/modules/$(uname -r)/kernel/net/ipv4
	depmod -a
	modprobe tcp_tsunami
	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=tsunami" >> /etc/sysctl.conf
	sysctl -p
	isrun=$(sysctl net.ipv4.tcp_congestion_control | grep tcp_tsunami)
	if [ ! -z "$isrun"];then
		echo 安装成功，bbr正在运行！
	else
		echo 安装失败！
	fi
}

function ubuntu_debian_install_bbr(){
	echo 乌班图和德班版本正在制作中...
	back_menu
}

menu
