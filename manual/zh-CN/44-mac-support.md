# Mac 支持

Omarchy 内置支持 **Intel Mac**。目前有几个已知的限制，但只要你了解这些限制并能接受，你就可以通过安装 Omarchy 为你的旧 Mac 注入新的活力。

请注意，目前还不直接支持在 M 系列 Mac 上安装。你可以在我们的 [Discord](https://discord.gg/tXFUdasqhY) 的 #omarchy-on-other 频道中了解更多关于其状态的信息。

在一次简单测试中，仅仅安装 Omarchy，我们在一台 2019 年的 MacBook Pro 上就获得了 36% 的性能提升。

 ![macbook-omarchy](images/macbook-omarchy.webp)

### 在 Mac 上安装 Omarchy

Omarchy 目前只支持作为**唯一**已安装的操作系统。在安装过程中，硬盘将被擦除，MacOS 将不再可启动。

如果需要，你仍然可以稍后通过 Internet Recovery 将其恢复。

在此部分中，我们假设你已经查看了[入门指南](02-getting-started.md)并备好了 USB 驱动器。如果还没有，现在就去准备。

#### 禁用安全启动

为了能够从可启动的 USB 以及操作系统启动，有必要禁用 Apple 的安全启动。要禁用它，请执行以下操作：

1. 关闭你的 Mac
2. 打开它并 _立即_ 按住 Command-R，直到看到加载屏幕出现
3. 选择你的用户，如提示则输入你的密码
4. 进入恢复屏幕后，从菜单栏中选择 **Utilities > Startup Security Utility**
5. 在提示进行身份验证时输入你的密码
6. 从 Secure Boot 选项中选择 "No Security"
7. 从 External Boot 选项中选择 "Allow booting from external or removable media"

#### 开始安装

1. 插入 USB 驱动器
2. 重启你的 Mac 并 _立即_ 按住 Option，直到你看到一个启动设备屏幕
3. 选择橙色的 EFI Boot 设备
4. 按[正常方式进行安装](02-getting-started.md)

安装程序会检测 Mac 硬件并自动应用所需的修复：Broadcom Wi-Fi 驱动程序和固件、那些需要的 MacBook 机型上的 SPI 键盘驱动程序，以及为同样机型准备的 NVMe 挂起修复。

### 已知限制

社区成员不断致力于解决这些挑战，所以如果这些对你来说是问题，请加入我们的 [Discord](https://discord.gg/tXFUdasqhY) 中的 #omarchy-on-other 频道，看看是否有解决这些问题的最新方法。

#### 配备 T1 芯片的设备

Apple T1 芯片于 2016 年末推出，仅用于第一代带 Touch Bar 的 MacBook Pro 机型。
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### 已知问题

- Touch Bar 不工作
- 声音不工作

#### 配备 T2 芯片的设备

Apple T2 安全芯片于 2017 年推出。T2 芯片随向 Apple 芯片（M 系列芯片）的过渡从 2020 年开始停产。

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

在这些机型上，安装程序会自动设置打过补丁的 `linux-t2` 内核、T2 音频配置、Apple 的 Broadcom Wi-Fi/Bluetooth 固件，以及通过 `t2fanrd` 的风扇控制。Touch Bar 运行在内核内置的 Boot Camp 式支持上。
