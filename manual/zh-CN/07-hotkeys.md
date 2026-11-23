# 快捷键

你可以用 `Super + K` 查看所有主要键盘绑定（Tmux 绑定用 `Super + Alt + K`，Herdr 绑定用 `Super + Ctrl + K`）。

## 快捷键的布局方式

每个快捷键都位于一个平面上，由其修饰键决定，每个平面只有一个用途。这就是快捷键不会混在一起的原因，也意味着你通常能猜出某个东西在哪里。

| 平面 | 存放什么 | 示例 |
| --- | --- | --- |
| `Super + key` | 系统：窗口、工作区、布局和核心菜单 | `Super + Space` Omarchy 菜单，`Super + W` 关闭窗口，`Super + F` 全屏 |
| `Super + Shift + key` | 应用 | `Super + Shift + B` 浏览器，`Super + Shift + E` 邮件，`Super + Shift + N` 编辑器 |
| `Super + Ctrl + key` | 面板和系统菜单 | `Super + Ctrl + A` 音频，`Super + Ctrl + N` 网络，`Super + Ctrl + C` 捕获菜单 |
| `Super + Ctrl + Alt + key` | 快速操作和通知 | `Super + Ctrl + Alt + T` 显示时间，`Super + Ctrl + Alt + B` 电池，`Super + Ctrl + Alt + C` 截屏 |

给快捷键加上 `Alt` 会得到同一事物的变体，绝不会是无关的东西：

- `Super + Shift + B` 打开浏览器；`Super + Shift + Alt + B` 打开隐私窗口
- `Super + Shift + E` 打开邮件；`Super + Shift + Alt + E` 新建一封邮件
- `Super + F` 进入全屏；`Super + Alt + F` 进入全宽
- `Super + Ctrl + C` 打开捕获菜单；`Super + Ctrl + Alt + C` 跳过菜单并截屏

添加快捷键时：

1. 先根据它的用途选平面，再选按键。
2. 不要为了腾地方而移动现有的快捷键。在正确的平面上找一个空闲的按键。
3. 只用 `Alt` 表示不带它的快捷键的变体。

有几个快捷键因为方便而打破这些规则。`Shift` 加方向键或 `Tab` 是移动或反向，而不是打开应用，而 `Print`、媒体键、`Alt + Tab` 和 `Ctrl + Alt + Del` 的行为与其它任何地方一样。它们是例外，不是可照抄的模式。

如果默认设置不适合你（比如你想像在 Windows 上那样用 `Super + Shift + S` 截屏），就在 `~/.config/hypr/bindings.lua` 中重新绑定它。

## 导航

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy 菜单（应用和其它一切）    |
| `Super + Alt + Space` | 应用网格 |
| `Super + Escape` | 系统菜单（挂起、重启等）  |
| `Super + Ctrl + L` | 锁定计算机 |
| `Super + W` or `Super + Q` | 关闭窗口             |
| `Ctrl + Alt + Del` | 关闭所有窗口 |
| `Super + K` | 显示所有快捷键 |
| `Super + Alt + K` | 显示 tmux 快捷键 |
| `Super + Ctrl + K` | 显示 herdr 快捷键 |
| `Super + M` | 将窗口最小化到程序坞 |
| `Super + T`               | 在平铺/浮动之间切换窗口             |
| `Super + J` | 切换窗口位置（水平/垂直） |
| `Super + O`               | 切换窗口弹出到 sticky'n'floating |
| `Super + L`               | 在 dwindle、scrolling 和 floating 布局之间循环 |
| `Super + Alt + L`         | 反向循环布局 |
| `Super + P`               | 切换伪窗口样式（natural 对 stretch） |
| `Super + F`                 | 进入全屏              |
| `Super + Alt + F`                 | 进入全宽              |
| `Super + Ctrl + F`                 | 在窗口内进入全屏              |
| `Super + 1…9/0`         | 跳转到聚焦显示器上的指定工作区（0 为 10） |
| `Super + Tab` | 跳转到聚焦显示器上的下一个工作区 |
| `Super + Shift + Tab` | 跳转到聚焦显示器上的上一个工作区 |
| `Super + Ctrl + Tab` | 跳转到聚焦显示器上先前的工作区 |
| `Super + Shift + 1…9/0` | 将窗口移到聚焦显示器上的工作区 |
| `Super + Shift + Alt + 1…9/0` | 将窗口移到聚焦显示器上的工作区，但不跟随过去 |
| `Super + S` | 切换完整 scratchpad |
| `Super + Alt + S` | 将窗口移到完整 scratchpad |
| `Super + the key above Tab` (grave on US layouts) | 切换 Quake 控制台 |
| `Super + Shift + the key above Tab` (grave on US layouts) | 将窗口移到 Quake 控制台 |
| `Super + Shift + Ctrl + Arrows` | 将窗口移到该方向的显示器 |
| `Super + Shift + Alt + Arrows` | 将工作区移到该方向的显示器 |
| `Super + Arrow`  | 将焦点移到方向键方向的窗口，在屏幕边缘时跨到该侧的显示器 |
| `Super + Shift + Arrow`  | 与方向键方向的另一个窗口交换，包括该侧显示器上的窗口 |
| `Super + Minus` | 向左扩展窗口 |
| `Super + Equal` | 向左缩小窗口 |
| `Super + Shift + Minus` | 向上缩小窗口 |
| `Super + Shift + Equal` | 向下扩展窗口 |
| `Super + Alt + Minus/Equal` | 以更小步幅进行同样的调整大小 |
| `Super + Ctrl + Minus/Equal` | 以更大步幅进行同样的调整大小 |
| `Super + Alt + Home` | 保存窗口宽度 |
| `Super + Home` | 恢复已保存的窗口宽度 |
| `Super + Left Mouse` | 拖动窗口 |
| `Super + Right Mouse` | 调整窗口大小 |
| `Super + Scroll Wheel` | 滚动浏览聚焦显示器上的工作区 |
| `Super + G`               | 切换窗口分组      |
| `Super + Alt + G`               | 将窗口移出分组      |
| `Super + Alt + Tab`               | 在分组内的窗口之间循环      |
| `Super + Alt + Shift + Tab`               | 在分组内的窗口之间反向循环      |
| `Super + Alt + Scroll Wheel` | 在分组内的窗口之间循环 |
| `Super + Alt + 1/2/3/4/5`               | 跳转到分组内的指定窗口      |
| `Super + Alt + Arrow`  | 按方向键方向将窗口移入分组，包括该侧显示器上的窗口 |
| `Super + Ctrl + Left/Right`  | 在平铺分组内的窗口之间移动 |
| `Super + Ctrl + Z` | 放大屏幕（重复按下可进一步放大） |
| `Super + Ctrl + Alt + Z` | 从屏幕完全缩小 |
| `Super + /` | 向前逐步切换显示器缩放选项 |
| `Super + Alt + /` | 向后逐步切换显示器缩放选项 |
| `Alt + Tab` | 在当前工作区向前循环切换窗口 |
| `Alt + Shift + Tab` | 在当前工作区向后循环切换窗口 |
| `Ctrl + Alt + Tab`| 向前循环切换显示器焦点 |
| `Ctrl + Alt + Shift + Tab`| 向后循环切换显示器焦点 |
| `Super + I` | 切换输入语言（有多个布局或输入法时） |
| `Super + Shift + I` | 向后切换输入语言 |

在触控板上，三指和四指滑动可切换工作区、移动窗口，以及打开菜单和 Quake 控制台；手势见 [键盘、鼠标和触控板](34-keyboard-mouse-trackpad.md)。

调整大小使用 0 右边的两个键，不管你的键盘上印的是什么：美国键盘上是 `-` 和 `=`，丹麦语和瑞典语键盘上是 `+` 和 `´`，挪威语键盘上是 `+` 和 `\`，德语键盘上是 `ß` 和 `´`，西班牙语键盘上是 `'` 和 `¡`，日语（JIS）键盘上是 `-` 和 `^`。`Super + K` 会按你的键盘上印的显示它们。在 JIS 上，`Super + ^` 是 `Super + Equal`，而 `Super + Shift + -`（输入 `=`）是 `Super + Shift + Minus`。显示器缩放和密码管理器使用 `/`；在只能用 Shift 输入 `/` 的布局上，如大多数欧洲布局，它们改用右 Shift 左边的键（丹麦语和德语键盘上是 `-`）。

## 系统控制

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | 音频面板    |
| `Super + Ctrl + B`           | 蓝牙面板    |
| `Super + Ctrl + N`           | Wifi/网络面板    |
| `Super + Ctrl + D`           | 显示面板    |
| `Super + Ctrl + P`           | 电源面板    |
| `Super + Ctrl + X`           | Agents 面板    |
| `Super + Ctrl + Alt + X`           | 本地模型面板    |
| `Super + Ctrl + Alt + D`           | 日历面板    |
| `Super + Ctrl + Alt + E`           | 世界时钟面板    |
| `Super + Ctrl + 1-9`           | 按位置切换栏面板    |
| `Super + Ctrl + S` | 分享菜单（通过 LocalSend） |
| `Super + Ctrl + C` | 捕获控制（截屏/-录制/拾取器） |
| `Super + Ctrl + O` | 切换菜单 |
| `Super + Ctrl + H` | 硬件菜单 |
| `Super + Ctrl + E` | 表情符号选择器 |
| `Super + Ctrl + .` | 转码媒体 |
| `Super + Shift + Ctrl + A` | 启动你的默认 agent |
| `Power` key | 系统菜单 |
| `Super + Shift + Copilot` key | Omarchy 菜单 |

## 调整

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | 屏幕亮度最大 |
| `Shift + Brightness Down` | 屏幕亮度最小 |
| `Alt + Brightness Up/Down` | 精确的 1% 亮度调整 |
| `Alt + Volume Up/Down` | 精确的 1% 音量调整 |
| `Keyboard Brightness Up/Down` | 键盘背光更亮/更暗 |
| `Keyboard Backlight` | 循环切换键盘背光等级 |
| `Ctrl + Brightness Up/Down` | 键盘背光更亮/更暗，适用于没有专用键的键盘 |
| `Mic Mute` | 静音麦克风 |
| `Shift + Mute` | 切换音频输出 |
| `Touchpad Toggle` | 打开或关闭触控板 |
| `Display` key | 循环切换工作区布局 |
| `Alt + Play` | 下一曲 |
| `Alt + Shift + Play` | 上一曲 |

## 启动应用

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + Return`           | 终端    |
| `Super + Alt + Return` | Tmux 终端 |
| `Super + Ctrl + Return` | Herdr (agent manager) |
| `Super + Shift + Return` or `Super + Shift + B`  | 浏览器    |
| `Super + Shift + Alt + B`           | 浏览器（隐私/无痕）    |
| `Super + Shift + F`           | 文件管理器    |
| `Super + Shift + Alt + F`           | 在终端的 cwd 中打开文件管理器    |
| `Super + Shift + M`           | 音乐 (Spotify)    |
| `Super + Shift + Alt + M`           | 音乐 (cliamp)    |
| `Super + Shift + /`           | 密码管理器 (1password)    |
| `Super + Shift + Q` or `Calculator` key  | 计算器 (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker，安装后)    |
| `Super + Shift + T`           | 活动 (btop)    |
| `Super + Shift + N`           | 编辑器 (Plain，或你选择的默认编辑器)  |
| `Super + Shift + C`           | 日历 ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | 邮件 ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | 新邮件 ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | 你的默认 agent，或在你选定之前用 ChatGPT |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | 消息应用 (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | 消息应用 (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | 消息应用 (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | 写作 (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X（新帖子） |
| `Super + Shift + Y`           | YouTube |

在 `~/.config/hypr/bindings.lua` 中更改/添加绑定。

## 通用剪贴板

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + A`           | 在支持 `Ctrl + A` 的应用中全选    |
| `Super + C`           | 复制    |
| `Super + X`           | 剪切（不在终端中）    |
| `Super + V`           | 粘贴    |
| `Super + Ctrl + V`           | 剪贴板管理器    |

在 Linux 上，通常你需要在终端中用 `Ctrl + Shift + C/V` 复制粘贴，在其它任何地方用 `Ctrl + C/V`。这些 Omarchy 统一剪贴板快捷键在任何地方都能用。

## 捕获

| 快捷键              | 功能                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | 截屏                      |
| `Super + Ctrl + Alt + C`            | 截屏（同样的截屏，适用于没有 Print Screen 键的键盘） |
| `Super + Ctrl + C` | 捕获菜单 |
| `Alt + Print Screen`            | 录屏                     |
| `Super + Shift + Ctrl + Alt + C` | 无音频录屏，跳过菜单（再次按下停止） |
| `Super + Print Screen` | 颜色拾取器 |
| `Super + Ctrl + Print Screen` | 将文本提取到剪贴板 |
| `Super + Alt + [` | 录制时缩小摄像头浮层 |
| `Super + Alt + ]` | 录制时放大摄像头浮层 |
| `Alt + Shift + L` | 从 webapp 或浏览器复制当前 URL |
| `Alt + Shift + D` | 将当前页面上的视频下载到 `~/Videos` |
| `Alt + Space` | 开始/停止听写（需要 _Setup > Defaults > Dictation_） |
| `Right Alt` | 按住进行听写（需要 _Setup > Defaults > Dictation_） |

进行录屏时，快捷键会先询问你想要哪种音频，然后开始录制。再次按下即可停止。详情见 [截屏和录制](12-screenshots-recording.md)。

所有捕获选项也可以在 Omarchy 菜单（`Super + Space`）的 _Trigger > Capture_ 下访问。

## 通知

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + ,` | 对最新通知执行操作：打开它或按下它唯一的按钮，从它的选项中选择，或在它没有按钮时将其关闭  |
| `Super + Shift + ,` | 关闭所有通知 |
| `Super + Ctrl + ,` | 用键盘控制通知  |
| `Super + Alt + ,` | 关闭最新通知  |
| `Super + Shift + Alt + ,` | 打开通知历史  |
| `Super + Ctrl + Alt + ,` | 切换通知静音  |

## 样式

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | 选择新主题（也可用 `Super + Ctrl + Shift + Space`） |
| `Super + Ctrl + W` | 选择主题背景（也可用 `Super + Ctrl + Space`） |
| `Super + Backspace` | 切换窗口透明度 |
| `Super + Ctrl + Backspace` | 切换单窗口方形宽高比 |

额外的背景图片位于 `~/.config/omarchy/backgrounds/<theme name>`。也可以通过 Omarchy 菜单中的 _Install > Style > Background_ 访问。

所有样式选项也可以在 Omarchy 菜单（`Super + Space`）的 _Appearance_ 下访问。

## 开关

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | 切换空闲时锁定 |
| `Super + Ctrl + Delete` | 切换笔记本显示屏开/关 |
| `Super + Ctrl + Alt + Delete` | 切换笔记本显示屏镜像 |
| `Super + Shift + Space` | 切换顶栏  |
| `Shift + Mute` | 切换到下一个音频输出 |
| `Shift + Play` | 切换到下一个媒体源 |
| `Super + Shift + Backspace` | 切换窗口间隙 |
| `Super + Ctrl + Alt + F` | 切换全屏桌面（顶栏 + 窗口间隙） |

## 提醒

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | 设置提醒  |
| `Super + Ctrl + Alt + R` | 查看所有提醒  |
| `Super + Ctrl + Shift + R` | 清除所有提醒  |

## 提示

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | 以通知形式显示时间  |
| `Super + Ctrl + Alt + B` | 以通知形式显示电池  |
| `Super + Ctrl + Alt + W` | 切换以通知形式显示天气  |

## Tmux

前缀键是 `Ctrl + Space`（`Ctrl + B` 也可用）。你可以在 `~/.config/tmux/tmux.conf` 中更改这些绑定。

### 窗格

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Prefix + v` | 在旁边拆分窗格（垂直） |
| `Prefix + h` | 在下方拆分窗格（水平） |
| `Prefix + x` | 终止窗格 |
| `Prefix + z` | 切换窗格缩放（全屏） |
| `Alt + Enter` | 在下方拆分窗格（无前缀） |
| `Alt + Shift + Enter` | 在旁边拆分窗格（无前缀） |
| `Alt + Escape` | 终止窗格（无前缀） |
| `Ctrl + Alt + Arrows` | 在窗格之间移动 |
| `Ctrl + Alt + Shift + Arrows` | 调整窗格大小 |

### 窗口

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Prefix + c` | 新建窗口 |
| `Prefix + k` | 终止窗口 |
| `Prefix + r` | 重命名窗口 |
| `Alt + 1-9` | 前往指定窗口 |
| `Alt + Arrow Left/Right` | 在窗口之间移动 |
| `Alt + Shift + Arrow Left/Right` | 将窗口左移/右移 |

### 会话

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Prefix + C` | 新建会话 |
| `Prefix + K` | 终止会话 |
| `Prefix + R` | 重命名会话 |
| `Prefix + N` | 下一个会话 |
| `Prefix + P` | 上一个会话 |
| `Alt + Arrow Up/Down` | 在会话之间移动 |
| `Prefix + s` | 列出会话 |
| `Prefix + d` | 从会话分离 |

### 复制模式 (vi-style)

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Prefix + [` | 进入复制模式 |
| `v` | 开始选择（在复制模式中） |
| `y` | 复制所选内容（在复制模式中） |

### 通用

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Prefix + q` | 重新加载配置 |
| `Prefix + ?` | 显示 Tmux 键绑定 |
| `Prefix + :` | 命令提示符 |

### Tmux 布局函数

这些函数必须在 Tmux 会话内运行。

| 命令 | 功能 |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | 创建包含编辑器、AI 和终端的开发布局 |
| `tdlm <ai> [<second_ai>]` | 为每个子目录创建开发布局 |
| `tsl <count> <command>` | 创建多窗格 swarm 布局 |

## Ghostty 终端

Ghostty 终端通过 Omarchy 菜单使用 _Install > Terminal_ 安装。

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | 在下方新建拆分 |
| `Ctrl + Shift + O` | 在旁边新建拆分 |
| `Ctrl + Alt + Arrows` | 在拆分之间移动 |
| `Super + Ctrl + Shift + Arrows` | 将拆分调整 10 行 |
| `Super + Ctrl + Shift + Alt + Arrows` | 将拆分调整 100 行 |
| `Ctrl + Shift + T` | 新建标签页  |
| `Ctrl + Shift + Arrows` | 在标签页之间移动 |
| `Alt + Numbers` | 前往指定标签页 |
| `Shift + Pg Up/Down` | 滚动历史 |
| `Ctrl + Left mouse` | 在浏览器中打开链接 |

## 文件管理器

| 快捷键              | 功能                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | 前往路径                     |
| `Space`               | 预览文件（方向键导航） |
| `Alt + Up`       | 上到父文件夹        |

## Neovim (w/ lazyvim)

### 导航

| 快捷键                   | 功能                        |
| ------------------------ | ------------------------------- |
| `Space`                    | 显示命令选项            |
| `Space Space`              | 通过模糊搜索打开文件      |
| `Space E`                  | 切换侧边栏                  |
| `Space G G`                | 显示 git 控制               |
| `Space S G`                | 搜索文件内容             |
| `Ctrl + W W`               | 在侧边栏和编辑器之间跳转 |
| `Ctrl + Left/right arrow`  | 更改侧边栏大小          |
| `Shift + H`                      | 前往左侧文件标签页             |
| `Shift + L`                      | 前往右侧文件标签页            |
| `Space B D`                | 关闭文件标签页                  |

### 在侧边栏时

| 快捷键                   | 功能                        |
| ------------------------ | ------------------------------- |
| `A`                        | 在父目录中添加新文件      |
| `Shift + A`                | 在父目录中添加新子目录    |
| `D`                        | 删除高亮的文件/目录     |
| `M`                        | 移动高亮的文件/目录       |
| `R`                        | 重命名高亮的文件/目录     |
| `?`                        | 显示所有命令的帮助      |

[查看 LazyVim 配置的所有 Neovim 快捷键](https://www.lazyvim.org/keymaps)。

## 快速表情符号

你可以用 `Super + Ctrl + E` 显示完整的表情符号选择器，它会将所选内容放到剪贴板，或者你可以使用这些快速访问选项。

| 快捷键       | EM | 提示       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | 微笑      |
| `Shift + CapsLock M C` | 😂 | 哭        |
| `Shift + CapsLock M L` | 😍 | 爱       |
| `Shift + CapsLock M V` | ✌️ | 胜利    |
| `Shift + CapsLock M H` | ❤️ | 心      |
| `Shift + CapsLock M Y` | 👍 | 是        |
| `Shift + CapsLock M N` | 👎 | 否         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | 祝愿       |
| `Shift + CapsLock M R` | 🤘 | 摇滚       |
| `Shift + CapsLock M K` | 😘 | 吻       |
| `Shift + CapsLock M E` | 🙄 | 翻白眼    |
| `Shift + CapsLock M I` | 😉 | 眨眼       |
| `Shift + CapsLock M P` | 🙏 | 祈祷 |
| `Shift + CapsLock M D` | 🤤 | 流口水      |
| `Shift + CapsLock M M` | 💰 | 钱      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | 干杯      |
| `Shift + CapsLock M O` |👌 | 好 |
| `Shift + CapsLock M G` |👋 | 问候 |
| `Shift + CapsLock M A` |💪 | 手臂 |
| `Shift + CapsLock M B` |🤯 | 爆炸 |

## 快速补全

| 快捷键       | 补全       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | 你的名字（如在设置时输入的）  |
| `Shift + CapsLock Space E` | 你的电子邮件（如在设置时输入的）  |

你可以通过编辑 `~/.XCompose` 添加更多你自己的，然后在终端中运行 `omarchy restart xcompose`，使更改生效。
