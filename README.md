# 小米平板 6S Pro 12.4（sheng）Debian 刷机包

> **仅适用于小米平板 6S Pro 12.4 英寸，设备代号 `sheng`，骁龙 8 Gen 2。**
>
> **不适用于小米平板 6、6 Pro、6 Max、6S Pro 以外的任何小米/Redmi 平板，也不适用于其他品牌设备。相同处理器不代表机型兼容。请勿在其他机型上尝试刷入。其他机型可能出现无法启动、显示/触控异常、分区损坏或数据丢失；因用于其他机型产生的兼容问题及损失，本项目概不负责，也不提供适配或恢复支持。**

本项目提供面向 `sheng` 的 Debian Linux 系统镜像、Fastboot 刷机脚本、Wi-Fi 驱动修补包及使用说明。刷机将覆盖设备 `boot` 和 `userdata` 分区，清除原有系统启动环境和用户数据。请先完成备份，自行评估风险；本项目不保证替代原厂 Android 的全部功能。

## 系统与下载

| 项目 | 随包记录 |
|---|---|
| 目标设备 | 小米平板 6S Pro 12.4 / `sheng` / 骁龙 8 Gen 2 |
| 系统 | Debian GNU/Linux 13（Trixie），arm64 |
| 桌面 | KDE Plasma 6，Wayland |
| 内核 | `7.2.6-sm8550-00102-gef2f794ee6f0`（随附驱动包要求的精确版本） |
| 原始镜像打包时间 | 2026-11-14 18:18（原随包说明记录） |
| 默认账号 | `oliver` |
| 初始密码 | `123456`，首次登录后立即运行 `passwd` 修改 |

**完整刷机包请到 [Releases](https://github.com/OliverGzh/xiaomi-sheng-flash-package/releases) 下载。** 仓库的 Code → Download ZIP 只包含脚本、说明和小文件，不包含大型 `userdata.img`。

镜像采用分卷压缩发布：下载同一版本的全部 `.tar.zst.partNNN` 文件和 `ASSET_SHA256SUMS.txt`，放在同一目录，按下文合并、解压。不要混用不同版本或漏下某一卷。

包内文档为打包时快照；维护者后续补充的兼容状态以本项目首页及 Release 说明为准。

## 这台机型具体适配了什么

详细依据与验证边界见 [适配清单](docs/ADAPTATION.md)。下面区分机型底层适配、系统配置与附带软件，避免把“预装应用”误认为硬件驱动已经完善。

| 范围 | 已提供的适配/配置 | 注意事项 |
|---|---|---|
| 基础外设 | **维护者 oliver 确认基础外设已全部适配**，系统以手指触控为主要交互方式 | 此状态来自维护者实机反馈；本次发布整理未重新执行全部硬件测试 |
| 官方键盘 | **维护者确认官方键盘可正常识别和使用** | 属于已适配的基础外设范围 |
| 扩展坞与键鼠 | **通过扩展坞连接键盘、鼠标，识别及使用均正常** | 此结论针对维护者实际使用的连接场景，不扩展成所有扩展坞附加功能均已验证的承诺 |
| 内核与启动 | `sheng` 对应 arm64 内核与 Android boot 镜像；启动参数为 `root=PARTLABEL=userdata`；系统安装在 userdata 分区 | 仅针对该设备的启动/分区布局，不是通用 ARM 镜像 |
| Wi-Fi | **维护者确认 Wi-Fi 联网及使用正常**；附带 `ath12k-sheng-he-mcs_7.2.6-1_arm64.deb`，修复 ath12k 的 HE 接收速率/MCS 解析 | 修补包仅适用于包内指定内核，不要强装到其它内核或机型 |
| 蓝牙 | **维护者确认蓝牙功能使用正常** | 属于已适配的基础外设范围 |
| 电量显示与充电 | **维护者确认电量显示正常，支持小米 120W、100W 等快充协议** | **请使用小米原装充电头和原装线材**；实际充电功率受设备协商、电量、温度及负载影响，协议支持不表示持续达到充电头标称功率 |
| 屏幕显示 | 3048×2032、200% 缩放、XWayland Scale 2；维护者反馈 **90 / 120 / 144 Hz 均可用**，附 `fix-display` 恢复工具 | **90 Hz 是维护者为省电作出的选择，不是适配上限**；当前刷新率可在 KDE 显示设置确认并切换，外接显示属于独立验证范围 |
| 手指触控与中文输入 | Wayland 桌面；Chrome/Chromium/VS Code 的 Ozone 配置；Fcitx 5 拼音及 Wayland 文本协议配置 | 主要面向手指操作；手写笔停止维护，详见下文 |
| 内存规格 | 随包说明记录动态 ZRAM：8 GB 内存约分配 4 GB，12 GB 约 6 GB，16 GB 约 8 GB | 属于配置目标，未提供逐台、逐规格实测报告 |
| 存储规格 | userdata 根文件系统，fstab 配置 `x-systemd.growfs`；首启尝试扩展到目标分区容量 | 同机型 256 GB/512 GB/1 TB 为原说明的适配目标；以实际分区布局、文件系统及首启扩容结果为准 |
| 休眠与认证 | 随包说明记录唤醒锁屏、sudo 会话隔离等配置 | 不等于已经完成待机功耗、长时间休眠唤醒及全部安全场景测试 |
| 网络防护 | 随包说明记录 nftables 入站过滤配置 | 防火墙不能代替更新、强密码或完整安全审计 |
| 应用与开发工具 | 办公通信应用、浏览器、编辑器、微信开发者工具、Node.js 与嵌入式工具链 | 属于软件环境，不是本项目自研；具体版本、来源、可用性与授权以实际软件为准 |

**基础外设已全部适配，以上状态按维护者实机反馈更新。** 本次文件核对不替代维护者的实测，也不将 Linux 系统描述为拥有原厂 Android 的全部应用、DRM 或专有功能。

### 手写笔停止维护

维护者认为手写笔在本系统中的实际使用价值有限，操作便利性不如手指，因此**后续不再维护、适配或支持手写笔相关功能**。相关文件已经清理，但系统中可能仍有配置、组件或入口残留；**存在残留不代表手写笔仍在维护或保证可用**。建议使用手指触控，不将手写笔功能作为选用本系统的依据。

## 刷机前必须准备

1. 在原厂系统和设备标识中核对准确机型：**小米平板 6S Pro 12.4，`sheng`**。
2. 备份照片、文档、账号恢复资料等全部重要数据；后续命令会写入 `boot` 与 `userdata`，不能保留原有用户数据。
3. 按小米官方流程完成 Bootloader 解锁。本项目不提供解锁绕过工具。
4. 在电脑安装 [Android 官方 SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools)，确保终端可运行 `fastboot --version`。Windows 按设备情况安装适用的 USB 驱动。
5. 平板电量建议至少 40%；使用可靠的数据线，刷机过程中保持稳定供电和连接。
6. 电脑预留足够空间：当前 userdata sparse 镜像约 22.86 GB（21.29 GiB），其逻辑大小为 24 GiB；还需要存放分卷、合并压缩包和解压文件。
7. 只连接一台目标 Fastboot 设备；不要在多台设备同时连接时执行本包脚本。
8. 事先准备该机型适用的原厂恢复资料。不要在自定义 Linux 系统仍在设备上时重新锁定 Bootloader。

## 下载、校验、合并与解压

先从 Releases 下载**同一版本的全部分卷**。将各卷与校验文件放在一起，通过 `ASSET_SHA256SUMS.txt` 核对每卷 SHA256；不匹配时重新下载，不要继续刷机。

Windows PowerShell 可查看分卷 SHA256：

```powershell
Get-ChildItem .\*.tar.zst.part* | Sort-Object Name | Get-FileHash -Algorithm SHA256
```

Windows 在这些分卷所在目录打开命令提示符，按下载文件的实际完整前缀合并：

```bat
copy /b xiaomi-sheng-flash-package-20261114.tar.zst.part* xiaomi-sheng-flash-package-20261114.tar.zst
```

Linux/macOS：

```bash
sha256sum -c ASSET_SHA256SUMS.txt  # macOS 可用 shasum -a 256 逐卷对照
cat xiaomi-sheng-flash-package-20261114.tar.zst.part* > xiaomi-sheng-flash-package-20261114.tar.zst
```

使用支持 Zstandard 的解压工具展开合并后的 `.tar.zst`，得到其中的 `.tar` 后再解压出 `xiaomi_sheng_flash_package/`。也可在已安装 `zstd` 的 Linux/macOS 上运行：

```bash
tar --zstd -xf xiaomi-sheng-flash-package-20261114.tar.zst
cd xiaomi_sheng_flash_package
sha256sum -c SHA256SUMS.txt
```

Windows 解压后，在刷机包目录检查关键载荷（与 `SHA256SUMS.txt` 对照）：

```powershell
Get-FileHash .\images\boot.img -Algorithm SHA256
Get-FileHash .\images\userdata.img -Algorithm SHA256
Get-FileHash .\packages\ath12k-sheng-he-mcs_7.2.6-1_arm64.deb -Algorithm SHA256
```

保留了原始 `md5sum.txt` 以兼容旧包核对；发布下载以 SHA256 校验为主。镜像是 Android sparse 格式，刷机时直接交给 fastboot，不要自行转换、格式化、重分区或改名冒充其他机型。

## 刷机步骤

1. 平板完全关机，按住 **音量减 + 电源键** 进入 Fastboot。
2. 用数据线连接电脑，在终端运行：

   ```text
   fastboot devices
   fastboot getvar product
   ```

   必须只有一台设备，且 product 明确返回 **`sheng`**；返回其它代号、空结果或报错时立即停止。Bootloader 未解锁时也不要继续。
3. 确认 `images/boot.img`、`images/userdata.img` 均存在，且文件校验正确。
4. Windows：在刷机包目录运行 `flash_all.bat`。Linux/macOS：

   ```bash
   chmod +x flash_all.sh
   ./flash_all.sh
   ```

5. 阅读覆盖数据警告，确认是自己的 `sheng` 设备后输入 `yes`。脚本依次执行：

   ```text
   fastboot flash boot images/boot.img
   fastboot flash userdata images/userdata.img
   fastboot reboot
   ```

   上述是实际写分区操作，不是只读检查。若任一步失败，请停止并保留错误信息，不要继续补刷不明镜像或强行重启。
6. 首次启动进行初始化和存储扩容。原随包说明估计约 30～60 秒，实际可能更久；不要把估计时间当作超时保证。

## 首次开机与日常使用

- 默认用户 `oliver`，初始密码 `123456`。首次登录立即运行 `passwd`；同步检查锁屏及密码钱包的凭据设置。镜像的公开初始密码不适合长期使用。
- 检查 `cat /etc/os-release`、`uname -r`，以及 `df -h /`、`zramctl`，确认系统、内核、根分区容量和 ZRAM 符合实际设备。
- 充电请使用**小米原装充电头和原装线材**。维护者确认电量显示正常，并支持小米 120W、100W 等快充协议；实际功率随设备协商、电量、温度及系统负载变化。
- 基础外设已由维护者确认适配。首次使用仍建议检查本机 Wi-Fi、手指触控、显示、输入法、音频及休眠唤醒；手写笔不属于后续维护范围。
- 随包说明记录 `fix-display` 可用于显示恢复；应在能进入终端的情况下使用，不能把它当作无法开机时的通用救砖工具。
- 维护者确认内屏 90 / 120 / 144 Hz 均可使用，90 Hz 为省电选择。需要更高刷新率时，在 KDE「系统设置 → 显示与监视器 → 显示配置」选择设备实际列出的 120 Hz 或 144 Hz 并应用；实际当前值以界面和驱动输出为准。
- 原说明记录 sudo 的终端会话认证缓存为 30 分钟。该行为不等于所有后台程序均不能提权，也不能替代日常安全维护。

### Wi-Fi 修补包

`packages/ath12k-sheng-he-mcs_7.2.6-1_arm64.deb` 只针对精确内核 `7.2.6-sm8550-00102-gef2f794ee6f0`。其安装脚本会检查正在运行的内核、原始模块 SHA256 和当前模块覆盖路径，不匹配就拒绝安装。

原说明称镜像已集成该修补包；无需无条件重复安装。仅在确认运行内核、原模块及实际安装状态匹配时，才考虑：

```bash
uname -r
dpkg -s ath12k-sheng-he-mcs
sudo dpkg -i packages/ath12k-sheng-he-mcs_7.2.6-1_arm64.deb
```

不要把此 deb 强装到其它内核或机型上。移除该包后，原始驱动在下次启动时恢复被选用；具体变更见随包安装脚本和补丁。

## 常见问题

| 情况 | 处理原则 |
|---|---|
| `fastboot` 找不到 | 安装官方 Platform-Tools，并将其目录加入 PATH，重新打开终端 |
| `fastboot devices` 没有设备 | 确认 Fastboot 模式、数据线、USB 口及驱动；没有设备时不要执行刷写 |
| 出现多台设备 | 断开其它设备，只保留目标 `sheng` |
| product 不是 `sheng` | 立即停止；禁止用于其它机型 |
| Bootloader locked / flashing not allowed | 按官方解锁流程处理，不要尝试绕过或盲刷其它分区 |
| 校验不一致、解压报错 | 重新核对同一版本全部分卷，重新下载损坏文件 |
| 刷 userdata 中途失败 | 保留完整 fastboot 错误，检查文件完整性和连接；不要自行执行清分区、重分区、重新上锁命令 |
| 开机不正常 | 记录机型、镜像版本、校验结果和现象，按 `sheng` 的恢复方案处理；不要混刷其它机型镜像 |

## 镜像维护与隐私边界

`sync_from_live.sh` 面向高级维护者：在 Linux 中使用 `simg2img`、loop mount、rsync、e2fsck 和 `img2simg` 把运行系统的文件同步回镜像。它**不是普通用户的刷机步骤**，会改变镜像内容及校验和；不要在刷机电脑上随意执行。

原始说明称已清理个人聊天、浏览器、网络配置和凭据等信息。本次发布整理核对了文件、镜像头、随附补丁和完整性校验，**不等同于镜像内部全部文件与已删除数据的隐私取证审计**。再次同步真实日常系统后，必须重新完成脱敏与校验，不能仅凭脚本名或原说明认定安全。

更新镜像时应同步更新校验文件、适配清单和 Release 说明，使用新版本发布，不能用旧校验值描述新镜像。

## 文件与第三方组件

```text
xiaomi_sheng_flash_package/
├── README.md
├── docs/ADAPTATION.md
├── flash_all.bat
├── flash_all.sh
├── sync_from_live.sh
├── 刷机与使用说明.txt
├── md5sum.txt
├── SHA256SUMS.txt
├── images/boot.img
├── images/userdata.img
└── packages/ath12k-sheng-he-mcs_7.2.6-1_arm64.deb
```

原始说明保留在 [`刷机与使用说明.txt`](刷机与使用说明.txt)，其中“全部规格支持”“完全脱敏”等措辞属于原包描述，并非本页面新增的全面验证承诺。本页的验证边界和实际脚本行为应一并阅读。

Linux 内核、Debian 软件包及所有第三方应用的版权、许可证和使用条件归各自权利人。本项目未擅自给全部第三方二进制追加统一许可证，也不表示这些软件均为项目自研或官方背书。缺少源代码/授权信息的组件应向对应提供者确认其再分发条件。

## 维护者

oliver
