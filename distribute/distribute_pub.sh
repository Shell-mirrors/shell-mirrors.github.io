#!/usr/bin/bash

if [ $# -eq 0 ] || [ ! -f $1 ];then
	echo -e "Tips:\nYou need to create a host list file before using the script.\nusage: bash $(basename $0) 'host list file'"
	exit 1
fi

echo "Please input login username and password!"
read -e  -p "username: " username
read -e  -p "password: " -s password

if [ -z $username ];then
	echo "Username is empty! exit(-1)."
	exit -1
fi

if [ -z $password ];then
	echo "Password is empty! exit(-2)."
	exit -2
fi

if [ ! -f ~/.ssh/id_rsa ];then
	echo "Generate ssh public key."
	ssh-keygen -t rsa
fi

which expect &>/dev/null
if [ ! $? -eq 0 ];then
	yum install -y expect
fi

for ip in $(cat $1)
do
	ping -c 1 $ip &>/dev/null
	if [ ! $? -eq 0 ];then
		echo -e "\e[31m$ip Unable to connect.\3[0m"
		break
	fi
	expect <<-EOF
	spawn ssh-copy-id $username@$ip
	expect {
	"yes/no" { send "yes\r" }
	"password:" { send "$password\r\n" }
	}
	expect eof
	EOF
done
