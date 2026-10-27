# 显示器

Omarchy 默认假定你运行在支持 2x 的 retina 级别显示器上。这正是获得那些漂亮、锐利的程序员字体所需要的。几乎所有配备高分辨率屏幕的新款高端笔记本都是为此优化的。如果你想在 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上运行，这也是你会想要的选择。

但如果你的显示器 PPI 没有达到 218 或以上，你就需要更改显示器设置。例如，如果你有一台 27" 或 32" 4K 显示器，你可以打开 `~/.config/hypr/monitors.lua`（通过 Omarchy 菜单中的 _Setup > Monitors_），并切换到针对该组合的推荐设置，来使用分数缩放：

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

如果你用的是 1080p 或 1440p 显示器，你可能只想使用 1x 缩放，这样你就可以用：

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

对 `GDK_SCALE` 的更改会应用到更改后启动的应用（而且 GTK 只支持整数，所以请将其保持在最接近你的显示器缩放比例的整数）。所以务必退出更改后尺寸过大的那些窗口（或者用 `Ctrl + Alt + Del` 关闭所有窗口！）。

你还可以使用 `Super + /` 快速调高、使用 `Super + Alt + /` 调低，在主要显示器缩放比例（1x、1.25x、1.6x、2x、3x、4x）之间逐步切换。如果你使用默认配置，这些更改在重启后也会保留。

### 让文字变大或变小

显示器缩放会改变所有内容的大小。如果你只想让_文字_变大或变小，有一个专门的旋钮可以调：

```
omarchy display text size 14
```

它接受 9 到 20 之间的像素大小，并会同时调整 Omarchy shell、GTK 应用和你的终端，让整个桌面保持比例一致。不带参数运行它可以查看你当前的值，运行 `omarchy display text size reset` 可以恢复默认值。Foot 是唯一的掉队者：它无法重新加载其配置，所以正在运行的终端会保持旧大小，直到你打开一个新的。

### 扩展和镜像笔记本显示器

当你把外接屏幕连接到笔记本时，显示器会自动扩展。但你可以通过 Omarchy 菜单中的 _Trigger > Hardware_ 或 `Super + Ctrl + Alt + Delete` 将其改为镜像。如果那块外接屏幕是投影仪，而你想一边工作一边展示内容，这尤其有帮助。

在扩展模式下，合上笔记本盖子会自动关闭内置屏幕。打开盖子会重新开启它。你也可以通过 Omarchy 菜单中的 _Trigger > Hardware_ 或 `Super + Ctrl + Delete` 手动控制这一行为。

### 排列多块屏幕

Hyprland 对多块屏幕的支持非常出色。有关如何布局它们的更多信息，请阅读 [Hyprland 显示器文档](https://wiki.hypr.land/Configuring/Basics/Monitors/)。在 Omarchy 中，这些配置以 `hl.monitor` 条目的形式写在 `~/.config/hypr/monitors.lua` 中——该文件自带注释示例，用于将特定显示器固定到某个分辨率、位置和旋转方向。

每台显示器都有自己独立的 1 到 10 号工作区，所以 `Super + 1` 始终表示你当前所在显示器的第一个工作区。在底层，Hyprland 仍然会跨所有显示器为工作区编号：你的笔记本屏幕（或第一台显示器）获得 1–10，下一台显示器获得 11–20，依此类推，而且每次你接入时，每台显示器都会保留它的编号块。如果你为特定显示器编写[工作区规则](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)或窗口规则，请使用这些编号，所以工作区 12 就是你第二台显示器的第二个工作区。`~/.local/state/omarchy/monitor-workspaces` 会列出每台显示器拥有的编号块。

方向键可以在布局中共用一条边缘的显示器之间工作。只在一个角相接、或之间有间隙的屏幕不算相邻，所以请用 `Ctrl + Alt + Tab` 在它们之间切换。

| 快捷键 | 跨显示器 |
| --- | --- |
| `Super + Arrow` | 当该方向上没有剩余窗口时，将焦点移到那一侧的显示器 |
| `Super + Shift + Arrow` | 与那一侧显示器上的窗口交换 |
| `Super + Alt + Arrow` | 将窗口移到那一侧显示器上的一个组中 |
| `Super + Shift + Ctrl + Arrow` | 将窗口移到那一侧的显示器上，放到它正在显示的工作区 |
| `Super + Shift + Alt + Arrow` | 将工作区移到那一侧的显示器上，如果其编号空闲则保持不变 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 将焦点移到下一台或上一台显示器，不受布局影响 |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | 停留在你当前所在的显示器上 |

你也可以看看 [Hyprmon](https://github.com/erans/hyprmon/)，如果你想用一个 TUI 来帮你定位多块屏幕的话。

### 控制亮度

显示器亮度由专用的亮度增减功能键控制。如果你在按这些键时按住 Shift，你会直接跳到最大或最小亮度。这些键控制你当前聚焦的显示器，所以支持 DDC/CI 的外接显示器会以与笔记本屏幕相同的方式进行调整。

### Apple 显示器

如果你使用的是 Apple 显示器，只要你聚焦在 Apple 显示器上，常规的键盘亮度键也会自动工作。这是通过 `asdcontrol` 命令实现的。

请注意，如果你使用的是 Apple 6K XDR 显示器，你可能会在你的 `hyprctl monitors` 列表中看到一个幻影屏幕。你可以通过 _Setup > Monitors_ 使用类似 `hl.monitor({ output = "DP-2", disabled = true })` 的内容将其关闭。

在 Intel 机器上，你应该使用普通的 Thunderbolt 线缆连接 Apple 显示器。在其他没有 Thunderbolt 的机器上，你通常必须使用一根 [DP + USB-A 转 USB-C 线缆](https://www.amazon.com/dp/B0BNX7MS6N) 才能让它工作。
