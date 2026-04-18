# LNMP 架构部署项目

## 项目概述
基于两台虚拟机的生产级 LNMP 架构部署，包含 Nginx、MySQL、PHP 及完整的监控告警体系。

## 技术栈
- **Web 服务器**: Nginx 1.24 + Apache 2.4 (反向代理)
- **数据库**: MySQL 8.0 (自动备份+异机同步)
- **后端**: PHP 8.1-FPM
- **监控**: Prometheus + Grafana + Node Exporter
- **自动化**: Shell 脚本 + Cron 定时任务

## 架构图
┌─────────────┐         ┌─────────────┐
│   web-srv   │◄───────►│   db-srv    │
│  192.168.   │  HTTPS  │  192.168.   │
│  229.135    │         │  229.136    │
├─────────────┤         ├─────────────┤
│ Nginx:443   │         │ Nginx:80    │
│ Apache:8080 │         │ MySQL:3306  │
│ PHP8.1-FPM  │         │ Prometheus  │
│ node_exp    │         │ Grafana:3000│
└─────────────┘         └─────────────┘

## 核心功能
- [x] 双向 SSH 免密登录
- [x] Nginx 反向代理 + SSL 证书
- [x] MySQL 自动备份 (每日 03:00)
- [x] Rsync 跨机备份 (每日 04:00)
- [x] 日志分析与异常检测
- [x] Prometheus + Grafana 监控可视化

## 脚本清单
| 脚本 | 功能 | 部署位置 |
|------|------|----------|
| check_services.sh | 服务状态巡检 | db-srv |
| backup_mysql.sh | MySQL 逻辑备份 | db-srv |
| rsync_backup.sh | 跨机同步备份 | db-srv |
| log_analysis.sh | Nginx 日志分析 | web-srv |
| ai_analyze.py | 智能日志分析 | web-srv |

## 监控面板
- Prometheus: http://192.168.229.136:9090
- Grafana: http://192.168.229.136:3000 (admin/admin)

