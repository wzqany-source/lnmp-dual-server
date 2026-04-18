import os
import requests
import json
import dashscope
from dashscope import Generation

# 配置区
dashscope.api_key = "sk-ec584ba4451941bbaa86b919c5b06fd7"
WEBHOOK = "https://oapi.dingtalk.com/robot/send?access_token=e64f4db1eed755075e7865863b8c949b3764bf70ff62aa89b95ed2ea300a4852"
LOG_PATH = "/var/log/nginx/access.log"

def get_logs():
    if os.path.exists(LOG_PATH):
        return os.popen(f"tail -n 15 {LOG_PATH}").read()
    return "No logs found."

def ask_qwen(logs):
    # 兼容性建议：如果 qwen3.5-flash 报错，请手动改为 qwen-turbo
    responses = Generation.call(
        model="qwen-turbo", 
        prompt=f"你是一个专业的Linux运维专家。请分析以下Nginx日志中的异常原因，并给出简洁的加固建议：\n{logs}"
    )
    if responses.status_code == 200:
        return responses.output.text
    else:
        return f"AI分析失败：{responses.message}"

def send_dingtalk(text):
    # 核心修改：加入“运维告警”四个字触发钉钉关键词过滤
    data = {
        "msgtype": "text",
        "text": {"content": f"运维告警 - AI深度分析：\n{text}"}
    }
    r = requests.post(WEBHOOK, json=data)
    print(f"钉钉接口返回状态: {r.text}")

if __name__ == "__main__":
    logs = get_logs()
    print("正在请求通义千问 AI 分析...")
    analysis_result = ask_qwen(logs)
    send_dingtalk(analysis_result)
