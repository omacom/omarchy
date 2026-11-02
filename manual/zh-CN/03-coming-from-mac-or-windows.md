# 来自 Mac 或 Windows

如果你在 macOS 或 Windows 上用了很多年，你的手指知道上百件大脑已经忘了自己学过的事情。本章就是翻译层：那些本能在 Omarchy 里去了哪里。具体功能在其他章节有深入讲解——这里只是一张地图。

### Super 是一切的中心

你围绕 Cmd 或 Windows 键建立的所有肌肉记忆，都转移到一个键上：Super。那就是 PC 键盘上的 Windows 键，它也是 Omarchy 里几乎每个快捷键的锚点。

你打开 Spotlight、Raycast 或开始菜单的 reflex 会变成 `Super + Space`。这会打开 Omarchy 菜单，它能启动应用、更改设置、安装软件、截取屏幕——几乎无所不能。开始输入即可筛选。`Super + Alt + Space` 会把所有应用显示在一个网格里，就像 Launchpad 那样。参见[导航](04-navigation.md)。

### 没有程序坞，也没有桌面图标

没有可以点击启动应用的东西，也没有要在桌面上排列的图标。应用通过快捷键启动（终端用 `Super + Return`，浏览器用 `Super + Shift + Return`，查看所有已映射内容的列表用 `Super + K`），或者通过菜单启动。唯一常驻的 UI 是[顶栏](05-the-top-bar.md)，它承担了以前菜单栏、系统托盘和 Notification Center 为你做的事情——而且它上面的几乎每个小部件都支持左键、右键和中键点击操作。

### 窗口会自己就位

最大的思维转变：你不用拖动窗口，也不用把它们贴靠到屏幕的某一半。打开一个窗口，它就占满整个屏幕。再打开第二个，它们就会平分屏幕。你永远不用从另一个窗口下面把某个窗口捞出来，因为窗口不会重叠。

当你确实需要一个浮动窗口时，`Super + T` 可以把当前窗口切换出平铺模式（再按一次切回来）。但请先认真给平铺一个机会——它是整套系统的核心。[导航](04-navigation.md)会带你了解它。

工作区会让你感到熟悉：它们就是 macOS Spaces 或 Windows 虚拟桌面，只不过你这次会真正用起来，因为 `Super + 1/2/3/4` 可以直接跳到某一个工作区，`Super + Shift + 1/2/3/4` 可以把当前窗口送过去。没有动画延迟，只有瞬间跳转。这意味着，如果你以前习惯用多台显示器，现在你可能甚至不再需要它们了。

### 复制和粘贴就是能用

在 Mac 上，你到处用 Cmd + C。在 Windows 上，你到处用 Ctrl + C——除了终端，在终端里它会杀掉你的程序。Omarchy 给你 `Super + C`、`Super + X` 和 `Super + V`，它们在任何地方都能用，包括终端。你不用再为 shell 单独学一套 reflex。

Windows 用户注意：你的 Win + V 剪贴板历史记录在 `Super + Ctrl + V` 上，它不仅能存文本，还能存图片。参见[统一剪贴板与历史记录](08-unified-clipboard-history.md)。

### 对照表

| 你习惯找的 | 在 Omarchy 中 |
| ------------- | ---------- |
| Spotlight / Raycast / 开始菜单 | `Super + Space`——Omarchy 菜单 |
| AirDrop | LocalSend，通过 `Super + Ctrl + S`——参见 [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 或 `Print Screen`——参见[截图与录屏](12-screenshots-recording.md) |
| Notification Center | 通知历史记录，`Super + Shift + Alt + ,` |
| Time Machine（用于系统） | 每次更新时自动创建[系统快照](47-system-snapshots.md) |
| App Store / 下载安装程序 | 菜单中的 _Install_，或 `omarchy pkg add`——参见[其他软件包](29-other-packages.md) |
| System Settings / Control Panel | 菜单中的 _Setup_，它编辑的是纯文本配置文件——参见 [dotfiles](31-dotfiles.md) |

### 有些事情确实不一样

很多设置都存放在你 직접 编辑的文本文件里，而不是靠点击面板来修改。听起来很原始，直到你意识到这意味着每个调整都能被看见、能复制到你的下一台机器上、能纳入版本控制。_Setup_ 菜单会直接把你带到正确的文件，并在你完成后重启所有需要重启的东西。

更新通过一条命令完成——_Update > Omarchy_——它会更新 Omarchy 本身和系统上的每个软件包，并先创建一个快照。没有各个应用的更新程序在随机时刻烦你。参见[更新](30-updates.md)。

软件来自软件包管理器，而不是下载的安装程序。

而且，当你关闭一个窗口时，应用真的会退出。没有 macOS 那种程序没有窗口却还在运行的悬置状态。`Super + W`——或者 `Super + Q`，如果你带来的手指记忆是这个——就意味着彻底关闭。

### 在 Mac 硬件上

Omarchy 在 Intel Mac 上运行良好——参见 [Mac 支持](44-mac-support.md)。而且键盘对你很友善：Omarchy 不会重映射任何按键，Linux 会把 Command 键当作 Super，所以 Super 就在 Cmd 一直所在的位置。你的拇指不会察觉到这次搬家。

### 给它两周时间

这些本能迁移过来的速度比你想象的要快。把[快捷键](07-hotkeys.md)这一章快速浏览一遍，之后每当你想不起某个绑定时，按 `Super + K`——它会把所有绑定都显示给你看。这是你唯一真正需要背下来的快捷键。
