#!/usr/bin/env bash
# ==============================================================================
# 小米平板 6S Pro 12.4 (sheng) - 镜像全量同步脚本 (Live System -> Flash Package)
# 功能：自动比对并将运行系统中的新软件、应用升级、配置变动同步注入刷机镜像中
# ==============================================================================
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_DIR="${SCRIPT_DIR}"
RAW_IMG="${PKG_DIR}/images/userdata.raw"
SPARSE_IMG="${PKG_DIR}/images/userdata.img"
MOUNT_DIR="/mnt/userdata_pkg"

# 若已以 root (如 pkexec/sudo) 身份运行，则无需再次调用 sudo
if [ "$(id -u)" -eq 0 ]; then
    sudo() { "$@"; }
fi

echo "=========================================================="
echo "  小米平板 6S Pro 系统变动同步工具 (Live -> userdata.img)"
echo "=========================================================="

# 1. 检查 raw 镜像
if [ ! -f "$RAW_IMG" ]; then
    echo "[1/5] 正在解压 userdata.img 为 raw 镜像..."
    simg2img "$SPARSE_IMG" "$RAW_IMG"
else
    echo "[1/5] 已存在解压后的 userdata.raw，直接使用..."
fi

# 2. 挂载镜像
echo "[2/5] 挂载镜像文件系统至 ${MOUNT_DIR}..."
sudo mkdir -p "$MOUNT_DIR"
sudo mount -o loop "$RAW_IMG" "$MOUNT_DIR"

cleanup() {
    if mountpoint -q "$MOUNT_DIR"; then
        echo "正在安全卸载镜像挂载点..."
        sudo umount "$MOUNT_DIR" || true
    fi
}
trap cleanup EXIT

# 3. 增量同步变动（严格执行隐私脱敏与系统完整性保护）
echo "[3/5] 开始同步系统软件与配置变动..."

# 3.1 办公与三方应用 (/opt)
echo " -> 同步 /opt (包含钉钉 DingTalk 9.0、Chrome、VS Code 运行依赖)..."
sudo rsync -aHAX --delete \
    --exclude "google/chrome/Default" \
    --exclude "*.log" \
    /opt/ "${MOUNT_DIR}/opt/"

# 3.2 桌面应用新版与库 (/usr)
echo " -> 同步 VS Code (最新 1.146.0)、ChatGPT 与系统组件..."
sudo rsync -aHAX --delete /usr/share/code/ "${MOUNT_DIR}/usr/share/code/" 2>/dev/null || true
sudo rsync -aHAX --delete /usr/lib/chatgpt/ "${MOUNT_DIR}/usr/lib/chatgpt/" 2>/dev/null || true
sudo rsync -aHAX /usr/bin/ "${MOUNT_DIR}/usr/bin/"
sudo rsync -aHAX /usr/sbin/ "${MOUNT_DIR}/usr/sbin/"
sudo rsync -aHAX /usr/lib/ "${MOUNT_DIR}/usr/lib/"
sudo rsync -aHAX /usr/share/applications/ "${MOUNT_DIR}/usr/share/applications/"
sudo rsync -aHAX /usr/share/icons/ "${MOUNT_DIR}/usr/share/icons/"
sudo rsync -aHAX /usr/share/debootstrap/ "${MOUNT_DIR}/usr/share/debootstrap/" 2>/dev/null || true

# 3.3 系统安全与基础配置 (/etc)
echo " -> 同步 AppArmor 规则、音频配置、sudo 规则与软件源..."
sudo rsync -aHAX /etc/apparmor.d/ "${MOUNT_DIR}/etc/apparmor.d/" 2>/dev/null || true
sudo rsync -aHAX /etc/apparmor/ "${MOUNT_DIR}/etc/apparmor/" 2>/dev/null || true
sudo rsync -aHAX /etc/alsa/ "${MOUNT_DIR}/etc/alsa/" 2>/dev/null || true
sudo rsync -aHAX /etc/sudoers.d/ "${MOUNT_DIR}/etc/sudoers.d/" 2>/dev/null || true
sudo cp -a /etc/default/google-chrome /etc/default/chatgpt "${MOUNT_DIR}/etc/default/" 2>/dev/null || true
sudo cp -a /etc/apt/sources.list.d/chatgpt.sources /etc/apt/sources.list.d/google-chrome.sources "${MOUNT_DIR}/etc/apt/sources.list.d/" 2>/dev/null || true

# 3.4 软件包管理器数据库 (/var/lib/dpkg)
echo " -> 同步 dpkg 状态索引与元数据..."
sudo cp -a /var/lib/dpkg/status "${MOUNT_DIR}/var/lib/dpkg/status"
sudo rsync -aHAX /var/lib/dpkg/info/ "${MOUNT_DIR}/var/lib/dpkg/info/"

# 3.5 清理镜像临时缓存
echo " -> 清理镜像内部临时文件与缓存..."
sudo rm -rf "${MOUNT_DIR}/tmp"/* "${MOUNT_DIR}/var/tmp"/*
sudo rm -rf "${MOUNT_DIR}/var/cache/apt/archives"/*.deb 2>/dev/null || true

sync

# 4. 卸载与文件系统修复校验
echo "[4/5] 卸载挂载点并进行 ext4 文件系统校验 (e2fsck)..."
sudo umount "$MOUNT_DIR"
trap - EXIT

sudo e2fsck -f -y "$RAW_IMG"

# 5. 压缩为 Sparse 镜像
echo "[5/5] 将 raw 镜像压缩为 Sparse 镜像 (img2simg)..."
img2simg "$RAW_IMG" "${SPARSE_IMG}.new"
mv "${SPARSE_IMG}.new" "$SPARSE_IMG"
rm -f "$RAW_IMG"

echo " -> 重新生成 MD5 校验和..."
cd "${PKG_DIR}"
md5sum images/boot.img images/userdata.img > md5sum.txt

NEW_USERDATA_MD5=$(grep "images/userdata.img" md5sum.txt | awk '{print $1}')
echo " -> 更新刷机说明文档..."
sed -i "s/userdata.img: [a-f0-9]\{32\}/userdata.img: ${NEW_USERDATA_MD5}/" "${PKG_DIR}/刷机与使用说明.txt"
sed -i "s/打包时间: .*/打包时间: $(date '+%Y-%m-%d %H:%M') (全量对齐最新系统变动)/" "${PKG_DIR}/刷机与使用说明.txt"

# 保证整个刷机包的属主权限
chown -R oliver:oliver "${PKG_DIR}" 2>/dev/null || true

echo "=========================================================="
echo "同步全部完成！新镜像已成功打包就绪。"
cat "${PKG_DIR}/md5sum.txt"
echo "=========================================================="
