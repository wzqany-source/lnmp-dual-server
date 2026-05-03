# LNMP 双机高可用架构

## 1. 问题（Problem）

单服务器部署 Web 应用，硬件故障或系统更新导致服务完全中断，RTO 不可控。
- 单点故障：一台服务器宕机，全站不可用
- 数据风险：无异地备份，磁盘损坏即丢失
- 故障盲区：无实时监控，依赖用户上报问题
- 日志分析：人工排查 Nginx 日志效率低，无法快速定位根因

## 2. 方案（Solution）

### 2.1 双机架构

| 节点 | IP | 角色 | 运行服务 |
|---|---|---|---|
| db-srv | 192.168.229.136 | 主节点 | Nginx + MySQL + Prometheus + Grafana |
| web-srv | 192.168.229.135 | 备节点 | Nginx(SSL) + Apache + PHP-FPM + MySQL |

**流量路径：**
外部请求 → Nginx:443(SSL) → proxy_pass → Apache:8080 → PHP8.1-FPM

### 2.2 数据同步

- **rsync 异机同步**：每日 04:00 从 db-srv 同步 MySQL 备份到 web-srv
- **备份路径**：`/home/yuwei/backup/mysql/` → `/home/yuwei/backup/mysql_from_db/`

### 2.3 监控告警

- **Prometheus + node_exporter**：跨节点采集 CPU/内存/磁盘/网络
- **Grafana Dashboard**：Node Exporter Full（ID: 1860）
- **AI 日志分析**：`ai_analyze.py` 调用百炼 Qwen，识别 Nginx 404/500/502 异常模式
- **钉钉告警**：`log_analysis.sh` 每 30 分钟检测异常，触发 AI 分析 + 钉钉通知

### 2.4 SSL 证书

- 自签名证书（`nginx.crt` / `nginx.key`）
- HTTP:80 → 301 跳转 → HTTPS:443

## 3. 验证（Verification）

- **双节点部署**：db-srv + web-srv，SSH 免密已配置
- **定时任务**：
  - 巡检：8:00 / 20:00（`check_services_v3.sh`）
  - MySQL 备份：03:00（`backup_mysql.sh`）
  - rsync 同步：04:00（`rsync_backup.sh`）
  - 日志分析：每 30 分钟（`log_analysis.sh`）
- **监控面板**：http://192.168.229.136:3000（Grafana）

## 4. 效果（量化与现状）

| 指标 | 现状 | 说明 |
|---|---|---|
| 监控告警延迟 | **检测周期 30 分钟，异常识别后 15 秒内钉钉通知** | `log_analysis.sh` 每 30 分钟扫描，AI 分析后即时告警 |
| 数据同步窗口 | **RPO &lt; 24 小时** | 每日 04:00 rsync 异机同步 |
| AI 日志分析 | **支持 404/500/502 异常模式识别** | 调用百炼 Qwen，输出根因 + 3 条建议 |
| 监控覆盖 | **2 节点全维度采集** | Prometheus + node_exporter + Grafana |

## 5. 技术栈

- Nginx / Apache / PHP-FPM
- MySQL
- Prometheus / Grafana / node_exporter
- Python + 阿里云百炼 Qwen
- 钉钉机器人 Webhook
- rsync / cron
- Shell / Bash

## 6. 目录结构
├── scripts/
│   ├── db-srv/
│   │   ├── check_services_v3.sh
│   │   ├── backup_mysql.sh
│   │   └── rsync_backup.sh
│   └── web-srv/
│       ├── ai_analyze.py
│       ├── auto_insert.sh
│       └── log_analysis.sh
├── monitoring/
│   ├── prometheus.yml
│   └── grafana.ini
└── docs/
└── README.md

## 7. 关键设计

- **反向代理层**：Nginx 统一入口，SSL 终止，后端 Apache 处理动态请求
- **异机备份**：rsync + cron 实现低成本冷备
- **AI 辅助排障**：异常日志自动送入大模型，减少人工排查时间
- **模块化脚本**：统一注释头、统一函数命名、ShellCheck 零 error
