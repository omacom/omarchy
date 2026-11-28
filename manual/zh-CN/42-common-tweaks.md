# 常见调整

这是对 Omarchy 设置进行的一些常见定制。要知道，系统更新有时可能需要将某些配置恢复到原始状态。如果发生这种情况，你的更改不会丢失，而是会被放入原始文件旁边的一个 `.bak.<timestamp>` 文件中。

如果你搞砸了，你可以通过 Omarchy 菜单中的 _Update > Config_ 将单个配置恢复到其原始设置。如果你_真的_把一切都搞砸了，你可以通过 `omarchy reinstall configs` 重置所有配置，或者用 `omarchy reinstall` 重新安装每一个默认软件包和配置。

### 始终显示所有托盘图标

默认情况下，像 Dropbox、1password 或 Steam 这样的托盘图标会隐藏在托盘展开箭头后面，当你将鼠标悬停在它上面时才会显示出来。如果你想让它们始终显示出来，右键点击展开箭头以打开托盘图标管理器，然后固定你想保持可见的图标（你也可以隐藏那些你永远不想看到的图标）。

### 圆角窗口边角

Omarchy 的默认设计是方角，但如果你想让它柔和一点，在 Omarchy 菜单中选择 _Appearance > Windows > Window Corners > Rounded Corners_，或者运行 `omarchy hyprland corners rounded`。_Theme Corners_ 会恢复为主题所使用的任何样式。要选择你自己的半径，请保持在 _Theme Corners_（`omarchy hyprland corners theme`）上，因为 Rounded 和 Sharp 会在你的配置之后加载并覆盖它，然后取消 `~/.config/hypr/looknfeel.lua` 中 rounding 的注释：

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### 移除窗口间隙

在笔记本电脑显示屏上，有些人不想在窗口间隙上浪费任何像素（甚至不想浪费在顶栏上，你可以用 `Super + Shift + Space` 将其关闭）。你可以用 `Super + Shift + Backspace` 关闭所有间隙和边框，或者通过取消 `~/.config/hypr/looknfeel.lua` 中这一部分的注释来永久移除它们：

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
