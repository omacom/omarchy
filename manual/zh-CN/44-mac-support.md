# Mac 支持

Omarchy 内置支持 **Intel Macs**。目前有几个已知限制，但只要你了解并能接受这些限制；你就可以通过安装 Omarchy 让你的旧 Mac 焕发新生。

请注意，目前不直接支持在 M 系列 Mac 上安装。你可以在我们的 [Discord](https://discord.gg/tXFUdasqhY) 中的 #omarchy-on-other 频道了解这方面的更多最新情况。

在一次简单的测试中，我们仅通过安装 Omarchy，就在一台 2019 款 MacBook Pro 上实现了 36% 的性能提升。

 ![macbook-omarchy](images/macbook-omarchy.webp)

### 在 Mac 上安装 Omarchy

Omarchy 目前仅支持作为**唯一**安装的操作系统。安装过程中，硬盘将被抹除，MacOS 将不再可启动。

之后如果你愿意，仍然可以通过 Internet Recovery 恢复它。

在这一部分，我们假设你已经看过 [入门指南](02-getting-started.md) 并准备好了 USB 驱动器。如果你还没有，现在就去做。

#### 禁用 Secure Boot

为了启动可启动的 USB 以及操作系统，必须禁用 Apple 的 Secure Boot。要禁用它，请执行以下操作：

1. 关闭你的 Mac
2. 将其开机，并_立即_按住 Command-R，直到看到加载屏幕出现
3. 选择你的用户，并在提示时输入密码
4. 进入恢复屏幕后，从菜单栏中选择 **Utilities > Startup Security Utility**
5. 在提示进行身份验证时输入你的密码
6. 从 Secure Boot 选项中选择 "No Security"
7. 从 External Boot 选项中选择 "Allow booting from external or removable media"

#### 开始安装

1. 插入 USB 驱动器
2. 重启你的 Mac，并_立即_按住 Option，直到看到启动设备屏幕
3. 选择橙色的 EFI Boot 设备
4. 按照[正常方式继续安装](02-getting-started.md)

安装程序会检测 Mac 硬件并自动应用所需的修复：Broadcom Wi-Fi 驱动程序和固件、需要它的 MacBook 机型上的 SPI 键盘驱动程序，以及这些相同机型的 NVMe 挂起修复。

### 已知限制

社区成员一直在努力寻找解决这些难题的方案，所以如果这些问题对你有影响，请加入我们 [Discord](https://discord.gg/tXFUdasqhY) 中的 #omarchy-on-other 频道，看看是否有最新的解决方法。

#### 配备 T1 芯片的设备

Apple T1 芯片于 2016 年末推出，专用于配备 Touch Bar 的第一代 MacBook Pro 机型。
- MacBook Pro 13 英寸（2016，两个 Thunderbolt 3 端口）– 型号：A1706
- MacBook Pro 13 英寸（2016，四个 Thunderbolt 3 端口）– 型号：A1708
- MacBook Pro 15 英寸（2016）– 型号：A1707

#### 已知问题

- Touch Bar 无法使用
- 声音无法使用

#### 配备 T2 芯片的设备

Apple T2 Security Chip 于 2017 年推出。随着 2020 年起向 Apple silicon（M 系列芯片）过渡，T2 芯片已停产。

- iMac Pro (2017) – 型号：A1862
- MacBook Pro 13 英寸（2018，四个 Thunderbolt 3 端口）– 型号：A1989
- MacBook Pro 15 英寸（2018）– 型号：A1990
- MacBook Air (Retina, 13 英寸，2018) – 型号：A1932
- Mac mini (2018) – 型号：A1998
- MacBook Pro 13 英寸（2019，两个 Thunderbolt 3 端口）– 型号：A2159
- MacBook Pro 13 英寸（2019，四个 Thunderbolt 3 端口）– 型号：A2178
- MacBook Pro 15 英寸（2019）– 型号：A1990
- iMac (Retina 5K, 27 英寸，2020) – 型号：A2115 (iMac20,1 和 iMac20,2)
- MacBook Pro 13 英寸（2020，两个 Thunderbolt 3 端口）– 型号：A2265
- MacBook Pro 15 英寸（2020）– 型号：A1990

在这些机型上，安装程序会自动设置打过补丁的 `linux-t2` 内核、T2 音频配置、Apple 的 Broadcom Wi-Fi/Bluetooth 固件，以及通过 `t2fanrd` 进行的风扇控制。Touch Bar 运行在内核内置的 Boot Camp 风格支持之上。

#### iMac Retina 5K (2017)

2017 款 27 英寸 iMac 没有 T2 芯片，所以安装程序会像设置其他 Intel Macs 一样设置它。

- iMac (Retina 5K, 27 英寸，2017) – 型号：A1419

#### 已知问题

- 显示屏无法以其原生 5120×2880 分辨率运行：该面板由两块拼接而成，标配驱动只能点亮其中一块
- 声音无法使用
- 亮度控制不起作用
- 睡眠会挂起机器；只有断电重启才能恢复

针对该机型的社区补丁程序修复了显示、声音和亮度问题：[omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3)。
