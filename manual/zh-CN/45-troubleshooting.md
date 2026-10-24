# 故障排除

### 我的系统被一次更新搞坏了！

首先尝试将你的系统[回滚](47-system-snapshots.md)到最近一次更新之前的版本。如果这不起作用，使用 `omarchy-debug` 在 Discord 的 #omarchy-help 频道中分享你的问题。如果这一切都失败了，你可以使用 `omarchy-reinstall` 重新安装默认配置和软件包。

### 为什么某些应用在我的显示器上那么大？

Omarchy 假设是 2 倍高分辨率显示器，这需要在 `~/.config/hypr/monitors.lua` 中将 `GDK_SCALE` 设置为 2。但如果你使用的是 1 倍显示器，你可以将 `local omarchy_gdk_scale = 2` 改为 1（然后重启任何过大的应用）。参见[关于显示器的手册](33-monitors.md)。

对于 Spotify，你可以使用 `Ctrl + Minus` 缩小 UI（使用 `Ctrl + Plus` 放大）。

### 我的 Wi-Fi、Bluetooth、音频或触控板突然停止工作了

在重启之前，试着单独重启出问题的子系统。Omarchy 菜单中的 _更新 > 硬件_ 有 Wi-Fi、Bluetooth、音频和触控板，重新加载其中之一能解决大多数“五分钟前还好好的”情况——比如 Bluetooth 耳机无法重新连接、触控板在一次挂起后无响应、拔掉显示器后声音消失。

### 为什么我的外置音箱没有声音？

可能是因为它们没有被设置为主输出。点击栏右侧的扬声器图标，它会打开音量弹窗，你可以在其中选择输出设备（还可以混合每个应用的音量）。

### 我的笔记本电脑扬声器听起来不对劲

在某些笔记本电脑上，Omarchy 会自动应用一个扬声器调音，用以校正内置扬声器的频率响应。`omarchy audio tuning status` 会告诉你你的机器上是否有一个处于激活状态，`omarchy audio tuning off` 会将其关闭，如果你更愿意听到扬声器原始的声音。

### 为什么我无法用我的密码登录或 sudo？

你很可能是输入错误太多次而被锁定了。如果这种情况发生在锁定屏幕上，你可以按 `CTRL + ALT + F2` 启动一个新的 TTY，在那里以 root 身份登录，然后运行 `faillock --reset --user [your-username]`。这将重置锁定状态，你就又可以正常使用了。

### 为什么我的 1Password SSH Agent / CLI 的 1Password 授权提示没有出现？

这可能有两个原因：

为了使丰富的批准提示出现，必须开启 Settings > Advanced > Use Hardware Acceleration。_注意：这需要重启后才能开始工作。_

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

或者，如果你自开机以来尚未启动过 1Password，该提示将不会出现。
