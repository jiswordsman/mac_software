#!/bin/bash

SERVICE_NAME="shadowsocks"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
INSTALL_DIR="/opt/shadowsocks"

echo "==== 停止 Shadowsocks 服务 ===="
if systemctl is-active --quiet $SERVICE_NAME; then
    systemctl stop $SERVICE_NAME
fi

echo "==== 禁用 Shadowsocks 服务 ===="
if systemctl is-enabled --quiet $SERVICE_NAME; then
    systemctl disable $SERVICE_NAME
fi

echo "==== 删除 systemd 服务文件 ===="
if [ -f "$SERVICE_FILE" ]; then
    rm -f "$SERVICE_FILE"
fi

echo "==== 刷新 systemd 配置 ===="
systemctl daemon-reload
systemctl reset-failed

echo "==== 删除安装目录 ===="
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
fi

echo "==== 清理完成 ===="
echo "Shadowsocks 已经卸载干净，可以重新执行安装脚本。"
