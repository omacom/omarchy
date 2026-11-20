# 开关、空闲与屏幕保护程序

你每天改的很多东西其实算不上设置。它们是你打开一小时、然后再关掉的模式：工作到很晚时开夜灯，演示时开勿扰，看东西时保持唤醒。Omarchy 把这些叫开关，它们的工作方式都一样——一个快捷键、一个菜单项和一条命令，都作用在同一个开关上。

### 开关菜单

`Super + Ctrl + O` 直接打开 _Trigger > Toggle_，或者你可以从 Omarchy 菜单（`Super + Space`）走过去。那个列表里的一切都是你可以随手翻转的开关，不用去想状态存在哪里。控制桌面外观的开关就在它旁边，位于 _Appearance_ 下。

在终端里，相同的开关是 `omarchy toggle <thing>`。单独运行 `omarchy toggle` 可以看到整个组。

| 开关 | 快捷键 | 命令 |
| ------ | ------ | ------- |
| 夜灯 | — | `omarchy toggle nightlight` |
| 静默通知 | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| 保持唤醒（无空闲锁定） | `Super + Ctrl + I` | `omarchy toggle idle` |
| 崩溃捕获 | — | `omarchy toggle crash-capture` |
| 屏幕保护程序 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 主题同步 | — | `omarchy toggle theme sync` |
| 菜单栏 | `Super + Shift + Space` | `omarchy toggle bar` |
| 触控板 | `XF86TouchpadToggle` | `omarchy device touchpad` |
| 触摸屏 | — | `omarchy device touchscreen` |
| 挂起 | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

触控板、触摸屏和 Hybrid GPU 开关位于 _Trigger > Hardware_（`Super + Ctrl + H`）下，而不是 Toggle 下，因为它们只在你确实有那类硬件时才会显示。触控板和触摸屏开关在 Hyprland 重载后依然有效——被禁用设备的名字会保存到一个小的状态文件里，Hyprland 启动时读取它，再次禁用该设备。

_Appearance_ 里有菜单栏和动画，还有几样不是 `omarchy toggle` 命令、但行为一样的东西：栏中的电池百分比、默认工作区布局，以及 _Windows_ 下的窗口间隙（`Super + Shift + Backspace`）和单窗口方形宽高比（`Super + Ctrl + Backspace`）。

当 Hyprland 没有 GPU 可用来绘制、改为在 CPU 上渲染（llvmpipe）时，比如在 GPU 尚未受支持的 Mac 上、在大多数虚拟机中，或者图形驱动加载失败时，Omarchy 会在那个会话中关掉动画、模糊和阴影，并用一条通知告诉你一次。_Appearance > Animations On_ 可以把它们带回来，Omarchy 也会为以后的会话记住这一点。

其中大多数只是一个位于 `~/.local/state/omarchy/toggles/` 下的标志文件。如果你想在脚本里根据某个开关分支判断，`omarchy-toggle-enabled` 会给你一个退出码，不用你自己去找：

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

这些标志以关闭状态命名——`screensaver-off`、`suspend-off`、`bar-off`——所以它们的存在意味着该功能已禁用。

### 顶栏中的指示器

当某个模式打开时，你会在顶栏中间、时钟旁边看到一个小字形。那就是指示器小部件，它承载听写、屏幕录制、待处理的提醒、夜灯、勿扰和保持唤醒。

未激活的指示器会隐藏。将鼠标悬停在栏上任意位置，它们会变暗淡入，这样你不用知道快捷键也能点击一个来打开它。点击一个已激活的指示器会把它关回去。如果你宁愿一直看到全部指示器，就在 `~/.config/omarchy/shell.json` 的 `omarchy.indicators` 条目上把 `alwaysShow` 设为 `true`——关于栏小部件如何配置，参见[顶栏](05-the-top-bar.md)。

### 夜灯

夜灯把屏幕调暖到 4000K，再切换一次则回到 6500K。从开关菜单（`Super + Ctrl + O`）翻转它，或者用 `omarchy toggle nightlight`。它由 hyprsunset 驱动，开关会在它尚未运行时替你启动它。

默认情况下，hyprsunset 完全不会对你的屏幕做任何事。`~/.config/hypr/hyprsunset.conf` 附带一个恒等配置文件，正是为了让显示器在你要求变暖之前保持原样。如果你宁愿让它按时钟切换，就把那换成一个时间配置文件：

```
profile {
    time = 20:00
    temperature = 4000
}
```

然后通过在 `~/.config/hypr/autostart.lua` 中添加 `o.launch_on_start("hyprsunset")`，让 hyprsunset 在登录时启动。开关使用的 4000K/6500K 组合是固定的，所以如果你想要不同的色温，就去改配置文件。

### 勿扰

`Super + Ctrl + Alt + ,` 会静默通知。打开它时不会弹出任何吐司提示，栏里会坐着那个划掉的铃铛指示器，提醒你桌面为什么安静下来了。

不过什么都不会丢。被静默的通知会被暂缓：用 `Super + Shift + Alt + ,` 把最近几条放回屏幕上。其余内容参见[通知](10-notices.md)。

有两种消息仍然能通过：Omarchy 自己针对你刚做的事情的确认吐司（"Theme changed"、"Screenshot saved"），以及从命令行发送的关键警报。那些把一切都标记为关键、想强行挤到你面前的聊天应用不算。

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

两个数字都是从你进入空闲那一刻起算的秒数——不是彼此相对计算。所以按默认值，屏幕保护程序在两分半钟后出现，锁屏在五分钟时接管，无论屏幕保护程序是否运行过。保存文件，shell 会立刻采用新的计时。

如果你在锁定截止时间之前关闭屏幕保护程序，那算作活动，待处理的锁定会被取消。你不会因为瞥了一眼机器就被锁在外面。

要完全停止空闲时锁定，`Super + Ctrl + I`——或者 `omarchy toggle idle`——会打开保持唤醒，咖啡杯指示器会出现在栏里。在长时间演示或者你想盯着的构建之前，就该按这个。再按一次则回到正常。`omarchy toggle idle status` 会以 JSON 形式打印当前状态，如果你需要从脚本里获取它。

这说的是锁定和屏幕保护程序，不是电源。挂起和休眠有它们自己的设置，见[系统睡眠](36-system-sleep.md)。

### 屏幕保护程序

Omarchy 的屏幕保护程序是经过随机文字效果的 ASCII 艺术，每个监视器一个实例。任意按键或鼠标移动都会退出它。

你可以从 _System > Screensaver_（`Super + Esc`）按需启动它，即使你已经关掉了空闲屏幕保护程序，它也会强制打开。默认没有为它绑定快捷键。

`omarchy toggle screensaver` 是用来关掉空闲屏幕保护程序的，如果你宁愿直接从工作跳到锁定。任意按键、点击、滚动或鼠标移动都会关闭它。

它绘制的徽标可以由你更改，位于 _Appearance > Branding > Screensaver_ 下。上传一个 png 或 svg，Omarchy 会把它转换成 ASCII。参见[品牌](41-branding.md)。

### 锁屏

`Super + Ctrl + L` 锁定机器。那会运行 Omarchy shell 的锁屏，熄灭显示器，把键盘布局重置为第一个，这样你就不会用错的字母表输入密码，并且——如果你正在运行它——在离开时锁定 1Password。

锁屏接受密码，一旦你设置了指纹，它也会接受指纹。这一点以及其他认证方式，在[硬件认证](37-hardware-authentication.md)中介绍。
