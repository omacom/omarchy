# Mac 支持

## 适用于 Apple Silicon 的 Omarchy

Omarchy for Apple Silicon 是官方的 Omacom 解决方案，随 Omarchy 4.5 首次发布。它与 macOS 并存安装，Mac 启动时你在两者之间选择。

收到有关 Omarchy Mac 的通知？请前往 [从 Omarchy Mac 迁移](#coming-from-omarchy-mac)。

它可在以下 Mac 上运行：

| Mac | 芯片 |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 及更新的 Mac 尚不受支持。M4 支持正在 edge 频道测试中，接下来就会推出。安装程序会在改动任何内容之前检查你的 Mac。

在任何 Apple Silicon Mac 上，包括 M4 及更新机型，你都可以用 [Try Omarchy](https://github.com/omacom/try-omarchy) 在虚拟机中运行 Omarchy。

### 所需条件

- macOS 15 Sequoia 或更高版本，以及一个管理员账户
- 为 Omarchy 预留的可用磁盘空间。安装程序会建议一个大小，并允许你更改。
- Mac 的备份、电源和互联网连接。安装过程会下载数 GB 数据。

### 安装

你从 macOS 中进行安装。使用 [Homebrew](https://brew.sh) 安装 Omarchy Installer：

```sh
brew install omacom/mac/omarchy
```

或者从其[发布页面](https://github.com/omacom/omarchy-mac-installer/releases)下载最新版 Omarchy Installer 并打开。

安装程序会检查你的 Mac，向你展示计划，并通过缩小 macOS 分区为 Omarchy 腾出空间。macOS 会保留在磁盘上，也不需要 USB 驱动器。第一阶段完成后，它会引导你在 macOS Recovery 中完成设置：关机，按住电源按钮直到 "Loading startup options" 出现，选择 Omarchy，然后按照步骤操作。

首次启动时，Omarchy 会要求你设置一个用于加密其磁盘的密码。没有恢复密钥：如果你忘记密码，你的 Omarchy 文件将无法恢复。

以后要在 Omarchy 和 macOS 之间切换，请关机，然后按住电源按钮直到启动选项出现，再选择其中一个。

### 从 Omarchy Mac 迁移

Omarchy Mac 现在是 Omarchy for Apple Silicon 的一部分，所有运行过它的 Mac 都受支持。你当前的安装会继续运行，其系统软件包仍会更新，但不会再收到 Omarchy 更新。没有截止日期，也没有就地升级：你需要备份、移除旧安装、全新安装，然后恢复。第 2 步到第 5 步在 macOS 中进行，所以在重启之前，先在手机上打开此页面。

1. **从 Omarchy 中备份，并备份到 Mac 之外。** 移除旧安装会将其擦除，而且 macOS 无法读取 Omarchy 磁盘。将你的主文件夹复制到外部驱动器或另一台电脑，包括 SSH 和 GPG 密钥、浏览器配置文件和未推送的工作。使用 `pacman -Qqe > ~/packages.txt` 保存你的软件包列表。也请备份 macOS，因为移除和安装都会调整其磁盘大小。
2. **在 macOS 中启动你的 Mac。** 关机，按住电源按钮直到启动选项出现，然后选择 macOS。
3. **安装 Omarchy Installer**，如 [安装](#installing) 中所示。
4. **移除旧安装。** 打开 Omarchy Installer，选择 Installation > Remove Omarchy。它会显示将要删除的内容，并将空间归还给 macOS。如果它无法识别你的安装，它会停止且不更改磁盘。在 [Discord](https://discord.gg/tXFUdasqhY) 中寻求帮助，不要手动删除分区，那样可能会擦除 macOS。
5. **使用安装程序安装 Omarchy for Apple Silicon。**
6. **恢复你的文件。** 逐项恢复你的设置，而不是将整个 `~/.config` 复制到新默认设置之上，因为旧设置可能会覆盖新默认设置。

### 需要了解的事项

- 在 M1 和 M2 MacBook 上，通过打开盖子或按下电源按钮从睡眠中唤醒。
- 有问题或遇到问题：请在我们的 [Discord](https://discord.gg/tXFUdasqhY) 中提问。

[安装程序的 README](https://github.com/omacom/omarchy-mac-installer#readme) 涵盖了发布频道、更新安装程序和移除 Omarchy。

## Intel Mac

在一次简单测试中，我们仅通过安装 Omarchy 就在一台 2019 年 MacBook Pro 上实现了 36% 的性能提升。

 ![macbook-omarchy](images/macbook-omarchy.webp)

### 在 Mac 上安装 Omarchy

Omarchy 目前仅支持作为**唯一**安装的操作系统。安装过程中，驱动器将被擦除，MacOS 将不再可启动。

你以后仍可以通过 Internet Recovery 恢复它。

在本节中，我们假设你已经查阅了 [入门指南](02-getting-started.md) 并且已经准备好 USB 驱动器。如果你还没有，现在就去做。

#### 禁用 Secure Boot

必须禁用 Apple 的 Secure Boot 才能启动可启动 USB 以及操作系统。按以下步骤禁用它：

1. 关闭你的 Mac
2. 打开它并_立即_按住 Command-R，直到看到加载屏幕出现
3. 选择你的用户，并在提示时输入你的密码
4. 进入恢复屏幕后，从菜单栏选择 **Utilities > Startup Security Utility**
5. 在提示进行身份验证时输入你的密码
6. 从 Secure Boot 选项中选择 "No Security"
7. 从 External Boot 选项中选择 "Allow booting from external or removable media"

#### 开始安装

1. 插入 USB 驱动器
2. 重启你的 Mac，并_立即_按住 Option，直到看到启动设备屏幕
3. 选择橙色的 EFI Boot 设备
4. 按[常规方式进行安装](02-getting-started.md)

安装程序会检测 Mac 硬件并自动应用所需的修复：Broadcom Wi-Fi 驱动程序和固件、配备 Broadcom 1570 的机器上的 FaceTime HD 摄像头驱动程序（其固件会在 Mac 联网后从 Apple 下载，因为安装程序可以离线工作）、需要它的 MacBook 机型上的 SPI 键盘驱动程序，以及这些相同机型上的 NVMe 挂起修复。

### 已知限制

社区成员一直在努力解决这些挑战，所以如果这些问题对你有困扰，加入我们 [Discord](https://discord.gg/tXFUdasqhY) 中的 #omarchy-on-other，看看是否有最新的解决方法。

#### FaceTime HD 摄像头

摄像头驱动程序如果在 Mac 休眠时加载，会让机器挂起，所以会先卸载它。应用程序打开摄像头时无法卸载它，所以休眠会被取消，并发送一条指明该应用程序的通知：关闭它并再次休眠。这包括在电池电量危急时自动休眠，以及 suspend-then-hibernate，它会在挂起之前被拒绝。普通的挂起则在摄像头打开时被驱动程序本身拒绝，且不会发送通知。

摄像头的固件从 Apple 下载，所以摄像头只有在 Mac 联网过后才能工作。下载会在启动时开始，如果问题出在网络上，每 15 分钟重试一次；如果 Apple 的文件已更改，它会停止并等待 Omarchy 更新。如果摄像头没有出现，`journalctl -u facetimehd-firmware-fetcher` 会说明原因，`sudo systemctl restart facetimehd-firmware-fetcher` 会再次尝试，如果下载已完成但摄像头仍不在那里，重启会加载驱动程序。

#### 配备 T1 芯片的设备

Apple T1 芯片于 2016 年末推出，仅用于第一代配备 Touch Bar 的 MacBook Pro 机型。
- MacBook Pro 13-inch（2016 年，两个 Thunderbolt 3 端口）– 型号：A1706
- MacBook Pro 13-inch（2016 年，四个 Thunderbolt 3 端口）– 型号：A1708
- MacBook Pro 15-inch（2016 年）– 型号：A1707

#### 已知问题

- Touch Bar 无法使用
- 声音无法使用

#### 配备 T2 芯片的设备

Apple T2 Security Chip 于 2017 年推出。随着 2020 年开始过渡到 Apple silicon（M 系列芯片），T2 芯片已停产。

- iMac Pro（2017 年）– 型号：A1862
- MacBook Pro 13-inch（2018 年，四个 Thunderbolt 3 端口）– 型号：A1989
- MacBook Pro 15-inch（2018 年）– 型号：A1990
- MacBook Air（Retina，13-inch，2018 年）– 型号：A1932
- Mac mini（2018 年）– 型号：A1998
- MacBook Pro 13-inch（2019 年，两个 Thunderbolt 3 端口）– 型号：A2159
- MacBook Pro 13-inch（2019 年，四个 Thunderbolt 3 端口）– 型号：A2178
- MacBook Pro 15-inch（2019 年）– 型号：A1990
- iMac（Retina 5K，27-inch，2020 年）– 型号：A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch（2020 年，两个 Thunderbolt 3 端口）– 型号：A2265
- MacBook Pro 15-inch（2020 年）– 型号：A1990

在这些机型上，安装程序会自动设置打过补丁的 `linux-t2` 内核、T2 音频配置、Apple 的 Broadcom Wi-Fi/Bluetooth 固件，以及通过 `t2fanrd` 进行的风扇控制。Touch Bar 运行在内核内置的 Boot Camp 风格支持上。

#### iMac Retina 5K (2017)

2017 年的 27-inch iMac 没有 T2 芯片，所以安装程序会像其他 Intel Mac 一样设置它。

- iMac（Retina 5K，27-inch，2017 年）– 型号：A1419

#### 已知问题

- 显示屏无法以其原生 5120×2880 运行：面板由两个图块组成，标准驱动程序只点亮其中一个
- 声音无法使用
- 亮度控制没有效果
- 睡眠会让机器挂起；只有断电重启才能恢复

针对此机型的一个社区补丁程序修复了显示、声音和亮度：[omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3)。
