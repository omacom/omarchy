# 导航

Omarchy 中的一切都通过键盘完成——_一切！_ 系统首次启动时，你真的无法仅用鼠标做任何事情。但你可以按 `Super + Space` 调出 Omarchy Menu，从这里你可以完成几乎所有事情。

但 Omarchy 菜单甚至本就不打算成为大多数时间操作系统的主要方式。我们可以比那更快！所有最重要的应用程序都直接绑定到单独的热键。你用 `Super + Return` 启动终端，用 `Super + Shift + Return` 启动浏览器。试着一个接一个地做，你就会看到 Hyprland 平铺的魔力在发挥作用：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

然后你可以按 `Super + J` 将它们上下堆叠，而不是并排放置：

 ![navigation-stacked](images/navigation-stacked.webp)

再次按 `Super + J` 可将它们恢复到并排位置。然后在浏览器中尝试 `Super + Shift + Arrow Right` 来交换窗口。

现在尝试 `Super + Shift + T` 启动 Activity 监视器。它会以浮动窗口的形式出现，带有可拖动的标题栏，以及最小化、最大化和关闭按钮。每个浮动窗口都有一个，无论它在哪里。你可以用 `Super + T` 让它平铺（再次按下可让它重新浮动）。现在按 `Super + Shift + F` 打开文件管理器。你将得到一个整洁的四分布局：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你用 `Super + Arrow` 在想要激活的窗口之间导航。这将切换焦点，并将光标移动到新应用程序的中心。在屏幕边缘，它会继续到那一侧的显示器上。

如果你按 `Super + Shift + 2`，你会将当前聚焦的应用程序移动到第二个工作区。`Super + Shift + 1` 会将它移回来。（而 `Super + Shift + Alt + 2` 会将当前聚焦的应用程序移动到第二个工作区，但不会切换到那个工作区）。

当有多个显示器时，每个显示器都有自己独立的 1 到 10 号工作区。`Super + 2` 会转到你所在显示器的第二个工作区，每个显示器的顶栏都会显示它自己的工作区以及当前显示的那个。`Super + Tab` 会在你所在显示器的工作区之间循环切换。`Super + Shift + Ctrl + Arrows` 会将你所在的窗口移动到那个方向的显示器上，并放到它当前显示的工作区上，而 `Super + Shift + Alt + Arrows` 会将你所在的工作区移动到那个方向的显示器上，在那里如果空闲的话它会占用相同的编号。当你拔掉一个显示器时，它会保留其工作区：它们会加入另一个屏幕的工作区，编号排在它已有工作区之后，当显示器恢复时，它们会回到原来的编号下。

如果你按住 `Super` 并用鼠标点击一个窗口，你将能够重新排列它所在的位置。如果你按住 `Super` 并使用鼠标右键，你可以自由调整窗口大小。

你用 `Super + W` 或 `Super + Q` 关闭一个窗口（并用 `Ctrl + Alt + Delete` 关闭所有窗口）。

你也可以用 `Super + F` 全屏，甚至可以用 `Super + Alt + F` 仅全宽（保留顶栏），或用 `Super + Ctrl + F` 在窗口内全屏（非常适合 YouTube！）。

### Dwindle 与 scrolling 布局

Omarchy 的默认布局叫做 dwindle。它让你在单个工作区上打开的所有窗口始终可见，即使不得不将它们缩小。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以选择将一个工作区变为 scrolling 布局，在这种布局中窗口并排排列，超出显示器的可见边缘。你可以通过 `Super + L` 将单个工作区变为这种布局。

再次按 `Super + L` 会将工作区变为浮动布局，在这种布局中窗口自由重叠，由你自己放置，第三次按下则会将其恢复为 dwindle。`Super + Alt + L` 会以相反的方向循环切换它们。一个本来就浮动的窗口——你用 `Super + T` 弹出的窗口，或者总是以浮动方式打开的应用——当工作区恢复为平铺时仍会保持浮动。顶栏会用其布局标记你所在的工作区：正方形代表 dwindle，圆形代表 scrolling，三角形代表浮动。点击该标记也可以循环切换布局，带有显示键的笔记本电脑上的该按键也可以。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

该选择是按工作区生效的，并且会保持不变。所以你可以将工作区 1 保持在 dwindle 用于浏览，将工作区 2 保持在 scrolling 用于写代码，重启后它们会以同样的方式回来。

如果你希望将 scrolling 布局用作默认布局，你可以在 `~/.config/hypr/looknfeel.lua` 中设置：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮动工作区

浮动工作区的工作方式就像传统桌面：窗口重叠，你自己移动和调整它们的大小。每个窗口都会获得一个采用你主题颜色的标题栏，带有最小化、最大化和关闭按钮。`Super + M` 也会最小化聚焦的窗口。最小化的窗口会在 dock 中等待；点击它的应用即可将其带回来。点击一个窗口即可将其带到前面。从任何边缘或角落调整它的大小。双击标题栏可最大化窗口，同时保持顶栏可见，再次双击可恢复其原来的大小。Chrome 和其他基于 Chromium 的浏览器、Disks 和 Document Viewer 会跳过标题栏，转而使用它们自己的标题栏；`Super + Alt + F` 会最大化它们，`Super + M` 会最小化它们。

每个工作区都有一个 dock，其中包含你固定的应用、所有正在运行的应用，以及在应用按钮后面的每个应用的网格，`Super + Alt + Space` 和 Omarchy 菜单中的 _Apps_ 也会打开它。在网格上右键点击一个应用，或按 `Delete`，即可卸载它。点击一个应用即可打开它，或将其窗口带到前面；再次点击可在其窗口之间循环切换。Files 只会从你所在的工作区带回一个窗口，否则会打开一个新窗口，Terminal 和 Agent 总是会启动另一个，不过最小化的窗口会先回来。中间点击会打开一个新窗口。沿 dock 拖动一个图标可移动它；将一个正在运行的应用拖到其他应用中间会将其保留在那里。右键点击可将应用保留在 dock 中、将其从中取出，或退出它。当工作区为空时，dock 会保持显示，一旦工作区有了一个窗口，它就会隐藏，直到指针到达其边缘。全屏窗口会将其完全隐藏。将应用按钮拖向屏幕的另一个边缘可将 dock 移动到那里。右键点击它选择 _Position_ 来选择一个边缘，选择 _Layout_ 来设置默认布局，就像 _Appearance > Workspace Layout_ 所做的那样。该位置也位于 _Appearance > Dock > Dock Position_ 下，`omarchy dock position left` 可从终端进行设置。你保留在 dock 中的应用在未运行时会变淡。要将 dock 仅保留在浮动工作区上，请使用 _Appearance > Dock > Dock Only on Floating_ 或 `omarchy dock tiling off`。

新工作区，以及任何你尚未用 `Super + L` 为其指定自己布局的工作区，都会使用默认布局。更改默认布局会将每个没有窗口的工作区重置为该布局，而有窗口的工作区会保持它已有的布局。最小化到 dock 的窗口仍算作它所离开的工作区上的一个窗口。在 _Appearance > Workspace Layout_ 下选择它：Tiling、Scrolling 或 Floating。`omarchy hyprland workspace layout default scrolling` 可从终端进行设置。

### 窗口分组

可以使用 `Super + G` 对窗口进行分组。一旦你进入一个组，在该组处于活动状态时你启动的每个窗口都将属于该组。你可以使用 `Super + Ctrl + Arrow Left/Right` 在这些分组窗口之间移动，或使用 `Super + Alt + 1/2/3/4` 按顺序直接转到分组窗口。

你可以用 `Super + Alt + G` 将一个窗口移出分组，或再次按 `Super + G` 解散整个组。最后，你可以用 `Super + Alt + Arrows` 将组外的窗口移入组内。

### 弹出窗口

你可以用 `Super + O` 将一个窗口从其工作区分配中弹出。那会将其固定为一个浮动窗口，无论你转到哪个工作区它都会跟着你。非常适合视频播放器之类的应用。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### 暂存工作区

有一个特殊的全尺寸暂存工作区，它会覆盖在你当前所在的工作区之上。你使用 `Super + S` 访问其上的内容，你使用 `Super + Alt + S` 将窗口放置在那里。

它非常适合你想要快速交互而不离开当前工作区的控件或终端。

### Quake 控制台

最后，有一个半高 Quake 控制台，它会下拉覆盖在你当前所在的工作区之上。用 `Super + the key above Tab`（在 US 布局上是 grave）切换它，并使用 `Super + Shift + the key above Tab` 将一个窗口放置在那里。

它第一次打开时，会启动你的默认 agent，或者如果你尚未选择一个，会要求你挑选一个。当控制台仅容纳单个窗口时，它会以居中面板的形式下拉，而不是横跨整个屏幕。在其上放置第二个应用，它就会恢复为全宽，这样两个应用就有空间并排放置。

要将窗口从暂存区或控制台移出，请使用类似 `Super + Shift + 1` 的方式将其直接发送到另一个工作区。

### 需要一些时间来适应！

需要一点时间来习惯以这种方式导航你的桌面，但一旦你习惯了，就很难再回到传统的鼠标驱动的桌面体验了！
