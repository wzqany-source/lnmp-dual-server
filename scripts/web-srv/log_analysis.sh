#!/bin/bash
# Nginx日志路径
LOG_FILE="/var/log/nginx/access.log"

# 1. 第一步：Shell 进行初筛（数数）
# 统计最近的 404 和 500 错误数量
HTTP_404=$(awk '{print $9}' $LOG_FILE | grep "404" | wc -l)
HTTP_500=$(awk '{print $9}' $LOG_FILE | grep "500" | wc -l)

# 2. 第二步：判断是否达到触发 Python 的条件
if [ $HTTP_404 -gt 5 ] || [ $HTTP_500 -gt 0 ]; then
    echo "【系统信号】检测到异常，正在唤醒 AI 专家 (Python) 进行深度分析..."
    
    # --- 核心连接点：Shell 在这里拉起 Python ---
    python3 /home/yuwei/scripts/ai_analyze.py
    # ----------------------------------------
    
    echo "【系统信号】AI 任务执行完毕。"
else
    # 如果没达到阈值，Shell 就自己输出了事，不打扰 Python
    echo "当前状态正常（404:$HTTP_404, 500:$HTTP_500），AI 模块继续休眠。"
fi
