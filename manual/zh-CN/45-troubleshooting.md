# 故障排除

### 我把系统更新坏了！

先尝试[将你的系统回滚](47-system-snapshots.md)到最近一次更新之前的版本。如果不行，请使用 `omarchy-debug` 在 Discord 的 #omarchy-help 频道里分享你的问题并寻求帮助。如果这些都不行，你可以使用 `omarchy-reinstall` 重新安装默认配置和软件包。

### 为什么有些应用在我的显示器上显得这么大？

Omarchy 默认使用的是 2x 高分辨率显示器，所以在你在显示器面板中选择缩放比例之前，它会将 `GDK_SCALE` 设置为 2。如果你用的是 1x 显示器，而 GTK 或 X11 应用显示得过大，请在显示器面板中为它选择 1x，或者将 `hl.env("GDK_SCALE", "1")` 添加到 `~/.config/hypr/monitors.lua`（然后重启任何显示过大的应用）。请参阅[显示器手册](33-monitors.md)。

对于 Spotify，你可以使用 `Ctrl + Minus` 缩小界面（使用 `Ctrl + Plus` 放大界面）。

### 为什么我所有的 Super 按键绑定都停止工作了？

在某些 ASUS ROG 和 TUF 笔记本电脑上，`Fn + Super` 是一个很容易误触的组合键，它会切换固件层面的 Windows 键锁定功能（这是为游戏设计的，这样你就不会误触退出游戏）。屏幕上不会有任何提示告诉你发生了这件事。锁定开启时，Super 完全不会发出任何信号——所以每个使用 Super 的 Omarchy 绑定都会停止工作，看起来就像 Hyprland 坏了一样。

在你深入研究 `~/.config/hypr/` 之前，先按一次 `Fn + Super`，如果 Super 还没有恢复，再按一次，这样你就不会让锁定一直开着。这不是 Fn-lock，Fn-lock 只会改变 F 键那一排的功能。

### 我的 Wi-Fi、Bluetooth、音频或触控板突然停止工作了

在重启之前，先试着单独重启出问题的子系统。Omarchy 菜单中的 _Update > Hardware_ 里有 Wi-Fi、Bluetooth、Audio 和 Trackpad，重新加载其中一个就能解决大多数“五分钟前还好好的”情况——比如 Bluetooth 耳机无法重新连接、触控板在挂起后失效、拔掉显示器后声音消失。

### 为什么我的外接音箱没有声音？

很可能是因为它们没有被设置为主要输出设备。点击顶部栏右侧的扬声器图标，它会打开音量弹窗，你可以在那里选择输出设备（还可以为每个应用单独调节音量）。

### 我的笔记本电脑扬声器听起来不对劲

在某些笔记本电脑上，Omarchy 会自动应用扬声器调音，校正内置扬声器的频率响应。`omarchy audio tuning status` 会告诉你你的机器上是否有调音正在生效，`omarchy audio tuning off` 可以将其关闭，如果你更想听扬声器未经处理的声音的话。

### 为什么我无法用密码登录或执行 sudo？

你很可能输错了十次，然后被锁定了。锁定会在两分钟后自动解除。如果你等不了，而且这发生在锁屏界面，你可以按 `CTRL + ALT + F2` 启动一个新的 TTY，在那里以 root 身份登录，然后运行 `faillock --reset --user [your-username]`。这会重置锁定，然后你就可以正常使用了。

### 我的密码被接受了，但我又回到了登录界面

即使密码正确，损坏的会话环境文件也可能阻止桌面启动。如果你编辑过 `~/.config/uwsm/env.d/`，这一点尤其值得检查。

按 `Ctrl + Alt + F2`，用你平常的用户名和密码登录，然后查看当前这次启动的用户日志：

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

查找指出你的某个环境文件出错的错误信息，比如 `bad substitution`，它就出现在一条提示未找到 env 输出标记的消息之前。在再次尝试登录之前，将该文件移出 `env.d`。例如，如果错误指向 `99-custom`：

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM 会跳过有语法错误的文件，但只在文件运行时才会出现的致命错误，比如 `bad substitution`，仍然可能阻止桌面启动。系统快照回滚并不能修复这些文件，因为 `/home` 不会被回滚。

等你能登录之后，在把保存的副本移回去之前先修复它。`sh -n` 可以在不运行文件的情况下捕获语法错误，但无法捕获所有在被 source 时才会发生的错误。测试更改时，请保持一个可用的终端开着。

### 为什么 1Password SSH Agent / CLI 的 1Password 授权提示没有出现？

这可能由以下 2 个原因造成：

要让内容丰富的批准提示出现，必须打开 Settings > Advanced > Use Hardware Acceleration。_注意：这需要重启后才能开始生效。_

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

或者，如果你开机后还没有启动过 1Password，提示也不会出现。
