# 更新

Omarchy 和你的软件包通过 Omarchy 菜单（`Super + Space`）中的 _更新 > Omarchy_ 保持最新。

Omarchy 本身从 [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) 作为常规 pacman 软件包安装，所以更新会安装[最新的 Omarchy 发布](https://github.com/omacom/omarchy/releases)，运行任何待处理的迁移以使你的系统与最新版本同步，并从 [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) 和 [AUR](https://aur.archlinux.org/) 更新所有系统软件包（如果你安装了任何 AUR 软件包的话）。

当新版本发布时，一个圆圈箭头图标会出现在你的时钟右侧。点击它，更新过程就会开始。

![update-available](images/update-available.webp)

### 四个通道

Omarchy 沿着四个通道更新：stable、RC、edge 和 dev。新安装从 stable 通道开始，它跟踪[官方发布](https://github.com/omacom/omarchy/releases/)，以及比最新版落后一个月的 [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror)，这样我们就可以在任何需要配置更改的新不兼容问题给人们带来麻烦之前发现它们。

但如果你想帮助发现这些潜在问题，你可以在 edge 通道上运行。这会让你的 Omarchy 软件包跟踪最新的开发构建，并让你在最新的 Arch 软件包可用时立即更新到它们。你只有在有 Linux 经验、并且知道如何恢复一个出问题的系统时才应该这样做。

在任何新的主要版本之前，我们将使用 RC 通道做最终验证。如果你有兴趣帮助完成最后的打磨，来 Discord 上的 #omarchy-release-candidates 聊聊。

最后，还有 dev 通道，它将 Omarchy 直接链接到 `~/omarchy` 中源代码的 git 检出，与 edge 软件包结合。你只有是经验丰富的 Linux 用户、直接在 Omarchy 上工作并愿意忍受破坏时，才应该使用这个通道。

你可以使用 Omarchy 菜单中的 _Update > Channel_（或终端中的 `omarchy-channel-set`）在通道之间切换。

### 固件更新

你的软件包并不是唯一会过时的东西。许多笔记本电脑和外设通过 Linux Vendor Firmware Service 发布 BIOS、SSD 和扩展坞固件，Omarchy 菜单中的 _Update > Firmware_ 将获取并安装你的硬件等待的任何内容。它在你第一次运行时安装 `fwupd`。很多固件只能在重启期间写入，所以被要求重启时，不要惊讶。

### 关于直接 pacman/yay 更新的警告

如果你已经熟悉 Arch，你可能会想自己直接运行 `pacman -Syu` 或 `yay -Syu`，但如果你这样做，你会错过 Omarchy 与新软件包一起运行的快照、迁移和配置更新。这就是为什么 Omarchy 实际上会阻止直接的系统升级并将你指向 `omarchy update`。（如果你真的知道你在做什么，保护程序会告诉你如何为单个事务绕过它。）

### 回滚不良更新

如果你在更新后遇到问题，你可以将你的系统回滚到更新前拍摄的快照。只需重启并在启动加载菜单中选择你开始更新之前的快照即可。

![bootloader](images/bootloader.webp)

如果你的配置文件以某种方式损坏了，你也可以使用终端中的 `omarchy reinstall` 执行 Omarchy 重新安装。这将重新安装所有默认的 Omarchy 软件包，将你置于 stable 上并将任何过新的软件包降级，并重置所有配置文件。请注意，这样做将覆盖你对 Omarchy 默认设置的所有用户配置更改！
