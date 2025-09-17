#!/bin/bash

SERVICE_NAME="shadowsocks"
CONFIG_FILE="/opt/shadowsocks/config.json"
SSSERVICE="/opt/shadowsocks/ssservice"

# 生成随机密码，用户可通过参数指定
if [ -n "$1" ]; then
    new_password="$1"
else
    method=$(jq -r '.method' $CONFIG_FILE 2>/dev/null)
    if [ -z "$method" ] || [ "$method" = "null" ]; then
        method="aes-256-gcm"
    fi
    new_password=$($SSSERVICE genkey -m "$method")
fi

# 修改 config.json 中的密码
if [ -f "$CONFIG_FILE" ]; then
    jq --arg pwd "$new_password" '.password = $pwd' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
else
    echo "错误: 找不到配置文件 $CONFIG_FILE"
    exit 1
fi

# 重启服务
systemctl restart $SERVICE_NAME

# 输出新的连接信息
ip=$(hostname -I | awk '{print $1}')
port=$(jq -r '.server_port' $CONFIG_FILE)
method=$(jq -r '.method' $CONFIG_FILE)

base64_credentials=$(echo -n "$method:$new_password" | base64 -w 0)
server_url="ss://$base64_credentials@$ip:$port#cloudcone"

echo "==== Shadowsocks 密码已更新 ===="
echo "IP地址: $ip"
echo "端口号: $port"
echo "加密方式: $method"
echo "新密码: $new_password"
echo "服务器URL: $server_url"
