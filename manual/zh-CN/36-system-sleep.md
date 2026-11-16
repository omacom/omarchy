# 系统休眠

Omarchy 默认启用挂起和休眠，但如果你的机器在这两者中的任何一个上遇到问题，你可以把它们关闭。

在 NVIDIA GB10 机器上，例如 DGX Spark 和 ASUS Ascent GX10，挂起和休眠是关闭的，正如 NVIDIA 的 DGX OS 中一样，因为尚未证明休眠能在该硬件上工作。ASUS Zenbook A16 (UX3607OA) 也是如此，其挂起尚不能让芯片完全进入休眠，可能会整夜挂起。挂起开关和休眠设置在那里不适用。要重新开启休眠，使用 `sudo rm` 删除 `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`；随后挂起会回到菜单中，休眠也可以像在其他机器上一样设置。运行 `sudo omarchy apply hardware --install-user "$USER"` 会把该文件放回去。

### 电源配置文件

在笔记本电脑上，Omarchy 会分别记住接通电源和用电池运行时的电源配置文件，并在你插拔电源时在这两者之间切换。开箱即用意味着交流电源下使用 performance，电池下使用 balanced。

你可以使用 `omarchy powerprofiles list` 查看你的机器提供了什么，并使用 `omarchy powerprofiles set autodetect power-saver` 为你当前所处的状态设置你想要的那个。要在不拔掉任何东西的情况下设置另一个状态，直接指名它：`omarchy powerprofiles set battery power-saver`。无论你选哪个，下次你处于那个状态时你都会回到它。

### 切换挂起

你通过从终端运行 `omarchy toggle suspend` 来切换挂起。那只是在 _System_（或 `Super + Esc`）下显示/隐藏该选项，然后你就可以看看它在你的系统上是否始终工作。如果不行，你可以用同一个命令再次把它隐藏起来。

### 切换休眠

你通过从终端运行 `omarchy hibernation setup` 来设置休眠。休眠会在你的启动驱动器上创建一个大小与你的物理 RAM 分配相同的 /swap 子卷，所以确保你有大量的空闲空间。在 32GB 的机器上，你将始终需要为这个卷留出 32GB+ 的空闲空间。休眠还需要默认的 Limine bootloader。

设置好后，你将在 _System_（或 `Super + Esc`）下看到休眠选项，然后你就可以看看它在你的系统上是否始终工作。如果不行，你可以通过运行 `omarchy hibernation remove` 再次删除它。
