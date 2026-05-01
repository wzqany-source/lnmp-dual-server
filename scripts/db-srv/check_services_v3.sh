#!/bin/bash

# Author: yuwei
# Description: 检查nginx/mysql/内存/磁盘/cpu/apache/情况以及压缩七天的日志
# Version: v3.0
# Usage: 直接执行 bash check_services_v3.sh 定时执行:0 8,20 * * */bin/bash 每天8点和20点自动执行

set -euo pipefail

TIME=$(/usr/bin/date +%Y%m%d_%H%M%S)
log=~/logs/check_${TIME}.log

function check_nginx(){
    if /usr/bin/systemctl is-active --quiet nginx; then
         echo "[OK],nginx is active"
    else
         echo "[警告] nginx没有运行"
fi
}

 function check_mysql() {
    if /usr/bin/systemctl is-active --quiet mysql; then
       echo "[ok] mysql is active"
    else
       echo "[no] mysql 没有运行"
fi
}
 function check_disk() {
    disk=$(/usr/bin/df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    echo "磁盘使用率：${disk}%"
    if [ "$disk" -gt 80 ]; then
        echo "警告磁盘使用率超过80%"
    else
       echo "[ok]磁盘使用率正常"
fi
}

function check_mem() {
    mem=$(/usr/bin/free -m | awk 'NR==2 {print $4}')
    echo "剩余内存:${mem}mb"
    if [ "$mem" -lt 200 ]; then
       echo "内存不足200mb"
    else
       echo "内存足够"
fi
}
function check_cpu(){
    cpu=$(/usr/bin/top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d',' -f1)
    cpu=$(echo "100 - $cpu" | /usr/bin/bc)
    cores=$(/usr/bin/nproc)
    load=$(/usr/bin/uptime | awk -F'load average:' '{print $2}' | xargs)
    echo "CPU使用率: ${cpu}%"
    echo "CPU核心数: ${cores}"
    echo "系统负载(1/5/15分钟): ${load}"
    cpu_int=$(echo "$cpu" | cut -d'.' -f1)
    if [ "$cpu_int" -gt 80 ]; then
        echo "[警告] CPU使用率超过80%!"
    else
        echo "[ok] CPU使用率正常"
    fi
}

  function check_apache(){
	if /usr/bin/systemctl is-active --quiet http || /usr/bin/systemctl is-active --quiet apache2; then
		echo "[ok]apache正常运行" | tee -a "$log"
	else
		echo "[on]apache没有运行" | tee -a "$log"
	fi
}

 function backup_logs(){
	#查找7天前的日志文件并压缩归档
	find /home/yuwei/logs -name "*.log" -mtime +7 -exec gzip {} \;
	echo "[ok]7天前的日志已压缩归档" | tee -a "$log"
}


#主程序
{
echo "----------------------------------"
echo "服务巡检报告"
echo "时间：$TIME"
echo "-------------------------------------"

check_nginx
echo "-----------------------------------"
check_mysql
echo "------------------------------------"
check_disk
echo "----------------------------"
check_mem
echo "-----------------------"
check_cpu
echo "---------------------------"
check_apache
echo "------------------------------------"
backup_logs
echo "-------------------------------------"
} | tee -a "$log"



