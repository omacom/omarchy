# 快捷键

你可以用 `Super + K` 查看所有主要键盘绑定（用 `Super + Alt + K` 查看 Tmux 绑定，用 `Super + Ctrl + K` 查看 Herdr 绑定）。

## 快捷键的布局方式

每个快捷键都位于一个平面上，由它的修饰键决定，每个平面都有一个职责。这样快捷键才不会混在一起，也意味着你通常能猜出某个功能在哪里。

| 平面 | 存放什么 | 示例 |
| --- | --- | --- |
| `Super + key` | 系统：窗口、工作区、布局和核心菜单 | `Super + Space` Omarchy 菜单，`Super + W` 关闭窗口，`Super + F` 全屏 |
| `Super + Shift + key` | 应用程序 | `Super + Shift + B` 浏览器，`Super + Shift + E` 电子邮件，`Super + Shift + N` 编辑器 |
| `Super + Ctrl + key` | 面板和系统菜单 | `Super + Ctrl + A` 音频，`Super + Ctrl + N` 网络，`Super + Ctrl + C` 捕获菜单 |
| `Super + Ctrl + Alt + key` | 快捷操作和提示 | `Super + Ctrl + Alt + T` 显示时间，`Super + Ctrl + Alt + B` 电池，`Super + Ctrl + Alt + C` 截图 |

给快捷键加上 `Alt`，得到的是同一事物的变体，绝不是毫不相关的东西：

- `Super + Shift + B` 打开浏览器；`Super + Shift + Alt + B` 打开隐私窗口
- `Super + Shift + E` 打开电子邮件；`Super + Shift + Alt + E` 开始写一封新电子邮件
- `Super + F` 进入全屏；`Super + Alt + F` 进入全宽
- `Super + Ctrl + C` 打开捕获菜单；`Super + Ctrl + Alt + C` 跳过菜单并截图

添加快捷键时：

1. 先根据它做什么来选平面，然后选按键。
2. 不要为了腾地方而移动现有的快捷键。在正确的平面上找一个空闲的按键。
3. 只用 `Alt` 表示不带 `Alt` 的那个快捷键的变体。

有几个快捷键因为方便而打破了这些规则。`Shift` 加方向键或 `Tab` 是移动或反向，而不是打开应用程序，`Print`、媒体键、`Alt + Tab` 和 `Ctrl + Alt + Del` 则和其他所有地方一样工作。它们是例外，不是值得效仿的模式。

如果默认设置不适合你（比如你想像 Windows 上那样用 `Super + Shift + S` 截图），就在 `~/.config/hypr/bindings.lua` 中重新绑定它。

## 导航

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy 菜单（应用程序和所有其他内容）    |
| `Super + Alt + Space` | 应用程序网格 |
| `Super + Escape` | 系统菜单（挂起、重启等）  |
| `Super + Ctrl + L` | 锁定计算机 |
| `Super + W` or `Super + Q` | 关闭窗口             |
| `Ctrl + Alt + Del` | 关闭所有窗口 |
| `Super + T`               | 在平铺/浮动之间切换窗口             |
| `Super + J` | 切换窗口位置（水平/垂直） |
| `Super + O`               | 切换把窗口弹出为 sticky'n'floating |
| `Super + L`               | 在 dwindle、scrolling 和 floating 布局之间循环切换 |
| `Super + Alt + L`         | 反向在布局之间循环切换 |
| `Super + P`               | 切换伪窗口样式（自然 v 拉伸） |
| `Super + F`                 | 进入全屏              |
| `Super + Alt + F`                 | 进入全宽              |
| `Super + Ctrl + F`                 | 在窗口内部全屏              |
| `Super + 1/2/3/4`         | 跳转到聚焦显示器上的指定工作区 |
| `Super + Tab` | 跳转到聚焦显示器上的下一个工作区 |
| `Super + Shift + Tab` | 跳转到聚焦显示器上的上一个工作区 |
| `Super + Ctrl + Tab` | 跳转到聚焦显示器上之前的工作区 |
| `Super + Shift + 1/2/3/4` | 将窗口移动到聚焦显示器上的工作区 |
| `Super + Shift + Alt + 1/2/3/4` | 将窗口移动到聚焦显示器上的工作区，但不跟随过去 |
| `Super + S` | 切换完整暂存区 |
| `Super + Alt + S` | 将窗口移动到完整暂存区 |
| `Super + Grave` | 切换 Quake 控制台 |
| `Super + Shift + Grave` | 将窗口移动到 Quake 控制台 |
| `Super + Shift + Ctrl + Arrows` | 将窗口移动到那个方向的显示器 |
| `Super + Shift + Alt + Arrows` | 将工作区移动到那个方向的显示器 |
| `Super + Arrow`  | 将焦点移动到箭头方向的窗口，到达屏幕边缘时跨到那一侧的显示器 |
| `Super + Shift + Arrow`  | 与箭头方向的另一个窗口交换位置，包括那一侧显示器上的窗口 |
| `Super + Minus` | 向左扩大窗口 |
| `Super + Equal` | 向左缩小窗口 |
| `Super + Shift + Minus` | 向上缩小窗口 |
| `Super + Shift + Equal` | 向下扩大窗口 |
| `Super + Alt + Minus/Equal` | 以更小的步幅进行相同的调整大小 |
| `Super + Ctrl + Minus/Equal` | 以更大的步幅进行相同的调整大小 |
| `Super + Alt + Home` | 保存窗口宽度 |
| `Super + Home` | 恢复已保存的窗口宽度 |
| `Super + Left Mouse` | 拖动窗口 |
| `Super + Right Mouse` | 调整窗口大小 |
| `Super + Scroll Wheel` | 在聚焦显示器上滚动切换工作区 |
| `Super + G`               | 切换窗口分组      |
| `Super + Alt + G`               | 将窗口移出分组      |
| `Super + Alt + Tab`               | 在分组内的窗口之间循环切换      |
| `Super + Alt + Shift + Tab`               | 在分组内的窗口之间反向循环切换      |
| `Super + Alt + Scroll Wheel` | 在分组内的窗口之间循环切换 |
| `Super + Alt + 1/2/3/4/5`               | 跳转到分组内的指定窗口      |
| `Super + Alt + Arrow`  | 将窗口移动到箭头方向的分组中，包括那一侧显示器上的分组 |
| `Super + Ctrl + Left/Right`  | 在平铺分组内的窗口之间移动 |
| `Super + Ctrl + Z` | 放大屏幕（重复按下可进一步放大） |
| `Super + Ctrl + Alt + Z` | 将屏幕完全缩小 |
| `Super + /` | 向前逐级切换显示器缩放选项 |
| `Super + Alt + /` | 向后逐级切换显示器缩放选项 |
| `Alt + Tab` | 在当前工作区向前循环切换窗口 |
| `Alt + Shift + Tab` | 在当前工作区向后循环切换窗口 |
| `Ctrl + Alt + Tab`| 向前循环切换显示器焦点 |
| `Ctrl + Alt + Shift + Tab`| 向后循环切换显示器焦点 |

调整大小的快捷键使用物理按键 `code:20` 和 `code:21`（XKB `<AE11>` 和 `<AE12>`），无论键盘上印的是什么字符。在美式键盘上，这些按键是 `-` 和 `=`；在日式（JIS）键盘上，它们是 `-` 和 `^`；在西班牙语键盘上，它们是 `'` 和 `¡`。在 JIS 上，`Super + ^` 是 `Super + Equal`，而 `Super + Shift + -`（输入 `=`）是 `Super + Shift + Minus`。

## 系统控制

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | 音频面板    |
| `Super + Ctrl + B`           | Bluetooth 面板    |
| `Super + Ctrl + N`           | Wi-Fi/网络面板    |
| `Super + Ctrl + D`           | 显示面板    |
| `Super + Ctrl + P`           | 电源面板    |
| `Super + Ctrl + X`           | Agents 面板    |
| `Super + Ctrl + Alt + D`           | 日历面板    |
| `Super + Ctrl + Alt + E`           | 世界时钟面板    |
| `Super + Ctrl + 1-9`           | 按位置切换栏面板    |
| `Super + Ctrl + S` | 共享菜单（通过 LocalSend） |
| `Super + Ctrl + C` | 捕获控制（截图/录制/拾取器） |
| `Super + Ctrl + O` | 切换菜单 |
| `Super + Ctrl + H` | 硬件菜单 |
| `Super + Ctrl + E` | 表情符号选择器 |
| `Super + Ctrl + .` | 转码媒体 |
| `Super + Shift + Ctrl + A` | 选择一个 AI 智能体 |

## 调节

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | 屏幕亮度最大 |
| `Shift + Brightness Down` | 屏幕亮度最小 |
| `Alt + Brightness Up/Down` | 精确的 1% 亮度调节 |
| `Alt + Volume Up/Down` | 精确的 1% 音量调节 |
| `Keyboard Brightness Up/Down` | 键盘背光调亮/调暗 |
| `Keyboard Backlight` | 循环切换键盘背光级别 |
| `Alt + Play` | 下一曲目 |
| `Alt + Shift + Play` | 上一曲目 |

## 启动应用程序

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + Return`           | 终端    |
| `Super + Alt + Return` | Tmux 终端 |
| `Super + Ctrl + Return` | Herdr（智能体管理器） |
| `Super + Shift + Return`           | 浏览器    |
| `Super + Shift + Alt + B`           | 浏览器（隐私/无痕）    |
| `Super + Shift + F`           | 文件管理器    |
| `Super + Shift + Alt + F`           | 在终端的 cwd 中打开文件管理器    |
| `Super + Shift + M`           | 音乐 (Spotify)    |
| `Super + Shift + Alt + M`           | 音乐 (cliamp)    |
| `Super + Shift + /`           | 密码管理器 (1password)    |
| `Super + Shift + Q`           | 计算器 (Omacalc)    |
| `Super + Shift + T`           | 活动 (btop)    |
| `Super + Shift + N`           | 编辑器 (Neovim)  |
| `Super + Shift + C`           | 日历 ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | 电子邮件 ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | 新电子邮件 ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | 消息应用 (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | 消息应用 (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | 消息应用 (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | 写作 (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

在 `~/.config/hypr/bindings.lua` 中更改/添加绑定。

## 通用剪贴板

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + A`           | 在支持 `Ctrl + A` 的应用程序中全选    |
| `Super + C`           | 复制    |
| `Super + X`           | 剪切（不在终端中）    |
| `Super + V`           | 粘贴    |
| `Super + Ctrl + V`           | 剪贴板管理器    |

在 Linux 上，通常你需要在终端中使用 `Ctrl + Shift + C/V` 来复制粘贴，在其他所有地方则使用 `Ctrl + C/V`。这些 Omarchy 统一剪贴板快捷键在任何地方都能工作。

## 捕获

| 快捷键              | 功能                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | 截图                      |
| `Super + Ctrl + Alt + C`            | 截图（同样的截图，适用于没有 Print Screen 键的键盘） |
| `Super + Ctrl + C` | 捕获菜单 |
| `Alt + Print Screen`            | 录屏                     |
| `Super + Print Screen` | 颜色拾取器 |
| `Super + Ctrl + Print Screen` | 将文本提取到剪贴板 |
| `Super + Alt + [` | 录制时缩小摄像头叠加层 |
| `Super + Alt + ]` | 录制时放大摄像头叠加层 |
| `Alt + Shift + L` | 从 Web 应用或浏览器复制当前 URL |
| `Alt + Shift + D` | 将当前页面上的视频下载到 `~/Videos` |
| `Alt + Space` | 开始/停止听写（需要 _设置 > 默认 > 听写_） |
| `Right Alt` | 按住进行听写（需要 _设置 > 默认 > 听写_） |

录屏时，该快捷键会先询问你要哪种音频，然后开始录制。再次按下即可停止。详情请参阅[截图和录制](12-screenshots-recording.md)。

所有捕获选项也可以通过 Omarchy 菜单（`Super + Space`）下的 _触发 > 捕获_ 访问。

## 通知

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + ,` | 对最新通知执行操作：打开它或按下它唯一的按钮，从它的选项中选择，或在它没有选项时关闭它  |
| `Super + Shift + ,` | 关闭所有通知 |
| `Super + Ctrl + ,` | 用键盘控制通知  |
| `Super + Alt + ,` | 关闭最新通知  |
| `Super + Shift + Alt + ,` | 打开通知历史  |
| `Super + Ctrl + Alt + ,` | 切换通知静音  |

## 样式

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | 选择一个新主题（也可以用 `Super + Ctrl + Shift + Space`） |
| `Super + Ctrl + W` | 选择主题背景（也可以用 `Super + Ctrl + Space`） |
| `Super + Backspace` | 切换窗口的透明度 |
| `Super + Ctrl + Backspace` | 切换单窗口方形比例 |

额外的背景图片位于 `~/.config/omarchy/backgrounds/<theme name>`。也可以通过 Omarchy 菜单中的 _安装 > 样式 > 背景_ 获得。

所有样式选项也可以通过 Omarchy 菜单（`Super + Space`）下的 _样式_ 访问。

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
| `Super + Ctrl + R` | 设置一个提醒  |
| `Super + Ctrl + Alt + R` | 查看所有提醒  |
| `Super + Ctrl + Shift + R` | 清除所有提醒  |

## 提示

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | 以通知形式显示时间  |
| `Super + Ctrl + Alt + B` | 以通知形式显示电池电量  |
| `Super + Ctrl + Alt + W` | 切换以通知形式显示天气  |

## Tmux

前缀键是 `Ctrl + Space`（`Ctrl + B` 也可以）。你可以在 `~/.config/tmux/tmux.conf` 中更改这些绑定。

### 窗格

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Prefix + v` | 在旁边拆分窗格（垂直） |
| `Prefix + h` | 在下方拆分窗格（水平） |
| `Prefix + x` | 关闭窗格 |
| `Prefix + z` | 切换窗格缩放（全屏） |
| `Alt + Enter` | 在下方拆分窗格（无需前缀） |
| `Alt + Shift + Enter` | 在旁边拆分窗格（无需前缀） |
| `Alt + Escape` | 关闭窗格（无需前缀） |
| `Ctrl + Alt + Arrows` | 在窗格之间移动 |
| `Ctrl + Alt + Shift + Arrows` | 调整窗格大小 |

### 窗口

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Prefix + c` | 新建窗口 |
| `Prefix + k` | 关闭窗口 |
| `Prefix + r` | 重命名窗口 |
| `Alt + 1-9` | 转到指定窗口 |
| `Alt + Arrow Left/Right` | 在窗口之间移动 |
| `Alt + Shift + Arrow Left/Right` | 向左/向右移动窗口 |

### 会话

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Prefix + C` | 新建会话 |
| `Prefix + K` | 关闭会话 |
| `Prefix + R` | 重命名会话 |
| `Prefix + N` | 下一个会话 |
| `Prefix + P` | 上一个会话 |
| `Alt + Arrow Up/Down` | 在会话之间移动 |
| `Prefix + s` | 列出会话 |
| `Prefix + d` | 从会话分离 |

### 复制模式（vi 风格）

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Prefix + [` | 进入复制模式 |
| `v` | 开始选择（在复制模式中） |
| `y` | 复制选择内容（在复制模式中） |

### 通用

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Prefix + q` | 重新加载配置 |
| `Prefix + ?` | 显示 Tmux 键绑定 |
| `Prefix + :` | 命令提示符 |

### Tmux 布局函数

这些函数必须在 Tmux 会话内部运行。

| 命令 | 功能 |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | 创建包含编辑器、AI 和终端的开发布局 |
| `tdlm <ai> [<second_ai>]` | 为每个子目录创建开发布局 |
| `tsl <count> <command>` | 创建多窗格 swarm 布局 |

## Ghostty 终端

Ghostty 终端通过 Omarchy 菜单使用 _安装 > 终端_ 安装。

| 快捷键                  | 功能              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | 在下方新建分屏 |
| `Ctrl + Shift + O` | 在旁边新建分屏 |
| `Ctrl + Alt + Arrows` | 在分屏之间移动 |
| `Super + Ctrl + Shift + Arrows` | 按 10 行调整分屏大小 |
| `Super + Ctrl + Shift + Alt + Arrows` | 按 100 行调整分屏大小 |
| `Ctrl + Shift + T` | 新建标签页  |
| `Ctrl + Shift + Arrows` | 在标签页之间移动 |
| `Alt + Numbers` | 转到指定标签页 |
| `Shift + Pg Up/Down` | 滚动历史记录 |
| `Ctrl + Left mouse` | 在浏览器中打开链接 |

## 文件管理器

| 快捷键              | 功能                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | 转到路径                     |
| `Space`               | 预览文件（用方向键导航） |
| `Alt + Up`       | 向上转到父文件夹        |

## Neovim（使用 lazyvim）

### 导航

| 快捷键                   | 功能                        |
| ------------------------ | ------------------------------- |
| `Space`                    | 显示命令选项            |
| `Space Space`              | 通过模糊搜索打开文件      |
| `Space E`                  | 切换侧边栏                  |
| `Space G G`                | 显示 git 控件               |
| `Space S G`                | 搜索文件内容             |
| `Ctrl + W W`               | 在侧边栏和编辑器之间跳转 |
| `Ctrl + Left/right arrow`  | 更改侧边栏大小          |
| `Shift + H`                      | 转到左侧文件标签页             |
| `Shift + L`                      | 转到右侧文件标签页            |
| `Space B D`                | 关闭文件标签页                  |

### 在侧边栏中时

| 快捷键                   | 功能                        |
| ------------------------ | ------------------------------- |
| `A`                        | 在父目录中添加新文件      |
| `Shift + A`                | 在父目录中添加新子目录    |
| `D`                        | 删除高亮显示的文件/目录     |
| `M`                        | 移动高亮显示的文件/目录       |
| `R`                        | 重命名高亮显示的文件/目录     |
| `?`                        | 显示所有命令的帮助      |

[查看 LazyVim 配置的所有 Neovim 快捷键](https://www.lazyvim.org/keymaps)。

## 快速表情符号

你可以使用 `Super + Ctrl + E` 显示一个完整的表情符号选择器，它会将所选内容放到剪贴板上，或者你可以使用这些快速访问选项。

| 快捷键       | EM | 提示       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | 微笑      |
| `Shift + CapsLock M C` | 😂 | 哭泣        |
| `Shift + CapsLock M L` | 😍 | 爱       |
| `Shift + CapsLock M V` | ✌️ | 胜利    |
| `Shift + CapsLock M H` | ❤️ | 爱心      |
| `Shift + CapsLock M Y` | 👍 | 是        |
| `Shift + CapsLock M N` | 👎 | 否         |
| `Shift + CapsLock M F` | 🖕 | 操       |
| `Shift + CapsLock M W` | 🤞 | 愿望       |
| `Shift + CapsLock M R` | 🤘 | 摇滚       |
| `Shift + CapsLock M K` | 😘 | 吻       |
| `Shift + CapsLock M E` | 🙄 | 翻白眼    |
| `Shift + CapsLock M I` | 😉 | 眨眼       |
| `Shift + CapsLock M P` | 🙏 | 祈祷 |
| `Shift + CapsLock M D` | 🤤 | 流口水      |
| `Shift + CapsLock M M` | 💰 | 钱      |
| `Shift + CapsLock M X` | 🎉 | 庆祝 |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | 干杯      |
| `Shift + CapsLock M O` |👌 | 好的 |
| `Shift + CapsLock M G` |👋 | 问候 |
| `Shift + CapsLock M A` |💪 | 手臂 |
| `Shift + CapsLock M B` |🤯 | 爆炸 |

## 快速补全

| 快捷键       | 补全内容       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | 你的名字（按设置时输入的内容）  |
| `Shift + CapsLock Space E` | 你的电子邮件（按设置时输入的内容）  |

你可以通过编辑 `~/.XCompose` 添加更多你自己的内容，然后在终端中运行 `omarchy-restart-xcompose` 让更改生效。
