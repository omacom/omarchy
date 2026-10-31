# 故障排查

### 我更新时把系统搞坏了！

首先尝试[回滚你的系统](47-system-snapshots.md)到最近一次更新之前的版本。如果不起作用，使用 `omarchy-debug` 在 Discord 的 #omarchy-help 里分享你的问题。如果这些都不行，你可以使用 `omarchy-reinstall` 重新安装默认配置和软件包。

### 为什么某些应用在我的显示屏上这么大？

Omarchy 默认你使用的是 2x 高分辨率显示屏，因此在你于显示器面板中选择缩放比例之前，它会把 `GDK_SCALE` 设为 2。如果你用的是 1x 显示屏，而 GTK 或 X11 应用显示得过大，在显示器面板中为它选择 1x，或者将 `hl.env("GDK_SCALE", "1")` 添加到 `~/.config/hypr/monitors.lua`（然后重启任何显示过大的应用）。参阅[显示器手册](33-monitors.md)。

对于 Spotify，你可以使用 `Ctrl + Minus` 缩小界面（使用 `Ctrl + Plus` 则放大）。

### 为什么我的所有 Super 键绑定都失效了？

在某些 ASUS ROG 和 TUF 笔记本上，`Fn + Super` 是一个很容易忽略的组合键，它会切换固件的 Windows 键锁定（本意是用于游戏，这样你就不会意外退出游戏）。屏幕上不会有任何提示告诉你这发生了。锁定开启时，Super 完全不发出任何信号——所以每个使用 Super 的 Omarchy 绑定都会失效，看起来就像是 Hyprland 坏了。

在你深入研究 `~/.config/hypr/` 之前，先按一次 `Fn + Super`，如果这没有让 Super 恢复，再按一次，以免让锁定保持开启。这不是 Fn-lock，Fn-lock 只会改变 F 键那一行的功能。

### 我的 Wi-Fi、Bluetooth、音频或触控板突然不工作了

在你重启之前，先试着单独重启出问题的子系统。Omarchy 菜单里的 _Update > Hardware_ 有 Wi-Fi、Bluetooth、Audio 和 Trackpad，重新加载其中一项能解决大多数“五分钟前还好好的”的情况——Bluetooth 耳机无法重新连接、触控板在挂起后失效、拔掉显示器后声音消失。

### 为什么我的外接音箱没有声音？

很可能是因为它们没有被设为主要输出。点击栏右侧的音箱图标，它会打开音量弹出窗口，你可以在那里选择输出设备（还可以按应用混合音量）。

### 我的笔记本音箱听起来不对劲

在某些笔记本上，Omarchy 会自动应用一种音箱调校来校正内置音箱的频率响应。`omarchy audio tuning status` 会告诉你你的机器上是否有调校在生效，而 `omarchy audio tuning off` 可以将其关闭，如果你更喜欢听音箱原始的声音。

### 为什么我无法用密码登录或 sudo？

你很可能输错太多次而被锁定了。如果这发生在锁屏界面，你可以按 `CTRL + ALT + F2` 启动一个新的 TTY，在那里以 root 身份登录，然后运行 `faillock --reset --user [your-username]`。这会重置锁定，然后你就可以继续了。

### 为什么我的 1Password SSH Agent / CLI 的 1Password 授权提示没有出现？

这可能由 2 个原因导致：

要让丰富的批准提示出现，必须打开 Settings > Advanced > Use Hardware Acceleration。_注意：这需要重启后才能开始生效。_

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

或者，如果你自开机以来没有启动过 1Password，提示就不会出现。
