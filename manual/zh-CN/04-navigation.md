# 导航

Omarchy 中的一切都通过键盘完成——*一切！*系统首次启动时，你真的无法仅靠鼠标做任何事。但你可以按下 `Super + Space` 显示 Omarchy Menu，从这里你可以完成几乎所有事情。

但 Omarchy 菜单甚至并不打算成为大多数时候操作系统的主要方式。我们可以比那更快！所有最重要的应用程序都直接绑定到单独的快捷键上。你用 `Super + Return` 启动终端，用 `Super + Shift + Return` 启动浏览器。试着依次打开它们，你就会看到 Hyprland 平铺的魔力在发挥作用：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

然后你可以按下 `Super + J` 将它们堆叠在一起，而不是并排放置：

 ![navigation-stacked](images/navigation-stacked.webp)

再次按下 `Super + J`，即可让它们回到并排位置。然后在浏览器中试着按下 `Super + Shift + Arrow Right` 来交换窗口。

现在试着按下 `Super + Shift + T` 启动 Activity 监视器。它会以浮动窗口的形式出现，带有可拖动的标题栏，以及最小化、最大化和关闭按钮。每个浮动窗口都有一个，无论它在哪里。你可以用 `Super + T` 将它平铺（再次按下可让它重新浮动）。现在按下 `Super + Shift + F` 打开文件管理器。你将拥有一个整洁的四窗口布局：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你可以用 `Super + Arrow` 在想要激活的窗口之间导航。这会切换焦点，并将光标移到新应用程序的中心。在屏幕边缘，它会继续转到那一侧的显示器。

如果你按下 `Super + Shift + 2`，你会把当前聚焦的应用程序移到第二个工作区。`Super + Shift + 1` 会把它移回来。（而 `Super + Shift + Alt + 2` 会把当前聚焦的应用程序移到第二个工作区，但不会切换到那个工作区）。

使用多台显示器时，每台显示器都有自己的 1 到 10 号工作区。`Super + 2` 会转到你当前所在显示器的第二个工作区，每台显示器的顶栏都会显示自己的工作区以及它当前显示的工作区。`Super + Tab` 会循环切换你当前所在显示器上的工作区。`Super + Shift + Ctrl + Arrows` 会把你当前所在的窗口移到那个方向的显示器上，移到它当前显示的工作区，`Super + Shift + Alt + Arrows` 会把你当前所在的工作区移到那个方向的显示器上，如果空闲，它在那里会占用相同的编号。显示器被拔下时，它会保留自己的工作区：它们会加入另一台屏幕的工作区，编号排在它已有工作区之后，当显示器恢复时，它们会回到原来的编号下。

如果你按住 `Super` 并用鼠标点击一个窗口，你就可以重新安排它的位置。如果你按住 `Super` 并使用鼠标右键，你可以自由调整窗口的大小。

你可以用 `Super + W` 或 `Super + Q` 关闭一个窗口（并用 `Ctrl + Alt + Delete` 关闭所有窗口）。

你也可以用 `Super + F` 全屏，或者用 `Super + Alt + F` 仅全宽（保留顶栏），甚至用 `Super + Ctrl + F` 在窗口内全屏（非常适合 YouTube！）。

### Dwindle 与滚动布局

Omarchy 的默认布局称为 dwindle。它让你在一个工作区上打开的所有窗口始终可见，即使它必须将它们缩小。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以选择将一个工作区转为滚动布局，在这种布局中，窗口并排排列，延伸到显示器的可见边缘之外。你可以通过 `Super + L` 将单个工作区转为此布局。

再次按下 `Super + L` 会将工作区转为浮动，在浮动布局中窗口自由重叠，你可以自己放置它们，第三次按下则将其恢复为 dwindle。`Super + Alt + L` 会以相反的顺序循环切换它们。一个本来就浮动的窗口——你用 `Super + T` 弹出的窗口，或总是以浮动方式打开的应用程序——当工作区恢复为平铺时，它会继续浮动。顶栏会用其布局标记你当前所在的工作区：正方形表示 dwindle，圆形表示滚动，三角形表示浮动。点击该标记也会循环切换布局，具有显示键的笔记本电脑也可使用该键切换。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

该选择是针对每个工作区的，并且会保留。所以你可以将工作区 1 保持为 dwindle 用于浏览，将工作区 2 保持为滚动用于编写代码，它们在重启后也会以那种方式回来。

如果你希望将滚动布局用作默认布局，你可以在 `~/.config/hypr/looknfeel.lua` 中进行设置：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮动工作区

浮动工作区像传统桌面一样工作：窗口相互重叠，你可以自己移动和调整它们。每个窗口都有一个采用你的主题颜色的标题栏，带有最小化、最大化和关闭按钮。`Super + M` 也会最小化聚焦的窗口。最小化的窗口会在 dock 中等待；点击它的应用程序可将其带回。点击一个窗口可将其提到前面。可以从任何边缘或角落调整其大小。双击标题栏可最大化窗口，同时保持顶栏可见，再次双击可恢复其原来的大小。Chrome 和其他基于 Chromium 的浏览器、Disks 和 Document Viewer 会跳过标题栏，改为使用它们自己的标头；`Super + Alt + F` 会最大化它们，`Super + M` 会最小化它们。

每个工作区都有一个 dock，其中包含你固定的应用程序、所有正在运行的应用程序，以及位于应用程序按钮后面的所有应用程序网格，`Super + Alt + Space` 和 Omarchy 菜单中的 _Apps_ 也可打开它。在网格上右键点击一个应用程序，或按下 `Delete`，即可卸载它。点击一个应用程序可打开它，或将其窗口提到前面；再次点击可循环切换它的窗口。Files 只会从你当前所在的工作区带回一个窗口，否则会打开一个新窗口，Terminal 和 Agent 则总是启动另一个，不过最小化的窗口会先恢复。中键点击会打开一个新窗口。沿着 dock 拖动一个图标可移动它；将一个正在运行的应用程序拖到其他应用程序中间会将它保留在那里。右键点击可将一个应用程序保留在 dock 中、从中移除或退出它。当工作区为空时，dock 会保持可见，一旦工作区有了一个窗口，它就会隐藏，直到指针到达其边缘。全屏窗口会将它完全隐藏。将应用程序按钮拖向屏幕的另一边缘，可将 dock 移到那里。右键点击它，选择 _Position_ 可选择一个边缘，选择 _Layout_ 可设置默认布局，方式与 _Appearance > Workspace Layout_ 相同，选择 _Visibility_ 可让 dock 始终开启、让第一个应用程序隐藏它，或让它始终隐藏。`omarchy dock visibility always` 可从终端进行该设置。其位置也位于 _Appearance > Dock > Dock Position_ 下，`omarchy dock position left` 可从终端进行设置。你保存在 dock 中的应用程序在未运行时会变淡。要将 dock 仅用于浮动工作区，请使用 _Appearance > Dock > Dock Only on Floating_ 或 `omarchy dock tiling off`。

新的工作区，以及任何你没有用 `Super + L` 为其指定自己布局的工作区，都使用默认布局。更改默认布局会将每个没有窗口的工作区重置为该布局，而有窗口的工作区会保留它现有的布局。最小化到 dock 的窗口仍算作它离开的那个工作区上的一个窗口。在 _Appearance > Workspace Layout_ 下选择它：Tiling、Scrolling 或 Floating。`omarchy hyprland workspace layout default scrolling` 可从终端进行设置。

### 窗口分组

可以使用 `Super + G` 将窗口分组。一旦你进入一个组，在该组处于活动状态时启动的每个窗口都将属于该组。你可以使用 `Super + Ctrl + Arrow Left/Right` 在这些分组窗口之间移动，或使用 `Super + Alt + 1/2/3/4` 按顺序直接转到分组窗口。

你可以用 `Super + Alt + G` 将一个窗口移出分组，或再次按下 `Super + G` 解散整个组。最后，你可以用 `Super + Alt + Arrows` 将组外的窗口移入组中。

### 弹出窗口

你可以用 `Super + O` 将一个窗口从其工作区分配中弹出。那会将它固定为一个浮动窗口，无论你转到哪个工作区，它都会跟着你。非常适合视频播放器之类的应用。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### 暂存工作区

有一个特殊的全尺寸暂存工作区，它会覆盖你当前所在的任何工作区。你可以用 `Super + S` 访问其中的内容，用 `Super + Alt + S` 将窗口放置在那里。

它非常适合你想快速交互而不离开当前工作区的控件或终端。

### Quake 控制台

最后，有一个半高 Quake 控制台，它会从你当前所在工作区的上方下拉。用 `Super + the key above Tab`（美式布局上的 grave 键）切换它，并用 `Super + Shift + the key above Tab` 将一个窗口放置在那里。

首次打开时，它会启动你的默认 agent，如果你尚未选择一个，它会要求你选择一个。当控制台只容纳一个窗口时，它会以居中面板的形式下拉，而不是横跨屏幕。在上面放置第二个应用程序，它会恢复为全宽，这样两个应用程序就有空间并排摆放了。

要将窗口从暂存工作区或控制台移走，直接用类似 `Super + Shift + 1` 的快捷键将其发送到另一个工作区。

### 需要一些时间适应！

需要一些时间来适应像这样导航你的桌面，但一旦你适应了，就很难再回到传统的鼠标驱动桌面体验了！
