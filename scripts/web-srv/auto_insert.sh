#!/bin/bash

#自动检测服务状态并远程写入mysql数据表

#配置区
DB_USER="ops_user"
DB_PASS="123456"
DB_HOST="192.168.229.136"
DB_NAME="ops_db"
MY_IP="192.168.229.135"
MY_NAME="web-srv"
CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")

#判断nginx是否在运行
if pgrep nginx > /dev/null; then
	STATUS="running"
else
	STATUS="stopped"
fi

#远程插入命令
mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} -e \
"INSERT INTO ${DB_NAME}.server_info (hostname, ip, service, status)\
 VALUES ('$MY_NAME', '$MY_IP', 'nginx', '${STATUS}');"

echo "[${CURRENT_TIME}]远程数据同步成功 "


