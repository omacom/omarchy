# 系统睡眠

Omarchy 默认启用挂起和休眠，但如果你的机器在使用其中任一功能时出现问题，你可以将其关闭。

### 电源配置文件

在笔记本电脑上，Omarchy 会分别记住插入电源时和使用电池时的电源配置文件，并随插拔在两者之间切换。开箱即用意味着交流电时使用性能模式，电池时使用平衡模式。

你可以用 `omarchy powerprofiles list` 查看你的机器提供了哪些选项，并用 `omarchy powerprofiles set autodetect power-saver` 设置当前状态下你想要的那个。要设置另一个状态而不拔掉任何东西，可以直接点名：`omarchy powerprofiles set battery power-saver`。无论你选什么，下次处于该状态时你都会得到它。

### 开关挂起

你通过在终端中运行 `omarchy toggle suspend` 来开关挂起。这只是显示/隐藏 _系统_ 下的选项（或 `Super + Esc`），然后你可以看看它在你的系统上是否能稳定工作。如果不能，你可以用相同的命令再次隐藏它。

### 开关休眠

你通过在终端中运行 `omarchy hibernation setup` 来设置休眠。休眠会在你的启动盘上创建一个大小与你的物理内存分配相等的 /swap 子卷，所以请确保你有充足的余量。在 32GB 的机器上，你将始终需要 32GB 以上的空闲空间用于此卷。休眠还需要默认的 Limine 引导程序。

设置完成后，你会在 _系统_ 下（或 `Super + Esc`）看到休眠选项，然后你可以看看它在你的系统上是否能稳定工作。如果不能，你可以通过运行 `omarchy hibernation remove` 再次移除它。
