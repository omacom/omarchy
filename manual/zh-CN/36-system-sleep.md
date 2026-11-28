# 系统睡眠

Omarchy 默认启用挂起，休眠则在设置完成后启用，但如果你的机器在使用其中任何一项时出现问题，你可以将它们关闭。

在 NVIDIA GB10 机器上，例如 DGX Spark 和 ASUS Ascent GX10，挂起和休眠处于关闭状态，这与 NVIDIA 的 DGX OS 相同，因为尚未证明睡眠功能能在该硬件上正常工作。挂起开关和休眠设置不适用于这些机器。要重新开启睡眠，请使用 `sudo rm` 删除 `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`；届时 Suspend 将重新出现在菜单中，休眠也可以像在其他机器上一样进行设置。运行 `sudo omarchy apply hardware --install-user "$USER"` 会将该文件恢复。

### 电源模式

在笔记本电脑上，Omarchy 会分别记住你接通电源和使用电池时的电源模式，并在插拔电源时在两者之间切换。开箱即用时，这意味着接通 AC 时使用 performance，使用电池时使用 balanced。

你可以使用 `omarchy powerprofiles list` 查看你的机器提供哪些模式，并使用 `omarchy powerprofiles set autodetect power-saver` 为你当前所处的状态设置想要的模式。要在不拔掉任何电源的情况下设置另一种状态，请直接指定它：`omarchy powerprofiles set battery power-saver`。无论你选择哪一个，下次进入该状态时都会恢复为该模式。

### 切换挂起

通过在终端中运行 `omarchy toggle suspend` 来切换挂起。这只会显示/隐藏 _System_（或 `Super + Esc`）下的选项，然后你可以查看它在你的系统上是否始终能正常工作。如果不能，你可以用同一命令再次将其隐藏。

### 切换休眠

通过在终端中运行 `omarchy hibernation setup` 来设置休眠（在 Apple Silicon Macs 上不可用）。休眠会在你的启动驱动器上创建一个与你的物理 RAM 大小相同的 /swap 子卷，因此请确保你有充足的剩余空间。在一台 32GB 的机器上，你始终需要为此卷预留 32GB+ 的可用空间。休眠还要求使用默认的 Limine 引导加载程序。

设置完成后，你会在 _System_（或 `Super + Esc`）下看到休眠选项，然后你可以查看它在你的系统上是否始终能正常工作。如果不能，你可以运行 `omarchy hibernation remove` 再次将其移除。
