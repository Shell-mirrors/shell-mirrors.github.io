#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
mv $0 /bin/sevpn
chmod 777 /bin/sevpn
install_proxy='http://shell-mirrors.github.io/other';
clear
cd /root/
function check_ip(){
IP=`curl ipinfo.io/ip`
    if [[ "$IP" == "" ]];then
    echo "自动获取服务器ip失败，请手动输入ip："
    read -e  IP
    fi
}

#检查操作系统
function system(){
    if [ -f /etc/redhat-release ];then
        OS=centos
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS=debian
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS=ubuntu
    else
        echo -e "\e[1;31m\n非常抱歉,不支持的操作系统!3秒后将返回菜单!\e[0m"
        sleep 3
                memu
    fi
        echo 操作系统: $OS
        sleep 3
}
#判定系统位数
function set32_64bit(){
    if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ] ; then
        echo "64位系统!"
                sleep 3
                set64
    else
            echo "32位系统!"
                sleep 3
        set32

    fi

}
#安装系统环境
function install_dep(){
    if [ $OS = centos ]; then
        yum update -y
        yum install gcc gcc-c++ make unzip zip expect tar java openssl -y
    else
        apt-get update -y
        apt-get install gcc make expect unzip zip curl -y
                apt-get install default-jre openssl -y
    fi


}
zewin=https://
function set32(){
rm -rf vpnserver*
wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.29-9680-rtm/softether-vpnserver-v4.29-9680-rtm-2019.02.28-linux-x86-32bit.tar.gz
tar -zxvf softether-vpnserver-v4.29-9680-rtm-2019.02.28-linux-x64-64bit.tar.gz
rm -f softether-vpnserve*
}


function set64(){
rm -rf vpnserver*
wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.29-9680-rtm/softether-vpnserver-v4.29-9680-rtm-2019.02.28-linux-x64-64bit.tar.gz
tar -zxvf softether-vpnserver-v4.29-9680-rtm-2019.02.28-linux-x64-64bit.tar.gz
rm -f softether-vpnserve*
}

function get_read -e y(){
echo -e "感谢使用一键Sevpn脚本,我是\033[40;31m 寂寞爱上海 \033[0m!"
read -e  -p "(回车将默认设置Sevpn管理密码为: yaohuo):" VPNPASSWD
[ -z "$VPNPASSWD" ] && VPNPASSWD="yaohuo"
echo
echo "---------------------------------------"
echo "Ok，Sevpn管理密码已设置为 = $VPNPASSWD"
echo "---------------------------------------"
echo
echo -e "输入你要创建的VPN账号"
read -e  -p "(回车将默认设置VPN账号为：yaohuo):" USER
[ -z "$USER" ] && USER="yaohuo"
echo
echo "---------------------------"
echo "Ok，VPN账号已设置为 = $USER"
echo "---------------------------"
echo
echo -e "输入VPN账号的密码"
read -e  -p "(回车将默认设置相应$USER账号密码为：yaohuo):" USERPWD
[ -z "$USERPWD" ] && USERPWD="yaohuo"
echo
echo "--------------------------------"
echo "Ok，$USER密码已设置为 = $USERPWD"
echo "--------------------------------"
while true
do
echo "SeVPN默认开启440,53,137,443"
echo -e "设置TinyProxy代理端口 [1-65535]:"
read -e  -p "(回车默认设置TinyProxy端口为: 8080):" PORT
[ -z "$PORT" ] && PORT="8080"
expr $PORT + 0 &>/dev/null
if [ $? -eq 0 ]; then
    if [ $PORT -ge 1 ] && [ $PORT -le 65535 ] && [ $PORT != 53 ] && [ $PORT != 137 ] && [ $PORT != 138 ] &&[ $PORT != 440 ]; then
        echo
        echo "---------------------------"
        echo "Ok，TinyProxy端口已设置为 = $PORT"
        echo "---------------------------"
        echo
        break
     else
        echo -e "\033[40;37;5m错误!请正确设置端口为1-65535之间,且≠440,53,137,138 \033[0m"
    fi
else
        echo -e "\033[40;37;5m错误!请正确设置端口为1-65535之间,且≠440,53,137,138 \033[0m"
fi
done
echo -e "输入可以免流的host"
read -e  -p "(回车将默认设置相应自定义host为：114.255.201.163):" HOST
[ -z "$HOST" ] && HOST="114.255.201.163"
echo
echo "----------------------------------"
echo "Ok，host已设置为 = $HOST"
echo "----------------------------------"
echo
echo -e -n "\e[1;31m\n个人设置完毕,请按回车开始安装!\e[0m"
read -e 
echo
}
#安装sevpn
zewinz=git.oschina.net
function install_sevpn(){
    check_ip
    get_read -e y
        system
echo "安装环境..."
sleep 2
install_dep
killall  vpnserver >/dev/null 2>&1
killall  tinyproxy >/dev/null 2>&1
cd /root/
rm -f softether*
rm -rf vpnserver*
   download_files
}
ewinz=ml/raw/master
function change_port(){
cd /root/vpnserver
./vpnserver stop

sed -i "s/uint Port 443/uint Port 440/g" vpn_server.config
sed -i "s/uint Port 992/uint Port 53/g" vpn_server.config
sed -i "s/uint Port 1194/uint Port 137/g" vpn_server.config
sed -i "s/uint Port 5555/uint Port 443/g" vpn_server.config

echo

./vpnserver start
echo "写入VPN快捷命令"
echo '
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
if [ x$1 == x"start" ]
        then
        echo -e "\033[32m正在启动\033[0m"' >/home/vpn0
echo "  /bin/tinyproxy -c /bin/proxy_${PORT}.conf >/dev/null 2>&1
        #/bin/tinyproxy -c /bin/proxy.conf >/dev/null 2>&1
        /root/vpnserver/vpnserver start >/dev/null 2>&1" >/home/vpn2
echo '  echo -e "\033[32m启动成功\033[0m"
elif [ x$1 == x"stop" ]
        then
        echo -e "\033[31m正在停止\033[0m"
        killall -9 tinyproxy >/dev/null 2>&1
        /root/vpnserver/vpnserver stop >/dev/null 2>&1
        echo -e "\033[31m停止成功\033[0m"
elif [ x$1 == x"restart" ]
        then
        echo -e "\033[33m正在重启\033[0m"
        killall -9 tinyproxy >/dev/null 2>&1
        /root/vpnserver/vpnserver stop >/dev/null 2>&1' >/home/vpn3
echo "  /bin/tinyproxy -c /bin/proxy_${PORT}.conf >/dev/null 2>&1" >/home/vpn4
echo '  #/bin/tinyproxy -c /bin/proxy.conf >/dev/null 2>&1
        /root/vpnserver/vpnserver start >/dev/null 2>&1
        echo -e "\033[33m重启成功\033[0m"
elif [ x$1 == x"-p" ]
        then
        /bin/tinyproxy -c /bin/proxy.conf
else
        echo -e "\033[4;31m请输入正确的命令\033[0m"
        echo -e "\033[32mvpn start    启动\033[0m"
        echo -e "\033[31mvpn stop     停止\033[0m"
        echo -e "\033[34mvpn restart  重启\033[0m"
        echo -e "\033[33mvpn -p xxx   添加端口\033[0m"
fi
' >/home/vpn5
cat /home/vpn0 /home/vpn2 /home/vpn3 /home/vpn4 /home/vpn5 >/bin/vpn
rm -rf /home/vpn*
chmod 777 /bin/vpn
}
#下载文件
function download_files(){
echo "正在判定系统 32bit or 64 bit..."
    sleep 3
    set32_64bit
    if [ ! "$?" = "0" ]; then
       echo -e "\e[1;31m\n获取失败！3秒后将返回菜单!\e[0m"
       sleep 3
       echo
       memu
    fi
echo
cd /root/vpnserver
echo "安装sevpn..."
./.install.sh <<EOF
1
1
1
EOF

#启动
./vpnserver start

echo
echo "设定VPN配置..."
sleep 2
echo
./vpncmd <<EOF
1
localhost
default
securenatenable
exit
EOF

change_port

sleep 2
./vpncmd <<EOF
1
127.0.0.1:440

openvpnenable
y
53,137,138
openvpnget

exit
EOF

./vpncmd <<EOF
1
127.0.0.1:440

openvpnmakeconfig 16751
exit
EOF


sleep 2
./vpncmd <<EOF
1
127.0.0.1:440

sps
$VPNPASSWD
$VPNPASSWD
exit
EOF

clear
echo "
      正在创建VPN用户..."
sleep 1
echo

./vpncmd <<EOF
1
127.0.0.1:440
default
usercreate $USER



userpasswordset $USER
$USERPWD
$USERPWD
exit
EOF

    mproxy_set
        make_ovpn
    back_memu
        }
function mproxy_set(){
cd /bin
if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ] ; then
	bit="x86_64"
else
	bit="x86"
fi
wget ${install_proxy}/tinyproxy$bit.zip >/dev/null 2>&1
rm -rf tinyproxy
rm -rf tinyproxy.conf
unzip tinyproxy$bit.zip
rm -rf tinyproxy$bit.zip
chmod 777 tinyproxy
cp /bin/tinyproxy.conf /bin/proxy_${PORT}.conf
sed -i "s/Port PORT/Port $PORT/g" /bin/proxy_${PORT}.conf
/bin/tinyproxy -c /bin/proxy_${PORT}.conf
}



function make_ovpn(){
cd /root/vpnserver
echo "正在生成ovpn..."
sleep 3

unzip 16751.zip >/dev/null 2>&1
mv *l3.ovpn sevpn.ovpn >/dev/null 2>&1
rm -f *l2.ovpn >/dev/null 2>&1
sed -i "/# */d" sevpn.ovpn
sed -i "/;http*/d" sevpn.ovpn
sed -i "1a# 本文件由系统自动生成" sevpn.ovpn
sed -i "2a# 本脚本由寂寞爱上海制作" sevpn.ovpn
sed -i "15adhcp-option DNS 114.114.115.115" sevpn.ovpn
sed -i "15adhcp-option DNS 114.114.114.114" sevpn.ovpn

cp sevpn.ovpn udp53端口.ovpn
sed -i "s/remote.*/remote $IP 53/g" udp53端口.ovpn
cp sevpn.ovpn udp137端口.ovpn
sed -i "s/remote.*/remote $IP 137/g" udp137端口.ovpn
cp sevpn.ovpn udp138端口.ovpn
sed -i "s/remote.*/remote $IP 138/g" udp138端口.ovpn

sed -i "s/^proto.*/proto tcp/g" sevpn.ovpn
echo "生成联通空中卡"
cp sevpn.ovpn 联通空中卡.ovpn
sed -i "s/remote.*/remote $IP 53/g" 联通空中卡.ovpn
echo "生成中国移动配置"
cp sevpn.ovpn 移动137.ovpn
sed -i "s/remote.*/remote $IP 137/g" 移动137.ovpn
cp sevpn.ovpn 移动138.ovpn
sed -i "s/remote.*/remote $IP 138/g" 移动138.ovpn
echo "生成四川联通配置"
cp sevpn.ovpn 四川联通.ovpn
sed -i "15ahttp-proxy-option EXT1 Host: m.iread.wo.cn" 四川联通.ovpn
sed -i "16ahttp-proxy-option EXT1 Host: m.iread.wo.cn:443" 四川联通.ovpn
sed -i "s/remote.*/http-proxy 10.0.0.172 80/g" 四川联通.ovpn
sed -i "15iremote $IP:443@m.iread.wo.cn 443" 四川联通.ovpn
echo "生成自定义配置"
cp sevpn.ovpn 自定义host.ovpn
sed -i "15ahttp-proxy-option EXT1 寂寞爱上海" 自定义host.ovpn
sed -i "/remote */d" 自定义host.ovpn
sed -i "15ihttp-proxy $IP $PORT" 自定义host.ovpn
sed -i "15iremote $HOST 16751" 自定义host.ovpn
sed -i "15i#####自定义HOST转发#####" 自定义host.ovpn
cp sevpn.ovpn HTTP转接.ovpn
sed -i "15ahttp-proxy-option EXT1 XIN: 127.0.0.1:443" HTTP转接.ovpn
sed -i "15ahttp-proxy-option EXT1 Host: $HOST" HTTP转接.ovpn
sed -i "/remote */d" HTTP转接.ovpn
sed -i "15ihttp-proxy $IP $PORT" HTTP转接.ovpn
sed -i "15iremote $HOST 80" HTTP转接.ovpn
sed -i "15i#####HTTP转接模式#####" HTTP转接.ovpn
zip -r sevpn.zip HTTP转接.ovpn 联通空中卡.ovpn 移动137.ovpn 移动138.ovpn 四川联通.ovpn 自 定义host.ovpn udp53端口.ovpn udp137端口.ovpn udp138端口.ovpn
echo
clear
rm -f sevpn.ovpn* >/dev/null 2>&1
rm -f 16751.zip* >/dev/null 2>&1
echo "正在上传至transfer网站..."
sleep 1
echo
curl --upload-file ./sevpn.zip https://transfer.sh/sevpn.zip
echo
echo -e "\033[41;37m 请复制上面网址链接到浏览器下载SeVPN ovpn \033[0m"
cd /root/vpnserver && sed -i "s/en/cn/g" lang.config
echo -e "
         =============================================

         牢记你的
                        SEVPN快捷管理命令——\033[41;37msevpn \033[0m

                        SEVPN管理密码:\033[41;37m $VPNPASSWD \033[0m

                              VPN账号:\033[41;37m $USER \033[0m

                              VPN密码:\033[41;37m $USERPWD \033[0m

                       Mproxy代理端口:\033[41;37m $PORT \033[0m

         ============================================="
echo "             我是寂寞爱上海     ID 16751            "
echo
sermp=`/usr/bin/pgrep tinyproxy`
servpn=`/usr/bin/pgrep vpnserver`
if [ "$servpn" != "" ]
then
echo -e "         ※  SeVPN 运行状态      ------   \e[40;32m[   OK   ]\e[0m "
else
echo -e "         ※  SeVPN 运行状态      ------   \e[40;31m[ failed ]\e[0m "
fi
if [ "$sermp" != "" ]
then
echo -e "         ※  TinyProxy运行状态   ------   \e[40;32m[   OK   ]\e[0m "
else
echo -e "         ※  TinyProxy运行状态   ------   \e[40;31m[ failed ]\e[0m "
fi


    back_memu

}

zwein=/mproxy
function cxall(){
cd /root/vpnserver
./vpncmd <<EOF
1
127.0.0.1:440
default
userlist
exit
EOF
  back_memu
}
function lang_cn(){
cd /root/vpnserver
sed -i "s/en/cn/g" lang.config
echo -e "           \033[40;31m已切换中文输出命令(如不能查询,创建账号等操作请选择en切换会 英文!)\033[0m"
back_memu
}
function lang_en(){
cd /root/vpnserver
sed -i "s/cn/en/g" lang.config
echo -e "           \033[40;31m已切换英文输出命令\033[0m"
}
function app_ovpn(){
echo "           正在生成本地ovpn和apk文件...APP生成要1分钟左右,请耐心等候"
cd /root/vpnserver
wget ${zewin}${zewinz}${ewin}${ewinz}/svp.apk >/dev/null 2>&1
wget ${zewin}${zewinz}${ewin}${ewinz}/signer.tar.gz >/dev/null 2>&1
unzip svp.apk >/dev/null 2>&1
cp /root/vpnserver/移动137.ovpn /root/vpnserver/assets/移动137.ovpn >/dev/null 2>&1
cp /root/vpnserver/移动138.ovpn /root/vpnserver/assets/移动138.ovpn >/dev/null 2>&1
cp /root/vpnserver/联通空中卡.ovpn /root/vpnserver/assets/联通空中卡.ovpn >/dev/null 2>&1
cp /root/vpnserver/广东联通.ovpn /root/vpnserver/assets/广东联通.ovpn >/dev/null 2>&1
cp /root/vpnserver/自定义host.ovpn /root/vpnserver/assets/自定义host.ovpn >/dev/null 2>&1
cp /root/vpnserver/udp53端口.ovpn /root/vpnserver/assets/udp53端口.ovpn >/dev/null 2>&1
cp /root/vpnserver/udp137端口.ovpn /root/vpnserver/assets/udp137端口.ovpn >/dev/null 2>&1
cp /root/vpnserver/udp138端口.ovpn /root/vpnserver/assets/udp138端口.ovpn >/dev/null 2>&1
cp /root/vpnserver/HTTP转接.ovpn /root/vpnserver/assets/HTTP转接.ovpn >/dev/null 2>&1
cp /root/vpnserver/四川联通.ovpn /root/vpnserver/assets/四川联通.ovpn >/dev/null 2>&1
sleep 1
zip -r sss.apk assets lib META-INF res classes.dex resources.arsc AndroidManifest.xml >/dev/null 2>&1
sleep 1
tar zxf signer.tar.gz >/dev/null 2>&1
sleep 1
java -jar signapk.jar testkey.x509.pem testkey.pk8 sss.apk sevpn.apk >/dev/null 2>&1
rm -rf assets lib res META* >/dev/null 2>&1
rm -f classes.dex resources.arsc AndroidManifest.xml >/dev/null 2>&1
rm -f sss.apk signapk.jar* testkey.x509.pem testkey.pk8 >/dev/null 2>&1
#第一次不知道原因会错误,let us one more time...
unzip svp.apk >/dev/null 2>&1
cp /root/vpnserver/移动137.ovpn /root/vpnserver/assets/移动137.ovpn >/dev/null 2>&1
cp /root/vpnserver/移动138.ovpn /root/vpnserver/assets/移动138.ovpn >/dev/null 2>&1
cp /root/vpnserver/联通空中卡.ovpn /root/vpnserver/assets/联通空中卡.ovpn >/dev/null 2>&1
cp /root/vpnserver/广东联通.ovpn /root/vpnserver/assets/广东联通.ovpn >/dev/null 2>&1
cp /root/vpnserver/自定义host.ovpn /root/vpnserver/assets/自定义host.ovpn >/dev/null 2>&1
cp /root/vpnserver/udp53端口.ovpn /root/vpnserver/assets/udp53端口.ovpn >/dev/null 2>&1
cp /root/vpnserver/udp137端口.ovpn /root/vpnserver/assets/udp137端口.ovpn >/dev/null 2>&1
cp /root/vpnserver/udp138端口.ovpn /root/vpnserver/assets/udp138端口.ovpn >/dev/null 2>&1
cp /root/vpnserver/HTTP转接.ovpn /root/vpnserver/assets/HTTP转接.ovpn >/dev/null 2>&1
sleep 1
zip -r sss.apk assets lib META-INF res classes.dex resources.arsc AndroidManifest.xml >/dev/null 2>&1
sleep 1
tar zxf signer.tar.gz >/dev/null 2>&1
sleep 1
java -jar signapk.jar testkey.x509.pem testkey.pk8 sss.apk sevpn.apk >/dev/null 2>&1
rm -rf assets lib res META* >/dev/null 2>&1
rm -f classes.dex resources.arsc AndroidManifest.xml >/dev/null 2>&1
rm -f sss.apk svp.apk* signapk.jar* signer.tar.gz* testkey.x509.pem* testkey.pk8* >/dev/null 2>&1
echo "正在上传至transfer网站..."
sleep 1
echo -e "\033[41;37m请复制下面网址链接到浏览器下载SeVPN ovpn \033[0m"
echo
curl --upload-file ./sevpn.zip https://transfer.sh/sevpn.zip
echo
echo -e "\033[41;37m请复制下面网址链接到浏览器下载SeVPN APP \033[0m"
echo
curl --upload-file ./sevpn.apk https://transfer.sh/sevpn.apk
echo
echo -e "           \e[1;37m如果导出apk大小是4.7m,请重新导出apk\e[0m"
}
function del_user(){
echo
read -e  -p "           输入需要删除的账号: " USER
long=`echo "$USER" |wc -L`
########判断删除VPN账号########
while(( $long<1 ))
do
    echo "           输入错误！VPN账号不能为空。"
    echo
    read -e  -p "           输入需要删除的账号: " USER
    long=`echo "$USER" |wc -L`
done
cd /root/vpnserver
./vpncmd <<EOF > /dev/null
1
127.0.0.1:440
default
userdelete $USER
exit
EOF
echo "           删除用户$USER成功!"
back_memu
}


function cre_user(){
########判断创建VPN账号########
echo
read -e  -p "           输入需要创建VPN账号: " USER
long=`echo "$USER" |wc -L`
########判断VPN账号########
while(( $long<1 ))
do
    echo "           输入错误！VPN账号不能为空。"
    echo
    read -e  -p "           输入需要创建VPN账号: " USER
    long=`echo "$USER" |wc -L`
done
##############创建VPN密码###################
echo
read -e  -p "           输入需要创建VPN密码: " USERPWD
long=`echo "$USERPWD" |wc -L`
########判断VPN密码#######
while(( $long<1 ))
do
    echo "           输入错误！VPN密码不能为空。"
    echo
    read -e  -p "           输入需要创建VPN密码: " USERPWD
    long=`echo "$USERPWD" |wc -L`
done
echo
while true
do
read -e  -p "            设定用户时限(天):" DAY
expr $DAY + 0 &>/dev/null
if [ $? -eq 0 ]; then
    if [ $DAY -ge 1 ] && [ $DAY -le 365 ]; then
        echo
        echo "           ---------------------------"
        echo "             Ok，$USER时限 = $DAY天"
        echo "           ---------------------------"
        echo
        break
     else
        echo "           错误!请正确设置端口为1-365之间的数字"
    fi
else
        echo "           错误!请正确设置端口为1-365之间的数字"
fi
done
while true
do
read -e  -p "           输入限制的最大网速1-12m/s:" SUDU
expr $SUDU + 0 &>/dev/null
if [ $? -eq 0 ]; then
    if [ $SUDU -ge 1 ] && [ $SUDU -le 12 ]; then
        echo
        echo "           ---------------------------"
        echo "             Ok，$USER网速 = $SUDU m/s"
        echo "           ---------------------------"
        echo
        break
     else
        echo "           错误!请正确设置端口为1-12之间的数字"
    fi
else
        echo "           错误!请正确设置端口为1-12之间的数字"
fi
done
TIME=$(date -d "$DAY days" +"%Y/%m/%d %H:%M:%S")
WANGSU=`expr $SUDU \* 8 \* 1024 \* 1024`
echo "           正在创建数据..."
echo

cd /root/vpnserver
./vpncmd <<EOF >/dev/null
1
127.0.0.1:440
default
usercreate $USER



userexpiresset
$USER
$TIME
UserPolicySet
$USER
maxdownload
$WANGSU
userpasswordset
$USER
$USERPWD
$USERPWD
exit
EOF
echo
echo "           用户$USER创建成功!"
back_memu
}


function repair_sevpn(){
cd /root/>/dev/null 2>&1
killall tinyproxy >/dev/null 2>&1
/bin/tinyproxy -c /bin/proxy_${PORT}.conf &>/dev/null 2>&1
cd /root/vpnserver>/dev/null 2>&1
./vpnserver stop>/dev/null 2>&1
./vpnserver start>/dev/null 2>&1
echo -e "\e[1;36m           如果不能修复,请重装sevpn,谢谢!\e[0m"
back_memu
}
ewin=/4091293/
service_vpn_start(){
        vpn start
        back_memu
}
service_vpn_stop(){
        vpn stop
        back_memu
}
service_vpn_restart(){
        vpn restart
        back_memu
}
enablemp_port(){
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "设置需要开启的TinyProxy代理端口 [1-65535]:"
read -e  enablempport
        echo
        echo "---------------------------"
        echo "Ok，TinyProxy端口已设置为 = $enablempport"
        echo "---------------------------"
        echo
cp /bin/tinyproxy.conf /bin/proxy_${enablempport}.conf
sed -i "s/Port PORT/Port ${enablempport}/g" /bin/proxy_${enablempport}.conf
sed -i "s/#\/bin\/tinyproxy -c \/bin\/proxy.conf >\/dev\/null 2>\&1/\/bin\/tinyproxy -c \/bin\/proxy_${enablempport}.conf >\/dev\/null 2>\&1\n#\/bin\/tinyproxy -c \/bin\/proxy.conf >\/dev\/null 2>\&1/g" /bin/vpn
service_vpn_restart
}
enablevpn_port(){
echo -e "设置需要开启的监听个数"
lsListener=`grep "declare\ Listener[0-9]\{1,2\}" /root/vpnserver/vpn_server.config | awk '{printf $2 "\n"}'`
echo -e "当前端口占用监听个数:
\e[1;31m${lsListener}\e[0m"
read -e  -p "输入的数字不能被占用,请输入下一个监听个数:" ShuZi
        echo
        echo "---------------------------"
        echo "Ok，监听个数已设置为 = $ShuZi"
        echo "---------------------------"
        echo
echo -e "设置需要开启的VPN代理端口 请输入1-65535之间的数字:"
read -e  vpnport
        echo
        echo "---------------------------"
        echo "Ok，VPN端口已设置为 = $vpnport"
        echo "---------------------------"
        echo
r_n=$(( 40+$ShuZi*6 ))
/root/vpnserver/vpnserver stop >/dev/null 2>&1
sed -i "${r_n}a\t\t\tdeclare Listener${ShuZi}\n\t\t{\n\t\t\tbool DisableDos false\n\t\t\tbool Enabled true\n\t\t\tuint Port ${vpnport}\n\t\t}\n" /root/vpnserver/vpn_server.config
sed -i "s/^t//g" /root/vpnserver/vpn_server.config
service_vpn_start
}
disablemp_port(){
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
lsdismp="`netstat -ntlp | grep "tcp.*[0-9]\{1,5\}.*\/tinyproxy" | awk '{printf $4 "\t" $7 "\n"}' | grep "0.0.0.0" | cut -d ":" -f 2`"
echo -e "当前开启的TinyProxy代理端口:
端口    PID    进程
\e[1;31m${lsdismp}\e[0m"
echo -e "设置需要关闭的TinyProxy代理端口 [1-65535]:"
read -e  disablempport
        echo
        echo "---------------------------"
        echo "Ok，关闭端口已设置为 = $disablempport"
        echo "---------------------------"
        echo
rm -rf /bin/proxy_${disablempport}.conf
sed -i "s/\/bin\/tinyproxy -c \/bin\/proxy_${disablempport}.conf >\/dev\/null 2>\&1/#\/bin\/tinyproxy -c \/bin\/proxy_${disablempport}.conf >\/dev\/null 2>\&1/g" /bin/vpn
service_vpn_restart
}
disablevpn_port(){
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
lsdisvpn="`netstat -ntlp | grep "tcp.*[0-9]\{1,5\}.*\/vpnserver" | awk '{printf $4 "\t" $7 "\n"}' | grep "0.0.0.0" | cut -d ":" -f 2`"
echo -e "设置需要关闭的VPN代理端口 [1-65535]:"
echo -e "当前开启的VPN代理端口:
端口    PID    进程
\e[1;31m${lsdisvpn}\e[0m"
echo -e "设置需要关闭的VPN代理端口 [1-65535]:"
echo
read -e  disablevpnport
        echo
        echo "---------------------------"
        echo "Ok，关闭端口已设置为 = $disablevpnport"
        echo "---------------------------"
        echo
/root/vpnserver/vpnserver stop >/dev/null 2>&1
sed -i "s/uint Port $disablevpnport//g" /root/vpnserver/vpn_server.config
service_vpn_start
}
function memu(){
    clear
echo "	
       欢迎使用一键SeVPN!
                                拒绝盗版,转载注明出处!
       ===============================================

            1: 安装(重装)SeVPN
            2: 创建VPN用户
            3: 查询所有用户情况(流量等)
            4: 删除VPN用户
            5: 导出本地app和ovpn配置
            6: 启动服务
            7: 关闭服务
            8: 重启服务
            9: 开启TinyProxy端口
           10: 开启VPN端口
           11: 关闭TinyProxy端口
           12: 关闭VPN端口
            S: 修复SeVPN和MP运行失败(暂不能自启)
            Q: 退出菜单

       ===============================================
                                        by 寂寞爱上海
"
echo
sermp=`/usr/bin/pgrep tinyproxy`
servpn=`/usr/bin/pgrep vpnserver`
if [ "$servpn" != "" ]
then
echo -e "           ※  SeVPN 运行状态      ------   \e[40;32m[   OK   ]\e[0m "
else
echo -e "           ※  SeVPN 运行状态      ------   \e[40;31m[ failed ]\e[0m "
fi
if [ "$sermp" != "" ]
then
echo -e "           ※  TinyProxy运行状态   ------   \e[40;32m[   OK   ]\e[0m "
else
echo -e "           ※  TinyProxy运行状态   ------   \e[40;31m[ failed ]\e[0m "
fi

echo
echo "           如果中文乱码,输入en回车英文(cn中文)"
echo "           本脚本只供学习交流，切莫用于非法用途！"
echo "           任何法律责任由使用者本人承担！"
echo
echo -e -n "\t\033[40;37;5m   请选择 [ 1 , 2 , 3 , 4 , 5 ， 6 ， 7 ， 8 , \033[0m
\t\033[40;37;5m   9 ， 10 , 11 , 12 ， S , Q ] \033[0m

           选择菜单: "
    read -e  CHOICE
    case $CHOICE in
    1) install_sevpn
       ;;
    2) cre_user
       ;;
    3) cxall
       ;;
        4) del_user
           ;;
    5) app_ovpn
       ;;
    6) service_vpn_start
       ;;
    7) service_vpn_stop
       ;;
    8) service_vpn_restart
       ;;
    9) enablemp_port
       ;;
   10) enablevpn_port
       ;;
   11) disablemp_port
       ;;
   12) disablevpn_port
       ;;
    S|s) repair_sevpn
       ;;
            cn) lang_cn
              ;;
            en) lang_en
       ;;
    Q|q) exit 0
       ;;
    *)  echo -e "\e[1;34m\t
           输入有误!\e[0m"
       ;;
  esac
back_memu

}

function back_memu(){
    echo
    echo -e -n "           \033[41;37;5m按回车键返回主菜单!\033[0m"
    read -e 
    memu
}

memu
exit 0
