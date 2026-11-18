# 更新

通过 Omarchy 菜单（`Super + Space`）中的 _Update > Omarchy_，可以让 Omarchy 和你的软件包保持最新。

Omarchy 本身是通过 [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) 以常规 pacman 软件包的形式安装的，因此更新会安装[最新版 Omarchy 发布](https://github.com/omacom/omarchy/releases)，运行任何待处理的迁移，让你的系统与最新版本保持同步，并从 [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) 和 [AUR](https://aur.archlinux.org/) 更新所有系统软件包（如果你安装了任何 AUR 软件包）。

有新版本发布时，时钟右侧会出现一个圆圈箭头图标。点击它，更新过程就会开始。

![update-available](images/update-available.webp)

### 四个频道

Omarchy 通过四个频道进行更新：stable、RC、edge 和 dev。新安装默认使用 stable 频道，它跟踪[官方版本发布](https://github.com/omacom/omarchy/releases/)，以及比最新版本落后一个月的 [stable Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror)，这样我们就能在新的不兼容问题给人们造成麻烦之前，提前发现那些需要修改配置的问题。

但如果你愿意帮忙发现这些潜在问题，可以使用 edge 频道。它会让你的 Omarchy 软件包跟踪最新的开发构建，并让你在 Arch 软件包一发布时就能更新到最新版本。只有在你有丰富的 Linux 经验，并且知道如何恢复出问题的系统时，才应该这样做。

在任何新的重大版本发布之前，我们会使用 RC 频道进行最终验证。如果你有兴趣帮忙做最后的打磨，欢迎来 Discord 的 #omarchy-release-candidates 频道一起交流。

最后是 dev 频道，它将 Omarchy 直接关联到 `~/omarchy` 中源代码的 git 检出，并结合 edge 软件包使用。只有在你是有经验的 Linux 用户、正在直接开发 Omarchy，并且愿意容忍系统损坏时，才应该使用这个频道。

你可以通过 Omarchy 菜单中的 _Update > Channel_（或在终端中运行 `omarchy-channel-set`）在各个频道之间切换。

### 切换内核

Omarchy 使用自己的 `linux-omarchy` 内核启动，但你可以同时安装并保留其他内核，例如 Arch 原装的 `linux` 内核，或者你正在测试的实验性构建。当系统中有多个内核时，Omarchy 菜单中的 _Update > Kernel_ 会列出它们，并在默认启动的那个旁边打勾。选择另一个，输入一次密码，它就会在下次重启后启动。其他内核仍会保留在启动菜单中，所以如果新的默认内核给你带来麻烦，你仍然可以手动选择一个。在终端中，使用 `omarchy-kernel` 查看当前默认内核，使用 `omarchy-kernel list` 查看已安装的内核，使用 `omarchy-kernel set <kernel>` 进行切换。

### 固件更新

会过时的不只有你的软件包。许多笔记本电脑和外设通过 Linux Vendor Firmware Service 提供 BIOS、SSD 和扩展坞固件，Omarchy 菜单中的 _Update > Firmware_ 会获取并安装你的硬件正在等待的任何更新。第一次运行时，它会安装 `fwupd`。许多固件只能在重启期间写入，所以如果系统要求你重启，不要感到惊讶。

当你需要更改 BIOS 本身中的某项设置时，在系统菜单（`Super + Escape`）中按住 `Alt`，_Reboot_ 就会变成 _Reboot to BIOS_，它会直接重启进入固件设置界面，无需在启动时费劲去按对按键。在终端中，对应的命令是 `omarchy system firmware`。

### 关于直接使用 pacman/yay 更新的警告

如果你已经熟悉 Arch，你可能会忍不住自己直接运行 `pacman -Syu` 或 `yay -Syu`，但如果你这样做，你就会错过 Omarchy 在安装新软件包时一同运行的快照、迁移和配置更新。这就是为什么 Omarchy 实际上会阻止直接的系统升级，并引导你改用 `omarchy update`。（如果你真的知道自己在做什么，防护机制会告诉你如何绕过它来进行单次事务。）

### 回滚有问题的更新

如果你在更新后遇到任何问题，你可以将系统回滚到更新前拍摄的快照。只需重启，然后在启动加载菜单中选择你开始更新之前的那份快照。

![bootloader](images/bootloader.webp)

如果你的配置文件不知为何已损坏，你也可以在终端中使用 `omarchy reinstall` 执行 Omarchy 重新安装。这将重新安装所有默认的 Omarchy 软件包，将你切换到 stable 并降级任何过新的软件包，并重置所有配置文件。请注意，这样做会覆盖你对 Omarchy 默认配置所做的所有用户配置更改！
