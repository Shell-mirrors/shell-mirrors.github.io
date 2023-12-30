#!/bin/bash
export PATH=~/bin:~/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

function Menu(){
	clear
	echo -ne "
\033[34m *\033[0m\033[31m******************************************************************************\033[0m\033[34m*\033[0m
\033[31m *\033[0m									        \033[31m*\033[0m
\033[31m *\033[0m			欢迎使用SHC and GZEXE加密脚本			        \033[31m*\033[0m
\033[31m *\033[0m				1、安装SHC				        \033[31m*\033[0m
\033[31m *\033[0m				2、使用SHC加密脚本			        \033[31m*\033[0m
\033[31m *\033[0m				3、使用GZEXE加密脚本			        \033[31m*\033[0m
\033[31m *\033[0m				4、使用SHC和GZEXE双加密脚本		        \033[31m*\033[0m
\033[31m *\033[0m				5、解密SHC脚本				        \033[31m*\033[0m
\033[31m *\033[0m				6、解密GZEXE脚本			        \033[31m*\033[0m
\033[31m *\033[0m				q、退出脚本				        \033[31m*\033[0m
\033[31m *\033[0m									        \033[31m*\033[0m
\033[34m *\033[0m\033[31m******************************************************************************\033[0m\033[34m*\033[0m
		\033[2;3;34m请选择[ 1 , 2 , 3 , 4 , 5 , 6 , q ]: \033[0m
		"
	read -e  Choice
	case $Choice in
	1) Install_Shc
	;;
	2) Run_Shc
	;;
	3) Run_Gzexe
	;;
	4) Run_Shc_Gzexe
	;;
	5) Unshc_Script
	;;
	6) Ungzexe_Script
	;;
	q|Q) exit
	;;
	*) echo -e "		\033[3;31m输入有误!\033[0m"
	;;
	esac
	Back_Menu
}

function Back_Menu(){
	echo -ne "
		\033[3;33m按回车键继续\033[0m"
	read -e 
	Menu
}

function Check_OS(){

	OSFILE=(/etc/os-release /etc/redhat-release /etc/system-release /etc/centos-release lsb-release)

	for i in ${OSFILE[@]}
	do
		if [ -e $i ];then
			CentOS=$(grep "CentOS" $i)
			Ubuntu=$(grep "Ubuntu" $i)
			Debian=$(grep "Debian" $i)
		fi
	done
	if [[ -z $CentOS ]] && [[ -z $Ubuntu ]] && [[ -z $Debian ]];then
		echo -e "\033[33抱歉，暂不支持此系统~\033[0m"
		exit
	fi
}

function Install_Shc(){

	Check_OS

	if [ ! -z "$CentOS" ];then
		yum update -y
		yum install -y git curl
		yum groupinstall -y "Development Tools"
	elif [ ! -z "$Ubuntu" ];then
		apt-get update -y
		apt-get install -y git curl
		apt-get install -y build-essential
	elif [ ! -z "$Debian" ];then
		apt-get update -y
		apt-get install -y git curl
		apt-get install -y build-essential
	fi

	if [ ! -e /usr/local/shc ];then
		mkdir -p /usr/local/shc
	else
		rm -rf /usr/local/shc/*
	fi

	if [ ! -e /home/shc ];then
		mkdir /home/shc
	fi

	if [ ! -e /usr/local/man/man1 ];then
		mkdir -p /usr/local/man/man1
	else
		rm -rf /usr/local/man/man1/*
	fi

	cd /usr/local/shc
	curl -LO http://www.datsi.fi.upm.es/~frosal/sources/shc-3.8.9b.tgz
	tar zxvf shc-3.8.9b.tgz
	rm -rf shc-3.8.9b.tgz
	cd shc-3.8.9b
	make install <<EOF
y
EOF
}

function Path_File(){
	if [ -z "$FilePath" ];then
		FilePath=$(pwd)
	fi
	if [ -e $FilePath ];then
		PathFile=$(ls $FilePath)
		echo -e "\033[32mINFO\033[0m: 当前路径下的文件:
$PathFile"
	else
		echo -e "\033[31mERROR\033[0m: 未找到'${FilePath}'文件夹
		\033[33m按回车键继续\033[0m"
		read -e 
		Check_PATH
	fi
}

function File_Name(){
	if [ ! -e $FilePath/$FileName ];then
		echo -e "\033[31mERROR\033[0m: 未找到'$FilePath/$FileName'文件,请重新输入!
		\033[3;33m按回车键继续\033[0m"
		read -e 
		Check_PATH
	else
		echo -e "\033[32mINFO\033[0m: 脚本已开始运行,请稍候..."
	fi
}

function Check_PATH(){
	echo -n "请输入文件路径:"
	read -e  FilePath
	Path_File
	echo -n "请输入文件名称:"
	read -e  FileName
	File_Name
	ALLPATH=$FilePath/$FileName
}

function Check_Shc_Installed(){
	if [ ! -e /usr/local/shc/shc-3.8.9b ];then
		echo -e "\033[31mERROR\033[0m: 抱歉你还未安装SHC,请安装后重试!"
		Back_Menu
	fi
}

function Run_Shc(){
	Check_PATH
	Check_Shc_Installed
	echo -e "\033[32mINFO\033[0m: 正在加密,请稍候..."
	if [ ! -e /home/shc ];then
		mkdir /home/shc
	fi
	shc -r -T -f $ALLPATH
	mv ${ALLPATH}.* /home/shc
	echo -e "\033[32mINFO\033[0m: 加密成功！
\033[32mINFO\033[0m: 所有加密文件都在/home/shc目录中,
\033[32mINFO\033[0m: ${FileName}.x文件为加密文件,${FileName}.x.c文件为c语言文件可用gcc编译成加密文件..."
}

function Run_Gzexe(){
	Check_PATH
	echo -e "\033[32mINFO\033[0m: 正在加密,请稍候..."
	if [ ! -e /home/gzexe ];then
		mkdir /home/gzexe
	fi
	gzexe $ALLPATH
	mv ${ALLPATH}* /home/gzexe
	mv /home/gzexe/${FileName}~ $ALLPATH
	echo -e "\033[32mINFO\033[0m: 加密成功！
\033[32mINFO\033[0m: 所有加密文件都在/home/gzexe目录中,
\033[32mINFO\033[0m: ${FileName}文件为加密文件,${FileName}~文件为备份文件..."
}

function Run_Shc_Gzexe(){
	Check_PATH
	Check_Shc_Installed
	echo -e "\033[32mINFO\033[0m: 正在加密,请稍候..."
	if [ ! -e /home/shc_gzexe ];then
		mkdir /home/shc_gzexe
	fi
	shc -r -T -f $ALLPATH
	gzexe ${ALLPATH}.x
	mv ${ALLPATH}* /home/shc_gzexe
	mv /home/shc_gzexe/$FileName $ALLPATH
	echo -e "\033[32mINFO\033[0m: 加密成功！
\033[32mINFO\033[0m: 所有加密文件都在/home/shc_gzexe目录中...
\033[32mINFO\033[0m: ${FileName}.x文件为SHC和GZEXE加密文件,${FileName}.x.c文件为c语言文件可用gcc编译成加密文件...
\033[32mINFO\033[0m: ${FileName}.x~文件为SHC加密文件..."
}

function Ungzexe_Script(){
	Check_PATH

	echo -e "\033[32mINFO\033[0m: 正在解密GZEXE,请稍候..."
	gzexe -d $ALLPATH
	echo -e "\033[32mINFO\033[0m: 解密成功！
\033[32mINFO\033[0m: ${FileName}为解密文件,${FileName}~为备份文件"
}

function Unshc_Script(){
	Check_PATH

	if [ ! -e /usr/local/bin/unshc ];then
		git clone https://github.com/yanncam/UnSHc
		mv UnSHc/latest/unshc.sh /usr/local/bin/unshc
	fi

	echo -e "\033[32mINFO\033[0m: 正在解密SHC,请稍候..."
	unshc $ALLPATH
	echo -e "\033[33mINFO\033[0m: SHC解密可能会失败,如果成功会生成一个${FileName}.sh文件,如果有就成功了,没有就失败了..."
}

if [ $UID -ne 0 ];then
	echo 'Please use root user run this script.'
	echo 'such as: sudo su'
fi

Menu
