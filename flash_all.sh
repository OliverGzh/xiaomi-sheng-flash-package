#!/usr/bin/env bash
# ============================================================
# 小米平板 6S Pro 12.4 (sheng) - Debian 13 (Trixie) 一键刷机脚本
# 支持所有规格版本 (8G/12G/16G 内存，256G/512G/1TB 存储)
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGES_DIR="${SCRIPT_DIR}/images"

echo "=========================================================="
echo "  Xiaomi Pad 6S Pro 12.4 (sheng) Linux 系统刷机程序"
echo "=========================================================="
echo "当前刷机包版本: Debian 13 (Trixie) + KDE Plasma 6 (Wayland)"
echo "适用设备: 小米平板 6S Pro (骁龙 8 Gen 2 / sheng)"
echo "支持配置: 兼容全部 RAM 与存储容量版本（开机自动扩容与适配）"
echo "默认用户: oliver"
echo "默认密码: 123456"
echo "----------------------------------------------------------"
echo "【警告】此操作将会格式化并覆盖目标平板的系统与数据！"
echo "请确保目标平板已解锁 Bootloader，并已处于 Fastboot 模式。"
echo "=========================================================="
read -p "确认开始刷机请输入 'yes'，退出按 Ctrl+C: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "刷机已取消。"
    exit 1
fi

echo ""
echo "[1/4] 检查 Fastboot 设备连接..."
if ! command -v fastboot &>/dev/null; then
    echo "【错误】未找到 fastboot 命令，请先安装 Android platform-tools！"
    exit 1
fi

DEVICE=$(fastboot devices | head -n 1)
if [ -z "$DEVICE" ]; then
    echo "【错误】未检测到处于 Fastboot 模式的设备！"
    echo "请关机后长按【音量减 + 电源键】进入 Fastboot，并用数据线连接电脑。"
    exit 1
fi
echo "成功检测到设备: $DEVICE"

echo ""
echo "[2/4] 刷入底层引导镜像 (boot.img)..."
fastboot flash boot "${IMAGES_DIR}/boot.img"

echo ""
echo "[3/4] 刷入系统根分区镜像 (userdata.img)..."
fastboot flash userdata "${IMAGES_DIR}/userdata.img"

echo ""
echo "[4/4] 刷机完成，正在重启平板进入系统..."
fastboot reboot

echo ""
echo "=========================================================="
echo "刷机全部完成！平板正在重启进入 Linux 系统。"
echo "首次开机系统会自动在线扩容存储空间并初始化 ZRAM 压缩内存。"
echo "登录账户: oliver | 登录密码: 123456"
echo "=========================================================="
