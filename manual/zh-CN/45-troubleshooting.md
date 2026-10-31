# 故障排除

### 我更新时把系统搞坏了！

首先尝试[将系统回滚](47-system-snapshots.md)到你最近一次更新之前的版本。如果不起作用，在 Discord 的 #omarchy-help 中使用 `omarchy-debug` 分享你的问题。如果这些都失败了，你可以使用 `omarchy-reinstall` 重新安装默认配置和软件包。

### 为什么有些应用在我的显示器上显得这么大？

Omarchy 假设你使用的是 2x 高分辨率显示器，所以在你在显示器面板中选择缩放比例之前，它会将 `GDK_SCALE` 设置为 2。如果你使用的是 1x 显示器，而 GTK 或 X11 应用显示得过大，在显示器面板中为它选择 1x，或者将 `hl.env("GDK_SCALE", "1")` 添加到 `~/.config/hypr/monitors.lua`（然后重新启动任何显示过大的应用）。请参阅[有关显示器的手册](33-monitors.md)。

对于 Spotify，你可以使用 `Ctrl + Minus` 缩小 UI（使用 `Ctrl + Plus` 将其放大）。

### 为什么我所有的 Super 键绑定都停止工作了？

在某些 ASUS ROG 和 TUF 笔记本电脑上，`Fn + Super` 是个很容易被忽略的组合键，它会切换固件中的 Windows 键锁定（这是为游戏设计的，这样你就不会意外离开游戏）。屏幕上不会有任何东西告诉你发生了这件事。锁定开启时，Super 完全不会发出任何信号——所以每一个使用 Super 的 Omarchy 绑定就都停止了，看起来就像 Hyprland 坏了一样。

在你深入研究 `~/.config/hypr/` 之前，先按一次 `Fn + Super`，如果这没有让 Super 恢复，再按一次，这样你就不会把锁定留在开启状态。这不是 Fn-lock，Fn-lock 只会改变 F 键那一排的功能。

### 我的 Wi-Fi、Bluetooth、音频或触控板突然停止工作了

在重启之前，先试着单独重新启动出问题的那个子系统。Omarchy 菜单中的 _Update > Hardware_ 有 Wi-Fi、Bluetooth、Audio 和 Trackpad，重新加载其中之一就能解决绝大多数“五分钟前还好好的”的情况——Bluetooth 耳机无法重新连接、触控板在挂起后失灵、你拔掉一台显示器后声音消失了。

### 为什么我的外置扬声器没有声音？

很可能是因为它们没有被设为主要输出设备。点击顶部栏右侧的扬声器图标，它会打开音量弹窗，你可以在其中选择输出设备（也可以分别混合每个应用的音量）。

### 我的笔记本扬声器听起来不对劲

在某些笔记本电脑上，Omarchy 会自动应用一种扬声器调校，来校正内置扬声器的频率响应。`omarchy audio tuning status` 会告诉你你的机器上是否有调校处于活动状态，而 `omarchy audio tuning off` 会关闭它，如果你更愿意听扬声器未调校的声音的话。

### 为什么我不能用密码登录或 sudo？

你可能输错了太多次密码，然后被锁定了。如果这发生在锁屏界面上，你可以按 `CTRL + ALT + F2` 启动一个新的 TTY，你可以在其中以 root 身份登录，然后运行 `faillock --reset --user [your-username]`。这会重置锁定，然后你就没问题了。

### 我的密码被接受了，但我又回到了登录界面

一个损坏的会话环境文件可能会阻止桌面启动，即便你的密码是正确的。在编辑了 `~/.config/uwsm/env.d/` 之后，这一点尤其值得检查。

按 `Ctrl + Alt + F2`，用你平常的用户名和密码登录，并检查本次启动的用户日志：

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

寻找一条指明你的某个环境文件的错误，例如 `bad substitution`，它就出现在一条说未找到 env 输出标记的消息之前。在再次尝试登录之前，把那个文件从 `env.d` 中移出去。例如，如果错误指出的是 `99-custom`：

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM 会跳过一个有语法错误的文件，但像 `bad substitution` 这样只有在文件运行时才会出现的致命错误，仍然可能阻止桌面启动。系统快照回滚不会修复这些文件，因为 `/home` 不会被回滚。

等你能登录之后，在把保存的副本移回去之前先把它修好。`sh -n` 能在不运行文件的情况下发现语法错误，但无法发现它被 source 时发生的每一个错误。在测试修改时，保持一个可用的终端打开。

### 为什么我用于 1Password SSH Agent / CLI 的 1Password 授权提示没有出现？

这有 2 个原因：

为了让功能丰富的批准提示出现，必须打开 Settings > Advanced > Use Hardware Acceleration。_注意：这需要重启后才能开始生效。_

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

或者，如果你自开机以来还没有启动过 1Password，提示就不会出现。
