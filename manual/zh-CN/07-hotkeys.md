# 快捷键

你可以通过 `Super + K` 查看所有主要键盘绑定（Tmux 绑定使用 `Super + Alt + K`，Herdr 绑定使用 `Super + Ctrl + K`）。

## 快捷键的布局方式

每个快捷键都位于一个平面上，由其修饰键决定，每个平面只有一个用途。这让快捷键不会混在一起，也意味着你通常能猜到某个功能在哪里。

| 平面 | 存放什么 | 示例 |
| --- | --- | --- |
| `Super + key` | 系统：窗口、工作区、布局和核心菜单 | `Super + Space` Omarchy 菜单，`Super + W` 关闭窗口，`Super + F` 全屏 |
| `Super + Shift + key` | 应用 | `Super + Shift + B` 浏览器，`Super + Shift + E` 邮件，`Super + Shift + N` 编辑器 |
| `Super + Ctrl + key` | 面板和系统菜单 | `Super + Ctrl + A` 音频，`Super + Ctrl + N` 网络，`Super + Ctrl + C` 捕获菜单 |
| `Super + Ctrl + Alt + key` | 快捷操作和提示 | `Super + Ctrl + Alt + T` 显示时间，`Super + Ctrl + Alt + B` 电池，`Super + Ctrl + Alt + C` 截图 |

给快捷键加上 `Alt` 会得到同一事物的一个变体，绝不会是毫不相关的东西：

- `Super + Shift + B` 打开浏览器；`Super + Shift + Alt + B` 打开隐私窗口
- `Super + Shift + E` 打开邮件；`Super + Shift + Alt + E` 开始写新邮件
- `Super + F` 进入全屏；`Super + Alt + F` 进入全宽
- `Super + Ctrl + C` 打开捕获菜单；`Super + Ctrl + Alt + C` 跳过菜单直接截图

添加快捷键时：

1. 先根据它的用途选择平面，再选择按键。
2. 不要移动已有快捷键来腾地方。在正确的平面上找一个空闲按键。
3. 只用 `Alt` 来表示没有它的那个快捷键的变体。

有几个快捷键因为方便而打破了这些规则。`Shift` 加方向键或 `Tab` 是移动或反向，而不是打开应用，而 `Print`、媒体键、`Alt + Tab` 和 `Ctrl + Alt + Del` 则和其他地方一样工作。它们是例外，不是可照搬的模式。

如果默认设置不适合你（比如你想像在 Windows 上那样用 `Super + Shift + S` 截图），在 `~/.config/hypr/bindings.lua` 中重新绑定它。

## 导航

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy 菜单（应用和其它一切） |
| `Super + Alt + Space` | 应用网格 |
| `Super + Escape` | 系统菜单（挂起、重启等） |
| `Super + Ctrl + L` | 锁定计算机 |
| `Super + W` 或 `Super + Q` | 关闭窗口 |
| `Ctrl + Alt + Del` | 关闭所有窗口 |
| `Super + K` | 显示所有快捷键 |
| `Super + Alt + K` | 显示 tmux 快捷键 |
| `Super + Ctrl + K` | 显示 herdr 快捷键 |
| `Super + M` | 将窗口最小化到 dock |
| `Super + T` | 在平铺/浮动之间切换窗口 |
| `Super + J` | 切换窗口位置（水平/垂直） |
| `Super + O` | 切换将窗口弹出为 sticky'n'floating |
| `Super + L` | 在 dwindle、scrolling 和 floating 布局之间循环切换 |
| `Super + Alt + L` | 以相反顺序在布局之间循环切换 |
| `Super + P` | 切换伪窗口样式（natural 与 stretch） |
| `Super + F` | 进入全屏 |
| `Super + Alt + F` | 进入全宽 |
| `Super + Ctrl + F` | 在窗口内进入全屏 |
| `Super + 1…9/0` | 跳转到聚焦显示器上的指定工作区（0 是 10） |
| `Super + Tab` | 跳转到聚焦显示器上的下一个工作区 |
| `Super + Shift + Tab` | 跳转到聚焦显示器上的上一个工作区 |
| `Super + Ctrl + Tab` | 跳转到聚焦显示器上的先前工作区 |
| `Super + Shift + 1…9/0` | 将窗口移动到聚焦显示器上的工作区 |
| `Super + Shift + Alt + 1…9/0` | 将窗口移动到聚焦显示器上的工作区且不跟随 |
| `Super + S` | 切换完整 scratchpad |
| `Super + Alt + S` | 将窗口移动到完整 scratchpad |
| `Super + Grave` | 切换 Quake 控制台 |
| `Super + Shift + Grave` | 将窗口移动到 Quake 控制台 |
| `Super + Shift + Ctrl + Arrows` | 将窗口移动到该方向的显示器 |
| `Super + Shift + Alt + Arrows` | 将工作区移动到该方向的显示器 |
| `Super + Arrow` | 将焦点移动到箭头方向的窗口，在屏幕边缘时跨到该侧的显示器 |
| `Super + Shift + Arrow` | 与箭头方向的另一个窗口交换位置，包括该侧显示器上的窗口 |
| `Super + Minus` | 向左扩展窗口 |
| `Super + Equal` | 向左收缩窗口 |
| `Super + Shift + Minus` | 向上收缩窗口 |
| `Super + Shift + Equal` | 向下扩展窗口 |
| `Super + Alt + Minus/Equal` | 以更小步幅进行相同缩放 |
| `Super + Ctrl + Minus/Equal` | 以更大步幅进行相同缩放 |
| `Super + Alt + Home` | 保存窗口宽度 |
| `Super + Home` | 恢复已保存的窗口宽度 |
| `Super + Left Mouse` | 拖动窗口 |
| `Super + Right Mouse` | 调整窗口大小 |
| `Super + Scroll Wheel` | 在聚焦显示器上滚动切换工作区 |
| `Super + G` | 切换窗口分组 |
| `Super + Alt + G` | 将窗口移出分组 |
| `Super + Alt + Tab` | 在分组内的窗口之间循环切换 |
| `Super + Alt + Shift + Tab` | 在分组内的窗口之间反向循环切换 |
| `Super + Alt + Scroll Wheel` | 在分组内的窗口之间循环切换 |
| `Super + Alt + 1/2/3/4/5` | 跳转到分组中的指定窗口 |
| `Super + Alt + Arrow` | 将窗口沿箭头方向移入分组，包括该侧显示器上的窗口 |
| `Super + Ctrl + Left/Right` | 在平铺组内的窗口之间移动 |
| `Super + Ctrl + Z` | 放大屏幕（重复按下可继续放大） |
| `Super + Ctrl + Alt + Z` | 完全缩小屏幕 |
| `Super + /` | 逐步向前切换显示器缩放选项 |
| `Super + Alt + /` | 逐步向后切换显示器缩放选项 |
| `Alt + Tab` | 在活动工作区的窗口之间向前循环切换 |
| `Alt + Shift + Tab` | 在活动工作区的窗口之间向后循环切换 |
| `Ctrl + Alt + Tab` | 在显示器之间向前循环切换焦点 |
| `Ctrl + Alt + Shift + Tab` | 在显示器之间向后循环切换焦点 |
| `Super + I` | 切换输入语言（有多个布局或输入法时） |
| `Super + Shift + I` | 反向切换输入语言 |

在触摸板上，三指和四指滑动可切换工作区、移动窗口，以及打开菜单和 Quake 控制台；手势请参阅 [键盘、鼠标和触控板](34-keyboard-mouse-trackpad.md)。

缩放快捷键使用物理按键 `code:20` 和 `code:21`（XKB `<AE11>` 和 `<AE12>`），无论键盘上印的是什么字符。在美式键盘上这些按键是 `-` 和 `=`；在日本（JIS）键盘上是 `-` 和 `^`；在西班牙键盘上是 `'` 和 `¡`。在 JIS 上，`Super + ^` 是 `Super + Equal`，而 `Super + Shift + -`（输入 `=`）是 `Super + Shift + Minus`。

## 系统控制

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | 音频面板 |
| `Super + Ctrl + B` | Bluetooth 面板 |
| `Super + Ctrl + N` | Wifi/网络面板 |
| `Super + Ctrl + D` | 显示面板 |
| `Super + Ctrl + P` | 电源面板 |
| `Super + Ctrl + X` | Agents 面板 |
| `Super + Ctrl + Alt + D` | 日历面板 |
| `Super + Ctrl + Alt + E` | 世界时钟面板 |
| `Super + Ctrl + 1-9` | 按位置切换栏面板 |
| `Super + Ctrl + S` | 共享菜单（通过 LocalSend） |
| `Super + Ctrl + C` | 捕获控制（截图/-录制/选取器） |
| `Super + Ctrl + O` | 切换菜单 |
| `Super + Ctrl + H` | 硬件菜单 |
| `Super + Ctrl + E` | 表情符号选择器 |
| `Super + Ctrl + .` | 转码媒体 |
| `Super + Shift + Ctrl + A` | 选择一个 AI agent |
| `Power` 键 | 系统菜单 |
| `Super + Shift + Copilot` 键 | Omarchy 菜单 |

## 调节

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | 屏幕亮度最大 |
| `Shift + Brightness Down` | 屏幕亮度最小 |
| `Alt + Brightness Up/Down` | 精确的 1% 亮度调节 |
| `Alt + Volume Up/Down` | 精确的 1% 音量调节 |
| `Keyboard Brightness Up/Down` | 键盘背光变亮/变暗 |
| `Keyboard Backlight` | 循环切换键盘背光等级 |
| `Ctrl + Brightness Up/Down` | 键盘背光变亮/变暗，适用于没有专用按键的键盘 |
| `Mic Mute` | 静音麦克风 |
| `Shift + Mute` | 切换音频输出 |
| `Touchpad Toggle` | 开启或关闭触摸板 |
| `Display` 键 | 循环切换工作区布局 |
| `Alt + Play` | 下一曲 |
| `Alt + Shift + Play` | 上一曲 |

## 启动应用

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Super + Return` | 终端 |
| `Super + Alt + Return` | Tmux 终端 |
| `Super + Ctrl + Return` | Herdr（agent 管理器） |
| `Super + Shift + Return` 或 `Super + Shift + B` | 浏览器 |
| `Super + Shift + Alt + B` | 浏览器（隐私/无痕） |
| `Super + Shift + F` | 文件管理器 |
| `Super + Shift + Alt + F` | 在终端的 cwd 中打开文件管理器 |
| `Super + Shift + M` | 音乐（Spotify） |
| `Super + Shift + Alt + M` | 音乐（cliamp） |
| `Super + Shift + /` | 密码管理器（1password） |
| `Super + Shift + Q` 或 `Calculator` 键 | 计算器（Omacalc） |
| `Super + Shift + D` | Docker（lazydocker，安装后） |
| `Super + Shift + T` | 活动（btop） |
| `Super + Shift + N` | 编辑器（Plain，或你选择的默认编辑器） |
| `Super + Shift + C` | 日历（[HEY](https://hey.com/)） |
| `Super + Shift + E` | 邮件（[HEY](https://hey.com/)） |
| `Super + Shift + Alt + E` | 新邮件（[HEY](https://hey.com/)） |
| `Super + Shift + A` | AI（ChatGPT） |
| `Super + Shift + Alt + A` | AI（Grok） |
| `Super + Shift + G` | 即时通讯（Signal） |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | 即时通讯（WhatsApp） |
| `Super + Shift + Ctrl + G` | 即时通讯（Google） |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | 写作（Omawrite） |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X（新帖子） |
| `Super + Shift + Y` | YouTube |

在 `~/.config/hypr/bindings.lua` 中更改/添加绑定。

## 通用剪贴板

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Super + A` | 在支持 `Ctrl + A` 的应用中全选 |
| `Super + C` | 复制 |
| `Super + X` | 剪切（终端中除外） |
| `Super + V` | 粘贴 |
| `Super + Ctrl + V` | 剪贴板管理器 |

在 Linux 上，通常你需要在终端中使用 `Ctrl + Shift + C/V` 复制粘贴，在其它地方使用 `Ctrl + C/V`。这些 Omarchy 统一剪贴板快捷键在任何地方都能用。

## 捕获

| 快捷键 | 功能 |
| ------------------- | ------------------------------ |
| `Print Screen` | 截图 |
| `Super + Ctrl + Alt + C` | 截图（同上，适用于没有 Print Screen 键的键盘） |
| `Super + Ctrl + C` | 捕获菜单 |
| `Alt + Print Screen` | 录屏 |
| `Super + Shift + Ctrl + Alt + C` | 无音频录屏，跳过菜单（再次按下停止） |
| `Super + Print Screen` | 取色器 |
| `Super + Ctrl + Print Screen` | 将文本提取到剪贴板 |
| `Super + Alt + [` | 录制时缩小摄像头浮窗 |
| `Super + Alt + ]` | 录制时放大摄像头浮窗 |
| `Alt + Shift + L` | 从 webapp 或浏览器复制当前 URL |
| `Alt + Shift + D` | 将当前页面的视频下载到 `~/Videos` |
| `Alt + Space` | 开始/停止听写（需要 _Setup > Defaults > Dictation_） |
| `Right Alt` | 按住进行听写（需要 _Setup > Defaults > Dictation_） |

录屏时，快捷键会先询问你要哪种音频，然后开始录制。再次按下停止。详情请参阅 [截图和录制](12-screenshots-recording.md)。

所有捕获选项也可以在 Omarchy 菜单（`Super + Space`）的 _Trigger > Capture_ 下访问。

## 通知

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Super + ,` | 处理最新通知：打开它或按下它唯一的按钮、从它的选项中选择，或在它没有选项时忽略它 |
| `Super + Shift + ,` | 忽略所有通知 |
| `Super + Ctrl + ,` | 用键盘控制通知 |
| `Super + Alt + ,` | 忽略最新通知 |
| `Super + Shift + Alt + ,` | 打开通知历史 |
| `Super + Ctrl + Alt + ,` | 切换静音通知 |

## 样式

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | 选择新主题（也可使用 `Super + Ctrl + Shift + Space`） |
| `Super + Ctrl + W` | 选择主题背景（也可使用 `Super + Ctrl + Space`） |
| `Super + Backspace` | 切换窗口透明度 |
| `Super + Ctrl + Backspace` | 切换单窗口正方形长宽比 |

额外背景图片位于 `~/.config/omarchy/backgrounds/<theme name>`。也可以通过 Omarchy 菜单中的 _Install > Style > Background_ 访问。

所有样式选项也可以在 Omarchy 菜单（`Super + Space`）的 _Appearance_ 下访问。

## 开关

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | 切换空闲时锁定 |
| `Super + Ctrl + Delete` | 切换笔记本显示屏开/关 |
| `Super + Ctrl + Alt + Delete` | 切换笔记本显示屏镜像 |
| `Super + Shift + Space` | 切换顶栏 |
| `Shift + Mute` | 切换到下一个音频输出 |
| `Shift + Play` | 切换到下一个媒体源 |
| `Super + Shift + Backspace` | 切换窗口间隙 |
| `Super + Ctrl + Alt + F` | 切换全屏桌面（顶栏 + 窗口间隙） |

## 提醒

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | 设置提醒 |
| `Super + Ctrl + Alt + R` | 查看所有提醒 |
| `Super + Ctrl + Shift + R` | 清除所有提醒 |

## 提示

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | 以通知形式显示时间 |
| `Super + Ctrl + Alt + B` | 以通知形式显示电池 |
| `Super + Ctrl + Alt + W` | 切换以通知形式显示天气 |

## Tmux

前缀键是 `Ctrl + Space`（`Ctrl + B` 也可用）。你可以在 `~/.config/tmux/tmux.conf` 中更改这些绑定。

### 窗格

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Prefix + v` | 在旁边分割窗格（垂直） |
| `Prefix + h` | 在下方分割窗格（水平） |
| `Prefix + x` | 终止窗格 |
| `Prefix + z` | 切换窗格缩放（全屏） |
| `Alt + Enter` | 在下方分割窗格（无需前缀） |
| `Alt + Shift + Enter` | 在旁边分割窗格（无需前缀） |
| `Alt + Escape` | 终止窗格（无需前缀） |
| `Ctrl + Alt + Arrows` | 在窗格之间移动 |
| `Ctrl + Alt + Shift + Arrows` | 调整窗格大小 |

### 窗口

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Prefix + c` | 新建窗口 |
| `Prefix + k` | 终止窗口 |
| `Prefix + r` | 重命名窗口 |
| `Alt + 1-9` | 转到指定窗口 |
| `Alt + Arrow Left/Right` | 在窗口之间移动 |
| `Alt + Shift + Arrow Left/Right` | 向左/向右移动窗口 |

### 会话

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Prefix + C` | 新建会话 |
| `Prefix + K` | 终止会话 |
| `Prefix + R` | 重命名会话 |
| `Prefix + N` | 下一个会话 |
| `Prefix + P` | 上一个会话 |
| `Alt + Arrow Up/Down` | 在会话之间移动 |
| `Prefix + s` | 列出会话 |
| `Prefix + d` | 从会话分离 |

### 复制模式（vi 风格）

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Prefix + [` | 进入复制模式 |
| `v` | 开始选择（在复制模式中） |
| `y` | 复制所选内容（在复制模式中） |

### 通用

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Prefix + q` | 重新加载配置 |
| `Prefix + ?` | 显示 Tmux 键绑定 |
| `Prefix + :` | 命令提示 |

### Tmux 布局函数

这些函数必须在 Tmux 会话内运行。

| 命令 | 功能 |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | 创建包含编辑器、AI 和终端的开发布局 |
| `tdlm <ai> [<second_ai>]` | 为每个子目录创建开发布局 |
| `tsl <count> <command>` | 创建多窗格 swarm 布局 |

## Ghostty 终端

Ghostty 终端通过 Omarchy 菜单使用 _Install > Terminal_ 安装。

| 快捷键 | 功能 |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | 在下方新建分屏 |
| `Ctrl + Shift + O` | 在旁边新建分屏 |
| `Ctrl + Alt + Arrows` | 在分屏之间移动 |
| `Super + Ctrl + Shift + Arrows` | 按 10 行调整分屏大小 |
| `Super + Ctrl + Shift + Alt + Arrows` | 按 100 行调整分屏大小 |
| `Ctrl + Shift + T` | 新建标签页 |
| `Ctrl + Shift + Arrows` | 在标签页之间移动 |
| `Alt + Numbers` | 转到指定标签页 |
| `Shift + Pg Up/Down` | 滚动历史 |
| `Ctrl + Left mouse` | 在浏览器中打开链接 |

## 文件管理器

| 快捷键 | 功能 |
| ------------------- | ------------------------------ |
| `Ctrl + L` | 转到路径 |
| `Space` | 预览文件（方向键导航） |
| `Alt + Up` | 转到上级文件夹 |

## Neovim（带 lazyvim）

### 导航

| 快捷键 | 功能 |
| ------------------------ | ------------------------------- |
| `Space` | 显示命令选项 |
| `Space Space` | 通过模糊搜索打开文件 |
| `Space E` | 切换侧边栏 |
| `Space G G` | 显示 git 控制 |
| `Space S G` | 搜索文件内容 |
| `Ctrl + W W` | 在侧边栏和编辑器之间跳转 |
| `Ctrl + Left/right arrow` | 调整侧边栏大小 |
| `Shift + H` | 转到左侧文件标签页 |
| `Shift + L` | 转到右侧文件标签页 |
| `Space B D` | 关闭文件标签页 |

### 在侧边栏中时

| 快捷键 | 功能 |
| ------------------------ | ------------------------------- |
| `A` | 在父目录中添加新文件 |
| `Shift + A` | 在父目录中添加新子目录 |
| `D` | 删除高亮的文件/目录 |
| `M` | 移动高亮的文件/目录 |
| `R` | 重命名高亮的文件/目录 |
| `?` | 显示所有命令的帮助 |

[查看 LazyVim 配置的所有 Neovim 快捷键](https://www.lazyvim.org/keymaps)。

## 快速表情符号

你可以使用 `Super + Ctrl + E` 显示完整的表情符号选择器，它会把所选内容放到剪贴板，或者你可以使用这些快速访问选项。

| 快捷键 | EM | 提示 |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | 微笑 |
| `Shift + CapsLock M C` | 😂 | 哭 |
| `Shift + CapsLock M L` | 😍 | 爱 |
| `Shift + CapsLock M V` | ✌️ | 胜利 |
| `Shift + CapsLock M H` | ❤️ | 爱心 |
| `Shift + CapsLock M Y` | 👍 | 是 |
| `Shift + CapsLock M N` | 👎 | 否 |
| `Shift + CapsLock M F` | 🖕 | 中指 |
| `Shift + CapsLock M W` | 🤞 | 祝愿 |
| `Shift + CapsLock M R` | 🤘 | 摇滚 |
| `Shift + CapsLock M K` | 😘 | 亲吻 |
| `Shift + CapsLock M E` | 🙄 | 翻白眼 |
| `Shift + CapsLock M I` | 😉 | 眨眼 |
| `Shift + CapsLock M P` | 🙏 | 祈祷 |
| `Shift + CapsLock M D` | 🤤 | 流口水 |
| `Shift + CapsLock M M` | 💰 | 钱 |
| `Shift + CapsLock M X` | 🎉 | 庆祝 |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | 干杯 |
| `Shift + CapsLock M O` |👌 | 好 |
| `Shift + CapsLock M G` |👋 | 问候 |
| `Shift + CapsLock M A` |💪 | 手臂 |
| `Shift + CapsLock M B` |🤯 | 爆炸 |

## 快速补全

| 快捷键 | 补全 |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | —（长破折号） |
| `Shift + CapsLock Space N` | 你的姓名（如在设置时输入） |
| `Shift + CapsLock Space E` | 你的电子邮件（如在设置时输入） |

你可以通过编辑 `~/.XCompose` 添加更多你自己的，然后在终端中运行 `omarchy restart xcompose` 让更改生效。
