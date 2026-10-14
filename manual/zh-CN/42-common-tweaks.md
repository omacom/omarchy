# 常见调整

这是对 Omarchy 设置的一些常见定制。请注意，系统更新偶尔可能需要将某些配置恢复到其原始状态。如果发生这种情况，你的更改不会丢失，而会被放在同一目录下的 `.bak` 文件中。

如果你搞砸了什么，你可以通过 Omarchy 菜单中的 _更新 > 配置_ 将单个配置恢复到其原始设置。如果你 _真的_ 把一切都搞砸了，你可以通过 `omarchy-reinstall` 重置所有配置。

### 始终显示所有托盘图标

默认情况下，托盘图标（比如 Dropbox、1password 或 Steam）会被藏在托盘展开箭头后面，当你悬停时会显示它们。如果你想让它们始终暴露在外，右键点击展开箭头以打开托盘图标管理器，然后固定你想保持可见的图标（你也可以隐藏那些你永远不想看到的）。

### 圆角窗口

Omarchy 的默认设计是直角窗口，但如果你喜欢稍微柔化一些，你可以更改 `~/.config/hypr/looknfeel.lua`，使圆角不再被注释掉：

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### 移除窗口间距

在笔记本电脑显示屏上，有些人更喜欢不在窗口间距上浪费任何像素（甚至是菜单栏，你可以用 `Super + Shift + Space` 关闭它）。你可以用 `Super + Shift + Backspace` 一并关闭所有间距和边框，或者通过移除 `~/.config/hypr/looknfeel.lua` 中这一部分的注释来永久移除它们：

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
