#!/bin/bash
export PATH=~/bin:~/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
CURRENT_DIR=$(dirname $0)
EXTEND_FILE=https://shell-mirrors.github.io/other/OpenVPN.tar.gz
function Menu(){
	CheckOS
	clear
	echo -e "\033[34m *\033[0m\033[31m**************************************\033[0m\033[34m*\033[0m
\033[31m *\033[0m				        \033[31m*\033[0m
\033[31m *\033[0m	1.Install OpenVPN	        \033[31m*\033[0m
\033[31m *\033[0m	2.Start OpenVPN Service	        \033[31m*\033[0m
\033[31m *\033[0m	3.Stop OpenVPN Service	        \033[31m*\033[0m
\033[31m *\033[0m	4.Restart OpenVPN Service       \033[31m*\033[0m
\033[31m *\033[0m	5.Add OpenVPN Account	        \033[31m*\033[0m
\033[31m *\033[0m	6.Remove OpenVPN Account        \033[31m*\033[0m
\033[31m *\033[0m					\033[31m*\033[0m
\033[31m *\033[0m	q.Quit Menu		        \033[31m*\033[0m
\033[31m *\033[0m					\033[31m*\033[0m
\033[31m *\033[0m   -------------------------------    \033[31m*\033[0m
\033[31m *\033[0m					\033[31m*\033[0m"
	if [[ ! -z $(ps aux | egrep "openvpn.*conf$") ]];then
		echo -e "\033[31m *\033[0m   OpenVPN Service Status  [ \033[32mTrue\033[0m ]   \033[31m*\033[0m"
	else
		echo -e "\033[31m *\033[0m   OpenVPN Service Status  [ \033[31mFlase\033[0m ]  \033[31m*\033[0m"
	fi
	echo -e "\033[31m *\033[0m				        \033[31m*\033[0m"
	echo -ne "\033[34m *\033[0m\033[31m**************************************\033[0m\033[34m*\033[0m
\033[2;3;34mPlease Choose [ 1, 2, 3, 4, 5, 6, q ]: \033[0m
"
	read -e  Choice
	case $Choice in
	1) Install_OpenVPN
	;;
	2) Start_Service
	;;
	3) Stop_Service
	;;
	4) Restart_Service
	;;
	5) Add_OpenVPN_Account
	;;
	6) Del_OpenVPN_Account
	;;
	q|Q) exit
	;;
	*) echo -e "\033[3;31mInput is invalid!\033[0m"
	esac
	Back_Menu
}

function Back_Menu(){
	echo -ne "\033[3;33mPress enter to menu.\033[0m"
	read -e 
	Menu
}

function CheckOS(){
	OSPATH=(/etc/redhat-release /etc/system-release /etc/os-release /etc/lsb-release)
	for i in ${OSPATH[@]}
	do
		if [ -e $i ];then
			CentOS6=$(grep "CentOS.*6.*" $i)
			CentOS7=$(grep "CentOS.*7.*" $i)
			Ubuntu=$(grep "Ubuntu" $i)
			Debian=$(grep "Debian" $i)
		fi
	done
	if [[ ! -z $Ubuntu || ! -z $Debian ]];then
		echo "Not support system."
	fi
}

function Add_OpenVPN_Account(){
	Set_Username
	Set_Password
	echo "$account $password" >> /etc/openvpn/pwd-file
}

function Del_OpenVPN_Account(){
	Set_Username
	if [[ ! -z $(grep "^$account " /etc/openvpn/pwd-file) ]];then
		sed -i "/^$account /d" /etc/openvpn/pwd-file
	fi
}

function Install_OpenVPN(){
	CheckOS
	if [ ! -z "$CentOS6" ];then
		CentOS6_Install
	elif [ ! -z "$CentOS7" ];then
		CentOS7_Install
	else
		echo "Check OS failed~"
		Error_Get_OS
	fi
	Install_Info
}

function Error_Get_OS(){
	echo -n "Please choose [ CentOS6 , CentOS7 ]："
	read -e  OS
	[ -z "$OS" ] && Error_Get_OS
	if [ $OS == "CentOS6" ];then
		CentOS6_Install
	elif [ $OS == "CentOS7" ];then
		CentOS7_Install
	else
		echo "Choice invalid, Please try again~"
		Error_Get_OS
	fi
	Install_Info
}

function Set_Port(){
	echo "Please input a port [1-65535]:"
	read -e port
	if [[ -z $port || $port -le 1 || $port -ge 65535 ]];then
		echo "Your input is invalid, Please try again."
		Set_Port
	fi
}

function Set_Username(){
	echo "Please input username:"
	read -e account
	if [[ -z $account ]];then
		echo "Your input is invalid, Please try again."
		Set_Username
	fi
}

function Set_Password(){
	echo "Please input password:"
	read -e password
	if [[ -z $password ]];then
		echo "Your input is invalid, Please try again."
		Set_Password
	fi
}

function Get_Ip(){
	which curl
	[[ $? -ne 0 ]] && yum install curl
	ip=$(curl ipinfo.io/ip)
	if [[ -z $(echo $ip | egrep "[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}") ]];then
		echo "Get ip failed, Please input your ip address."
		read -e ip
		[[ -z $(echo $ip | egrep "[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3}") ]] && echo "Your input is invalid, Please try again." && Get_Ip
	fi
	echo "Your ip is $ip"
	sleep 2
	clear
}

function User_Settings_Init(){
	Get_Extend
	Get_Ip
	Set_Port
	Set_Username
	Set_Password
	for i in $(ls /etc/openvpn | egrep -v "client|server")
	do
		rm -rf /etc/openvpn/$i
	done
}

function Get_Extend(){
	rm -rf OpenVPN.tar.gz*
	which wget
	[[ $? -ne 0 ]] && yum install -y wget
	cd $CURRENT_DIR
	wget $EXTEND_FILE
	which tar
	[[ $? -ne 0 ]] && yum install -y tar
	tar zxvf OpenVPN.tar.gz
}

function CentOS6_Install(){
	User_Settings_Init
	yum update -y
	yum install -y epel-release
	yum install -y easy-rsa-3.0.8 openvpn expect openssl
	sed -i "s/port template/port $port/g" OpenVPN/server.conf
	echo "$account $password" > OpenVPN/pwd-file
	mkdir /etc/openvpn/ccd
	mkdir /etc/openvpn/logs
	cp -rf /usr/share/easy-rsa/3.0.8 /etc/openvpn/easy-rsa
	cp -rf OpenVPN/* /etc/openvpn
	Gen_Cert_Build_ovpn
	service openvpn start
	chkconfig openvpn on
}

function CentOS7_Install(){
	User_Settings_Init
	yum update -y
	yum install -y epel-release
	yum install -y easy-rsa-3.0.8 openvpn expect openssl
	sed -i "s/port template/port $port/g" OpenVPN/server.conf
	echo "$account $password" > OpenVPN/pwd-file
	mkdir /etc/openvpn/ccd
	mkdir /etc/openvpn/logs
	cp -rf /usr/share/easy-rsa/3.0.8 /etc/openvpn/easy-rsa
	cp -rf OpenVPN/* /etc/openvpn
	Gen_Cert_Build_ovpn
	systemctl enable --now openvpn@server
}

function Gen_Cert_Build_ovpn(){
	cd /etc/openvpn/easy-rsa
	./easyrsa init-pki
	expect <<-EOF
	spawn ./easyrsa build-ca nopass
	expect {
		"Common Name" { send default.host\r }
	}
	spawn ./easyrsa gen-req server nopass
	expect {
		"Common Name" { send default.host\r }
	}
	spawn ./easyrsa sign-req server server nopass
	expect {
		"Confirm request details:" { send yes\r }
	}
	expect eof
	EOF
	./easyrsa gen-dh
	ca=$(cat /etc/openvpn/easy-rsa/pki/ca.crt)
	cert=$(cat /etc/openvpn/easy-rsa/pki/issued/server.crt)
	key=$(cat /etc/openvpn/easy-rsa/pki/private/server.key)
	cp -f /etc/openvpn/sample.ovpn /etc/openvpn/client_${port}.ovpn
	sed -i "s/remote ip port/remote $ip $port/g" /etc/openvpn/client_${port}.ovpn
	echo -e "<ca>\n$ca\n</ca>" >> /etc/openvpn/client_${port}.ovpn
	echo -e "<cert>\n$cert\n</cert>" >> /etc/openvpn/client_${port}.ovpn
	echo -e "<key>\n$key\n</key>" >> /etc/openvpn/client_${port}.ovpn
}

function Install_Info(){
	echo "----------------------------------------------------"
	echo "	ovpn file path: /etc/openvpn/client_${port}.ovpn"
	echo "	vpn account: $account"
	echo "	vpn password: $password"
	echo "----------------------------------------------------"
}

function Start_Service(){
	CheckOS
	if [ ! -z "$CentOS6" ];then
		CentOS6_Start_Service
	elif [ ! -z "$CentOS7" ];then
		CentOS7_Start_Service
	else
		Error_Get_OS_Start
	fi
	echo "OpenVPN is Started..."
}

function Restart_Service(){
	Stop_Service
	Start_Service
}

function Error_Get_OS_Start(){
	echo -n "Please input [ CentOS6 , CentOS7 ]："
	read -e  OS
	[ -z "$OS" ] && Error_Get_OS_Start
	if [ $OS == "CentOS6" ];then
		CentOS6_Start_Service
	elif [ $OS == "CentOS7" ];then
		CentOS7_Start_Service
	else
		Error_Get_OS_Start
	fi
	echo "OpenVPN is Started..."
}

function CentOS6_Start_Service(){
	service openvpn start
}

function CentOS7_Start_Service(){
	systemctl start openvpn@server
}

function Stop_Service(){
	CheckOS
	if [ ! -z "$CentOS6" ];then
		CentOS6_Stop_Service
	elif [ ! -z "$CentOS7" ];then
		CentOS7_Stop_Service
	else
		Error_Get_OS_Stop
	fi
	echo "OpenVPN is Stopped..."
}

function Error_Get_OS_Stop(){
	echo -n "Please input [ CentOS6 , CentOS7 ]："
	read -e  OS
	[ -z "$OS" ] && Error_Get_OS_Stop
	if [ $OS == "CentOS6" ];then
		CentOS6_Stop_Service
	elif [ $OS == "CentOS7" ];then
		CentOS7_Stop_Service
	else
		Error_Get_OS_Stop
	fi
	echo "OpenVPN is Stopped..."
}

function CentOS6_Stop_Service(){
	service openvpn stop
}

function CentOS7_Stop_Service(){
	systemctl stop openvpn@server
}

if [ $UID != 0 ];then
	echo "Please use root account running..."
	exit;
fi

Menu

exit;
