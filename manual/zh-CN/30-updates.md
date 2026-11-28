# 更新

通过 Omarchy 菜单中的 _Update > Omarchy_（`Super + Space`），可以让 Omarchy 和你的软件包保持最新状态。

Omarchy 本身是通过 [Omarchy 软件包仓库](https://github.com/omacom-io/omarchy-pkgs) 中的常规 pacman 软件包安装的，因此更新会安装 [最新版 Omarchy 发布版本](https://github.com/omacom/omarchy/releases)，运行任何待处理的迁移以使你的系统与最新版本同步，并从 [Omarchy Arch 镜像](https://github.com/omacom-io/omarchy-mirror) 和 [AUR](https://aur.archlinux.org/) 更新所有系统软件包（如果你安装了任何 AUR 软件包）。

当有新版本发布时，时钟右侧会出现一个圆圈箭头图标。点击它，更新过程就会开始。

![update-available](images/update-available.webp)

### 四个通道

Omarchy 通过四个通道更新：stable、RC、edge 和 dev。新安装的系统从 stable 通道开始，该通道跟踪 [官方发布版本](https://github.com/omacom/omarchy/releases/)，以及比最新版本落后一个月的 [stable Omarchy Arch 镜像](https://github.com/omacom-io/omarchy-mirror)，这样我们就能在任何需要更改配置的新不兼容问题给用户带来麻烦之前发现它们。

但如果你想帮忙发现这些潜在问题，可以使用 edge 通道。这样你的 Omarchy 软件包将跟踪最新的开发构建，并且一有最新的 Arch 软件包可用，你就可以立即更新。只有当你经验丰富、熟悉 Linux，并且知道如何恢复出现问题的系统时，才应该这样做。

在任何新的主要版本发布之前，我们都会使用 RC 通道进行最终验证。如果你有兴趣帮忙做最后的打磨，欢迎来 Discord 的 #omarchy-release-candidates 频道一起交流。

最后是 dev 通道，它将 Omarchy 直接链接到 `~/omarchy` 中源代码的 git 检出，并与 edge 软件包结合使用。只有当你是经验丰富的 Linux 用户、正在直接开发 Omarchy，并且愿意承受系统损坏时，才应该使用此通道。

你可以使用 Omarchy 菜单中的 _Update > Channel_ 在通道之间切换（或在终端中使用 `omarchy channel set <stable|rc|edge|dev>`，使用 `omarchy channel current` 查看你当前所在的通道）。

### 切换内核

Omarchy 启动其自带的 `linux-omarchy` 内核，但你可以同时安装其他内核，例如 Arch 原装的 `linux` 内核，或者你正在测试的实验性构建。当内核多于一个时，Omarchy 菜单中的 _Update > Kernel_ 会列出它们，并在默认启动的那个旁边打勾。选择另一个，输入一次密码，下次重启后就会启动它。其他内核仍会保留在启动菜单中，所以如果新的默认内核给你带来了麻烦，你仍然可以手动选择一个。在终端中，使用 `omarchy kernel` 查看当前默认内核，使用 `omarchy kernel list` 查看已安装的内核，使用 `omarchy kernel set <kernel>` 进行切换。

### 固件更新

不只是你的软件包会过时。许多笔记本电脑和外围设备通过 Linux Vendor Firmware Service 提供 BIOS、SSD 和扩展坞固件，Omarchy 菜单中的 _Update > Firmware_ 会获取并安装你的硬件正在等待的任何固件。首次运行时，它会安装 `fwupd`。许多固件只能在重启期间写入，所以当系统要求重启时不要感到惊讶。

当你需要更改 BIOS 本身的设置时，在系统菜单（`Super + Escape`）中按住 `Alt`，_Reboot_ 就会变成 _Reboot to BIOS_，它会直接重启并进入固件设置，而无需在启动时抢按正确的按键。在终端中，命令是 `omarchy system firmware`。

### 关于直接使用 pacman/yay 更新的警告

如果你已经熟悉 Arch，可能会想自己直接运行 `pacman -Syu` 或 `yay -Syu`，但如果这样做，你会错过 Omarchy 随新软件包一起运行的快照、迁移和配置更新。这就是为什么 Omarchy 实际上会阻止直接的系统升级，并引导你改用 `omarchy update`。（如果你真的知道自己在做什么，防护机制会告诉你如何绕过它来进行单次事务。）

### 回滚有问题的更新

如果在更新后遇到任何问题，你可以将系统回滚到更新前拍摄的快照。只需重启，然后在启动加载菜单中选择开始更新之前创建的快照。

![bootloader](images/bootloader.webp)

如果你的配置文件以某种方式损坏了，你还可以在终端中使用 `omarchy reinstall` 执行 Omarchy 重新安装。这将重新安装所有默认的 Omarchy 软件包，将你置于 stable 通道（在 Apple Silicon 上为 edge），降级任何版本过新的软件包，并重置所有配置文件。请注意，这样做会覆盖你对 Omarchy 默认配置所做的所有用户配置更改！
