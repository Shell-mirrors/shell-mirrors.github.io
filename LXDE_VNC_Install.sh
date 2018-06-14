#!/bin/bash
export PATH=~/bin:~/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

function Get_Var(){
	GetIp=$(curl -L ifconfig.co)
	GetPort=($(netstat -ntlp | grep "[v,V][n,N][c,C]" | grep "[0-9]\{1,5\}" | cut -d ":" -f 2 | awk '{printf("%d ",$1)}'))
	if [ ! -z "$CentOS6" ];then
		VncRun=$(ps aux | grep "Xvnc" | grep -v "grep")
	elif [ ! -z "$CentOS7" ];then
		VncRun=$(ps aux | grep "Xvnc" | grep -v "grep")
	elif [ ! -z "$Ubuntu" ];then
		VncRun=$(ps aux | grep "Xtightvnc" | grep -v "grep")
	elif [ ! -z "$Debian" ];then
		VncRun=$(ps aux | grep "Xtightvnc" | grep -v "grep")
	fi
}

function Menu(){
	CheckOS
	Get_Var
	clear
	echo -e "
\033[34m *\033[0m\033[31m******************************************************************************\033[0m\033[34m*\033[0m
\033[31m *\033[0m									        \033[31m*\033[0m
\033[31m *\033[0m				1、安装VNC			 	        \033[31m*\033[0m
\033[31m *\033[0m				2、启动VNC				        \033[31m*\033[0m
\033[31m *\033[0m				3、关闭VNC				        \033[31m*\033[0m
\033[31m *\033[0m				4、重置VNC登录密码			        \033[31m*\033[0m
\033[31m *\033[0m									        \033[31m*\033[0m
\033[31m *\033[0m				q、退出脚本				        \033[31m*\033[0m
\033[31m *\033[0m									        \033[31m*\033[0m
\033[31m *\033[0m			-------------------------------			        \033[31m*\033[0m
\033[31m *\033[0m									        \033[31m*\033[0m"
	if [ ! -z "$VncRun" ];then
		echo -e "\033[31m *\033[0m			    VNC运行状态：  [ \033[32mTrue\033[0m ]			        \033[31m*\033[0m"
	else
		echo -e "\033[31m *\033[0m			    VNC运行状态：  [ \033[31mFlase\033[0m ]			        \033[31m*\033[0m"
	fi
	echo -e "\033[31m *\033[0m									        \033[31m*\033[0m"
	echo -ne "\033[34m *\033[0m\033[31m******************************************************************************\033[0m\033[34m*\033[0m
		\033[2;3;34m请选择[ 1 , 2 , 3 , q ]: \033[0m
		"
	read Choice
	case $Choice in
	1) Install_Vnc_Lxde
	;;
	2) Start_Service
	;;
	3) Stop_Service
	;;
	4) Re_Vnc_Passwd
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
		\033[3;33m按任意键继续\033[0m"
	read
	Menu
}

function CheckOS(){
	OSPATH=(/etc/redhat-release /etc/system-release /etc/os-release /etc/lsb-release)
	for i in ${OSPATH[@]}
	do
		if [ -e $i ];then
			CentOS6=$(grep "CentOS.*\b6\..*\b.*" $i)
			CentOS7=$(grep "CentOS.*\b7\..*\b.*" $i)
			Ubuntu=$(grep "Ubuntu" $i)
			Debian=$(grep "Debian" $i)
		fi
	done
}

function Re_Vnc_Passwd(){
		SetVnc
		DOWNLOAD_FILE=(Start_Vnc loadingvnc)
		for i in ${DOWNLOAD_FILE[@]}
		do
			if [ ! -e /usr/bin/$i ];then
				wget script.xmxin.top/$i -O /usr/bin/$i;chmod +x /usr/bin/$i
			fi
		done
		Start_Vnc $VncPass
		echo "重置密码为：$VncPass"
}

function Install_Vnc_Lxde(){
	CheckOS
	if [ ! -z "$CentOS6" ];then
		CentOS6_Install
		Install_Info
	elif [ ! -z "$CentOS7" ];then
		CentOS7_Install
		Install_Info
	elif [ ! -z "$Ubuntu" ];then
		Ubuntu_Install
		Install_Info
	elif [ ! -z "$Debian" ];then
		Debian_Install
		Install_Info
	else
		Error_Get_OS
	fi
}

function Error_Get_OS(){
	echo -n "自动判断系统出错请输入你的系统版本[ CentOS6 , CentOS7 , Ubuntu , Debian ]："
	read OS
	[ -z "$OS" ] && Error_Get_OS
	if [ $OS == "CentOS6" ];then
		CentOS6_Install
		Install_Info
	elif [ $OS == "CentOS7" ];then
		CentOS7_Install
		Install_Info
	elif [ $OS == "Ubuntu" ];then
		Ubuntu_Install
		Install_Info
	elif [ $OS == "Debian" ];then
		Debian_Install
		Install_Info
	else
		Error_Get_OS
	fi
}

function SetVnc(){
	echo -n "请输入你的VNC密码："
	read VncPass
}

function CentOS6_Install(){
	SetVnc
	yum update -y
	yum groupinstall -y "X Window System" "Desktop"
	yum install -y tigervnc-server tigervnc firefox expect curl
	echo '	VNCSERVERS="1:root"
	VNCSERVERARGS[1]="-geometry 1366x768 -alwaysshared -depth 24"' >>/etc/sysconfig/vncservers
	DOWNLOAD_FILE=(Start_Vnc loadingvnc)
	for i in ${DOWNLOAD_FILE[@]}
	do
		wget script.xmxin.top/$i -O /usr/bin/$i;chmod +x /usr/bin/$i
	done
	sed -i "8,9d" /usr/bin/Start_Vnc
	Start_Vnc $VncPass
	vncserver
	chmod 777 ~/.vnc/xstartup
	chkconfig vncserver on
	echo '*/10 * * * * reboot' test.cron
	crontab -u root test.cron
}

function CentOS7_Install(){
	SetVnc
	yum update -y
	yum groupinstall -y "X Window System" "Desktop"
	yum install -y tigervnc-server tigervnc firefox expect curl
	echo '	VNCSERVERS="1:root"
	VNCSERVERARGS[1]="-geometry 1366x768 -alwaysshared -depth 24"' >>/etc/sysconfig/vncservers
	DOWNLOAD_FILE=(Start_Vnc loadingvnc)
	for i in ${DOWNLOAD_FILE[@]}
	do
		wget script.xmxin.top/$i -O /usr/bin/$i;chmod +x /usr/bin/$i
	done
	Start_Vnc $VncPass
	vncserver
	systemctl enable vncserver
	chmod 777 ~/.vnc/xstartup
	echo '*/10 * * * * reboot' test.cron
	crontab -u root test.cron
}

function Ubuntu_Install(){
	SetVnc
	apt-get update -y
	apt-get install -y xorg lxde-core tightvncserver firefox expect curl
	DOWNLOAD_FILE=(Start_Vnc loadingvnc)
	for i in ${DOWNLOAD_FILE[@]}
	do
		wget script.xmxin.top/$i -O /usr/bin/$i;chmod +x /usr/bin/$i
	done
	Start_Vnc $VncPass
	tightvncserver -kill :1
	echo '#!/bin/sh

xrdb $HOME/.Xresources
xsetroot -solid grey
#x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
#x-window-manager &
# Fix to make GNOME work
export XKL_XMODMAP_DISABLE=1
/etc/X11/Xsession
lxterminal &
/usr/bin/lxsession -s LXDE &' >>~/.vnc/xstartup
	chmod 777 ~/.vnc/xstartup
	tightvncserver :1
}

function Debian_Install(){
	SetVnc
	apt-get update -y
	apt-get install -y xorg lxde-core tightvncserver iceweasel expect curl
	DOWNLOAD_FILE=(Start_Vnc loadingvnc)
	for i in ${DOWNLOAD_FILE[@]}
	do
		wget script.xmxin.top/$i -O /usr/bin/$i;chmod +x /usr/bin/$i
	done
	Start_Vnc $VncPass
	tightvncserver -kill :1
	echo '#!/bin/sh

xrdb $HOME/.Xresources
xsetroot -solid grey
#x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
#x-window-manager &
# Fix to make GNOME work
export XKL_XMODMAP_DISABLE=1
/etc/X11/Xsession
lxterminal &
/usr/bin/lxsession -s LXDE &' >>~/.vnc/xstartup
	chmod 777 ~/.vnc/xstartup
	tightvncserver :1
}

function Install_Info(){
	Get_Var
	if [ ! -z "$VncRun" ];then
		echo "安装成功!

----登录密码为：$VncPass"
		num=0
		for i in ${GetPort[@]}
		do
			echo "----登录节点为：$GetIp:${GetPort[$num]}"
			num=$(expr $num + 1)
		done
	else
		echo "安装失败!"
	fi
}

function Start_Service(){
	CheckOS
	if [ ! -z "$CentOS6" ];then
		CentOS6_Start_Service
	elif [ ! -z "$CentOS7" ];then
		CentOS7_Start_Service
	elif [ ! -z "$Ubuntu" ];then
		Ubuntu_Debian_Start_Service
	elif [ ! -z "$Debian" ];then
		Ubuntu_Debian_Start_Service
	else
		Error_Get_OS_Start
	fi
}

function Error_Get_OS_Start(){
	echo -n "自动判断系统出错请输入你的系统版本[ CentOS6 , CentOS7 , Ubuntu , Debian ]："
	read OS
	[ -z "$OS" ] && Error_Get_OS_Start
	if [ $OS == "CentOS6" ];then
		CentOS6_Start_Service
	elif [ $OS == "CentOS7" ];then
		CentOS7_Start_Service
	elif [ $OS == "Ubuntu" ];then
		Ubuntu_Debian_Start_Service
	elif [ $OS == "Debian" ];then
		Ubuntu_Debian_Start_Service
	else
		Error_Get_OS_Start
	fi
}

function Ubuntu_Debian_Start_Service(){
	Get_Var
	while true
	do
		echo -n "请输入要开起的VNC窗口号[1-∞]："
		read VncNum
		expr $VncNum + 0 >/dev/null
		if [ $? -eq 0 ];then
			if [ $VncNum -ge 1 ] && [ $VncNum -le 65535 ];then
				echo "你的窗口为：$VncNum"
				break
			else
				echo "输入有误"
			fi
			echo "输入有误"
		fi
	done
	if [ -z "$VncRun" ];then
		tightvncserver :$VncNum
		echo "	登录信息"
		num=0
		for i in ${GetPort[@]}
		do
			echo "----登录节点为：$GetIp:${GetPort[$num]}"
			num=$(expr $num + 1)
		done
	else
		echo "VNC已在运行"
	fi
}

function CentOS6_Start_Service(){
	Get_Var
	if [ -z "$VncRun" ];then
		service vncserver start
	else
		echo "VNC已在运行"
	fi
}

function CentOS7_Start_Service(){
	Get_Var
	if [ -z "$VncRun" ];then
		systemctl start vncserver
	else
		echo "VNC已在运行"
	fi
}

function Stop_Service(){
	CheckOS
	if [ ! -z "$CentOS6" ];then
		CentOS6_Stop_Service
	elif [ ! -z "$CentOS7" ];then
		CentOS7_Stop_Service
	elif [ ! -z "$Ubuntu" ];then
		Ubuntu_Debian_Stop_Service
	elif [ ! -z "$Debian" ];then
		Ubuntu_Debian_Stop_Service
	else
		Error_Get_OS_Stop
	fi
}

function Error_Get_OS_Stop(){
	echo -n "自动判断系统出错请输入你的系统版本[ CentOS6 , CentOS7 , Ubuntu , Debian ]："
	read OS
	[ -z "$OS" ] && Error_Get_OS_Stop
	if [ $OS == "CentOS6" ];then
		CentOS6_Stop_Service
	elif [ $OS == "CentOS7" ];then
		CentOS7_Stop_Service
	elif [ $OS == "Ubuntu" ];then
		Ubuntu_Debian_Stop_Service
	elif [ $OS == "Debian" ];then
		Ubuntu_Debian_Stop_Service
	else
		Error_Get_OS_Stop
	fi
}

function Ubuntu_Debian_Stop_Service(){
	Get_Var
	while true
	do
		echo -n "请输入要停止的VNC窗口号[1-∞]："
		read VncNum
		expr $VncNum + 0 >/dev/null
		if [ $? -eq 0 ];then
			if [ $VncNum -ge 1 ] && [ $VncNum -le 65535 ];then
				echo "你的窗口为：$VncNum"
				break
			else
				echo "输入有误"
			fi
			echo "输入有误"
		fi
	done
	if [ ! -z "$VncRun" ];then
		tightvncserver -kill :$VncNum
	else
		echo "VNC已停止"
	fi
}

function CentOS6_Stop_Service(){
	Get_Var
	if [ ! -z "$VncRun" ];then
		service vncserver stop
	else
		echo "VNC已停止"
	fi
}

function CentOS7_Stop_Service(){
	Get_Var
	if [ ! -z "$VncRun" ];then
		systemctl stop vncserver
	else
		echo "VNC已停止"
	fi
}

if [ $UID != 0 ];then
	echo "请用root用户运行
已退出"
	exit;
fi

Menu

exit;
