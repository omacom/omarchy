# 显示器

Omarchy 默认假定你正在使用一块支持 2x 的 retina 级别显示器。你需要这样的显示器，才能获得那些漂亮、锐利的编程字体。几乎所有配备高分辨率屏幕的新款高端笔记本，都是为此优化的。这也是你在 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或者 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上会想用的配置。

但如果你的显示器 PPI 没有达到 218 或以上，你就需要改一下显示器设置。例如，如果你有一台 27" 或 32" 4K 显示器，你可以打开 `~/.config/hypr/monitors.lua`（通过 Omarchy 菜单中的 _设置 > 显示器_），切换到针对这种组合的推荐值，从而使用分数缩放：

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

如果你用的是 1080p 或 1440p 显示器，你可能只想用 1x 缩放，所以可以用：

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

对 `GDK_SCALE` 的更改只会应用到更改后启动的应用程序（而且 GTK 只支持整数，所以请把它保持在最接近你的显示器缩放值的整数）。所以改完之后，务必退出那些尺寸过大的窗口（或者用 `Ctrl + Alt + Del` 关闭所有窗口！）。

你也可以用 `Super + /` 往上、`Super + Alt + /` 往下，快速在几个主要的显示器缩放比例（1x、1.25x、1.6x、2x、3x、4x）之间切换，或者从顶栏的显示器面板中选一个。这些更改只影响你当前聚焦的显示器，所以笔记本屏幕和外接显示器可以各有自己的缩放比例。这个选择会被保存到 `~/.config/hypr/monitors.lua`，作为针对那台显示器的一条 `hl.monitor` 规则，因此重启后依然有效，并且优先级高于 `omarchy_monitor_scale`；`omarchy_monitor_scale` 仍然是没有自己规则的每台显示器的缩放值。由于 `GDK_SCALE` 是所有屏幕共用的一个值，这些更改会按缩放值最低的那台显示器来设置它，这样 X11 应用在密度更高的屏幕上会稍微小一点，而不是在另一块屏幕上过大。

### 让文字变大或变小

显示器缩放会改变一切的大小。如果你只想让_文字_变大或变小，只有一个旋钮可以调：

```
omarchy display text size 14
```

它接受 9 到 20 之间的像素大小，并且会同时移动 Omarchy shell、GTK 应用程序和你的终端，这样整个桌面就能保持比例。不带参数运行它可以查看你当前的值，`omarchy display text size reset` 可以回到默认值。Foot 是唯一掉队的一个：它没有办法重新加载配置，所以正在运行的终端会保持旧大小，直到你打开一个新的。

### 扩展和镜像笔记本显示屏

当你把外接屏幕连接到笔记本时，显示会自动扩展。但你可以通过 Omarchy 菜单中的 _触发 > 硬件_ 或者 `Super + Ctrl + Alt + Delete`，把这一点改成镜像。如果那块外接屏幕是投影仪，而你想一边工作一边展示内容，这就特别有帮助。

当你处于扩展模式时，合上笔记本的盖子会自动关闭内置屏幕。打开盖子会把它重新打开。你也可以通过 Omarchy 菜单中的 _触发 > 硬件_ 或者 `Super + Ctrl + Delete` 手动控制这一点。

### 排列多块屏幕

Hyprland 对多块屏幕的支持非常出色。在 [Hyprland 显示器文档](https://wiki.hypr.land/Configuring/Basics/Monitors/) 中阅读更多关于如何排列它们的内容。在 Omarchy 中，这些设置以 `hl.monitor` 条目的形式写在 `~/.config/hypr/monitors.lua` 中——这个文件自带注释示例，用于把特定显示器固定到某个分辨率、位置和旋转方向。

每台显示器都有它自己的 1 到 10 号工作区，所以 `Super + 1` 永远意味着你所在显示器的第一个工作区。在后台，Hyprland 仍然会跨所有显示器给工作区编号：你的笔记本屏幕（或第一台显示器）获得 1–10，下一台显示器获得 11–20，以此类推，并且每次你插上时，每台显示器都会保留自己的那一段编号。如果你要为特定显示器编写[工作区规则](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)或窗口规则，就使用这些编号，所以工作区 12 就是你的第二台显示器的第二个工作区。`~/.local/state/omarchy/monitor-workspaces` 会列出每台显示器拥有的那一段编号。

方向键可以在布局中共享一条边的显示器之间工作。只在角落相接的屏幕，或者之间有间隙的屏幕，并不是邻居，所以请用 `Ctrl + Alt + Tab` 在它们之间切换。

| 快捷键 | 跨显示器 |
| --- | --- |
| `Super + Arrow` | 在那个方向上没有窗口剩下时，把焦点移到那一侧的显示器 |
| `Super + Shift + Arrow` | 与那一侧显示器上的一个窗口交换 |
| `Super + Alt + Arrow` | 把窗口移到那一侧显示器上的一个组中 |
| `Super + Shift + Ctrl + Arrow` | 把窗口移到那一侧的显示器，并放到它正在显示的工作区上 |
| `Super + Shift + Alt + Arrow` | 把工作区移到那一侧的显示器，如果它的编号空闲就保持该编号 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 把焦点移到下一台或上一台显示器，与布局无关 |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 停留在你所在的显示器上 |

你也可以看看 [Hyprmon](https://github.com/erans/hyprmon/)，如果你想要一个 TUI 来帮你定位多块屏幕的话。

### 控制亮度

显示器亮度由专用的亮度增/减功能键控制。如果你按住 Shift 同时按下这些键，你会直接跳到最大或最小亮度。这些键控制你当前聚焦的显示器，所以支持 DDC/CI 的外接显示器会以与笔记本屏幕相同的方式调节。

### Apple 显示器

如果你在用 Apple 显示器，常规的键盘亮度键也会自动工作，前提是你聚焦在 Apple 显示器上。这是通过 `asdcontrol` 命令实现的。

请注意，如果你在用 Apple 6K XDR 显示器，你可能会在 `hyprctl monitors` 列表中看到一个幽灵屏幕。你可以通过 _设置 > 显示器_，用类似 `hl.monitor({ output = "DP-2", disabled = true })` 的设置把它关掉。

在 Intel 机器上，你应该使用普通的 Thunderbolt 线缆连接 Apple 显示器。在其他没有 Thunderbolt 的机器上，你通常需要使用一根 [DP + USB-A -> USB-C 线缆](https://www.amazon.com/dp/B0BNX7MS6N) 才能让它工作。
