#!/bin/bash

SOURCE_DIR="/home/yuwei/backup/mysql/"
#db上面的，每天备份文件地址要从这上面获取新的备份文件
REMOTE_USER="root"
#远程登录的账户
REMOTE_IP="192.168.229.135"
#远程登录的地址
REMOTE_DIR="/home/yuwei/backup/mysql_from_db/"
#传过去的文件存放地址
DATE=$(date +%Y-%m-%d)
#时间
LOG_FILE="/home/yuwei/logs/rsync/rsync_push_${DATE}.log"
#记录rsync的传递日志

# 2. 创建日志目录
mkdir -p /home/yuwei/logs/

# 3. 执行 rsync 同步并记录日志
echo "--- 备份同步开始: $(date '+%Y-%m-%d %H:%M:%S') ---" >> "$LOG_FILE"
if rsync -avz $SOURCE_DIR $REMOTE_USER@$REMOTE_IP:$REMOTE_DIR >> "$LOG_FILE" 2>&1; then
    echo "状态: [OK] 同步成功" >> "$LOG_FILE"
else
    echo "状态: [ERROR] 同步失败，请检查网络或SSH密钥" >> "$LOG_FILE"
fi
echo "--- 备份同步结束 ---" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
