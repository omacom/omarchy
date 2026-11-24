# 从 Mac 或 Windows 转过来

如果你多年来一直用 macOS 或 Windows，你的手指知道上百件你的大脑早已忘了自己学过的事。本章就是翻译层：这些本能在 Omarchy 里都去了哪里。功能本身会在其他地方深入讲解——这里只是一张地图。

### Super 是一切的中心

你围绕 Cmd 或 Windows 键建立的所有肌肉记忆，都转移到一个键上：Super。它就是 PC 键盘上的 Windows 键，也是 Omarchy 中几乎每个快捷键的锚点。

你对 Spotlight 或 Raycast 或开始菜单的条件反射，变成了 `Super + Space`。这会打开 Omarchy 菜单，它能启动应用、更改设置、安装软件、捕获屏幕——几乎无所不能。开始输入即可筛选。`Super + Alt + Space` 会在一个网格中显示每个应用，就像 Launchpad 那样。参见[导航](04-navigation.md)。

### 没有桌面图标，Dock 只在浮动时出现

桌面上没有要排列的图标，平铺工作区上也没有 Dock——Dock 只出现在浮动工作区上（参见[导航](04-navigation.md)）。应用从快捷键启动（`Super + Return` 打开终端，`Super + Shift + Return` 打开浏览器，`Super + K` 打开所有已映射内容的列表），或者从菜单启动。唯一常驻的 UI 部分是[顶部栏](05-the-top-bar.md)，它承担了以前菜单栏、系统托盘和 Notification Center 为你做的事——而且上面几乎每个小部件在左键、右键和中键单击时都会有所动作。

### 窗口会自己就位

最大的思维转变是：你不用四处拖动窗口，也不用把它们吸附到屏幕的一半。打开一个窗口，它占据整个屏幕。再打开一个，它们就平分屏幕。你永远不需要从另一个窗口下面把某个窗口捞出来，因为窗口不会重叠。

当你真的需要一个浮动窗口时，`Super + T` 会把活动窗口移出平铺布局（再按一次则移回去）。但先真正给平铺布局一个机会——它是整套东西的核心。[导航](04-navigation.md)会带你了解它。

工作区会让你感到熟悉：它们就是 macOS Spaces 或 Windows 虚拟桌面，只不过你真的会用它们，因为 `Super + 1/2/3/4` 能直接跳转到某个工作区，`Super + Shift + 1/2/3/4` 能把活动窗口发送到那里。没有动画延迟，只有瞬间跳转。这意味着，如果你以前习惯那样，你甚至可能不再需要多台显示器了。

### 复制和粘贴就是能用

在 Mac 上，你到处都用 Cmd + C。在 Windows 上，你到处都用 Ctrl + C——除了终端，在那里它会杀掉你的程序。Omarchy 给你 `Super + C`、`Super + X` 和 `Super + V`，而且它们到处都能用，包括终端。不需要为 Shell 再学一套单独的条件反射。

Windows 用户们：你们的 Win + V 剪贴板历史现在位于 `Super + Ctrl + V`，而且它不仅保存文本，还保存图片。参见[统一剪贴板与历史](08-unified-clipboard-history.md)。

### 对照表

| 你下意识想找的 | 在 Omarchy 中 |
| ------------- | ---------- |
| Spotlight / Raycast / 开始菜单 | `Super + Space` — Omarchy 菜单 |
| AirDrop | LocalSend，通过 `Super + Ctrl + S` — 参见 [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 或 `Print Screen` — 参见[截图与录制](12-screenshots-recording.md) |
| Notification Center | `Super + Shift + Alt + ,` 上的通知历史 |
| Time Machine（用于系统） | 每次更新时自动创建[系统快照](47-system-snapshots.md) |
| App Store / 下载安装程序 | 菜单中的 _Install_，或 `omarchy pkg add` — 参见[其他软件包](29-other-packages.md) |
| System Settings / Control Panel | 菜单中的 _Setup_，它编辑纯文本配置文件 — 参见 [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files，位于 `Super + Shift + F` — 参见 [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome，位于 `Super + Shift + Return`；在 _Setup > Defaults > Browser_ 下选择另一个 — 参见[浏览器](23-browsers.md) |
| Preview / Photos | Omaview 用于图片、视频和音乐，Document Viewer 用于 PDF — 参见 [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain，位于 `Super + Shift + N`；在 _Setup > Defaults > Editor_ 下选择另一个 |

### 有些东西确实不同

很多设置都位于由你编辑的文本文件中，而不是让你一路点下去的面板中。这听起来很原始，直到你意识到这意味着每一处调整都可以被查看、复制到你的下一台机器上，并纳入版本控制。_Setup_ 菜单会把你直接送到正确的文件，并在你完成后重启任何需要重启的东西。

更新通过一个命令完成——_Update > Omarchy_——它更新 Omarchy 本身和系统上的每一个软件包，并事先创建一个快照。没有各个应用各自的更新程序在随机时刻烦你。参见[更新](30-updates.md)。

软件来自软件包管理器，而不是下载的安装程序。

而且当你关闭一个窗口时，应用真的会退出。不存在那种 macOS 式的悬置状态：程序没有窗口却还在继续运行。`Super + W`——或者 `Super + Q`，如果你带来的手指记忆是那个的话——就意味着彻底关闭。

### 在 Mac 硬件上

Omarchy 在 Intel Mac 上运行良好，在 M1、M2 和 M3 Mac 上则可使用面向 Apple Silicon 的 Omarchy。参见 [Mac support](44-mac-support.md)。而且键盘对你很友好：Omarchy 不会重新映射任何东西，Linux 将 Command 键视为 Super，所以 Super 就在 Cmd 一直所在的位置。你的拇指不会察觉这次迁移。

### 给它两周时间

这些本能的迁移比你想象的要快。快速浏览一遍[快捷键](07-hotkeys.md)章节，每当你想不起某个绑定时，就按 `Super + K`——它会向你显示所有绑定。这是你真正必须记住的唯一快捷键。
