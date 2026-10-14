# 显示器

Omarchy 默认假设你运行在一块支持 2x 的 retina 级显示器上。这是获得那些漂亮、锐利的编程字体所需要的。这几乎是所有带高分辨率屏幕的新高端笔记本电脑所优化的目标。这也是你想在 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上运行的。

但如果你没有运行 PPI 在 218 或以上的显示器，你会想要更改显示器设置。例如，如果你有一台 27" 或 32" 4K，你可以使用分数缩放，方法是打开 `~/.config/hypr/monitors.lua`（通过 Omarchy 菜单中的 _Setup > Monitors_）并切换到针对该组合的推荐值：

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

如果你使用的是 1080p 或 1440p 显示器，你可能只想用 1x 缩放，所以你可以使用：

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

对 `GDK_SCALE` 的更改适用于更改后启动的应用程序（并且 GTK 仅接受整数，所以将其保持在你显示器缩放比例最近的整数）。所以更改后，确保你退出那些你拥有的尺寸过大的窗口（或用 `Ctrl + Alt + Del` 关闭所有窗口！）。

你也可以使用 `Super + /` 增大，使用 `Super + Alt + /` 减小，快速步进主要的显示器缩放比例（1x、1.25x、1.6x、2x、3x、4x）。如果你有默认配置，这些更改也会在重启后保留。

### 让文本更大或更小

显示器缩放会改变一切的大小。如果你想要的只是更大或更小的_文本_，有一个单一的旋钮可以做到：

```
omarchy display text size 14
```

这接受 9 到 20 之间的像素大小，并同时移动 Omarchy shell、GTK 应用程序和你的终端，这样整个桌面保持比例。不带参数运行它可查看你当前的值，而 `omarchy display text size reset` 可回到默认。Foot 是唯一的落后者：它没有办法重新加载其配置，所以正在运行的终端会保持它们旧的大小，直到你打开一个新的。

### 扩展和镜像笔记本电脑显示屏

当你将外接屏幕连接到笔记本电脑时，显示屏会自动扩展。但你可以改而使用 Omarchy 菜单中的 _Trigger > Hardware_ 或 `Super + Ctrl + Alt + Delete` 将其改为镜像。如果那块外接屏幕是投影仪，而你想在工作时展示某些东西，这尤其有用。

当你扩展时，合上笔记本电脑的盖子会自动关闭内部屏幕。打开盖子会将其重新打开。你也可以使用 Omarchy 菜单中的 _Trigger > Hardware_ 或 `Super + Ctrl + Delete` 手动控制此功能。

### 布置多个屏幕

Hyprland 与多个屏幕配合得很好。在 [Hyprland 显示器文档](https://wiki.hypr.land/Configuring/Basics/Monitors/) 中了解更多关于如何布置它们的信息。你也可以[将特定的工作区绑定到特定的显示器](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)。在 Omarchy 中，这些规则作为 `hl.monitor` 条目放入 `~/.config/hypr/monitors.lua`——该文件附带了将特定显示器固定到分辨率、位置和旋转的注释示例。

你也可以看看 [Hyprmon](https://github.com/erans/hyprmon/)，如果你想要一个 TUI 来帮助你定位多个屏幕。

### 控制亮度

显示器亮度由专门的亮度增/减功能键控制。如果你按这些键时按住 shift，你会到达最大或最小亮度。这些键控制你聚焦的显示器，所以支持 DDC/CI 的外接显示器与笔记本电脑屏幕以相同方式调节。

### Apple 显示屏

如果你在使用 Apple 显示屏，常规的键盘亮度键也会自动工作，前提是你聚焦在 Apple 显示屏上。这是通过 `asdcontrol` 命令完成的。

请注意，如果你使用的是 Apple 6K XDR 显示屏，你可能会在 `hyprctl monitors` 列表中看到一个幽灵屏幕。你可以通过 _Setup > Monitors_ 使用类似 `hl.monitor({ output = "DP-2", disabled = true })` 的东西将其关闭。

在 Intel 机器上，你应该使用普通的 Thunderbolt 线缆连接到 Apple 显示屏。在其他没有 Thunderbolt 的机器上，你通常必须使用 [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) 才能使其工作。
