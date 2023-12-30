#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:~/sbin

OSFILE=(/etc/os-release /etc/redhat-release /etc/system-release /etc/lsb-release)

if [ $UID -ne 0 ];then
	echo '请用root用户运行此脚本！脚本已退出！'
	exit
fi

SSRPATH=/shadowsocksr

SSRSTART=/shadowsocksr/shadowsocks

function Choice(){
	Install_Info
	clear
	while true
	do
	echo -n "请输入你的端口(默认443)："
	read -e  Port
	[ -z "$Port" ] && Port=443
	if [ $? -eq 0 ];then
		if [ $Port -ge 1 ] && [ $Port -le 65535 ];then
			break
		else
			echo "你的输入有误，请重新输入..."
		fi
	else
		echo "你的输入有误，请重新输入..."
	fi

	done

	echo "
已设置端口 = $Port
	"
	echo "请输入你的密码(默认Ximxin)："
	read -e  Pass
	[ -z "$Pass" ] && Pass=Ximxin

	echo "
已设置密码 = $Pass
	"
	if [ ! -z "$GetIP" ];then
		echo "你的IP是：$GetIP
		"
	else
		echo "自动获取IP失败，请手动输入："
		read -e  GetIP
		echo "你的IP是：$GetIP
		"
	fi
	if [ ! -z "$Success" ];then
		echo "你已安装SSR，无需重复安装..."
		exit
	fi
}

function CheckOS(){
	for i in ${OSFILE[@]}
	do
		if [ -e $i ];then
			CentOS=$(grep "CentOS" $i)
			Ubuntu=$(grep "Ubuntu" $i)
			Debian=$(grep "Debian" $i)
		fi
	done
}

function Installer(){
	echo "脚本正在初始化，请稍候..."
	if [ ! -z "$CentOS" ];then
		yum update -y
		yum install -y git python curl
	elif [ ! -z "$Ubuntu" ] || [ ! -z "$Debian" ];then
		apt-get update -y
		apt-get install -y git python curl
	fi
	GetIP=$(curl ip.cn | grep "[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}" | cut -d " " -f 2 | sed "s/IP：//g")
	iptables -F
	clear
}

function Instaing(){
	if [ ! -e "$SSRPATH" ];then
		git clone https://github.com/Shell-mirrors/shadowsocksr $SSRPATH
		if [ -z "$SSRPATH/user-config.json" ];then
			touch $SSRPATH/user-config.json
		fi
		echo "	{
		\"server\":\"0.0.0.0\",
		\"server_ipv6\": \"[::]\",
		\"local_address\":\"127.0.0.1\",
		\"local_port\":1080,
		\"port_password\":{
			\"$Port\":\"$Pass\"
		},
		\"timeout\":300,
		\"method\":\"rc4-md5\",
		\"protocol\": \"auth_sha1_v4\",
		\"protocol_param\": \"\",
		\"obfs\": \"http_simple_compatible\",
		\"obfs_param\": \"\",
		\"redirect\": \"\",
		\"dns_ipv6\": false,
		\"fast_open\": false,
		\"workers\": 1
	}" >$SSRPATH/user-config.json
	fi
}

function Runing(){
	cd $SSRSTART
	python server.py -d start
}

function Install_Info(){
	Success=$(python $SSRSTART/server.py -h | grep "usage")
}

function Installed_Info(){
	Install_Info
	if [ ! -z "$Success" ];then
		echo -e "
			\033[32m安装成功！\033[0m
			你的SSR IP是：	$GetIP
			你的SSR 端口是：$Port
			你的SSR 密码是：$Pass
			你的加密方法是：rc4-md5
			你的协议是：	auth_sha1_v4
			你的混淆方式是：http_simple
		"
	else
		echo -e "\033[31m
			安装失败！
		\033[0m"
	fi
}

CheckOS

Installer

Choice

Instaing

Installed_Info
