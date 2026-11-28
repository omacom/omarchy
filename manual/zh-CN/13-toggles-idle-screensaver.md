# 开关、空闲与屏幕保护程序

你日常频繁改动的很多东西，其实并不算真正的设置。它只是一种你开启一个小时、然后再关掉的模式：深夜工作时开夜间光，演示时开勿扰，看东西时保持唤醒。Omarchy 把这些叫做开关，它们的工作方式都一样——一个快捷键、一个菜单项和一个命令，都触发同一个开关。

### 开关菜单

`Super + Ctrl + O` 会直接打开 _Trigger > Toggle_，你也可以从 Omarchy 菜单（`Super + Space`）进入那里。列表中的每一项都是一个开关，你可以随手切换，无需操心状态保存在哪里。控制桌面外观的开关就紧挨着它，位于 _Appearance_ 下。

在终端中，同样的开关是 `omarchy toggle <thing>`。单独运行 `omarchy toggle` 即可查看整个分组。

| 开关 | 快捷键 | 命令 |
| ------ | ------ | ------- |
| 夜间光 | — | `omarchy toggle nightlight` |
| 让通知静音 | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| 保持唤醒（无空闲锁定） | `Super + Ctrl + I` | `omarchy toggle idle` |
| 崩溃捕获 | — | `omarchy toggle crash-capture` |
| 屏幕保护程序 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 主题同步 | — | `omarchy toggle theme sync` |
| 菜单栏 | `Super + Shift + Space` | `omarchy toggle bar` |
| 全屏桌面（无栏、无间隙） | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| 动画、模糊和阴影 | — | `omarchy toggle animations` |
| 触摸板 | `XF86TouchpadToggle` | `omarchy device touchpad` |
| 触摸屏 | — | `omarchy device touchscreen` |
| 挂起 | — | `omarchy toggle suspend` |
| 混合 GPU | — | `omarchy device gpu hybrid` |

触摸板、触摸屏和混合 GPU 开关位于 _Trigger > Hardware_（`Super + Ctrl + H`）下，而不是 Toggle 下，因为只有当你确实拥有该硬件时它们才会出现。触摸板和触摸屏开关在 Hyprland 重新加载后依然有效——被禁用设备的名称会保存到一个小的状态文件中，Hyprland 在启动时会读取它，再次禁用该设备。

_Appearance_ 中有菜单栏和动画，还有一些并非 `omarchy toggle` 命令但行为相同的功能：栏中的电池百分比、默认工作区布局，以及 _Windows_ 下的窗口间隙（`Super + Shift + Backspace`）和 1 窗口方形宽高比（`Super + Ctrl + Backspace`）。

当 Hyprland 没有 GPU 可用于绘制、转而在 CPU 上渲染时（llvmpipe），例如在 GPU 尚未受支持的 Mac 上、在大多数虚拟机中，或者图形驱动加载失败时，Omarchy 会在该会话中关闭动画、模糊和阴影，并用一条通知告诉你一次。_Appearance > Animations On_ 会将它们重新打开，Omarchy 也会为以后的会话记住这一点。

其中大多数只不过是 `~/.local/state/omarchy/toggles/` 下的一个标志文件。如果你想在脚本中根据其中之一进行分支，`omarchy-toggle-enabled` 会为你提供退出码，免得你亲自去查找：

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

这些标志以关闭状态命名——`screensaver-off`、`suspend-off`、`bar-off`——因此它们的存在即表示该功能已被禁用。

### 栏中的指示器

当某个模式开启时，你会在顶栏中间、时钟旁边看到一个小字形。那就是指示器小部件，它承载屏幕录制、待处理的提醒、夜间光、勿扰和保持唤醒，以及无密码 sudo 开启时或有人连接到远程会话时出现的警告。

未激活的指示器会被隐藏。将鼠标悬停在栏的任意位置，它们会以变暗的状态淡入，这样你无需知道其快捷键即可点击其中一个来开启它。点击已激活的指示器会将其关闭。如果你希望一直看到全部指示器，请在 `~/.config/omarchy/shell.json` 中为 `omarchy.indicators` 条目将 `alwaysShow` 设为 `true`——有关如何配置栏小部件，请参阅[顶栏](05-the-top-bar.md)。

### 夜间光

夜间光会将屏幕调暖至 4000K，再次切换则恢复到 6500K。通过开关菜单（`Super + Ctrl + O`）或 `omarchy toggle nightlight` 来切换它。它由 hyprsunset 驱动，如果 hyprsunset 尚未运行，切换开关会为你启动它。

默认情况下，hyprsunset 完全不会对你的屏幕做任何处理。`~/.config/hypr/hyprsunset.conf` 自带一个恒等配置文件，正是为了在你要求变暖之前让显示器保持原样。如果你更希望它按时钟切换，请将该文件替换为时间配置文件：

```
profile {
    time = 20:00
    temperature = 4000
}
```

然后将 `o.launch_on_start("hyprsunset")` 添加到 `~/.config/hypr/autostart.lua`，以便在登录时启动 hyprsunset。开关使用的 4000K/6500K 组合是固定的，因此如果你想要不同的色温，需要去修改配置文件。

### 勿扰

`Super + Ctrl + Alt + ,` 会让通知静音。开启时不会弹出任何提示弹窗，被划掉的铃铛指示器会停留在栏中，提醒你桌面为什么安静了下来。

但任何内容都不会丢失。被静音的通知会被延后：使用 `Super + Shift + Alt + ,` 将最近的几条重新显示到屏幕上。其余内容请参阅[通知](10-notices.md)。

有三种消息仍然可以穿透：Omarchy 自身针对你刚完成的操作显示的确认弹窗（"Theme changed"、"Screenshot saved"）、从命令行发出的关键警报，以及验证码。那些把一切都标记为关键、强行挤到你面前的聊天应用不在此列。

### 空闲

Omarchy shell 负责空闲行为，计时设置位于 `~/.config/omarchy/shell.json` 中的顶层 `idle` 块：

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

这两个数字都是从你进入空闲状态那一刻起计算的秒数，而不是从对方之后开始计算。因此，在默认设置下，屏幕保护程序会在两分半钟后出现，锁屏会在五分钟时接管，无论屏幕保护程序是否运行过。保存文件后，shell 会立即采用新的计时设置。

如果你在锁定截止时间之前关闭屏幕保护程序，这会被视为活动，待执行的锁定会被取消。你不会因为瞥了一眼电脑就被锁在外面。

要完全停止空闲锁定，`Super + Ctrl + I`——或 `omarchy toggle idle`——会开启保持唤醒，咖啡杯指示器会出现在栏中。在长时间的演示或你想盯着完成的构建之前，就应该点它。再点一次即可恢复正常。`omarchy toggle idle status` 会以 JSON 格式打印当前状态，供你在脚本中使用。

这里讨论的是锁定和屏幕保护程序，而不是电源。挂起和休眠有其自己的设置，详见[系统睡眠](36-system-sleep.md)。

### 屏幕保护程序

Omarchy 的屏幕保护程序是运行随机文本效果的 ASCII 艺术，每个显示器运行一个实例。按下任意键或移动鼠标即可退出。

你可以从 _System > Screensaver_（`Super + Esc`）按需启动它，即使你已关闭空闲屏幕保护程序，它也会强制出现。默认没有为它绑定快捷键。

如果你更想直接从工作状态进入锁定状态，`omarchy toggle screensaver` 即可关闭空闲屏幕保护程序。任意按键、点击、滚动或鼠标移动都会关闭它。

它绘制的徽标可以由你自行更改，位置在 _Appearance > Branding > Screensaver_ 下。上传 png 或 svg 文件，Omarchy 会将其转换为 ASCII。详见[品牌定制](41-branding.md)。

### 锁屏

`Super + Ctrl + L` 会锁定机器。这会运行 Omarchy shell 的锁屏、熄灭显示屏、将键盘布局重置为第一个布局，以免你用错误的字母输入密码，并且——如果你正在运行 1Password——会在离开时将其锁定。

锁屏接受密码，一旦你设置了指纹，也接受指纹。这一点以及其他身份验证方式，详见[硬件身份验证](37-hardware-authentication.md)。
