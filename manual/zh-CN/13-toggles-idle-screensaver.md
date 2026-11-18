# 切换开关、空闲与屏幕保护程序

你日常改动的很多东西其实算不上真正的设置。它是你打开一小时、然后再关掉的一种模式：加班到很晚时开夜光、演示时开免打扰、看东西时保持唤醒。Omarchy 把这些叫做切换开关，它们的运作方式都一样——一个快捷键、一个菜单项和一条命令，都作用在同一个开关上。

### 切换菜单

`Super + Ctrl + O` 会直接打开 _触发 > 切换_，你也可以从 Omarchy 菜单（`Super + Space`）一步步走过去。这个列表里的每一项都是一个开关，你不用去想状态到底存在哪里就能翻转它。决定桌面外观的开关就在它旁边，位于 _外观_ 下面。

在终端里，同样的开关是 `omarchy toggle <thing>`。单独运行 `omarchy toggle` 就能看到整个分组。

| 切换项 | 快捷键 | 命令 |
| ------ | ------ | ------- |
| 夜光 | — | `omarchy toggle nightlight` |
| 静默通知 | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| 保持唤醒（无空闲锁定） | `Super + Ctrl + I` | `omarchy toggle idle` |
| 崩溃捕获 | — | `omarchy toggle crash-capture` |
| 屏幕保护程序 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 主题同步 | — | `omarchy toggle theme sync` |
| 菜单栏 | `Super + Shift + Space` | `omarchy toggle bar` |
| 触控板 | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| 触控屏 | — | `omarchy toggle touchscreen` |
| 挂起 | — | `omarchy toggle suspend` |
| 混合 GPU | — | `omarchy toggle hybrid gpu` |

触控板、触控屏和混合 GPU 开关位于 _触发 > 硬件_（`Super + Ctrl + H`）下面，而不是位于切换下面，因为它们只有在你确实拥有相应硬件时才会显示。触控板和触控屏的开关在 Hyprland 重新加载后依然有效——被禁用设备的名称会保存到一个小的状态文件里，Hyprland 启动时读取它，并再次禁用该设备。

_外观_ 里有菜单栏和动画，还有几样不是 `omarchy toggle` 命令、但行为一样的东西：栏中的电池百分比、默认工作区布局，以及 _窗口_ 下面的窗口间隙（`Super + Shift + Backspace`）和单窗口正方形长宽比（`Super + Ctrl + Backspace`）。

当 Hyprland 没有 GPU 可以用来绘图、转而在 CPU 上渲染（llvmpipe）时，比如在 GPU 尚未受支持的 Mac 上、在大多数虚拟机中，或者图形驱动加载失败时，Omarchy 会为该会话关闭动画、模糊和阴影，并用一条通知告诉你一次。_外观 > 开启动画_ 可以把它们带回来，而且 Omarchy 也会为以后的会话记住这个选择。

这些开关大多只是 `~/.local/state/omarchy/toggles/` 下面的一个标志文件。如果你想在脚本中根据其中某个开关做分支判断，`omarchy-toggle-enabled` 会给你一个退出码，不用你自己去翻找：

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

这些标志以关闭状态命名——`screensaver-off`、`suspend-off`、`bar-off`——所以它们的存在就意味着该功能被禁用了。

### 栏中的指示器

当某个模式开启时，你会在顶栏中间、时钟旁边看到一个小字形。那就是指示器小部件，它承载着听写、屏幕录制、待处理的提醒、夜光、免打扰和保持唤醒。

未激活的指示器会被隐藏。将鼠标悬停在栏的任意位置，它们就会以变暗的状态淡入，这样你不用知道它的快捷键就能点击一个来开启它。点击已激活的指示器会把它关回去。如果你更想一直看到全部指示器，就在 `~/.config/omarchy/shell.json` 中把 `omarchy.indicators` 条目的 `alwaysShow` 设为 `true`——关于栏小部件的配置方式，参见[顶栏](05-the-top-bar.md)。

### 夜光

夜光会把屏幕调暖到 4000K，再切换一次就会把它恢复到 6500K。从切换菜单（`Super + Ctrl + O`）翻转它，或者使用 `omarchy toggle nightlight`。它由 hyprsunset 驱动，如果 hyprsunset 还没有在运行，这个开关会替你启动它。

默认情况下，hyprsunset 根本不会对你的屏幕做任何事。`~/.config/hypr/hyprsunset.conf` 自带一个恒等配置文件，为的就是在你要求变暖之前让显示保持原样。如果你更想让它按时钟切换，就把那份配置替换成一个时间配置文件：

```
profile {
    time = 20:00
    temperature = 4000
}
```

然后将 `o.launch_on_start("hyprsunset")` 添加到 `~/.config/hypr/autostart.lua`，让 hyprsunset 在登录时启动。开关使用的 4000K/6500K 这一对数值是固定的，所以如果你想要不同的色温，去改配置文件就行。

### 免打扰

`Super + Ctrl + Alt + ,` 会静默通知。开启时不会有任何弹窗冒出来，栏里会坐着一个划掉的铃铛指示器，提醒你为什么桌面变得这么安静。

不过什么都不会丢。被静默的通知会被扣住：用 `Super + Shift + Alt + ,` 把最近的几条重新放回屏幕。其他内容参见[通知](10-notices.md)。

有两种消息仍然能通过：Omarchy 自己就你刚刚做的事发出的确认弹窗（“Theme changed”、“Screenshot saved”），以及从命令行发出的严重警报。那些把一切都标记为严重、想强行挤到你面前的聊天应用不算。

### 空闲

Omarchy 壳负责空闲行为，这些计时是 `~/.config/omarchy/shell.json` 中的一个顶层 `idle` 块：

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

两个数字都是从你进入空闲那一刻起计的秒数——不是彼此相继计的。所以按默认值，屏幕保护程序会在两分半钟后出现，锁屏会在五分钟时接管，不管屏幕保护程序是否运行过。保存文件后，壳会立刻采用新的计时。

如果你在锁定截止时间前关闭了屏幕保护程序，那会被算作活动，待处理的锁定会被取消。你不会因为瞥了一眼自己的机器就被锁在外面。

要完全停止空闲时锁定，按 `Super + Ctrl + I`——或者使用 `omarchy toggle idle`——就会打开保持唤醒，咖啡杯指示器就会出现在栏里。在长时间演示或想盯着构建跑完之前，要按的就是这个。再按一次就恢复正常。如果你需要从脚本中获取当前状态，`omarchy toggle idle status` 会以 JSON 形式打印当前状态。

这里说的是锁定和屏幕保护程序，不是电源。挂起和休眠有它们自己的设置，参见[系统睡眠](36-system-sleep.md)。

### 屏幕保护程序

Omarchy 的屏幕保护程序是 ASCII 艺术，会运行随机文字效果，每台显示器一个实例。任何按键或鼠标移动都会退出它。

你可以从 _系统 > 屏幕保护程序_（`Super + Esc`）按需启动它，它会强制出现，哪怕你已经关闭了空闲屏幕保护程序。默认没有给它绑定快捷键。

如果你更想从工作直接进入锁定，`omarchy toggle screensaver` 就是用来关闭空闲屏幕保护程序的。任何按键、点击、滚动或鼠标移动都会关闭它。

它绘制的标志由你来改，位于 _外观 > 品牌 > 屏幕保护程序_ 下面。上传一张 png 或 svg，Omarchy 会把它转换成 ASCII。参见[品牌定制](41-branding.md)。

### 锁屏

`Super + Ctrl + L` 会锁定机器。这会运行 Omarchy 壳的锁屏，让显示变黑，把你的键盘布局重置为第一个，这样你就不会用错字母表输入密码，而且——如果你正在运行它——会在退出时顺路锁定 1Password。

锁屏接受密码，一旦你设置了指纹，它也会接受指纹。这一点，以及其他身份验证方式，都在[硬件身份验证](37-hardware-authentication.md)中介绍。
