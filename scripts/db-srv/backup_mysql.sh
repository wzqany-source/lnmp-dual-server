#!/bin/bash
#功能:MySQL的自动备份脚本

BACKUP_DIR="/home/yuwei/backup/mysql"
DATE=$(date +%F)
DB_USER="root"
DB_PASS="123456"  # 务必替换
DB_NAME="ops_db"
KEEP_DAYS=7

function backup_db() {
	echo "开始创建备份文件"
	mkdir -p "${BACKUP_DIR}"

	#执行备份命令
if /usr/bin/mysqldump -u${DB_USER} -p${DB_PASS} ${DB_NAME} > "${BACKUP_DIR}/${DB_NAME}_${DATE}.sql" ;then
   echo "[$(date +'%T')]备份成功：${DB_NAME}_${DATE}.sql"
  return 0
	else
  echo "[$(date +'%T')]备份失败：请检查数据库权限和状态"
  return 1
	fi
}

#清理过期函数
function clean_old_files() {
    echo "[$(date +'%T')] [INFO] 开始检索 7 天前的旧备份..."

    # 查找并删除
    find ${BACKUP_DIR} -name "*.sql" -mtime +${KEEP_DAYS} -delete

    echo "[$(date +'%T')] [OK] 清理任务已完成。"
}

echo "任务开始"

if backup_db; then
    clean_old_files
    echo "===== 任务全部圆满完成 ====="
else
    echo "===== 任务因错误中断，未执行清理 ====="
    exit 1
fi
