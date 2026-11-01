# 入门

Omarchy 使用 ISO 安装。你可以选择全盘安装，它会接管整个驱动器；也可以选择空闲空间安装，它会把 Omarchy 放到驱动器上的未分配空间中——这就是与 Windows 或其他操作系统并存双系统启动的方式（见[双系统启动安装](50-dual-boot-install.md)——注意，你需要先在 Windows 中关闭 BitLocker）。无论哪种方式，安装默认都会启用全盘加密，而且全盘选项会擦除所选驱动器，所以在使用现有驱动器之前，务必做好备份！

先[下载 Omarchy ISO](https://omarchy.org/)，把它写入 U 盘（在 Windows 上使用 [Rufus](https://rufus.ie/)，在 Mac 上使用 [balenaEtcher](https://etcher.balena.io/)，在 Linux 上使用 [caligula](https://github.com/ifd3f/caligula)），然后从 U 盘启动。

_你必须在 BIOS 中关闭 Secure Boot 和/或 TPM。你必须关闭这些才能安装 Omarchy。它们是为 Windows 和与微软相关的 Linux 发行版设计的微软安全方案。_

然后回答配置问题，并像这样确认它们：

 ![install-config](images/install-config.webp)

然后选择一个驱动器进行安装，坐下来看安装表演吧。在最快的现代机器上，不到一分钟就能完成，但即使在较旧的计算机上，也不应该超过 5 分钟。

 ![install-done](images/install-done.webp)

现在你已经准备好使用 Omarchy 了！

### 使用有线或 2.4ghz 键盘！

全盘加密不允许你在启动时使用蓝牙键盘输入密码。就像你不能使用蓝牙键盘在 PC 上进入 BIOS 一样。你需要一把使用 2.4ghz 接收器或线缆的键盘（而且线缆在延迟方面也好得多！）。我个人非常喜欢 [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)！

### 为其他所有者安装

如果你正在为其他人设置一台机器——家人、新员工、买家——你不应该替他们回答个人问题。在安装程序的第一个界面（键盘选择）按 `Ctrl + C`，Omarchy 就会提供为其他所有者准备这台机器的选项。系统会立即安装，但所有个人设置——键盘布局、用户名、密码——都会推迟到机器首次启动时。驱动器默认仍然加密，新所有者在首次启动时选择的密码也会成为加密密码。（已经使用过的机器也可以无需重新安装就移交——见[重置计算机](48-security.md)。）

### 无人值守安装

ISO 也可以完全自行安装——无需键盘，无需向导——只要在第二个驱动器上向它提供配置即可。这就是把 Omarchy 作为 VM 和机群机器的基础镜像来使用的方式。见[无人值守安装](51-unattended-installs.md)。

### 无加密安装

Omarchy 默认带加密安装。对于任何可能丢失或被盗的计算机来说，这是安全、负责任的选择。你不会希望任何能接触到你的硬件的人都能获取你的数据！

但在特殊情况下，比如在受保护的计算机上远程安装 Omarchy，或者用于没有敏感数据的一次性安装，你可能希望在不加密的情况下安装。你可以在磁盘格式化确认时按 `Ctrl + C`，切换到无加密安装。

### 语言

Omarchy 支持 50 种语言——与 omarchy.org 相同的集合——默认是英语。要切换，打开 Omarchy 菜单，进入 _设置 > 语言_，或在终端中运行 `omarchy language <code>`（`omarchy language list` 会显示这些代码）。菜单、桌面和 Omarchy 自己的通知会立即更改语言，之后打开的每个应用程序也会跟随更改。已经打开的应用会在你重启它们后切换。

### 卡住时寻求帮助

如果你卡住了，你通常可以在[社区 Discord](https://omarchy.org/discord) 的 _#omarchy-help_ 频道找到愿意帮忙的人。
