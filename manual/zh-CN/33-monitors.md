# 显示器

Omarchy 默认假设你运行的是一块支持 2x 的 Retina 级显示器。这正是你获得那些漂亮、清晰的编程字体所需要的。这几乎是所有配备高分辨率屏幕的新款高端笔记本都为之优化的配置。这也是你会想在 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上运行的配置。

但如果你运行的显示器 PPI 没有达到 218 或以上，你就需要更改显示器设置。例如，如果你有一台 27" 或 32" 4K 显示器，你可以从顶栏的显示器面板中为它选择一个分数缩放比例，或者打开 `~/.config/hypr/monitors.lua` 并切换到针对该组合的推荐设置，为每一台显示器设置默认值：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

如果你使用的是 1080p 或 1440p 显示器，你大概只需要使用 1x 缩放，GTK 和 X11 应用也同样如此，因此你可以使用：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` 的更改只会应用于更改后启动的应用程序（并且 GTK 只接受整数，所以请将其保持为最接近你的显示器缩放比例的整数）。所以请确保在更改后退出那些你打开的、尺寸过大的窗口（或者用 `Ctrl + Alt + Del` 关闭所有窗口！）。

你还可以使用 `Super + /` 调高、使用 `Super + Alt + /` 调低，快速逐步切换主要的显示器缩放比例（1x、1.25x、1.6x、2x、3x、4x），或者从顶栏的显示器面板中选择一个。这些设置只会更改你当前聚焦的显示器，因此笔记本屏幕和外接显示器可以各自拥有自己的缩放比例。该面板还会设置每台显示器的分辨率、刷新率和旋转方向。你的选择会针对那台物理显示器保存在 `~/.local/state/omarchy/monitors/settings` 中，因此它们在重启后依然保留，并且会跟随该显示器，无论它下次插入哪个端口或扩展坞。它们优先于 `~/.config/hypr/monitors.lua` 中针对同一台显示器的任何规则，而 Omarchy 永远不会编辑那个文件。如果你更愿意完全在那个文件中设置你的显示器，请在其中添加 `omarchy_monitor_panel_settings = false`，这样面板所做的更改只会持续到 Hyprland 重新加载为止。由于 `GDK_SCALE` 是适用于所有屏幕的单一值，所选的缩放会根据缩放比例最低的那台显示器来设置它，这样 X11 应用在密度更高的屏幕上会显得小一点，而不是在另一台屏幕上过大。

### 让文字变大或变小

显示器缩放会改变所有内容的大小。如果你只想让_文字_变大或变小，只有一个旋钮可以调：

```
omarchy display text size 14
```

它接受 9 到 20 之间的像素大小，并会同时移动 Omarchy shell、GTK 应用程序和你的终端，让整个桌面保持比例协调。不带参数运行它可以查看你当前的值，使用 `omarchy display text size reset` 则可以恢复为默认值。Foot 是唯一拖后腿的：它没有重新加载其配置的方法，所以已经运行的终端会保持其旧大小，直到你打开一个新的。

### 扩展和镜像笔记本显示器

当你将外接屏幕连接到笔记本时，显示会自动扩展。但你可以通过顶栏显示器面板中的 _扩展_ | _镜像_、Omarchy 菜单中的 _Trigger > Hardware_，或者 `Super + Ctrl + Alt + Delete`，将其改为镜像。这在那台外接屏幕是投影仪、而你想一边工作一边展示内容时特别有帮助。

当你正在扩展时，合上笔记本的盖子会自动关闭内建屏幕。打开盖子会将其重新打开。你也可以使用 Omarchy 菜单中的 _Trigger > Hardware_ 或 `Super + Ctrl + Delete` 手动控制这一点。

### 排列多个屏幕

Hyprland 在多个屏幕下工作得很好。顶栏的显示器面板会按它们实际所在的位置绘制它们：将一台拖到另一台的侧边即可将它移动到那里，并且该排列会与每台显示器的其他设置一起保存。对于面板未涵盖的任何内容，请在 [Hyprland 显示器文档](https://wiki.hypr.land/Configuring/Basics/Monitors/) 中阅读更多关于如何排列它们的信息。在 Omarchy 中，这些设置以 `hl.monitor` 条目的形式写入 `~/.config/hypr/monitors.lua`——该文件附带了注释示例，用于保持显示器关闭、使用面板不提供的模式、10-bit 颜色以及可变刷新率。

每台显示器都有自己的 1 到 10 号工作区，因此 `Super + 1` 始终表示你所在显示器的第一个工作区。在幕后，Hyprland 仍然会跨所有显示器对工作区进行编号：你的笔记本屏幕（或第一台显示器）获得 1–10 号，下一台显示器获得 11–20 号，依此类推，并且每台显示器每次插入时都会保留自己的编号块。如果你为特定显示器编写[工作区规则](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)或窗口规则，请使用这些编号，这样工作区 12 就是你的第二台显示器的第二个工作区。`~/.local/state/omarchy/monitors/workspaces` 列出了每台显示器拥有的编号块。

箭头键可以在你的布局中共用一条边的显示器之间工作。仅在角落相触或之间有间隙的屏幕不是邻居，因此请使用 `Ctrl + Alt + Tab` 在它们之间切换。

| 快捷键 | 跨显示器 |
| --- | --- |
| `Super + Arrow` | 在该方向上再没有窗口后，将焦点移至那一侧的显示器 |
| `Super + Shift + Arrow` | 与那一侧显示器上的一个窗口交换 |
| `Super + Alt + Arrow` | 将窗口移入那一侧显示器上的一个组 |
| `Super + Shift + Ctrl + Arrow` | 将窗口移至那一侧的显示器，并放到它正在显示的工作区上 |
| `Super + Shift + Alt + Arrow` | 将工作区移至那一侧的显示器，如果其编号空闲则保持该编号 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 将焦点移至下一台或上一台显示器，无论布局如何 |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 停留在你所在的显示器上 |

你还可以看看 [Hyprmon](https://github.com/erans/hyprmon/)，如果你想要一个 TUI 来帮助你定位多个屏幕。

### 控制亮度

显示器亮度由专用的亮度调高/调低功能键控制。如果你在按下这些键时按住 Shift，你将直接达到最大或最小亮度。这些键控制你当前聚焦的显示器，因此支持 DDC/CI 的外接显示器会以与笔记本屏幕相同的方式进行调整。

### Apple 显示器

如果你使用的是 Apple 显示器，只要你聚焦在该 Apple 显示器上，常规的键盘亮度键也会自动工作。这是通过 `asdcontrol` 命令实现的。

请注意，如果你使用的是 Apple 6K XDR 显示器，你可能会在你的 `hyprctl monitors` 列表中看到一个幻影屏幕。你可以在 `~/.config/hypr/monitors.lua` 中用类似 `hl.monitor({ output = "DP-2", disabled = true })` 的设置将其关闭。

在 Intel 机器上，你应该使用普通的 Thunderbolt 线缆连接 Apple 显示器。在其他没有 Thunderbolt 的机器上，你通常必须使用一根 [DP + USB-A -> USB-C 线缆](https://www.amazon.com/dp/B0BNX7MS6N) 才能让它工作。
