# 切换项、闲置与屏幕保护程序

你日常改动的很多东西其实算不上设置。它们是你打开一小时、然后再关掉的模式：工作到很晚时开夜间暖光，演示时开勿扰，看东西时保持唤醒。Omarchy 把这些叫做切换项，它们的工作方式都一样——快捷键、菜单项和命令，全都拨动同一个开关。

### 切换菜单

`Super + Ctrl + O` 可以直接打开_触发 > 切换_，你也可以从 Omarchy 菜单（`Super + Space`）走过去。那份列表里的一切都是开关，你不用去想状态存在哪里就能随手拨动。控制桌面外观的开关就在它旁边，位于_外观_之下。

在终端里，同样的开关是 `omarchy toggle <thing>`。单独运行 `omarchy toggle` 可以看到整个分组。

| 切换项 | 快捷键 | 命令 |
| ------ | ------ | ------- |
| 夜间暖光 | — | `omarchy toggle nightlight` |
| 静默通知 | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| 保持唤醒（无闲置锁定） | `Super + Ctrl + I` | `omarchy toggle idle` |
| 崩溃捕获 | — | `omarchy toggle crash-capture` |
| 屏幕保护程序 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 主题同步 | — | `omarchy toggle theme sync` |
| 菜单栏 | `Super + Shift + Space` | `omarchy toggle bar` |
| 触控板 | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| 触摸屏 | — | `omarchy toggle touchscreen` |
| 挂起 | — | `omarchy toggle suspend` |
| 混合 GPU | — | `omarchy toggle hybrid gpu` |

触控板、触摸屏和混合 GPU 开关位于_触发 > 硬件_（`Super + Ctrl + H`）之下，而不是在切换项之下，因为它们只有当你真的有那类硬件时才会出现。触控板和触摸屏这两个开关在 Hyprland 重载后依然有效——被禁用设备的名称会被保存到一个小的状态文件中，Hyprland 在启动时读取它，再次将该设备禁用。

_外观_里放着菜单栏和动画，还有几样不是 `omarchy toggle` 命令、但行为方式相同的东西：栏中的电池百分比、默认工作区布局，以及在_窗口_之下的窗口间隙（`Super + Shift + Backspace`）和单窗口方形比例（`Super + Ctrl + Backspace`）。

这些切换项大多只是 `~/.local/state/omarchy/toggles/` 下的一个标志文件。如果你想在脚本里根据某个切换项做分支判断，`omarchy-toggle-enabled` 会给你一个退出码，免得你自己去找：

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

这些标志以关闭状态命名——`screensaver-off`、`suspend-off`、`bar-off`——所以它们的存在就意味着该功能已被禁用。

### 栏中的指示器

当某个模式开启时，你会在顶栏中部、时钟旁边看到一个小字形。那就是指示器小组件，它承载着听写、屏幕录制、待处理的提醒、夜间暖光、勿扰和保持唤醒。

未激活的指示器是隐藏的。将鼠标悬停在栏的任意位置，它们会以变暗的样子淡入，这样你不用知道快捷键也能点一下把它们打开。点击一个已激活的指示器会把它关回去。如果你宁愿一直看到全部指示器，就在 `~/.config/omarchy/shell.json` 中把 `omarchy.indicators` 条目的 `alwaysShow` 设为 `true`——栏小组件的配置方法见[顶栏](05-the-top-bar.md)。

### 夜间暖光

夜间暖光把屏幕变暖到 4000K，再切换一次则恢复到 6500K。从切换菜单（`Super + Ctrl + O`）或用 `omarchy toggle nightlight` 来拨动它。它由 hyprsunset 驱动，如果 hyprsunset 还没有运行，这个切换项会替你把它启动起来。

默认情况下，hyprsunset 根本不会对你的屏幕做任何事。`~/.config/hypr/hyprsunset.conf` 自带一个恒等配置文件，为的就是让显示屏在你要求变暖之前保持原样不动。如果你宁愿让它按时钟自动切换，就把那个文件替换成一个时间配置文件：

```
profile {
    time = 20:00
    temperature = 4000
}
```

然后通过把 `o.launch_on_start("hyprsunset")` 添加到 `~/.config/hypr/autostart.lua`，让 hyprsunset 在登录时启动。切换项使用的 4000K/6500K 这一对数值是固定的，所以如果你想要不同的色温，去改配置文件。

### 勿扰

`Super + Ctrl + Alt + ,` 会静默通知。它开启时不会有任何提示框弹出来，栏中会出现一个划掉的铃铛指示器，提醒你桌面为什么安静下来了。

不过不会有任何东西丢失。被静默的通知会被扣住：用 `Super + Shift + Alt + ,` 把最近几条重新放回屏幕。其余内容见[通知](10-notices.md)。

有两类消息仍然能穿透进来：Omarchy 自己给你的操作确认提示（“主题已更改”、“截图已保存”），以及从命令行发出的关键警报。那些把一切都标记为关键、就为了强行挤到你面前的聊天应用不够格。

### 闲置

Omarchy shell 掌管闲置行为，时间设置是 `~/.config/omarchy/shell.json` 中顶层的 `idle` 块：

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

两个数字都是从你进入闲置那一刻起计数的秒数——不是从彼此起计。所以按默认设置，屏幕保护程序在两分半钟后出现，锁屏在五分钟时接管，不管屏幕保护程序有没有运行过。保存文件，shell 会立即采用新的时间设置。

如果你在锁定截止时间之前关掉了屏幕保护程序，那会被算作一次活动，待处理的锁定就会被取消。你不会因为瞥了一眼机器就被锁在外面。

要彻底停止闲置时锁定，`Super + Ctrl + I`——或者 `omarchy toggle idle`——会打开保持唤醒，栏中会出现咖啡杯指示器。做长时间演示或想盯着某个构建过程之前，就该按这个。再按一次则恢复正常。如果你需要从脚本里获取它，`omarchy toggle idle status` 会以 JSON 形式打印当前状态。

这里说的是锁定和屏幕保护程序，不是电源。挂起和休眠有它们自己的设置，见[系统睡眠](36-system-sleep.md)。

### 屏幕保护程序

Omarchy 的屏幕保护程序是通过随机文字效果运行的 ASCII 艺术，每个显示器一个实例。任意按键或鼠标移动都会退出它。

你可以从_系统 > 屏幕保护程序_（`Super + Esc`）按需启动它，它会强制出现，哪怕你已经关掉了闲置屏幕保护程序。默认没有给它绑定快捷键。

`omarchy toggle screensaver` 关闭的是闲置时的那个屏幕保护程序，如果你宁愿从工作中直接进入锁定状态的话。它需要一个它知道如何配置的终端——Alacritty、Foot、Ghostty 或 Kitty——如果你的默认终端是别的什么，它会告诉你的。

它绘制的徽标可以由你来改，位于_外观 > 品牌 > 屏幕保护程序_之下。上传一张 png 或 svg，Omarchy 会把它转换成 ASCII。见[品牌](41-branding.md)。

### 锁屏

`Super + Ctrl + L` 会锁定机器。它会运行 Omarchy shell 的锁屏，熄灭显示屏，把你的键盘布局重置为第一个，这样你就不会用错字母表输入密码，而且——如果你正在运行 1Password——会在退出时顺带把它也锁上。

锁屏接受密码，一旦你设置好了指纹，它也能接受指纹。这一点以及其他身份验证方式，都在[硬件身份验证](37-hardware-authentication.md)中介绍。
