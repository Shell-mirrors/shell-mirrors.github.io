#!/system/bin/sh
export PATH=/sbin:/system/sbin:/system/bin:/system/xbin:/vendor/bin:/vendor/xbin

echo 准备查找配置文件所在位置
sleep 1
num="1 2"
for i in $num
do
	PID=$(busybox ps | grep ss-local | grep -v grep | cut -d " " -f $i)
	echo 正在进行第${i}次查找
	sleep 1
	if [ -e /proc/$PID/environ ];then
		echo 恭喜，找到了，正在获取ss配置
		sleep 1
		wostore_get_file=/proc/$PID/environ
		break;
	else
		if [ $i == 2 ];then
			echo 第${i}次查找失败，程序终止！
			exit;
		fi
		echo 第${i}次查找失败，正进行第$(expr $i + 1)次查找！
		sleep 1
	fi
done

wostore_get_ss=$(cat $wostore_get_file | sed -e "s/:/\n/g" -e "s/,\/data/\n/g" -e "s/ARGS=/\n/g" | busybox grep aes-256-cfb)

if [ ! -z "$wostore_get_ss" ];then
	echo 恭喜获取ss成功，请复制以下配置到China Uni客户端使用：
	echo $wostore_get_ss
else
	echo 获取失败！
fi
