# 系统睡眠

Omarchy 默认启用挂起，休眠则在设置好后启用，但如果你的机器在使用其中任何一个时出现问题，你可以把它们关闭。

在 NVIDIA GB10 机器上，例如 DGX Spark 和 ASUS Ascent GX10，挂起和休眠都是关闭的，NVIDIA 的 DGX OS 也是如此，因为睡眠在该硬件上尚未被证明能正常工作。ASUS Zenbook A16 (UX3607OA) 也是如此，它的挂起尚不能让芯片完全进入睡眠，可能会挂一整夜。那里不适用挂起切换和休眠设置。要重新开启睡眠，请用 `sudo rm` 删除 `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`；随后挂起会重新回到菜单中，休眠也可以像在其他机器上一样进行设置。运行 `sudo omarchy apply hardware --install-user "$USER"` 会把该文件放回去。

### 电源模式

在笔记本电脑上，Omarchy 会分别记住插电时和使用电池时的电源模式，并在你插上或拔下电源时在两者之间切换。开箱即用的情况下，这意味着使用交流电源时是性能模式，使用电池时是均衡模式。

你可以用 `omarchy powerprofiles list` 查看你的机器提供哪些模式，并用 `omarchy powerprofiles set autodetect power-saver` 设置你当前状态下想要使用的模式。要在不拔下任何东西的情况下设置另一种状态，请直接指明它：`omarchy powerprofiles set battery power-saver`。无论你选择哪个，下次进入该状态时都会恢复到那个模式。

### 切换挂起

你可以通过在终端运行 `omarchy toggle suspend` 来切换挂起。这只是显示/隐藏 _系统_（或 `Super + Esc`）下的那个选项，然后你就可以看看它在你的系统上是否始终能正常工作。如果不能，你可以用同一条命令再次把它隐藏起来。

### 切换休眠

你可以通过在终端运行 `omarchy hibernation setup` 来设置休眠（它在 Apple Silicon Mac 上不可用）。休眠会在你的启动驱动器上创建一个 /swap 子卷，其大小与你的物理 RAM 分配相同，所以请确保你有足够多的可用空间。在一台 32GB 的机器上，你始终需要为这个卷留出 32GB 以上的可用空间。休眠还需要默认的 Limine 引导加载程序。

设置好后，你会在 _系统_（或 `Super + Esc`）下看到休眠选项，然后你就可以看看它在你的系统上是否始终能正常工作。如果不能，你可以运行 `omarchy hibernation remove` 再次把它移除。
