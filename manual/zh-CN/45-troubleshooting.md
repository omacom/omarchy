# 故障排查

### 我更新后把系统弄坏了！

首先尝试将你的系统[回滚](47-system-snapshots.md)到最近一次更新之前的版本。如果这不起作用，使用 `omarchy-debug` 在 Discord 的 #omarchy-help 中分享你的问题。如果这些都不行，你可以使用 `omarchy-reinstall` 重新安装默认配置和软件包。

### 为什么有些应用在我的显示器上显得这么大？

Omarchy 预设使用 2x 高分辨率显示器，这需要在 `~/.config/hypr/monitors.lua` 中将 `GDK_SCALE` 设为 2。但如果你用的是 1x 显示器，你可以将 `local omarchy_gdk_scale = 2` 改为 1（然后重启任何显示过大的应用）。参阅[关于显示器的手册](33-monitors.md)。

对于 Spotify，你可以使用 `Ctrl + Minus` 缩小界面（使用 `Ctrl + Plus` 放大界面）。

### 为什么我的所有 Super 键绑定都失效了？

在某些 ASUS ROG 和 TUF 笔记本上，`Fn + Super` 是一个很容易被忽略的组合键，它会切换固件级的 Windows 键锁定（这是为游戏设计的，避免你误触而意外离开游戏）。屏幕上不会有任何提示告诉你发生了这件事。锁定开启时，Super 完全不会发出任何信号——所以每个使用 Super 的 Omarchy 绑定都会失效，看起来就像 Hyprland 坏了一样。

在你深入翻 `~/.config/hypr/` 之前，先按一次 `Fn + Super`，如果这没有让 Super 恢复，再按一次，以免让锁定一直保持开启。这不是 Fn-lock，Fn-lock 只会改变 F 键行的功能。

### 我的 Wi-Fi、Bluetooth、音频或触控板突然停止工作了

在重启之前，先试着单独重启出问题的子系统。Omarchy 菜单中的_更新 > 硬件_里有 Wi-Fi、Bluetooth、音频和触控板，重新加载其中一项就能解决大多数“五分钟前还好好的”情况——Bluetooth 耳机无法重新连接、触控板在休眠唤醒后失灵、拔掉显示器后声音消失。

### 为什么我的外接音箱没有声音？

大概是因为它们没有被设为主要输出。点击栏右侧的扬声器图标，就会打开音量弹窗，你可以在那里选择输出设备（也可以按应用分别混合音量）。

### 我的笔记本扬声器听起来不对劲

在某些笔记本上，Omarchy 会自动应用一种扬声器调音，以校正内置扬声器的频率响应。`omarchy audio tuning status` 会告诉你你的机器上是否有一项调音处于活动状态，`omarchy audio tuning off` 则可以将其关闭，如果你更想听到扬声器未经处理的声音。

### 为什么我无法用密码登录或 sudo？

你大概是输错太多次，被锁定了。如果这发生在锁屏界面，你可以按 `CTRL + ALT + F2` 打开一个新的 TTY，在那里以 root 身份登录，然后运行 `faillock --reset --user [your-username]`。这会重置锁定状态，然后你就可以正常使用了。

### 为什么 1Password SSH Agent / CLI 的 1Password 授权提示没有出现？

这可能是由 2 个原因造成的：

要让丰富的审批提示出现，必须开启设置 > 高级 > 使用硬件加速。_注意：这需要重启后才能开始生效。_

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

或者，如果你开机后还没有启动过 1Password，提示也不会出现。
