# 更新

Omarchy 和你的软件包通过 Omarchy 菜单（`Super + Space`）中的 _更新 > Omarchy_ 保持最新。

Omarchy 本身以常规 pacman 软件包的形式从 [Omarchy 软件包仓库](https://github.com/omacom-io/omarchy-pkgs) 安装，因此更新会安装 [最新的 Omarchy 发行版](https://github.com/omacom/omarchy/releases)，运行任何待处理的迁移以使你的系统与最新版本保持同步，并从 [Omarchy Arch 镜像](https://github.com/omacom-io/omarchy-mirror) 和 [AUR](https://aur.archlinux.org/) 更新所有系统软件包（如果你安装了任何 AUR 软件包）。

当新发行版发布时，你的时钟右侧会出现一个圆形箭头图标。点击它，更新过程就会开始。

![update-available](images/update-available.webp)

### 四个渠道

Omarchy 沿四个渠道更新：stable、RC、edge 和 dev。新安装从 stable 渠道开始，该渠道跟踪[官方发行版](https://github.com/omacom/omarchy/releases/)，以及比最新版本落后一个月的 [stable Omarchy Arch 镜像](https://github.com/omacom-io/omarchy-mirror)，这样我们就能在任何需要更改配置的新不兼容问题给人们造成麻烦之前将其发现。

但如果你愿意帮忙发现这些潜在问题，你可以运行 edge 渠道。这会让你的 Omarchy 软件包跟踪最新的开发构建，并让你在最新的 Arch 软件包一可用时就能更新到它们。只有当你有丰富的 Linux 经验，并且知道如何恢复出现问题的系统时，你才应该这样做。

在任何新的主要发行版发布之前，我们都会使用 RC 渠道进行最终验证。如果你有兴趣帮忙做最后的打磨，欢迎来 Discord 上的 #omarchy-release-candidates 频道一起交流。

最后，还有 dev 渠道，它将 Omarchy 直接链接到 `~/omarchy` 中的源代码 git 检出，并结合 edge 软件包。只有当你是经验丰富的 Linux 用户、直接参与 Omarchy 的开发工作，并且愿意容忍系统损坏时，你才应该使用这个渠道。

你可以使用 Omarchy 菜单中的 _更新 > 渠道_（或在终端中使用 `omarchy-channel-set`）在各个渠道之间切换。

### 切换内核

Omarchy 启动其自有的 `linux-omarchy` 内核，但你可以在它旁边安装并保留其他内核，例如 Arch 原装的 `linux` 内核，或者你正在测试的实验性构建。当存在多个内核时，Omarchy 菜单中的 _更新 > 内核_ 会列出它们，并在默认启动的那个旁边打勾。选择另一个，输入一次密码，它就会在下次重启后启动。其他内核仍保留在启动菜单中，所以如果新的默认内核给你带来麻烦，你仍然可以手动选择一个。在终端中，用 `omarchy-kernel` 查看当前默认内核，用 `omarchy-kernel list` 查看已安装的内核，用 `omarchy-kernel set <kernel>` 进行切换。

### 固件更新

会过时的不只是你的软件包。许多笔记本电脑和外围设备会通过 Linux Vendor Firmware Service 推送 BIOS、SSD 和扩展坞固件，而 Omarchy 菜单中的 _更新 > 固件_ 会获取并安装你的硬件正在等待的任何固件。它会在你第一次运行它时安装 `fwupd`。很多固件只能在重启期间写入，所以如果它要求你重启，不要感到意外。

### 关于直接使用 pacman/yay 更新的警告

如果你已经熟悉 Arch，你可能会忍不住自己直接运行 `pacman -Syu` 或 `yay -Syu`，但如果你这样做，你就会错过 Omarchy 随新软件包一起运行的快照、迁移和配置更新。这就是为什么 Omarchy 实际上会阻止直接的系统升级，并指引你改用 `omarchy update`。（如果你真的知道自己在做什么，该防护机制会告诉你如何针对单次事务绕过它。）

### 回滚有问题的更新

如果你在执行更新后遇到任何问题，你可以将系统回滚到更新前拍摄的快照。只需重启，然后在启动加载菜单中选择你开始更新之前的快照。

![bootloader](images/bootloader.webp)

如果以某种方式你的配置文件已经损坏，你还可以在终端中使用 `omarchy reinstall` 执行一次 Omarchy 重装。这将重新安装所有默认的 Omarchy 软件包，把你置于 stable 渠道，降级任何过新的软件包，并重置所有配置文件。请注意，这样做会覆盖你对 Omarchy 默认设置所做的所有用户配置更改！
