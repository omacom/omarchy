# 入门指南

Omarchy 使用 ISO 进行安装。你可以选择全盘安装，它会占用整个驱动器；也可以选择空闲空间安装，它会将 Omarchy 安装到驱动器上未分配的空间中——这就是与 Windows 或其他操作系统双启动的方法（请参阅[双启动安装](50-dual-boot-install.md)——请注意，你需要先在 Windows 中关闭 BitLocker）。无论哪种方式，安装默认都启用全盘加密，而全盘选项会擦除所选驱动器，所以在使用现有驱动器之前，一定要先做好备份！

先[下载 Omarchy ISO](https://omarchy.org/)，将其写入 U 盘（在 Mac/Windows 上使用 [balenaEtcher](https://etcher.balena.io/)，在 Linux 上使用 [caligula](https://github.com/ifd3f/caligula)），然后从 U 盘启动。

_你必须在 BIOS 中关闭 Secure Boot 和/或 TPM。你必须关闭这些功能才能安装 Omarchy。它们是 Microsoft 为 Windows 和与 Microsoft 相关的 Linux 发行版设计的安全方案。_

然后回答配置问题，并按如下方式确认：

 ![install-config](images/install-config.webp)

然后为安装选择一个驱动器，坐下来观看安装过程。在最快的现代机器上，不到一分钟就能完成，但在较旧的计算机上也不应该超过 5 分钟。

 ![install-done](images/install-done.webp)

现在你已经准备好开始使用 Omarchy 了！

### 使用有线或 2.4ghz 键盘！

全盘加密不允许你在启动时使用蓝牙键盘输入密码。就像你无法在 PC 上使用蓝牙键盘进入 BIOS 一样。你需要一个使用 2.4ghz 接收器或有线连接的键盘（无论如何，有线连接在延迟方面要好得多！）。我个人非常喜欢 [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)！

### 为另一位所有者安装

如果你正在为其他人设置机器——家人、新员工、买家——你不应该替他们回答个人问题。在安装程序的第一个界面（键盘选择）按下 `Ctrl + C`，Omarchy 就会改为提供为另一位所有者准备机器的选项。系统会立即安装，但所有个人设置——键盘布局、用户名、密码——都会推迟到机器首次启动时再进行。驱动器默认仍然加密，新所有者在首次启动时选择的密码也会成为加密密码。（一台你已经使用过的机器也可以无需重新安装就移交——请参阅[重置计算机](48-security.md)。）

### 无人值守安装

当通过第二个驱动器向 ISO 提供其配置时，ISO 也可以完全自行安装——无需键盘，无需向导。这就是将 Omarchy 用作 VM 和批量部署机器的基础镜像的方法。请参阅[无人值守安装](51-unattended-installs.md)。

### 无加密安装

Omarchy 默认带加密安装。对于任何可能丢失或被盗的计算机来说，这是安全、负责任的选择。你不想让任何能够接触到你硬件的人都能获取你的数据！

但在特殊情况下，比如在受保护的计算机上远程安装 Omarchy，或者进行不含敏感数据的一次性安装，你可能想在不加密的情况下安装。你可以在磁盘格式化确认界面按下 `Ctrl + C`，切换到无加密安装。

### 语言

Omarchy 支持 50 种语言——与 omarchy.org 相同的集合——默认语言为英语。要切换语言，请打开 Omarchy 菜单并前往 _设置 > 语言_，或在终端中运行 `omarchy language <code>`（`omarchy language list` 会显示语言代码）。菜单、桌面和 Omarchy 自身的通知会立即更改语言，你之后打开的每个应用程序也会跟随更改。已经打开的应用程序会在你重启它们后切换。

### 卡住时获取帮助

如果你卡住了，通常可以在[社区 Discord](https://omarchy.org/discord) 的 _#omarchy-help_ 频道中找到愿意帮助你的人。
