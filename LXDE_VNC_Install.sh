#!/bin/bash
export PATH=~/bin:~/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

function Get_Var(){
	GetIp=$(curl -L ifconfig.co)
	GetPort=($(netstat -ntlp | grep "[v,V][n,N][c,C]" | grep "[0-9]\{1,5\}" | grep -v ".*:::.*" | cut -d ":" -f 2 | awk '{printf("%d ",$1)}'))
	if [ ! -z "$CentOS6" ];then
		VncRun=$(ps aux | egrep "Xvnc|vncserver" | grep -v "grep")
	elif [ ! -z "$CentOS7" ];then
		VncRun=$(ps aux | egrep "Xvnc|vncserver" | grep -v "grep")
	elif [ ! -z "$Ubuntu" ];then
		VncRun=$(ps aux | egrep "Xtightvnc|vncserver" | grep -v "grep")
	elif [ ! -z "$Debian" ];then
		VncRun=$(ps aux | egrep "Xtightvnc|vncserver" | grep -v "grep")
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
	read -e  Choice
	case $Choice in
	1) Install_Vnc_Lxde
	;;
	2) Start_Service
	;;
	3) Stop_Service
	;;
	4) Set_Vnc_Passwd
	;;
	q|Q) exit
	;;
	*) echo -e "		\033[3;31m输入有误!\033[0m"
	esac
	Back_Menu
}

function Back_Menu(){
	echo -ne "
		\033[3;33m按任意键继续\033[0m"
	read -e 
	Menu
}

function CheckOS(){
	OSPATH=(/etc/redhat-release /etc/system-release /etc/os-release /etc/lsb-release)
	for i in ${OSPATH[@]}
	do
		if [ -e $i ];then
#			echo $(cat $i)
			CentOS6=$(grep "CentOS.*6.*" $i)
			CentOS7=$(grep "CentOS.*7.*" $i)
			Ubuntu=$(grep "Ubuntu" $i)
			Debian=$(grep "Debian" $i)
		fi
	done
}

function Set_Vnc_Passwd(){
	SetVnc
	which expect
	if [ ! $? -eq 0 ];then
		yum install -y expect
	fi
	which vncpasswd
	if [ $? -eq 0 ];then
		echo "正在设置密码，请勿输入..."
		expect <<-EOF
		spawn vncpasswd
		expect {
		"Password:" { send $VncPass\r }
		"Verify:" { send $VncPass\r }
		"Would you like to enter a view-only password (y/n)? { send n\r }"
		}
		expect eof
		EOF
	else
		echo "本机未安装vnc，自动设置密码失败，请安装后重试！"
		exit 1
	fi
	echo "已设置密码为：$VncPass"
}

function Install_Vnc_Lxde(){
	CheckOS
	if [ ! -z "$CentOS6" ];then
		CentOS6_Install
	elif [ ! -z "$CentOS7" ];then
		CentOS7_Install
	elif [ ! -z "$Ubuntu" ];then
		Ubuntu_Install
	elif [ ! -z "$Debian" ];then
		Debian_Install
	else
		echo "自动判断系统出错~"
		Error_Get_OS
	fi
	Install_Info
}

function Error_Get_OS(){
	echo -n "请输入你的系统版本[ CentOS6 , CentOS7 , Ubuntu , Debian ]："
	read -e  OS
	[ -z "$OS" ] && Error_Get_OS
	if [ $OS == "CentOS6" ];then
		CentOS6_Install
	elif [ $OS == "CentOS7" ];then
		CentOS7_Install
	elif [ $OS == "Ubuntu" ];then
		Ubuntu_Install
	elif [ $OS == "Debian" ];then
		Debian_Install
	else
		echo "输入的版本有误~"
		Error_Get_OS
	fi
	Install_Info
}

function SetVnc(){
	echo "请输入你的VNC密码："
	read -e  -s VncPass
}

function CentOS6_Install(){
	yum update -y
	yum groupinstall -y "GNOME Desktop"
	yum groupinstall -y "Chinese Support"
	yum install -y tigervnc-server tigervnc firefox expect curl
	echo '	VNCSERVERS="1:root"
	VNCSERVERARGS[1]="-geometry 1920x1080 -alwaysshared -depth 24"' >>/etc/sysconfig/vncservers
	Set_Vnc_Passwd
	chmod 777 ~/.vnc/xstartup
	vncserver -kill :1
	vncserver :1
#	echo '*/10 * * * * reboot' test.cron
#	crontab -u root test.cron
}

function CentOS7_Install(){
	yum update -y
	yum groupinstall -y "GNOME Desktop"
	yum groupinstall -y "Chinese Support"
	yum install -y tigervnc-server tigervnc firefox expect curl
	echo '	VNCSERVERS="1:root"
	VNCSERVERARGS[1]="-geometry 1920x1080 -alwaysshared -depth 24"' >>/etc/sysconfig/vncservers
	Set_Vnc_Passwd
	chmod 777 ~/.vnc/xstartup
	vncserver -kill :1
	vncserver :1
#	echo '*/10 * * * * reboot' test.cron
#	crontab -u root test.cron
}

function Ubuntu_Install(){
	apt-get update -y
	apt-get install -y xorg lxde-core tightvncserver firefox expect curl
	Set_Vnc_Passwd
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
	apt-get update -y
	apt-get install -y xorg lxde-core tightvncserver iceweasel expect curl
	Set_Vnc_Passwd
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
	read -e  OS
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
		read -e  VncNum
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
		vncserver :1
	else
		echo "VNC已在运行"
	fi
}

function CentOS7_Start_Service(){
	Get_Var
	if [ -z "$VncRun" ];then
		echo 7
		vncserver :1
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
	read -e  OS
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
		read -e  VncNum
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
		vncserver -kill :1
	else
		echo "VNC已停止"
	fi
}

function CentOS7_Stop_Service(){
	Get_Var
	if [ ! -z "$VncRun" ];then
		vncserver -kill :1
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
