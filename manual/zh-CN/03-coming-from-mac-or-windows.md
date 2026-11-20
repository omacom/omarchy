# 从 Mac 或 Windows 转过来

如果你已经在 macOS 或 Windows 上用了很多年，你的手指知道一百件你的大脑早就忘了自己学过的事情。这一章就是翻译层：那些本能在 Omarchy 里都去了哪里。具体功能在其他地方有深入介绍——这里只是一张地图。

### Super 是一切的中心

你围绕 Cmd 或 Windows 键建立的全部肌肉记忆，都转移到一个键上：Super。它就是 PC 键盘上的 Windows 键，也是 Omarchy 里几乎每一个快捷键的锚点。

你对 Spotlight、Raycast 或开始菜单的 reflex 变成了 `Super + Space`。它会打开 Omarchy 菜单，可以启动应用、更改设置、安装软件、截取屏幕——几乎什么都能做。开始输入即可筛选。`Super + Alt + Space` 会像 Launchpad 那样，在一个网格里显示每一个应用。参见[导航](04-navigation.md)。

### 没有桌面图标，dock 只在浮动时出现

桌面上没有要排列的图标，平铺工作区上也没有 dock——dock 只会出现在浮动工作区上（参见[导航](04-navigation.md)）。应用从快捷键启动（`Super + Return` 打开终端，`Super + Shift + Return` 打开浏览器，`Super + K` 显示所有已映射内容的列表），或从菜单启动。唯一常驻的 UI 是[顶部栏](05-the-top-bar.md)，它承担了以前菜单栏、系统托盘和 Notification Center 为你做的事情——而且上面几乎每个小部件在左键、右键和中键点击时都会做些什么。

### 窗口会自己找位置

最大的思维转变是：你不用拖动窗口，也不用把它们吸附到屏幕的一半。打开一个窗口，它就占满整个屏幕。再打开一个，它们就平分屏幕。你永远不用从另一个窗口下面把某个窗口捞出来，因为窗口不会重叠。

当你确实需要一个浮动窗口时，`Super + T` 会把当前窗口切换出平铺布局（也可以切回来）。但先给平铺一个真正的机会——它是整个系统的核心。[导航](04-navigation.md)会带你走一遍。

工作区会让你感到熟悉：它们就是 macOS 的 Spaces 或 Windows 的虚拟桌面，只不过你真的会用它们，因为 `Super + 1/2/3/4` 会直接跳到某一个，`Super + Shift + 1/2/3/4` 会把当前窗口送到那里。没有动画延迟，只有瞬间跳转。这意味着，如果你以前习惯那样做，你可能甚至不再需要多个显示器了。

### 复制和粘贴就是能直接用

在 Mac 上，你到处都用 Cmd + C。在 Windows 上，你到处都用 Ctrl + C——除了终端，在终端里它会杀掉你的程序。Omarchy 给你 `Super + C`、`Super + X` 和 `Super + V`，它们到处都能用，包括终端。你不用再为 shell 学一套单独的 reflex。

Windows 用户：你的 Win + V 剪贴板历史位于 `Super + Ctrl + V`，它除了文本还能保存图片。参见[统一剪贴板与历史](08-unified-clipboard-history.md)。

### 翻译表

| 你想找的是 | 在 Omarchy 里 |
| ------------- | ---------- |
| Spotlight / Raycast / 开始菜单 | `Super + Space` — Omarchy 菜单 |
| AirDrop | LocalSend，通过 `Super + Ctrl + S` — 参见 [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 或 `Print Screen` — 参见[截图与录屏](12-screenshots-recording.md) |
| Notification Center | `Super + Shift + Alt + ,` 上的通知历史 |
| Time Machine（用于系统） | 每次更新时自动创建[系统快照](47-system-snapshots.md) |
| App Store / 下载安装程序 | 菜单中的 _Install_，或 `omarchy pkg add` — 参见[其他软件包](29-other-packages.md) |
| 系统设置 / 控制面板 | 菜单中的 _Setup_，它会编辑纯文本配置文件 — 参见 [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files，位于 `Super + Shift + F` — 参见 [GUIs](22-guis.md) |
| Safari / Edge | `Super + Shift + Return` 上的 Google Chrome；在 _Setup > Defaults > Browser_ 下选择另一个 — 参见[浏览器](23-browsers.md) |
| Preview / Photos | Omaview 用于图片、视频和音乐，Document Viewer 用于 PDFs — 参见 [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain，位于 `Super + Shift + N`；在 _Setup > Defaults > Editor_ 下选择另一个 |

### 有些事情确实不一样

很多设置都放在你需要编辑的文本文件里，而不是你点来点去的面板里。这听起来很原始，直到你意识到这意味着每一处调整都能被看见、能复制到你的下一台机器上，还能放入版本控制。_Setup_ 菜单会直接把你送到正确的文件里，并在你完成后重启任何需要重启的东西。

更新通过一个命令完成——_Update > Omarchy_——它会更新 Omarchy 本身和系统上的每一个软件包，并事先创建一个快照。没有各个应用的更新程序在随机时刻烦你。参见[更新](30-updates.md)。

软件来自软件包管理器，而不是下载的安装程序。

当你关闭一个窗口时，应用真的会退出。没有那种 macOS 式的悬空状态：程序没有窗口了却还在运行。`Super + W`——或者 `Super + Q`，如果你带来的手指记忆是那个——就意味着彻底关闭。

### 在 Mac 硬件上

Omarchy 在 Intel Macs 上运行得很好——参见 [Mac 支持](44-mac-support.md)。而且键盘对你很友好：Omarchy 不会重映射任何东西，Linux 会把 Command 键当作 Super，所以 Super 就在 Cmd 一直所在的位置。你的拇指不会察觉这次搬家。

### 给它两周时间

这些本能转移得比你想的要快。把[快捷键](07-hotkeys.md)这一章快速看一遍，之后每当你想不起某个绑定时，就按 `Super + K`——它会把它们全都显示给你。那是你真正必须记住的唯一快捷键。
