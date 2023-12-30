#!/bin/bash
export PATH=/bin:~/bin:/usr/bin:/usr/local/bin:/sbin:~/sbin:/usr/sbin:/usr/local/sbin

function Check_CentOS_or_Ubuntu_or_Debian(){
	if [ -e /etc/redhat-release ];then
		CentOS=$(grep "CentOS.*" /etc/redhat-release)
		Release6=$(grep "CentOS.*release.*\b6.*\b.*" /etc/redhat-release)
		Release7=$(grep "CentOS.*release.*\b7.*\b.*" /etc/redhat-release)
	elif [ -e /etc/os-release ];then
		Ubuntu=$(grep ".*Ubuntu.*" /etc/os-release)
		Debian=$(grep ".*Debian.*" /etc/os-release)
	fi
}

function TestSsserver(){
	NEWPATH=($(echo "$PATH" | sed "s/:/ /g"))
	for i in ${NEWPATH[@]}
	do
	if [ -e $i/ssserver ];then
		ssstest=$(ssserver --version | grep "Shadowsocks")
	fi
	done
}

function Install_Success(){
	echo -e "\033[32m
*************************************************
*						*
*		    安装成功！			*
*	  shadowsocks快捷管理命令: sss		*
*						*
*************************************************
\033[0m"
	sss
	sss status
}

function Install_Failure(){
	echo -e "\033[31m
*************************************************
*						*
*		     安装失败！			*
*						*
*************************************************
\033[0m"
}

function Install_Info(){
	TestSsserver
	if [ ! -z "$ssstest" ];then
		Install_Success
	else
		Install_Failure
	fi
}

function Ubuntu_Install_ss(){
	apt-get update -y
	apt-get install -y python-setuptools
	apt-get install -y vim curl
	easy_install pip
	pip install shadowsocks
	Editor_ss
	sss start
}

function Ubuntu_Install_ss_if(){
	TestSsserver
	if [ ! -z "$ssstest" ];then
		echo "你已安装shadowsocks,无需重复安装..."
	else
		Ubuntu_Install_ss
		Install_Info
	fi
}

function CentOS_Install_ss(){
	python3x=$(echo $(yum search python | grep "^python34" | cut -d "-" -f 1 | awk '{printf("%s",$1)}' | cut -d "." -f 1))
	if [ -z "$python3x" ];then
		echo -e "Error,Your host not epel,Please use \033[31mrpm -i https://mirrors.aliyun.com/centos/6.9/extras/x86_64/Packages/epel-release-6-8.noarch.rpm\033[0m or \033[31mrpm -i https://mirrors.aliyun.com/centos/7.4.1708/extras/x86_64/Packages/epel-release-7-9.noarch.rpm\033[0m.
exited!"
	exit;
	fi
	yum update -y
	yum install -y $python3x
	yum install -y $python3x-setuptools
	yum install -y vim curl
	easy_install-3.4 pip
	pip install shadowsocks
	Editor_ss
	sss start
}

function CentOS_Install_ss_if(){
	TestSsserver
	if [ ! -z "$ssstest" ];then
		echo "你已安装shadowsocks,无需重复安装..."
	else
		CentOS_Install_ss
		Install_Info
	fi
}

function Debian_Install_ss(){
	apt-get update -y
	apt-get install -y python
	apt-get install -y python-setuptools
	apt-get install -y vim curl
	easy_install pip
	pip install shadowsocks
	Editor_ss
	sss start
}

function Debian_Install_ss_if(){
	TestSsserver
	if [ ! -z "$ssstest" ];then
		echo "	你已安装shadowsocks,无需重复安装..."
	else
		Debian_Install_ss
		Install_Info
	fi
}

function Configure_ss(){
	while true
	do
	echo -n "	请选择Shadowsocks运行方式(默认为1)；
	多端口请输入1 单端口请输入2 多端口自动开启25端口：
	"
	read -e  ModeChoice
	[ -z "$ModeChoice" ] && ModeChoice="1"
	expr $ModeChoice + 0 &>/dev/null
	if [ $? -eq 0 ];then
		if [ $ModeChoice -ge 1 ] && [ $ModeChoice -le 2 ];then
			break
		else
			echo -e '	\033[3;31m输入有误，请重新输入...\033[0m'
		fi
	else
		echo -e '	\033[3;31m输入有误，请重新输入...\033[0m'
	fi
	done
	while true
	do
	echo -n "	请输入你的Shadowsocks端口(默认443多端口不可为25)：
	"
	read -e  Port
	[ -z "$Port" ] && Port="443"
	expr $Port + 0 &>/dev/null
	if [ $? -eq 0 ];then
		if [ $Port -ge 1 ] && [ $Port -le 65535 ] || [ $ModeChoice == 1 ] && [ $Port != 25 ];then
			echo "	你的端口为：$Port"
			sleep 1
			break
		else
			echo -e '	\033[3;31m输入有误，请重新输入...\033[0m'
		fi
	else
		echo -e '	\033[3;31m输入有误，请重新输入...\033[0m'
	fi
	done
	echo -n "	请输入你的Shadowsocks密码(默认ass)：
	"
	read -e  Pass
	[ -z "$Pass" ] && Pass="ass"
	echo "	你的密码为：$Pass"
}

function Editor_ss(){
	Cat_Profile=$(grep "export SS_RUN=.*" /etc/profile)
	FileUrl=/etc/shadowsocks/shadowsocks.json
	if [ ! -e /etc/shadowsocks ];then
		mkdir /etc/shadowsocks
	fi
	curl -L shell-mirrors.github.io/bin/sss -o /bin/sss
	chmod +x /bin/sss
	if [ -e /etc/shadowsocks ];then
		if [ "$ModeChoice" == "1" ];then
			echo "
	{
		\"server\":\"0.0.0.0\",
		\"local_address\": \"127.0.0.1\",
		\"port_password\": {
		\"$Port\":\"$Pass\",
		\"25\":\"25passwd\"
		},
		\"local_port\":1080,
		\"timeout\":300,
		\"method\":\"aes-256-cfb\",
		\"fast_open\": false
	}" >$FileUrl
			sed -i "s/^DefaultMode.*/DefaultMode=$ModeChoice/g" /bin/sss
		elif [ "$ModeChoice" == "2" ];then
			echo "
	{
		\"server\":\"0.0.0.0\",  
		\"server_port\":$Port,
		\"local_address\":\"127.0.0.1\",  
		\"local_port\":1080,
		\"password\":\"$Pass\",  
		\"timeout\":300,
		\"method\":\"aes-256-cfb\",  
		\"fast_open\": false  
	}" >$FileUrl
			sed -i "s/^DefaultMode.*/DefaultMode=$ModeChoice/g" /bin/sss
		else
			echo "
	{
		\"server\":\"0.0.0.0\",
		\"local_address\": \"127.0.0.1\",
		\"port_password\": {
		\"$Port\":\"$Pass\",
		\"25\":\"25passwd\"
		},
		\"local_port\":1080,
		\"timeout\":300,
		\"method\":\"aes-256-cfb\",
		\"fast_open\": false
	}" >$FileUrl
			sed -i "s/^DefaultMode.*/DefaultMode=$ModeChoice/g" /bin/sss
		fi
	fi
	if [ -z "$Cat_Profile" ];then
		echo "export SS_RUN=\$(ps aux | grep \"ssserver -c /etc/shadowsocks/shadowsocks.json\" | grep -v \"grep\")" >>/etc/profile
		echo "
source /etc/profile
if [ -z \"\$SS_RUN\"  ];then
	sss start
fi
" >>~/.bashrc
	fi
}

function Error_Not_Install_ss(){
	echo -ne '\033[31m判断系统错误,请手动输入\033[0m[ Ubuntu or Debian or CentOS ]:'
	read -e  OS
	[ -z "$OS" ] && echo -e "\033[31m输入内容不能为空！\033[0m"
	if [ $OS == "Ubuntu" ];then
		Configure_ss
		Ubuntu_Install_ss_if
	elif [ $OS == "Debian" ];then
		Configure_ss
		Debian_Install_ss_if
	elif [ $OS == "CentOS" ];then
		Configure_ss
		CentOS_Install_ss_if
	else
		Error_Not_Install_ss
	fi
}

function All_Output_ss(){
	Check_CentOS_or_Ubuntu_or_Debian
	if [ ! -z "$CentOS" ];then
		Configure_ss
		CentOS_Install_ss_if
	elif [ ! -z "$Ubuntu" ];then
		Configure_ss
		Ubuntu_Install_ss_if
	elif [ ! -z "$Debian" ];then
		Configure_ss
		Debian_Install_ss_if
	else
		Error_Not_Install_ss
	fi
}

function CentOS6_Image(){
	CENTOS6_KERNEL=http://vault.centos.org/6.6/updates/x86_64/Packages
	KERNEL_DIR=/Packages/kernel
	Kernel=(kernel-2.6.32-504.3.3.el6.x86_64.rpm kernel-devel-2.6.32-504.3.3.el6.x86_64.rpm kernel-firmware-2.6.32-504.3.3.el6.noarch.rpm kernel-headers-2.6.32-504.3.3.el6.x86_64.rpm)
	default_image=$(rpm -qa | grep "^kernel-2.6.32-504.3.3.el6.x86_64")
	if [ ! -e $KERNEL_DIR ];then
		mkdir -p $KERNEL_DIR
	fi
	if [ ! -z "$default_image" ];then
		echo '你的内核已经支持锐速,无需替换...'
	else
		echo '正在下载内核资源,请稍等...'
		for i in ${Kernel[@]}
		do
		wget $CENTOS6_KERNEL/$i -O $KERNEL_DIR/$i
		done
		echo '正在安装内核,请稍候...'
		rpm -ivh /Packages/kernel/kernel*rpm --force
		echo '请核对内核是否替换成功后重启系统...'
		rpm -qa | grep "^kernel"
	fi
}

function CentOS7_Image(){
	default_image=$(rpm -qa | grep "^kernel-3.10.0-229.1.2.el7.x86_64")
	CENTOS7_KERNEL=http://vault.centos.org/7.1.1503/updates/x86_64/Packages
	KERNEL_DIR=/Packages/kernel
	Kernel=(kernel-3.10.0-229.1.2.el7.x86_64.rpm kernel-tools-3.10.0-229.1.2.el7.x86_64.rpm kernel-tools-libs-3.10.0-229.1.2.el7.x86_64.rpm)
	if [ ! -e $KERNEL_DIR ];then
		mkdir -p $KERNEL_DIR
	fi
	if [ ! -z "$default_image" ];then
		echo '你的内核已支持锐速,无需替换...'
	else
		echo '正在下载资源,请稍候...'
		for i in ${Kernel[@]}
		do
		wget $CENTOS7_KERNEL/$i -O $KERNEL_DIR/$i
		done
		echo '正在安装内核,请稍候...'
		rpm -ivh /Packages/kernel/kernel*rpm --force
		echo '请核对内核是否安装成功后重启系统...'
		rpm -qa | grep "^kernel"
	fi
	
}

function Ubuntu14_Image(){
	find_linux_image=$(dpkg -l | grep "linux-image" | cut -d ' ' -f 3)
	default_linux_image='linux-image-3.13.0-24-generic
linux-image-extra-3.13.0-24-generic'
	apt-get update -y
	apt-get install -y linux-image-3.13.0-24-generic
	apt-get install -y linux-image-extra-3.13.0-24-generic
	if [ "$find_linux_image" == "$default_linux_image" ];then
		echo '你的内核已支持锐速,无需替换...'
	else
		apt-get purge -y $find_linux_image
		update-grub
		echo -e '\033[32m替换内核完成,请对照内核是否为3.13.0-24版本后输入reboot重启系统...\033[0m'
		dpkg -l | grep linux-image
	fi
}

function Debian8_Image(){
	find_linux_image=$(dpkg -l | grep "linux-image" | cut -d ' ' -f 3)
	default_linux_image='linux-image-3.16.0-4-amd64'
	wget http://ftp.br.debian.org/debian/pool/main/l/linux/linux-image-3.16.0-4-amd64_3.16.51-2_amd64.deb -O /Packages/image/linux-image-3.16.0-4-amd64_3.16.51-2_amd64.deb
	dpkg -i /Packages/image/*deb
	if [ "$find_linux_image" == "$default_linux_image" ];then
		echo '你的内核已支持锐速,无需替换...'
	else
		apt-get purge -y $find_linux_image
		update-grub
		echo -e '\033[32m替换内核完成,请对照内核是否为3.13.0-24版本后输入reboot重启系统...\033[0m'
		dpkg -l | grep linux-image
	fi
}

function Not_Found_Release(){
	echo -en '\033[31m判断系统错误,请手动输入\033[0m[ Ubuntu or Debian or CentOS6 or CentOS7 ]:'
        read -e  OS
		[ -z "$OS" ] && echo -e "\033[31m输入内容不能为空！\033[0m"
        if [ $OS == "Ubuntu" ];then
                Ubuntu_Image
        elif [ $OS == "CentOS6" ];then
                CentOS6_Image
        elif [ $OS == "CentOS7" ];then
                CentOS7_Image
        elif [ $OS == "Debian" ];then
                Debian8exc_Image	
        else
                Not_Found_Release
        fi
}

function All_Output_Linux_Image(){
	Check_CentOS_or_Ubuntu_or_Debian
	if [ ! -z "$Release6" ];then
		CentOS6_Image
	elif [ ! -z "$Release7" ];then
		CentOS7_Image
	elif [ ! -z "$Ubuntu" ];then
		Ubuntu14_Image
	elif [ ! -z "$Debian" ];then
		Debian8_Image
	else
		Not_Found_Release
	fi
}

function All_Output_Rui_Su(){
	Check_CentOS_or_Ubuntu_or_Debian
	Dir=$(cd "${0%/*}";pwd)
	speederDir=$Dir/91yunserverspeeder/apxfiles/bin
	if [ ! -z "$CentOS" ];then
		yum update -y
		yum install -y net-tools
	elif [ ! -z "$Ubuntu" ];then
		apt-get update -y
		apt-get install -y net-tools
	elif [ ! -z "$Debian" ];then
		apt-get update -y
		apt-get install -y net-tools
	fi
	wget -N --no-check-certificate https://github.com/91yun/serverspeeder/raw/master/serverspeeder.sh && bash serverspeeder.sh
	SearchPATH=$(grep "$speederDir" /etc/profile)
	if [ -z "$SearchPATH" ];then
		echo "export PATH=$PATH:$speederDir" >>/etc/profile
	fi
	cp $speederDir/serverSpeeder.sh $speederDir/speeder
	echo 'source /etc/profile' >>~/.bashrc
	source ~/.bashrc
}

function CentOS_Install_Libsodium(){
	yum update -y
	yum groupinstall -y "Development Tools"
	yum install -y curl
	Install_Libsodium
}

function Install_Libsodium(){
	curl https://download.libsodium.org/libsodium/releases/old/libsodium-1.0.9.tar.gz -o /usr/local/libsodium-1.0.9.tar.gz
	rm -rf /usr/local/libsodium
	cd /usr/local
	tar zxvf libsodium-1.0.9.tar.gz
	mv libsodium-1.0.9 libsodium
	cd libsodium
	./configure;make;make install
	echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf
	echo "include ld.so.conf.d/*.conf" > /etc/ld.so.conf
	echo "/lib" >> /etc/ld.so.conf
	echo "/usr/lib64" >> /etc/ld.so.conf
	echo "/usr/local/lib" >> /etc/ld.so.conf
	ldconfig
	cd ~
	rm -rf /usr/local/libsodium-1.0.9.tar.gz
}

function Ubuntu_or_Debian_Install_Libsodium(){
	apt-get update -y
	apt-get install -y curl
	apt-get install -y build-essential
	Install_Libsodium
}

function Error_Not_Install_Libsodium(){
	echo -en '\033[31m判断系统错误,请手动输入\033[0m[ Ubuntu or Debian or CentOS ]:'
        read -e  OS
		[ -z "$OS" ] && echo -e "输入内容不能为空！"
        if [ $OS == "Ubuntu" ];then
                Ubuntu_or_Debian_Install_Libsodium
        elif [ $OS == "Debian" ];then
                Ubuntu_or_Debian_Install_Libsodium
        elif [ $OS == "CentOS" ];then
                CentOS_Install_Libsodium
        else
                Error_Not_Install_Libsodium
        fi
}

function All_Output_Libsodium(){
	Check_CentOS_or_Ubuntu_or_Debian
	if [ ! -z "$CentOS" ];then
		CentOS_Install_Libsodium
	elif [ ! -z "$Ubuntu" ];then
		Ubuntu_or_Debian_Install_Libsodium
	elif [ ! -z "$Debian" ];then
		Ubuntu_or_Debian_Install_Libsodium
	else
		Error_Not_Install_Libsodium
	fi
}

function Menu(){
	clear
	echo -n '
 ********************************************************************************
 *									        *
 *		请选择执行项:						        *
 *		1、安装shadowsocks(Debian系统请使用8以上的系统)		        *
 *		2、安装支持锐速的内核					        *
 *		3、安装锐速破解版					        *
 *		4、安装libsodium					        *
 *		q、退出							        *
 *									        *
 ********************************************************************************
		请选择[ 1 , 2 , 3 , 4 , q ]
		'
	read -e  User_Input
	case $User_Input in
	1) All_Output_ss
	;;
	2) All_Output_Linux_Image
	;;
	3) All_Output_Rui_Su
	;;
	4) All_Output_Libsodium
	;;
	Q|q) exit
	;;
	*) echo -e '
		\033[3;31m输入有误\033[0m'
	esac
	Back_Menu
}

function Back_Menu(){
	echo -ne '\033[3;33m		按回车键返回主菜单\033[0m'
	read -e 
	Menu
}

if [ $UID -ne 0 ];then
	echo '此脚本需要root权限，请切换到root用户下执行'
	echo '比如：sudo su'
	echo '脚本已退出'
	exit
fi

Menu

exit
