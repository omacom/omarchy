# 开关、空闲与屏幕保护程序

你日常改动的很多东西其实算不上设置。它是你打开一个小时、然后又关掉的一种模式：熬夜工作时开夜灯，演示时开勿扰，看东西时保持唤醒。Omarchy 把这些叫做开关，而且它们的工作方式都一样——一个快捷键、一个菜单项和一条命令，触发的都是同一个开关。

### 开关菜单

`Super + Ctrl + O` 可以直接打开 _Trigger > Toggle_，或者你可以从 Omarchy 菜单（`Super + Space`）一步步走过去。那个列表里的一切都是你不用去想状态存在哪里就能翻转的开关。控制桌面外观的开关就在它旁边，位于 _Appearance_ 下。

在终端里，同样的开关是 `omarchy toggle <thing>`。单独运行 `omarchy toggle` 可以查看整个分组。

| 切换项 | 快捷键 | 命令 |
| ------ | ------ | ------- |
| 夜灯 | — | `omarchy toggle nightlight` |
| 静默通知 | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| 保持唤醒（不因空闲锁定） | `Super + Ctrl + I` | `omarchy toggle idle` |
| 崩溃捕获 | — | `omarchy toggle crash-capture` |
| 屏幕保护程序 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 主题同步 | — | `omarchy toggle theme sync` |
| 菜单栏 | `Super + Shift + Space` | `omarchy toggle bar` |
| 触控板 | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| 触摸屏 | — | `omarchy toggle touchscreen` |
| 挂起 | — | `omarchy toggle suspend` |
| 混合 GPU | — | `omarchy toggle hybrid gpu` |

触控板、触摸屏和混合 GPU 开关位于 _Trigger > Hardware_（`Super + Ctrl + H`）下，而不是 Toggle 下，因为只有当你真的有相应硬件时它们才会出现。触控板和触摸屏的开关在 Hyprland 重新加载后依然有效——被禁用设备的名称会保存到一个小的状态文件中，Hyprland 启动时读取它，再次禁用该设备。

_Appearance_ 里有菜单栏和动画，还有几项不是 `omarchy toggle` 命令、但行为方式相同的东西：栏中的电池百分比、默认工作区布局，以及 _Windows_ 下的窗口间隙（`Super + Shift + Backspace`）和单窗口正方形比例（`Super + Ctrl + Backspace`）。

这些开关大多只是 `~/.local/state/omarchy/toggles/` 下的一个标志文件。如果你想在脚本中根据某个开关进行分支判断，`omarchy-toggle-enabled` 会给你一个退出码，不用你自己去找：

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

这些标志以关闭状态命名——`screensaver-off`、`suspend-off`、`bar-off`——所以它们的存在就意味着该功能已被禁用。

### 栏中的指示器

某种模式打开时，顶部栏中间、时钟旁边会出现一个小字形。那就是指示器小部件，它承载着听写、屏幕录制、待处理的提醒、夜灯、勿扰和保持唤醒。

未激活的指示器会被隐藏。将鼠标悬停在栏的任意位置，它们会以变暗状态淡入，这样你不用知道快捷键也能点击一个来打开它。点击已激活的指示器则会把它关掉。如果你更愿意一直看到所有指示器，把 `~/.config/omarchy/shell.json` 中 `omarchy.indicators` 条目的 `alwaysShow` 设置为 `true`——栏小部件的配置方式见[顶部栏](05-the-top-bar.md)。

### 夜灯

夜灯会把屏幕暖至 4000K，再切换一次则恢复到 6500K。从开关菜单（`Super + Ctrl + O`）或用 `omarchy toggle nightlight` 都可以切换它。它由 hyprsunset 驱动，如果 hyprsunset 还没在运行，开关会自动为你启动它。

默认情况下，hyprsunset 完全不会对你的屏幕做任何事。`~/.config/hypr/hyprsunset.conf` 附带了一个 identity 配置，正是为了让显示器在你要求变暖之前保持原样。如果你更愿意让它按时间切换，把它替换为一个时间配置：

```
profile {
    time = 20:00
    temperature = 4000
}
```

然后把 `o.launch_on_start("hyprsunset")` 添加到 `~/.config/hypr/autostart.lua`，让 hyprsunset 在登录时启动。开关使用的 4000K/6500K 这一对数值是固定的，所以如果你想要不同的色温，就去改配置文件。

### 勿扰

`Super + Ctrl + Alt + ,` 会静默通知。开启时不会弹出任何提示，栏中会出现一个划掉的铃铛指示器，提醒你桌面为什么安静了下来。

不过什么都不会丢失。被静默的通知会被保留下来：用 `Super + Shift + Alt + ,` 把最近几条重新放回屏幕上。其余内容见[通知](10-notices.md)。

有两类消息仍然能穿透：Omarchy 自己针对你刚做的事情发出的确认弹窗（"Theme changed"、"Screenshot saved"），以及从命令行发出的关键警报。那些把所有消息都标为关键、强行挤到你面前的聊天应用不算数。

### 空闲

Omarchy shell 负责空闲行为，计时是 `~/.config/omarchy/shell.json` 中一个顶级的 `idle` 块：

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

这两个数字都是从你进入空闲状态那一刻起计算的秒数——不是彼此相对计算。所以按默认值，屏幕保护程序会在两分半钟后出现，锁屏会在五分钟时接管，无论屏幕保护程序是否运行过。保存文件，shell 就会立即采用新的计时。

如果你在锁定截止时间之前关闭了屏幕保护程序，那会被算作一次活动，待定的锁定就会被取消。你不会因为瞥了一眼机器就被锁在外面。

要完全停止因空闲而锁定，`Super + Ctrl + I`——或者 `omarchy toggle idle`——会打开保持唤醒，栏中会出现咖啡杯指示器。在长时间演示之前，或者你想盯着某个构建时，就该按下这个。再按一次则恢复正常。如果你需要从脚本中获取当前状态，`omarchy toggle idle status` 会以 JSON 形式打印它。

这里讲的是锁定和屏幕保护程序，而不是电源。挂起和休眠有它们自己的设置，见[系统睡眠](36-system-sleep.md)。

### 屏幕保护程序

Omarchy 的屏幕保护程序是通过随机文字效果运行的 ASCII 艺术，每个显示器一个实例。按任意键或移动鼠标即可退出。

你可以从 _System > Screensaver_（`Super + Esc`）按需启动它，即使你已经关闭了空闲屏幕保护程序，它也会强制出现。默认情况下没有为它绑定快捷键。

`omarchy toggle screensaver` 用来关闭空闲时的那个屏幕保护程序，适合你更愿意从工作状态直接进入锁定状态的情况。按任意键、点击、滚动或移动鼠标都会关闭它。

它绘制的标志可以由你来更改，位于 _Appearance > Branding > Screensaver_ 下。上传一个 png 或 svg，Omarchy 会把它转换成为 ASCII。见[品牌](41-branding.md)。

### 锁屏

`Super + Ctrl + L` 会锁定机器。它会运行 Omarchy shell 的锁屏、让显示器变黑、把键盘布局重置为第一个，这样你就不会用错误的字母体系输入密码，并且——如果你正在运行 1Password——在退出时将其锁定。

锁屏接受密码，等你设置好指纹后，也接受指纹。这一点以及其他身份验证方式，在[硬件身份验证](37-hardware-authentication.md)中都有介绍。
