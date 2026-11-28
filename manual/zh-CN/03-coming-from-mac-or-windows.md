# 从 Mac 或 Windows 迁移而来

如果你多年来一直使用 macOS 或 Windows，你的手指知道一百件你的大脑已经忘了自己曾经学会的事情。本章就是翻译层：那些本能在 Omarchy 中何去何从。功能本身在其他地方有深入介绍——这里只是一张地图。

### Super 是一切的中心

你在 Cmd 或 Windows 键周围建立的所有肌肉记忆，都转移到一个键上：Super。那就是 PC 键盘上的 Windows 键，也是 Omarchy 中几乎所有快捷键的锚点。

你对 Spotlight、Raycast 或开始菜单的条件反射，变成了 `Super + Space`。这会打开 Omarchy 菜单，它能启动应用、更改设置、安装软件、截取屏幕——几乎无所不能。开始输入即可筛选。`Super + Alt + Space` 会在一个网格中显示所有应用，就像 Launchpad 那样。参阅[导航](04-navigation.md)。

### 没有桌面图标，dock 也不会挡路

没有需要摆放在桌面上的图标，dock 一旦某个工作区有了窗口就会隐藏，直到你把指针推到它所在的屏幕边缘，默认是底部边缘，除非你把它移走（参阅[导航](04-navigation.md)）。应用通过快捷键启动（`Super + Return` 打开终端，`Super + Shift + Return` 打开浏览器，`Super + K` 打开所有已映射内容的列表），或从菜单启动。唯一常驻的 UI 是[顶栏](05-the-top-bar.md)，它涵盖了以前菜单栏、系统托盘和 Notification Center 为你做的事——而且它上面的几乎每个小部件在左键、右键和中键点击时都会做些事情。

### 窗口会自己就位

最大的思维转变是：你不用拖动窗口，也不用把它们贴靠到屏幕的一半。打开一个窗口，它会占据整个屏幕。打开第二个，它们会平分屏幕。你永远不用从另一个窗口下面把某个窗口捞出来，因为窗口不会重叠。

当你确实需要一个浮动窗口时，`Super + T` 会把当前活动窗口切出平铺布局（再切回去）。但先给平铺一个真正的机会——它是整个系统的核心。[导航](04-navigation.md)会带你了解它。

工作区会让你觉得熟悉：它们就是 macOS Spaces 或 Windows 虚拟桌面，只不过你真的会去用它们，因为 `Super + 1/2/3/4` 会直接跳到某个工作区，`Super + Shift + 1/2/3/4` 会把当前活动窗口送到那里。没有动画延迟，只有瞬间跳转。这意味着，如果你以前习惯用多台显示器，你现在可能甚至不再需要它们了。

### 复制和粘贴就是能用

在 Mac 上，你到处用 Cmd + C。在 Windows 上，你到处用 Ctrl + C——除了终端，在那里它会杀掉你的程序。Omarchy 给你 `Super + C`、`Super + X` 和 `Super + V`，它们到处都能用，包括终端。你不用为 shell 再学一套单独的条件反射。

Windows 用户：你的 Win + V 剪贴板历史位于 `Super + Ctrl + V`，它除了文本还能保存图片。参阅[统一剪贴板与历史](08-unified-clipboard-history.md)。

### 对照表

| 你习惯找的 | 在 Omarchy 中 |
| ------------- | ---------- |
| Spotlight / Raycast / 开始菜单 | `Super + Space` — Omarchy 菜单 |
| AirDrop | LocalSend，通过 `Super + Ctrl + S` — 参阅 [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 或 `Print Screen` — 参阅[截图与录屏](12-screenshots-recording.md) |
| Notification Center | `Super + Shift + Alt + ,` 上的通知历史 |
| Time Machine（针对系统） | 每次更新时自动创建[系统快照](47-system-snapshots.md) |
| App Store / 下载安装程序 | 菜单中的 _Install_，或 `omarchy pkg add` — 参阅[其他软件包](29-other-packages.md) |
| 系统设置 / 控制面板 | 菜单中的 _Setup_，它会编辑纯文本配置文件 — 参阅 [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files，在 `Super + Shift + F` 上 — 参阅 [GUI](22-guis.md) |
| Safari / Edge | Google Chrome 在 `Super + Shift + Return` 上；在 _Setup > Defaults > Browser_ 下选择另一个 — 参阅[浏览器](23-browsers.md) |
| 预览 / 照片 | Omaview 用于图片、视频和音乐，Document Viewer 用于 PDFs — 参阅 [GUI](22-guis.md) |
| TextEdit / Notepad | Plain，在 `Super + Shift + N` 上；在 _Setup > Defaults > Editor_ 下选择另一个 |

### 有些事情确实不同

很多设置位于你编辑的文本文件中，而不是你点击的面板中。这听起来很原始，直到你意识到这意味着每个调整都能被看见、能复制到你的下一台机器上、能纳入版本控制。_Setup_ 菜单会把你直接带到正确的文件，并在你完成后重启任何需要重启的东西。

更新通过一个命令完成——_Update > Omarchy_——它会更新 Omarchy 本身和系统上的每个软件包，并先创建一个快照。没有各个应用的更新程序在随机时刻烦你。参阅[更新](30-updates.md)。

软件来自软件包管理器，而不是来自下载的安装程序。

而且当你关闭一个窗口时，应用真的会退出。没有那种 macOS 的悬置状态，程序在没有窗口的情况下继续运行。`Super + W`——或者 `Super + Q`，如果你带来的手指记忆是那个——就意味着消失。

### 在 Mac 硬件上

Omarchy 在 Intel Macs 上运行良好，在配备 Omarchy for Apple Silicon 的 M1、M2 和 M3 Macs 上也运行良好。参阅 [Mac 支持](44-mac-support.md)。而且键盘对你很友善：Omarchy 不会重映射任何东西，Linux 会把 Command 键当作 Super，所以 Super 就位于 Cmd 一直所在的位置。你的拇指不会察觉这次迁移。

### 给它两周时间

这些本能转移得比你想象的要快。把[快捷键](07-hotkeys.md)这一章略读一遍，每当你想不起某个绑定时，按 `Super + K`——它会把它们全显示出来。那是你真正必须记住的唯一快捷键。
