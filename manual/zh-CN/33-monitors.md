# 显示器

Omarchy 默认假设你正在使用支持 2x 缩放的 retina 级显示器。这正是你获得那些漂亮、清晰的编程字体所需要的。几乎所有配备高分辨率屏幕的新款高端笔记本都是为此优化的。这也是你会想在 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上运行的配置。

但如果你使用的显示器 PPI 没有达到 218 或以上，你就需要更改显示器设置。例如，如果你有一台 27" 或 32" 4K 显示器，你可以从顶栏的显示器面板中为它选择一个分数缩放，或者打开 `~/.config/hypr/monitors.lua`，切换到针对该组合的推荐设置，为每一台显示器设置默认值：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

如果你使用的是 1080p 或 1440p 显示器，你可能只想使用 1x 缩放，GTK 和 X11 应用也同样如此，这样你就可以使用：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

对 `GDK_SCALE` 的更改适用于更改后启动的应用（而且 GTK 只支持整数，所以请把它保持在与你的显示器缩放最接近的整数）。所以更改后，一定要退出那些尺寸过大的窗口（或者用 `Ctrl + Alt + Del` 关闭所有窗口！）。

你也可以使用 `Super + /` 快速在主要的显示器缩放比例（1x、1.25x、1.6x、2x、3x、4x）之间逐步调高，使用 `Super + Alt + /` 逐步调低，或者从顶栏的显示器面板中选择一个。这些只会更改你当前聚焦的显示器，所以笔记本屏幕和外接显示器可以各有自己的缩放。面板还可以设置每台显示器的分辨率、刷新率和旋转。你的选择会针对那台物理显示器保存在 `~/.local/state/omarchy/monitors/settings` 中，所以它们在重启后依然保留，并会跟随显示器到它下一次插入的任何端口或扩展坞。它们优先于 `~/.config/hypr/monitors.lua` 中针对同一台显示器的任何规则，而 Omarchy 永远不会编辑那个文件。如果你更愿意完全在那个文件中设置你的显示器，就把 `omarchy_monitor_panel_settings = false` 添加到其中，面板所做的更改就只会持续到 Hyprland 重新加载为止。由于 `GDK_SCALE` 是所有屏幕共用的一个值，所选的缩放会根据缩放最低的那台显示器来设置它，这样 X11 应用在密度更高的屏幕上会显得小一点，而不是在另一块屏幕上过大。

### 让文字变大或变小

显示器缩放会改变一切的大小。如果你只想要更大或更小的_文字_，这里有一个单独的旋钮可以调：

```
omarchy display text size 14
```

它接受 9 到 20 之间的像素大小，并会让 Omarchy shell、GTK 应用和你的终端一起移动，这样整个桌面就保持了比例。不带参数运行它可以查看你当前的状态，而 `omarchy display text size reset` 可以恢复默认值。Foot 是唯一一个掉队的：它没有办法重新加载自己的配置，所以正在运行的终端会保持旧的大小，直到你打开一个新的。

### 扩展和镜像笔记本显示器

当你将外接屏幕连接到笔记本时，显示会自动扩展。但你可以通过顶栏显示器面板中的 _Extend_ | _Mirror_、Omarchy 菜单中的 _Trigger > Hardware_，或 `Super + Ctrl + Alt + Delete` 将其改为镜像。这在外接屏幕是投影仪、你想一边工作一边展示某些内容时特别有帮助。

当你处于扩展状态时，合上笔记本盖子会自动关闭内置屏幕。打开盖子则会重新开启它。你也可以使用 Omarchy 菜单中的 _Trigger > Hardware_ 或 `Super + Ctrl + Delete` 手动控制这一行为。

当笔记本接通电源时，合上盖子永远不会让它进入睡眠，所以即使外接屏幕短暂断开连接，处于扩展坞上的笔记本也会保持清醒。在没有连接外接屏幕时，接通电源合上盖子只会锁定它。在电池供电时，合上盖子会像往常一样挂起。

### 排列多块屏幕

Hyprland 与多块屏幕配合得很好。顶栏中的显示器面板会按它们所在的位置绘制它们：将一台拖到另一台的侧边即可将它移动到那里，排列方式会与每台显示器的其他设置一同保存。对于面板未涵盖的任何内容，请在 [Hyprland 显示器文档](https://wiki.hypr.land/Configuring/Basics/Monitors/) 中阅读更多关于如何布局它们的内容。在 Omarchy 中，这些设置以 `hl.monitor` 条目的形式放在 `~/.config/hypr/monitors.lua` 中——该文件附带了注释示例，用于保持某台显示器关闭、面板未提供的模式、10-bit 颜色和可变刷新率。

每台显示器都拥有自己的 1 到 10 号工作区，所以 `Super + 1` 始终表示你所在显示器的第一个工作区。在幕后，Hyprland 仍然在所有显示器之间对工作区进行编号：你的笔记本屏幕（或第一台显示器）获得 1–10，下一台显示器获得 11–20，依此类推，并且每台显示器在你每次插入时都会保留自己的区块。如果你针对某台特定显示器编写 [workspace rules](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) 或窗口规则，请使用这些编号，这样工作区 12 就是你的第二台显示器的第二个工作区。`~/.local/state/omarchy/monitors/workspaces` 列出了每台显示器拥有的区块。

方向键可以在布局中共享一条边的显示器之间工作。只在一个角相接触、或之间有间隙的屏幕不是邻居，所以请使用 `Ctrl + Alt + Tab` 在它们之间切换。

| 快捷键 | 跨显示器 |
| --- | --- |
| `Super + Arrow` | 当该方向上没有窗口剩下时，将焦点移动到那一侧的显示器 |
| `Super + Shift + Arrow` | 与那一侧显示器上的一个窗口交换 |
| `Super + Alt + Arrow` | 将窗口移动到那一侧显示器上的一个组中 |
| `Super + Shift + Ctrl + Arrow` | 将窗口移动到那一侧的显示器，放到它正在显示的工作区上 |
| `Super + Shift + Alt + Arrow` | 将工作区移动到那一侧的显示器，如果其编号空闲则保持不变 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 将焦点移动到下一台或上一台显示器，无论布局如何 |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 停留在你所在的显示器上 |

你也可以看看 [Hyprmon](https://github.com/erans/hyprmon/)，如果你想要一个 TUI 来帮助你定位多块屏幕的话。

### 控制亮度

显示器亮度由专用的亮度增/减功能键控制。如果你按住 shift 的同时按下这些键，你会调到最大或最小亮度。这些键控制你聚焦的那台显示器，所以支持 DDC/CI 的外接显示器会以与笔记本屏幕相同的方式进行调节。

### Apple 显示器

如果你使用的是 Apple 显示器，那么当你聚焦在 Apple 显示器上时，常规的键盘亮度键也会自动工作。这是通过 `asdcontrol` 命令实现的。

请注意，如果你使用的是 Apple 6K XDR 显示器，你可能会在 `hyprctl monitors` 列表中看到一个幻影屏幕。你可以在 `~/.config/hypr/monitors.lua` 中用类似 `hl.monitor({ output = "DP-2", disabled = true })` 的设置将其关闭。

在 Intel 机器上，你应该使用常规的 Thunderbolt 线缆连接 Apple 显示器。在其他没有 Thunderbolt 的机器上，你通常必须使用 [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) 才能让它工作。
