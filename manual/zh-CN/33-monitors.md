# 显示器

Omarchy 默认假设你运行的是支持 2x 的 retina 级显示器。这正是你获得漂亮、清晰的程序员字体所需要的。这是几乎所有采用高分辨率屏幕的新款高端笔记本电脑所优化的目标。这正是你会想在 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 或 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 上运行的配置。

但如果你运行的显示器 PPI 没有达到 218 或更高，你就需要更改显示器设置。例如，如果你有一台 27" 或 32" 4K 显示器，你可以从顶部栏的显示器面板中为它选择一个分数缩放比例，或者打开 `~/.config/hypr/monitors.lua` 并切换到针对该组合的推荐设置，为每一台显示器设置默认值：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

如果你使用的是 1080p 或 1440p 显示器，你可能只想使用 1x 缩放，并且让 GTK 和 X11 应用也同样如此，这样你就可以使用：

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

对 `GDK_SCALE` 的更改适用于更改之后启动的应用（而且 GTK 只接受整数，所以请将它保持为与你的显示器缩放比例最接近的整数）。所以请务必在更改后退出那些尺寸过大的窗口（或者用 `Ctrl + Alt + Del` 关闭所有窗口！）。

你也可以使用 `Super + /` 逐步升高、使用 `Super + Alt + /` 逐步降低，在主要的显示器缩放比例（1x、1.25x、1.6x、2x、3x、4x）之间快速切换，或者从顶部栏的显示器面板中选择一个。这些设置只会更改你当前聚焦的显示器，所以笔记本屏幕和外接显示器可以各自拥有自己的缩放比例。该面板还会设置每台显示器的分辨率。你的选择会针对那台物理显示器保存在 `~/.local/state/omarchy/monitors/settings` 中，所以它们在重启后依然保留，并且会跟随显示器到它下一次插入的任何端口或扩展坞。它们优先于 `~/.config/hypr/monitors.lua` 中针对同一台显示器的任何规则，而 Omarchy 永远不会编辑那个文件。由于 `GDK_SCALE` 是所有屏幕共用的一个值，所选的缩放比例会根据缩放比例最低的显示器来设置它，这样 X11 应用在密度更高的屏幕上会显得小一点，而不是在另一台屏幕上显得过大。

### 让文字变大或变小

显示器缩放会改变所有内容的大小。如果你只想让_文字_变大或变小，那么只有一个旋钮可以调：

```
omarchy display text size 14
```

它接受 9 到 20 之间的像素大小，并且会让 Omarchy shell、GTK 应用和你的终端一起调整，这样整个桌面就能保持比例协调。不带参数运行它可以查看你当前的设置，而 `omarchy display text size reset` 可以恢复到默认值。Foot 是唯一拖后腿的：它没有办法重新加载它的配置，所以已经运行的终端会保持旧的大小，直到你打开一个新的。

### 扩展和镜像笔记本显示器

当你将外接屏幕连接到笔记本时，显示器会自动扩展。但你可以使用 Omarchy 菜单中的 _Trigger > Hardware_ 或 `Super + Ctrl + Alt + Delete` 将它改为镜像。如果那个外接屏幕是投影仪，而你想一边工作一边展示内容，这会特别有帮助。

当你正在扩展时，合上笔记本的盖子会自动关闭内置屏幕。打开盖子会将它重新打开。你也可以使用 Omarchy 菜单中的 _Trigger > Hardware_ 或 `Super + Ctrl + Delete` 手动控制这一行为。

### 排列多台屏幕

Hyprland 与多台屏幕配合得非常好。顶部栏的显示器面板会按它们实际所在的位置绘制它们：将一台拖到另一台的侧边就可以将它移动到那里，并且这种排列会与每台显示器的其他设置一起保存。对于面板没有涵盖的任何内容，请在 [Hyprland 显示器文档](https://wiki.hypr.land/Configuring/Basics/Monitors/) 中进一步了解如何布局它们。在 Omarchy 中，这些设置以 `hl.monitor` 条目的形式放在 `~/.config/hypr/monitors.lua` 中——该文件自带注释示例，用于将特定显示器固定到某个分辨率、位置和旋转角度。

每台显示器都有它自己的 1 到 10 号工作区，所以 `Super + 1` 始终意味着你所在显示器的第一个工作区。在幕后，Hyprland 仍然会跨所有显示器为工作区编号：你的笔记本屏幕（或第一台显示器）得到 1–10，下一台显示器得到 11–20，依此类推，并且每台显示器在你每次插入时都会保留它的那个区段。如果你为特定显示器编写[工作区规则](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)或窗口规则，请使用这些数字，所以工作区 12 就是你的第二台显示器的第二个工作区。`~/.local/state/omarchy/monitors/workspaces` 会列出每台显示器拥有哪个区段。

方向键可以在布局中共享一条边的显示器之间工作。只在一个角相接或之间有间隙的屏幕不是邻居，所以请使用 `Ctrl + Alt + Tab` 在它们之间切换。

| Hotkey | Across monitors |
| --- | --- |
| `Super + Arrow` | 当该方向上没有窗口剩下时，将焦点移到那一侧的显示器上 |
| `Super + Shift + Arrow` | 与那一侧显示器上的一个窗口交换 |
| `Super + Alt + Arrow` | 将窗口移到那一侧显示器上的一个组中 |
| `Super + Shift + Ctrl + Arrow` | 将窗口移到那一侧的显示器上，移到它正在显示的工作区 |
| `Super + Shift + Alt + Arrow` | 将工作区移到那一侧的显示器上，如果它的编号空闲则保持不变 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 无论布局如何，都将焦点移到下一台或上一台显示器 |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | 停留在你所在的显示器上 |

你也可以看看 [Hyprmon](https://github.com/erans/hyprmon/)，如果你想要一个 TUI 来帮你定位多台屏幕的话。

### 控制亮度

显示器亮度由专用的亮度增/减功能键控制。如果你按住 shift 再按这些键，你会直接跳到最大或最小亮度。这些键控制的是你聚焦的那个显示器，所以支持 DDC/CI 的外接显示器会以与笔记本屏幕相同的方式进行调整。

### Apple Displays

如果你使用的是 Apple 显示器，常规的键盘亮度键也会自动工作，前提是你聚焦在 Apple 显示器上。这是通过 `asdcontrol` 命令实现的。

请注意，如果你使用的是 Apple 6K XDR 显示器，你可能会在 `hyprctl monitors` 列表中看到一个幻影屏幕。你可以在 `~/.config/hypr/monitors.lua` 中使用类似 `hl.monitor({ output = "DP-2", disabled = true })` 的设置将其关闭。

在 Intel 机器上，你应该使用普通的 Thunderbolt 线缆连接 Apple 显示器。在其他没有 Thunderbolt 的机器上，你通常必须使用一根 [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) 才能让它工作。
