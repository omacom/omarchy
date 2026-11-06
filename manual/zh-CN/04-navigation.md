# 导航

在 Omarchy 中，一切都通过键盘完成——_一切！_ 系统刚启动时，你真的没法只靠鼠标做任何事。但你可以按下 `Super + Space` 唤出 Omarchy 菜单，从这里你可以完成几乎所有事情。

但 Omarchy 菜单甚至本就不该是大多数时间操作该系统的主要方式。我们可以比那更快！所有最重要的应用都直接绑定到了单独的快捷键上。你用 `Super + Return` 启动终端，用 `Super + Shift + Return` 启动浏览器。试着依次打开它们，你就会看到 Hyprland 平铺布局的魔力在实际运行：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

然后你可以按下 `Super + J` 将它们上下堆叠，而不是并排排列：

 ![navigation-stacked](images/navigation-stacked.webp)

再次按下 `Super + J` 让它们回到并排位置。然后在浏览器中试试 `Super + Shift + Arrow Right` 来交换窗口。

现在试试 `Super + Shift + T` 启动 Activity 监控器。它会以浮动窗口形式出现。你可以用 `Super + T` 将它平铺（再次按下则让它重新浮动）。现在按下 `Super + Shift + F` 打开文件管理器。你就会得到一个整洁的四分布局：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你可以用 `Super + Arrow` 在想要激活的窗口之间导航。这会切换焦点，并将光标移动到新应用的中央。在屏幕边缘时，它会继续移动到那一侧的显示器上。

如果你按下 `Super + Shift + 2`，你会将当前聚焦的应用移动到第二个工作区。`Super + Shift + 1` 会将它移回来。（而 `Super + Shift + Alt + 2` 会将当前聚焦的应用移动到第二个工作区，但不会切换过去）。

有多台显示器时，每台显示器都有自己独立的 1 到 10 号工作区。`Super + 2` 会前往你所在显示器的第二个工作区，每台显示器的顶栏都会显示它自己的工作区以及它当前显示的那个。`Super + Tab` 会在你所在显示器的工作区之间循环切换。`Super + Shift + Ctrl + Arrows` 会将你所在的窗口移动到那个方向的显示器上，放到它当前显示的工作区上，而 `Super + Shift + Alt + Arrows` 会将你所在的工作区移动到那个方向的显示器上，如果那个编号空闲，它就沿用相同的编号。显示器被拔下时，它的工作区会保留下来：它们会加入另一块屏幕，编号排在那块屏幕已有工作区之后，当显示器重新接回时，它们会恢复原来的编号。

如果你按住 `Super` 并用鼠标点击窗口，你就能重新安排它的位置。如果你按住 `Super` 并使用鼠标右键，你可以自由调整窗口大小。

你可以用 `Super + W` 或 `Super + Q` 关闭窗口（用 `Ctrl + Alt + Delete` 关闭所有窗口）。

你也可以用 `Super + F` 全屏，或者用 `Super + Alt + F` 仅全宽显示（保留顶栏），或者用 `Super + Ctrl + F` 在窗口内全屏（看 YouTube 时很好用！）。

### Dwindle 与滚动布局

Omarchy 的默认布局名为 dwindle。它让单个工作区上打开的所有窗口始终全部可见，哪怕必须把它们缩小。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以选择将一个工作区切换为滚动布局，在这种布局下，窗口会并排排列，延伸到显示屏可见边缘之外。你可以通过 `Super + L` 将单个工作区切换为这种布局。

再次按下 `Super + L` 会将工作区变为浮动布局，在这种布局下窗口可以自由重叠，由你自己摆放，第三次按下则让它回到 dwindle。`Super + Alt + L` 会以相反顺序在它们之间切换。本来就是浮动的窗口——你用 `Super + T` 弹出的窗口，或者始终以浮动方式打开的应用——在工作区回到平铺时仍会保持浮动。顶栏会用其布局标记你所在的工作区：正方形代表 dwindle，圆形代表滚动，三角形代表浮动。点击该标记也会循环切换布局。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

这个选择按工作区独立设置，而且会保留下来。所以你可以让 1 号工作区保持 dwindle 用于浏览，2 号工作区保持滚动用于写代码，重启后它们还会以这种方式回来。

如果你希望将滚动布局设为默认布局，你可以在 `~/.config/hypr/looknfeel.lua` 中这样设置：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮动工作区

浮动工作区的工作方式就像传统桌面：窗口互相重叠，由你自己移动和调整大小。每个窗口都会有一个使用你的主题配色的标题栏，上面带有最小化、最大化和关闭按钮。`Super + M` 也会最小化聚焦的窗口。最小化的窗口会停留在 dock 中；点击它的应用即可将它恢复。点击窗口可将其带到前面。从任意边缘或角落调整它的大小。双击标题栏可以将窗口最大化同时保持顶栏可见，再次双击则恢复到它原来的大小。

浮动工作区还会显示一个 dock，其中包含你固定的应用、所有正在运行的应用，以及 apps 按钮后面的全部应用网格，`Super + Alt + Space` 和 Omarchy 菜单中的 _Apps_ 也能打开它。在网格上右键点击某个应用，或者按下 `Delete`，即可卸载它。点击某个应用即可打开它，或者将其窗口带到前面；再次点击会在它的窗口之间循环切换。中键点击会打开一个新窗口。沿着 dock 拖动图标即可移动它；将一个正在运行的应用拖到其他应用之间会让它保留在那里。右键点击可将某个应用保留在 dock 中、从中移除，或者退出它。dock 会为全屏窗口让路。右键点击 apps 按钮可将 dock 移到另一个边缘，或者让它隐藏起来直到指针到达其边缘所在位置。这个位置也在 _Appearance > Dock > Dock Position_ 中，而 `omarchy dock position left` 和 `omarchy dock autohide on` 可以从终端设置这两项。你保留在 dock 中的应用在未运行时会显示为变淡状态。

新的工作区，以及任何你没有用 `Super + L` 为其单独指定布局的工作区，都会使用默认布局。更改默认布局会将每个没有窗口的工作区重置为该布局，而有窗口的工作区则保留它现有的布局。最小化到 dock 的窗口仍算作它离开的那个工作区上的窗口。在 _Appearance > Workspace Layout_ 下选择它：Tiling、Scrolling 或 Floating。`omarchy-hyprland-workspace-layout-default scrolling` 可以从终端设置它。

### 窗口分组

可以使用 `Super + G` 对窗口进行分组。一旦你进入一个组，在该组处于活动状态时启动的每个窗口都会属于该组。你可以使用 `Super + Ctrl + Arrow Left/Right` 在这些分组窗口之间移动，或者使用 `Super + Alt + 1/2/3/4` 按顺序直接前往分组窗口。

你可以用 `Super + Alt + G` 将某个窗口移出分组，或者再次按下 `Super + G` 解散整个组。最后，你可以用 `Super + Alt + Arrows` 将组外的窗口移入组中。

### 弹出窗口

你可以用 `Super + O` 将窗口从其工作区分配置中弹出。那会将它固定为一个浮动窗口，无论你前往哪个工作区，它都会跟着你。非常适合视频播放器之类的应用。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad 工作区

有一个特殊的全尺寸 scratchpad 工作区，它会覆盖在你当前所在的任何工作区之上。你使用 `Super + S` 访问上面的内容，使用 `Super + Alt + S` 将窗口放到那里。

它非常适合放控制面板或终端，让你在不离开当前工作区的情况下快速与之交互。

### Quake 控制台

最后，还有一个半高的 Quake 控制台，它会从上方降下，覆盖在你当前所在的任何工作区之上。用 `Super + Grave` 切换它，用 `Super + Shift + Grave` 将窗口放到那里。

它打开时，你的默认 agent 已经就绪可用。当控制台只容纳一个窗口时，它会以居中面板的形式降下，而不是横跨整个屏幕。在上面放上第二个应用，它就会恢复到全宽，这样两个应用就有空间并排摆放。

要将窗口从 scratchpad 或控制台移走，直接用类似 `Super + Shift + 1` 的快捷键将它发送到另一个工作区。

### 需要一些时间来习惯！

像这样导航你的桌面需要花一点时间来习惯，但一旦你习惯了，就很难再回到传统的鼠标驱动的桌面体验了！
