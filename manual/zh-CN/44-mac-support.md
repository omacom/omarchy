# Mac 支持

## 适用于 Apple Silicon 的 Omarchy

适用于 Apple Silicon 的 Omarchy 是 Omacom 的官方解决方案，随 Omarchy 4.5 首次发布。它与 macOS 并存安装，你可以在 Mac 启动时在两者之间进行选择。

收到关于 Omarchy Mac 的通知？前往 [从 Omarchy Mac 迁移过来](#coming-from-omarchy-mac)。

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

M4 及更新的 Mac 尚不受支持。M4 支持正在 edge 频道中测试，接下来就会推出。安装程序在做出任何更改之前会先检查你的 Mac。

在任何 Apple Silicon Mac 上，包括 M4 及更新机型，你都可以使用 [Try Omarchy](https://github.com/omacom/try-omarchy) 在虚拟机中运行 Omarchy。

### 你需要准备什么

- macOS 15 Sequoia 或更高版本，以及一个管理员账户
- 为 Omarchy 预留的可用磁盘空间。安装程序会建议一个大小，你也可以更改它。
- 做好 Mac 的备份、接通电源并连接互联网。安装过程会下载数 GB 的数据。

### 安装

你从 macOS 中进行安装。使用 [Homebrew](https://brew.sh) 安装 Omarchy Installer：

```sh
brew install omacom/mac/omarchy
```

或者从其[发布页面](https://github.com/omacom/omarchy-mac-installer/releases)下载最新版 Omarchy Installer 并打开它。

安装程序会检查你的 Mac，向你展示方案，并通过缩小 macOS 分区为 Omarchy 腾出空间。macOS 会保留在磁盘上，且不需要 USB 驱动器。第一阶段完成后，它会引导你在 macOS Recovery 中完成设置：关机，按住电源按钮，直到出现“Loading startup options”，选择 Omarchy，然后按照步骤操作。

首次启动时，Omarchy 会要求你设置一个用于加密其磁盘的密码。没有恢复密钥：如果你忘记了该密码，你的 Omarchy 文件将无法恢复。

之后要在 Omarchy 和 macOS 之间切换，请关机，然后按住电源按钮，直到启动选项出现，再选择其中一个。

### 从 Omarchy Mac 迁移过来

Omarchy Mac 现已成为适用于 Apple Silicon 的 Omarchy 的一部分，所有运行过它的 Mac 都受支持。你当前的安装会继续运行，其系统软件包仍会更新，但不会再收到 Omarchy 更新。没有截止日期，也没有原地升级：你需要备份、移除旧安装、全新安装，然后恢复。步骤 2 到 5 在 macOS 中进行，因此在重启前，先在手机上打开此页面。

1. **从 Omarchy 中备份，并备份到 Mac 之外。** 移除旧安装会将其抹除，且 macOS 无法读取 Omarchy 磁盘。将你的主文件夹复制到外置驱动器或另一台电脑，包括 SSH 和 GPG 密钥、浏览器配置文件以及未推送的工作。使用 `pacman -Qqe > ~/packages.txt` 保存你的软件包列表。同时也要备份 macOS，因为移除和安装都会调整其磁盘大小。
2. **在 macOS 中启动你的 Mac。** 关机，按住电源按钮，直到启动选项出现，然后选择 macOS。
3. **安装 Omarchy Installer**，如[安装](#installing)所示。
4. **移除旧安装。** 打开 Omarchy Installer，选择 Installation > Remove Omarchy。它会展示将要删除的内容，并将空间归还给 macOS。如果它无法识别你的安装，它会停止且不更改磁盘。请在 [Discord](https://discord.gg/tXFUdasqhY) 中寻求帮助，而不要手动删除分区，那样可能会抹除 macOS。
5. **安装适用于 Apple Silicon 的 Omarchy**，使用安装程序进行安装。
6. **恢复你的文件。** 一点一点地把设置恢复回来，而不要将整个 `~/.config` 复制并覆盖新默认值，因为旧设置可能会覆盖它们。

### 须知

- 在 M1 和 M2 MacBook 上，通过打开盖子或按下电源按钮从睡眠中唤醒。
- 有疑问或遇到问题：在我们的 [Discord](https://discord.gg/tXFUdasqhY) 中提问。

[安装程序的 README](https://github.com/omacom/omarchy-mac-installer#readme) 介绍了发布频道、更新安装程序以及移除 Omarchy。

## Intel Mac

在一次简单的测试中，我们仅通过安装 Omarchy，就在一台 2019 年 MacBook Pro 上实现了 36% 的性能提升。

 ![macbook-omarchy](images/macbook-omarchy.webp)

### 在 Mac 上安装 Omarchy

Omarchy 目前仅支持作为**唯一**安装的操作系统。安装过程中，驱动器将被清空，MacOS 将无法再启动。

之后你仍然可以根据需要通过 Internet Recovery 将其恢复。

在本节中，我们假定你已经查看过[入门指南](02-getting-started.md)并准备好了 USB 驱动器。如果还没有，现在就去做。

#### 禁用 Secure Boot

为了启动可启动 USB 以及该操作系统，必须禁用 Apple 的 Secure Boot。要禁用它，请执行以下操作：

1. 关闭你的 Mac
2. 将其开机，并_立即_按住 Command-R，直到看到加载画面出现
3. 选择你的用户，并在出现提示时输入你的密码
4. 进入恢复画面后，从菜单栏选择 **Utilities > Startup Security Utility**
5. 在出现身份验证提示时输入你的密码
6. 从 Secure Boot 选项中选择“No Security”
7. 从 External Boot 选项中选择“Allow booting from external or removable media”

#### 开始安装

1. 插入 USB 驱动器
2. 重启你的 Mac，并_立即_按住 Option，直到看到启动设备画面
3. 选择橙色的 EFI Boot 设备
4. 按照[常规安装方式](02-getting-started.md)继续

安装程序会检测 Mac 硬件并自动应用所需的修复：Broadcom Wi-Fi 驱动程序和固件、需要它的 MacBook 机型上的 SPI 键盘驱动程序，以及针对相同机型的 NVMe 挂起修复。

### 已知限制

社区成员一直在努力解决这些难题，所以如果这些问题对你有影响，请加入我们 [Discord](https://discord.gg/tXFUdasqhY) 中的 #omarchy-on-other，看看是否有最新的解决方法。

#### 配备 T1 芯片的设备

Apple T1 芯片于 2016 年末推出，仅用于配备 Touch Bar 的第一代 MacBook Pro 机型。
- MacBook Pro 13 英寸（2016，两个 Thunderbolt 3 端口）– 型号：A1706
- MacBook Pro 13 英寸（2016，四个 Thunderbolt 3 端口）– 型号：A1708
- MacBook Pro 15 英寸（2016）– 型号：A1707

#### 已知问题

- Touch Bar 无法使用
- 声音无法使用

#### 配备 T2 芯片的设备

Apple T2 Security Chip 于 2017 年推出。随着 2020 年开始向 Apple silicon（M 系列芯片）过渡，T2 芯片已停产。

- iMac Pro（2017）– 型号：A1862
- MacBook Pro 13 英寸（2018，四个 Thunderbolt 3 端口）– 型号：A1989
- MacBook Pro 15 英寸（2018）– 型号：A1990
- MacBook Air（Retina，13 英寸，2018）– 型号：A1932
- Mac mini（2018）– 型号：A1998
- MacBook Pro 13 英寸（2019，两个 Thunderbolt 3 端口）– 型号：A2159
- MacBook Pro 13 英寸（2019，四个 Thunderbolt 3 端口）– 型号：A2178
- MacBook Pro 15 英寸（2019）– 型号：A1990
- iMac（Retina 5K，27 英寸，2020）– 型号：A2115（iMac20,1 和 iMac20,2）
- MacBook Pro 13 英寸（2020，两个 Thunderbolt 3 端口）– 型号：A2265
- MacBook Pro 15 英寸（2020）– 型号：A1990

在这些机型上，安装程序会自动设置打过补丁的 `linux-t2` 内核、T2 音频配置、Apple 的 Broadcom Wi-Fi/Bluetooth 固件，以及通过 `t2fanrd` 实现的风扇控制。Touch Bar 运行在内核内置的 Boot Camp 风格支持之上。

#### iMac Retina 5K (2017)

2017 年的 27 英寸 iMac 没有 T2 芯片，因此安装程序会像对待其他 Intel Mac 一样对其进行设置。

- iMac（Retina 5K，27 英寸，2017）– 型号：A1419

#### 已知问题

- 显示屏无法以其原生 5120×2880 运行：面板由两块拼接而成，默认驱动只能点亮其中一块
- 声音无法使用
- 亮度控制不起作用
- 睡眠会使机器挂起；只能断电重启才能恢复

针对此机型的社区补丁程序修复了显示屏、声音和亮度：[omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3)。
