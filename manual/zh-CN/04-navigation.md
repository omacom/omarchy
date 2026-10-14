# 导航

Omarchy 中的一切都通过键盘完成——_一切！_系统刚启动时，你真的只用鼠标什么都做不了。但你可以按 `Super + Space` 显示 Omarchy 菜单，从这里你可以完成几乎所有事情。

但 Omarchy 菜单甚至不打算成为大多数时候操作系统的主要方式。我们可以比那更快！所有最重要的应用程序都直接绑定到各自的热键上。你用 `Super + Return` 启动终端，用 `Super + Shift + Return` 启动浏览器。试着一个接一个地运行，你就会看到 Hyprland 平铺的魔力发挥作用：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

然后你可以按 `Super + J` 将它们上下堆叠，而不是并排排列：

 ![navigation-stacked](images/navigation-stacked.webp)

再次按 `Super + J` 将它们恢复到并排的位置。然后在浏览器上试一下 `Super + Shift + Arrow Right` 来交换窗口。

现在试一下 `Super + Ctrl + T` 来启动 Activity 监视器。它会以浮动窗口的形式出现。你可以用 `Super + T` 将它平铺（再次按下该键可以让它重新浮动）。现在按 `Super + Shift + F` 打开文件管理器。你就会得到一个整齐的四分区布局：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你可以用 `Super + Arrow` 在你想要激活的窗口之间导航。这会切换焦点，并将光标移动到新应用程序的中心。

如果你按 `Super + Shift + 2`，你会将当前聚焦的应用程序移动到第二个工作区。`Super + Shift + 1` 会将它移回来。（而 `Super + Shift + Alt + 2` 会将当前聚焦的应用程序移动到第二个工作区，而不切换到该工作区）。

如果你按住 `Super` 并用鼠标点击一个窗口，你就能重新排列它的位置。如果你按住 `Super` 并使用鼠标右键，你可以自由调整窗口大小。

你可以用 `Super + W` 或 `Super + Q` 关闭一个窗口（并用 `Ctrl + Alt + Delete` 关闭所有窗口）。

你还可以用 `Super + F` 全屏，或者甚至只是全宽（保留顶部栏），用 `Super + Alt + F`，或者用 `Super + Ctrl + F` 在窗口内全屏（非常适合 YouTube！）。

### Dwindle 与滚动布局

Omarchy 的默认布局叫做 dwindle。它始终让单个工作区上打开的所有窗口保持可见，即使这意味着必须将它们缩小。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以选择将工作区切换为滚动布局，在该布局中，窗口并排排列，延伸到显示屏的可见边缘之外。你可以通过 `Super + L` 将单个工作区切换为此布局。

再次按 `Super + L` 会将工作区切换为浮动布局，在该布局中，窗口自由重叠，由你自己放置它们，再按第三次会将其恢复为 dwindle。`Super + Alt + L` 以相反的顺序切换它们。本来就浮动的窗口——用 `Super + T` 弹出的窗口，或者总是浮动打开的应用程序——当工作区恢复为平铺时，会保持浮动。顶部栏用其布局标记你所在的工作区：正方形表示 dwindle，圆形表示滚动，三角形表示浮动。点击该标记也会循环切换布局。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

该选择是按工作区生效的，而且会一直保留。因此，你可以将工作区 1 保持在 dwindle 以便浏览，将工作区 2 保持在滚动以便编写代码，重启后它们会以同样的方式恢复。

如果你希望将滚动布局用作默认布局，你可以在 `~/.config/hypr/looknfeel.lua` 中设置：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮动工作区

浮动工作区的工作方式就像传统桌面一样：窗口相互重叠，由你自己移动和调整大小。每个窗口都有一个采用你主题颜色的标题栏，带有最小化、最大化和关闭按钮。`Super + M` 也会最小化聚焦的窗口。最小化的窗口会在 dock 中等待；点击它的应用程序即可将其恢复。点击一个窗口即可将其带到前面。从任何边缘或角落调整它的大小。双击标题栏可以最大化窗口，同时保持顶部栏可见，再次双击可恢复其原来的大小。

浮动工作区还会显示一个 dock，其中有你固定的应用程序、所有正在运行的应用程序，以及位于应用程序按钮之后的所有应用程序的网格，`Super + Alt + Space` 和 Omarchy 菜单中的_应用程序_也可以打开该网格。右键点击网格上的应用程序，或按 `Delete`，即可卸载它。点击一个应用程序即可打开它，或将其窗口带到前面；再次点击可以循环切换它的窗口。中键点击打开一个新窗口。沿着 dock 拖动一个图标可以移动它；将正在运行的应用程序拖到其他应用程序之间会将它保留在那里。右键点击可以将应用程序保留在 dock 中、将其移除，或退出它。dock 会让全屏窗口遮挡自己。右键点击应用程序按钮可以将 dock 移动到另一条边缘，或者让它隐藏，直到指针到达其边缘。该位置也在_触发器 > 外观 > Dock > Dock 位置_下，`omarchy dock position left` 和 `omarchy dock autohide on` 可以从终端设置这两项。你保留在 dock 中的应用程序在未运行时会变淡。

新的工作区，以及任何你尚未用 `Super + L` 为其指定自己布局的工作区，都会使用默认布局。更改默认布局会将每一个没有窗口的工作区重置为该布局，而有窗口的工作区会保留它现有的布局。最小化到 dock 的窗口仍然算作它离开的那个工作区上的窗口。在_触发器 > 外观 > 工作区布局_下选择它：平铺、滚动或浮动。`omarchy-hyprland-workspace-layout-default scrolling` 从终端设置它。

### 窗口分组

可以使用 `Super + G` 将窗口分组。一旦你进入一个组，你在该组处于活动状态时启动的每个窗口都将属于该组。你可以使用 `Super + Ctrl + Arrow Left/Right` 在这些分组窗口之间移动，或使用 `Super + Alt + 1/2/3/4` 直接按顺序转到分组窗口。

你可以用 `Super + Alt + G` 将窗口移出分组，或再次按 `Super + G` 解散整个组。最后，你可以用 `Super + Alt + Arrows` 将组外的窗口移入组内。

### 弹出窗口

你可以用 `Super + O` 将窗口从其工作区分配中弹出。这会将它固定为一个浮动窗口，无论你去哪个工作区，它都会跟着你。非常适合视频播放器等场景。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### 暂存工作区

最后，有一个特殊的暂存工作区，它会像 Quake 控制台一样，在你当前所在的任何工作区上方下拉。用 `Super + Grave` 或 `Super + S` 切换它，并使用 `Super + Shift + Grave` 或 `Super + Alt + S` 将窗口放置在那里。

它特别适合运行 agent 的终端，或者适合你想快速交互而又不离开当前工作区的控件。要将窗口从暂存区移开，可以用 `Super + Shift + 1` 之类的快捷键将它直接发送到另一个工作区。

当暂存区只容纳单个窗口时，它会以居中面板的形式下拉，而不是横跨整个屏幕。在上面放置第二个应用程序，它就会恢复到全宽，这样两个应用程序就有空间并排放置。

### 需要一点时间来适应！

适应以这种方式在桌面上导航需要一点时间，但一旦你适应了，就会很难再回去使用传统的鼠标驱动的桌面体验了！
