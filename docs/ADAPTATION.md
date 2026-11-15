# sheng 适配依据与验证边界

## 目标机型

仅小米平板 6S Pro 12.4（`sheng`，骁龙 8 Gen 2）。其它机型禁止尝试；本项目不对其它机型的兼容问题及损失负责。

## 本次直接核对的文件证据

| 文件 | 可确认的内容 |
|---|---|
| `images/boot.img` | Android boot 镜像头；内核启动参数 `root=PARTLABEL=userdata` |
| `images/userdata.img` | Android sparse v1，块大小 4096 字节，6291456 个逻辑块；展开后为 24 GiB 的逻辑镜像 |
| `packages/ath12k-sheng-he-mcs_7.2.6-1_arm64.deb` | arm64 修补包；依赖 kmod 与 linux-xiaomi-sheng；包含 ath12k 替换模块和修补源文本 |
| deb 的 preinst | 仅接受运行内核 `7.2.6-sm8550-00102-gef2f794ee6f0`；检查原始 ath12k 模块 SHA256 与已有覆盖路径 |
| deb 的 postinst | 执行该内核的 depmod，并确认选中 updates 目录内的替换模块 |
| deb 的 postrm | 移除覆盖模块后重建该内核的模块依赖 |
| `flash_all.*` | 写入 `boot`、`userdata` 后重启，不是 Android 双系统保留数据的安装方案 |

Wi-Fi 修补针对 HE 接收速率元数据/MCS 处理，不能从这个补丁推出所有 Wi-Fi 连接与性能问题都已解决。

## 原随包说明记录的配置

追加的镜像只读核对确认：`/usr/lib/os-release` 为 Debian 13（trixie，13.7）；`/etc/fstab` 确实使用 `PARTLABEL=userdata / ext4 defaults,noatime,x-systemd.growfs`；`/etc/systemd/zram-generator.conf` 配置 `min(ram / 2, 8192)`、Zstandard 压缩及 swap 优先级 100；KWin 配置含 `Xwayland Scale=2` 和 Fcitx 5 Wayland 启动器；`fix-display` 实际通过禁用再启用 `DSI-1` 恢复显示管线。此核对未改动原镜像，也不代表完成实机功能或稳定性测试。

- Debian 13 arm64、KDE Plasma 6、Wayland。
- 屏幕 3048×2032、200% 缩放、XWayland Scale 2、`fix-display` 工具。维护者 oliver 确认 90 / 120 / 144 Hz 均可用；原说明中的 90 Hz 是为省电作出的选择，不是适配上限。镜像里保留了 120 Hz 的 KWin 配置项，实际当前刷新率以 KDE 显示设置和驱动输出为准。
- Wayland/Ozone 及 Fcitx 5 中文输入配置。
- ZRAM 按内存一半、最多约 8 GiB 的目标配置。
- fstab 的 `x-systemd.growfs` 首启扩容配置。
- 唤醒锁屏、sudo 认证缓存和 nftables 规则。
- 办公通信应用、浏览器、编辑器、小程序与嵌入式开发工具。

这些属于系统配置/软件环境的记录，不构成每台机器、每种容量及每项硬件功能的实测证明。相机、蓝牙、音频、传感器、触控笔、键盘盖、USB/显示输出、充电、功耗和长期稳定性仍需提供逐项实测记录后再标记完成。

## 本次未执行的操作

没有连接或刷写真实平板，没有执行 live 系统同步脚本，没有将“镜像可以读取/校验通过”等同于全部功能实测通过。

## 维护者

oliver
