# 开始使用

Omarchy 使用 ISO 安装。你可以选择全盘安装，也就是接管整个硬盘；也可以选择空闲空间安装，也就是把 Omarchy 装到硬盘上的未分配空间里——这就是与 Windows 或其他操作系统双系统启动的方式（参见[双系统安装](50-dual-boot-install.md)——请注意，你需要先在 Windows 中关闭 BitLocker）。无论哪种方式，安装默认都会启用全盘加密，而且全盘选项会清空所选硬盘，所以在已有硬盘上安装之前，一定要先做好备份！

先[下载 Omarchy ISO](https://omarchy.org/)，把它写入 U 盘（在 Windows 上使用 [Rufus](https://rufus.ie/)，在 Mac 上使用 [balenaEtcher](https://etcher.balena.io/)，在 Linux 上使用 [caligula](https://github.com/ifd3f/caligula)），然后从 U 盘启动。

_你必须在 BIOS 中关闭 Secure Boot 和/或 TPM。你必须关闭这些才能安装 Omarchy。它们是 Microsoft 为 Windows 和与 Microsoft 相关的 Linux 发行版设计的安全方案。_

然后回答配置问题，并像这样确认：

 ![install-config](images/install-config.webp)

然后选择一个安装硬盘，坐下来看安装表演就行了。在最快的现代机器上，不到一分钟就能完成，但即使在较旧的电脑上，也不应超过 5 分钟。

 ![install-done](images/install-done.webp)

现在你已经准备好使用 Omarchy 了！

### 使用有线键盘或 2.4ghz 键盘！

全盘加密不允许你在启动时用蓝牙键盘输入密码。就像你不能在 PC 上用蓝牙键盘进入 BIOS 一样。你需要一把使用 2.4ghz 接收器或线缆的键盘（而且线缆在延迟方面也好得多！）。我个人非常喜欢 [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)！

### 为另一位所有者安装

如果你是在为别人——家人、新员工、买家——设置一台机器，你不应该替他们回答个人问题。在安装程序的第一个界面（键盘选择）按 `Ctrl + C`，Omarchy 就会改为提供为另一位所有者准备这台机器的选项。系统会立即安装，但所有个人设置——键盘布局、用户名、密码——都会推迟到机器首次启动时再进行。硬盘默认仍然加密，而且新所有者在首次启动时设置的密码也会成为加密密码。（一台你已经用过的机器也可以无需重装就移交——参见[重置电脑](48-security.md)。）

### 无人值守安装

当把配置放在第二个硬盘上交给 ISO 时，它也可以完全自行安装——不需要键盘，不需要向导。这是把 Omarchy 当作 VM 和机群机器基础镜像的方式。参见[无人值守安装](51-unattended-installs.md)。

### 无加密安装

Omarchy 默认带加密安装。对于任何可能丢失或被盗的电脑来说，这是安全、负责任的选择。你肯定不希望任何能接触到你硬件的人都能拿到你的数据！

但在特殊情况下，比如在受保护的电脑上远程安装 Omarchy，或者用于没有敏感数据的一次性安装，你可能想不加密安装。你可以在硬盘格式化确认时按 `Ctrl + C`，切换到无加密安装。

### 语言

Omarchy 支持 50 种语言——与 omarchy.org 相同的语言集合——且默认是 English。要切换，请打开 Omarchy 菜单并前往 _Setup > Region > Language_，或在终端中运行 `omarchy language <code>`（`omarchy language list` 会显示代码）。菜单、桌面和 Omarchy 自己的通知会立即更改语言，之后你打开的每个应用程序也会跟随更改。已经打开的应用程序会在你重启它们后切换。

如果想保留语言，但让日期、时间、数字、货币、单位和纸张尺寸按另一个地区的方式书写（比如使用欧洲日期和 24 小时制的 English），请在 _Setup > Region > Formats_ 下选择一个地区，那里每个选项都会显示一个示例，或运行 `omarchy region formats <code>`（`omarchy region formats list` 会显示代码）。_Same as language_ 会回到该语言自身的格式。与切换语言一样，它会影响你之后打开的应用程序。

### 卡住时寻求帮助

如果你卡住了，通常可以在[社区 Discord](https://omarchy.org/discord) 的 _#omarchy-help_ 频道找到愿意帮忙的人。
