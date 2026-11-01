# 显示器

Omarchy 默认假设你运行在一块支持 2x 的 retina 级显示器上。你需要这样的显示器，才能得到那种漂亮、锐利的编程字体。这也是几乎所有配备高分辨率屏幕的新款高端笔记本所针对的优化方向。这也是你会想搭配在 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上使用的设置。

但如果你的显示器 PPI 没有达到 218 或以上，你就需要更改显示器设置。例如，如果你有一台 27" 或 32" 4K 显示器，你可以从顶栏的显示器面板中为它选择一个分数缩放比例，或者通过打开 `~/.config/hypr/monitors.lua` 并切换到针对该组合的推荐设置，来为每台显示器设置默认值：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

如果你使用的是 1080p 或 1440p 显示器，你可能只想使用 1x 缩放，并让 GTK 和 X11 应用也同样如此，这样你就可以使用：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

对 `GDK_SCALE` 的更改只适用于更改后启动的应用程序（而且 GTK 只接受整数，所以请将它保持为最接近你的显示器缩放值的整数）。所以务必在更改后退出那些尺寸过大的窗口（或者用 `Ctrl + Alt + Del` 关闭所有窗口！）。

你也可以使用 `Super + /` 快速向上切换主要的显示器缩放比例（1x、1.25x、1.6x、2x、3x、4x），用 `Super + Alt + /` 向下切换，或者从顶栏的显示器面板中挑选一个。这些设置只更改你当前聚焦的显示器，所以笔记本屏幕和外接显示器可以各有各自的缩放比例。该面板还可以设置每台显示器的分辨率、刷新率和旋转。你的选择会针对那台物理显示器保存在 `~/.local/state/omarchy/monitors/settings` 中，所以重启后依然有效，而且无论显示器下次插入哪个接口或扩展坞，都会跟随它。这些设置优先于 `~/.config/hypr/monitors.lua` 中针对同一台显示器的任何规则，而 Omarchy 永远不会编辑那个文件。如果你更愿意完全在那个文件中设置显示器，给它加上 `omarchy_monitor_panel_settings = false`，面板所做的更改就只会持续到 Hyprland 重新加载为止。由于 `GDK_SCALE` 对所有屏幕是同一个值，所选缩放会以缩放值最低的显示器来设置它，这样 X11 应用在密度更高的屏幕上会显得稍小一些，而不是在另一块屏幕上过大。

### 让文字更大或更小

显示器缩放会改变一切的大小。如果你想要的只是更大或更小的_文字_，这有一个单独的旋钮：

```
omarchy display text size 14
```

它接受一个介于 9 到 20 之间的像素大小，并让 Omarchy shell、GTK 应用程序和你的终端一起调整，这样整个桌面就始终保持比例。不带参数运行它可以查看你当前的值，而 `omarchy display text size reset` 则可以回到默认值。Foot 是唯一的拖后腿者：它没有办法重新加载自己的配置，所以已经在运行的终端会保持旧大小，直到你打开一个新终端。

### 扩展和镜像笔记本显示器

当你将一块外接屏幕连接到笔记本时，显示器会自动扩展。但你可以用 Omarchy 菜单中的 _Trigger > Hardware_ 或 `Super + Ctrl + Alt + Delete` 将其改为镜像。这在外接屏幕是投影仪、而你想在工作时展示些什么的时候特别有用。

当你正在扩展时，合上笔记本的盖子会自动关闭内置屏幕。打开盖子则会重新打开它。你也可以用 Omarchy 菜单中的 _Trigger > Hardware_ 或 `Super + Ctrl + Delete` 手动控制这一行为。

### 排列多块屏幕

Hyprland 在多块屏幕上工作得非常好。顶栏中的显示器面板会按它们所在的位置绘制它们：将一块屏幕拖到另一块屏幕的边缘即可把它移过去，而排列方式会与每台显示器的其他设置一起保存。对于面板涵盖不到的任何事情，请在 [Hyprland 显示器文档](https://wiki.hypr.land/Configuring/Basics/Monitors/) 中阅读更多关于如何排列它们的内容。在 Omarchy 中，这些设置以 `hl.monitor` 条目的形式放在 `~/.config/hypr/monitors.lua` 中——该文件自带了一些注释示例，用于保持显示器关闭、面板不提供的模式、10-bit 颜色和可变刷新率。

每台显示器都有它自己的工作区 1 到 10，所以 `Super + 1` 始终表示你所在显示器的第一个工作区。在幕后，Hyprland 仍然会跨所有显示器对工作区进行编号：你的笔记本屏幕（或第一台显示器）得到 1–10，下一台显示器得到 11–20，以此类推，而且每次你插入一台显示器时，它都会保留它的编号块。如果你为特定显示器编写 [工作区规则](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) 或窗口规则，请使用这些编号，所以工作区 12 就是你的第二台显示器的第二个工作区。`~/.local/state/omarchy/monitors/workspaces` 会列出每台显示器拥有哪个编号块。

方向键可以在布局中共用一条边缘的显示器之间工作。只在角落相切或之间有间隙的屏幕不是邻居，所以用 `Ctrl + Alt + Tab` 在它们之间切换。

| 快捷键 | 跨显示器 |
| --- | --- |
| `Super + Arrow` | 当该方向上再没有窗口时，将焦点移到那一侧的显示器 |
| `Super + Shift + Arrow` | 与那一侧显示器上的一个窗口交换 |
| `Super + Alt + Arrow` | 将窗口移到那一侧显示器上的一个分组中 |
| `Super + Shift + Ctrl + Arrow` | 将窗口移到那一侧的显示器，放到它正在显示的工作区上 |
| `Super + Shift + Alt + Arrow` | 将工作区移到那一侧的显示器，如果其编号空闲则保持该编号 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 将焦点移到下一台或上一台显示器，无论布局如何 |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 停留在你当前所在的显示器上 |

你也可以了解一下 [Hyprmon](https://github.com/erans/hyprmon/)，如果你想用一个 TUI 来帮助你定位多块屏幕的位置。

### 控制亮度

显示器亮度由专用的亮度调高/调低功能键控制。如果你按住 shift 的同时按下这些键，你就会跳到最大或最小亮度。这些键控制的是你当前聚焦的显示器，所以支持 DDC/CI 的外接显示器会以与笔记本屏幕相同的方式进行调整。

### Apple 显示器

如果你使用的是 Apple 显示器，常规的键盘亮度键也会自动工作，前提是你当前聚焦在 Apple 显示器上。这是通过 `asdcontrol` 命令实现的。

请注意，如果你使用的是 Apple 6K XDR 显示器，你可能会在 `hyprctl monitors` 列表中看到一个幻影屏幕。你可以在 `~/.config/hypr/monitors.lua` 中用类似 `hl.monitor({ output = "DP-2", disabled = true })` 的设置来关闭它。

在 Intel 机器上，你应该使用普通的 Thunderbolt 线缆连接到 Apple 显示器。在其他没有 Thunderbolt 的机器上，你通常必须使用一根 [DP + USB-A -> USB-C 线缆](https://www.amazon.com/dp/B0BNX7MS6N) 才能让它工作。
