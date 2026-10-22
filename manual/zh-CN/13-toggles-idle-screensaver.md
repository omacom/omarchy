# 开关、空闲与屏保

你日常更改的很多东西其实并不算是设置。它是你打开一小时再关闭的模式：工作到很晚时打开夜灯，演示时打开勿扰，看东西时保持唤醒。Omarchy 将这些称为开关，它们都以相同的方式工作——一个快捷键、一个菜单条目和一个命令，都命中同一个开关。

### 开关菜单

`Super + Ctrl + O` 直接打开_触发 > 开关_，或者你可以从 Omarchy 菜单（`Super + Space`）走到那里。该列表中的一切都是一个开关，你可以无需思考状态存在哪里就将其翻转。与桌面外观相关的开关位于它旁边，在_触发 > 外观_下。

在终端中，同样的开关是 `omarchy toggle <thing>`。单独运行 `omarchy toggle` 可查看整个组。

| 开关 | 快捷键 | 命令 |
| ------ | ------ | ------- |
| 夜灯 | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| 静默通知 | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| 保持唤醒（无空闲锁） | `Super + Ctrl + I` | `omarchy toggle idle` |
| 崩溃捕获 | — | `omarchy toggle crash-capture` |
| 屏保 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 主题同步 | — | `omarchy toggle theme sync` |
| 菜单栏 | `Super + Shift + Space` | `omarchy toggle bar` |
| 触控板 | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| 触摸屏 | — | `omarchy toggle touchscreen` |
| 挂起 | — | `omarchy toggle suspend` |
| 混合 GPU | — | `omarchy toggle hybrid gpu` |

触控板、触摸屏和混合 GPU 开关位于_触发 > 硬件_（`Super + Ctrl + H`）下，而不是开关下，因为它们只在你确实拥有该硬件时才会出现。触控板和触摸屏的那两个在 Hyprland 重新加载后仍能保留——已禁用设备的名称会保存到一个小状态文件中，Hyprland 在启动时读取它以再次禁用它。

_触发 > 外观_包含菜单栏和动画，以及一些不是 `omarchy toggle` 命令但行为相同的功能：栏中的电池百分比、默认工作区布局、窗口间距（`Super + Shift + Backspace`）和单窗口正方形纵横比（`Super + Ctrl + Backspace`）。

其中大多数只是 `~/.local/state/omarchy/toggles/` 下的一个标记文件。如果要在脚本中基于其中一个进行分支，`omarchy-toggle-enabled` 会为你提供退出代码，而不必让你去找：

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

这些标记以关闭状态命名——`screensaver-off`、`suspend-off`、`bar-off`——所以它们的存在意味着该功能已禁用。

### 栏中的指示器

当某个模式打开时，你会在菜单栏中间、时钟旁边看到一个小字形。这是指示器小组件，它承载听写、录屏、待处理的提醒、夜灯、勿扰和保持唤醒。

非活动的指示器会隐藏。将鼠标悬停在它们周围的区域，它们会变暗地淡入，这样你就可以单击一个将其打开，而无需知道其快捷键。单击活动的指示器会将其关闭。如果你希望始终看到所有指示器，请将 `~/.config/omarchy/shell.json` 中 `omarchy.indicators` 条目上的 `alwaysShow` 设置为 `true`——有关如何配置栏小组件，请参见[菜单栏](05-the-top-bar.md)。

### 夜灯

`Super + Ctrl + N` 将屏幕暖到 4000K，再次按它可将其恢复到 6500K。它由 hyprsunset 驱动，如果该工具尚未运行，开关会为你启动它。

默认情况下，hyprsunset 根本不会影响你的屏幕。`~/.config/hypr/hyprsunset.conf` 附带了一个恒等配置文件，正是为了让显示器在你要求暖色之前保持原样。如果你更喜欢让它按时钟切换，请将其替换为时间配置文件：

```
profile {
    time = 20:00
    temperature = 4000
}
```

然后通过将 `o.launch_on_start("hyprsunset")` 添加到 `~/.config/hypr/autostart.lua`，在登录时启动 hyprsunset。开关使用的 4000K/6500K 组合是固定的，所以如果你想要不同的温度，配置文件就是你要去的地方。

### 勿扰模式

`Super + Ctrl + ,` 可静默通知。当它打开时，不会弹出提示，带斜杠的铃铛指示器会留在栏中提醒你为什么桌面变安静了。

不过，什么也不会丢失。被静默的通知会直接写入你的通知历史，当你回来想知道错过了什么时，这正是你想要的记录。用 `Super + Shift + Alt + ,` 打开它。有关通知故事的其余部分，请参见[提示](10-notices.md)。

两种消息仍然可以通过：Omarchy 针对你刚刚做的事情给出的确认提示（“主题已更改”、“截图已保存”），以及从命令行发送的关键警报。将所有内容都标记为关键以强行出现在你面前的聊天应用不符合条件。

### 空闲

Omarchy shell 负责空闲行为，计时是 `~/.config/omarchy/shell.json` 中的一个顶级 `idle` 块：

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

这两个数字都是从你空闲那一刻起计数的秒数——而不是从彼此计数。所以使用默认值时，屏保在两分半后出现，锁屏在五分钟时接管，无论屏保是否运行过。保存文件，shell 会立即获取新的计时。

如果你在锁定截止时间之前关闭屏保，这计为活动，待处理的锁定将被取消。你不会因为瞥了一眼机器就被锁在外面。

要完全停止空闲时锁定，`Super + Ctrl + I`——或 `omarchy toggle idle`——会打开保持唤醒，咖啡杯指示器会出现在栏中。这就是要在长时间演示或你想观看的构建之前按下的键。再次按它可恢复正常。`omarchy toggle idle status` 以 JSON 形式打印当前状态，如果你需要从脚本中获取它。

这是关于锁定和屏保，而不是电源。挂起和休眠在[系统睡眠](36-system-sleep.md)中有自己的设置。

### 屏保

Omarchy 的屏保是运行随机文本效果的 ASCII 艺术，每个显示器一个实例。任何按键或鼠标移动都会退出它。

你可以从_系统 > 屏保_（`Super + Esc`）按需启动它，这会强制它打开，即使你已关闭空闲屏保。默认没有绑定快捷键。

`omarchy toggle screensaver` 用于关闭空闲屏保，如果你更喜欢直接从工作状态进入锁定状态。它需要一个它知道如何配置的终端——Alacritty、Foot、Ghostty 或 Kitty——如果你的默认终端是别的，它会告诉你。

它绘制的徽标由你更改，位于_样式 > 屏保_下。上传 png 或 svg，Omarchy 会将其转换为 ASCII。参见[品牌](41-branding.md)。

### 锁屏

`Super + Ctrl + L` 锁定机器。这会从 Omarchy shell 运行锁屏，熄灭显示器，将你的键盘布局重置为第一个，这样你就不会用错误的字母输入密码，并且——如果你正在运行它——在退出时锁定 1Password。

锁屏接受密码，一旦你设置了指纹，它也会接受指纹。这一点以及其他身份验证方式在[硬件身份验证](37-hardware-authentication.md)中有介绍。
