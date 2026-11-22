# 导航

Omarchy 中的一切都通过键盘进行——_一切！_ 系统首次启动时，你真的单靠鼠标什么都做不了。但你可以按 `Super + Space` 呼出 Omarchy 菜单，从这里你几乎可以做任何事。

但 Omarchy 菜单甚至不是为了成为大多数时候操作系统的主要方式。我们还能更快！所有最重要的应用程序都直接绑定到各自的快捷键上。你用 `Super + Return` 启动终端，用 `Super + Shift + Return` 启动浏览器。试着一个接一个地做，你就会看到 Hyprland 平铺的魔力在发挥作用：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

然后你可以按 `Super + J`，将它们上下堆叠，而不是并排放置：

 ![navigation-stacked](images/navigation-stacked.webp)

再次按 `Super + J`，将它们恢复到并排的位置。然后在浏览器中试着按 `Super + Shift + Arrow Right`，交换这些窗口。

现在试着按 `Super + Shift + T` 启动 Activity 监视器。它会以浮动窗口的形式出现。你可以用 `Super + T` 将它平铺（再次按该组合键会让它恢复浮动）。现在按 `Super + Shift + F` 打开文件管理器。你会得到一个整洁的四分设置：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你可以用 `Super + Arrow` 在你想要激活的窗口之间导航。这会切换焦点，并将光标移动到新应用程序的中心。在屏幕的边缘处，它会继续移动到该侧的显示器上。

如果你按 `Super + Shift + 2`，你会将当前聚焦的应用程序移动到第二个工作区上。`Super + Shift + 1` 会将它移回来。（而 `Super + Shift + Alt + 2` 会将当前聚焦的应用程序移动到第二个工作区上，但不会切换过去。）

当有多台显示器时，每台显示器都有它自己的 1 到 10 号工作区。`Super + 2` 前往你所在显示器的第二个工作区，每台显示器的顶栏都会显示它自己的工作区以及它正在显示的那一个。`Super + Tab` 在你所在显示器的工作区之间循环切换。`Super + Shift + Ctrl + Arrows` 将你所在的窗口移动到那个方向的显示器上、移动到它正在显示的工作区上，而 `Super + Shift + Alt + Arrows` 将你所在的工作区移动到那个方向的显示器上，在那里如果该编号空闲，它就会采用相同的编号。显示器被拔下时，它会保留自己的工作区：它们会加入另一台屏幕，编号排在它已有的工作区之后，并在显示器回来时恢复到它们原来的编号之下。

如果你按住 `Super` 并用鼠标点击一个窗口，你就能重新安排它所在的位置。如果你按住 `Super` 并使用鼠标右键，你可以自由调整窗口大小。

你用 `Super + W` 或 `Super + Q` 关闭一个窗口（用 `Ctrl + Alt + Delete` 关闭所有窗口）。

你还可以用 `Super + F` 全屏，或者甚至用 `Super + Alt + F` 只占满全部宽度（保留顶栏），或者用 `Super + Ctrl + F` 在窗口内全屏（非常适合 YouTube！）。

### Dwindle 与 scrolling 布局

Omarchy 的默认布局叫做 dwindle。它让你在一个单一工作区上打开的所有窗口始终保持可见，即使这意味着它不得不将它们缩小。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以选择将一个工作区变为滚动布局，在这种布局中，窗口并排排成一行，超出显示屏可见边缘之外。你通过 `Super + L` 将单个工作区变为这种布局。

再次按 `Super + L` 会让工作区变为浮动布局，在这种布局中窗口自由重叠，由你自行放置它们，第三次按下则返回到 dwindle。`Super + Alt + L` 以相反方向循环切换。无论如何都会浮动的窗口——你用 `Super + T` 弹出的窗口，或总是以浮动方式打开的应用——在工作区恢复平铺时仍会保持浮动。顶栏会用它的布局标记你所在的工作区：正方形代表 dwindle，圆形代表 scrolling，三角形代表浮动。点击该标记也会循环切换布局，带有该按键的笔记本电脑上的显示按键也可以做到这一点。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

该选择是按工作区生效的，而且会保持不变。所以你可以让工作区 1 保持 dwindle 用于浏览，让工作区 2 保持 scrolling 用于写代码，重启后它们会以这种方式回来。

如果你希望将滚动布局用作默认布局，你可以在 `~/.config/hypr/looknfeel.lua` 中进行设置：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮动工作区

浮动工作区的工作方式像传统桌面：窗口重叠，由你自己移动它们并调整大小。每个窗口都会获得一个以你的主题颜色呈现的标题栏，带有最小化、最大化和关闭按钮。`Super + M` 也会最小化聚焦的窗口。最小化的窗口会在 dock 中等待；点击它的应用即可将其带回来。点击一个窗口将其提到前面。从任意边缘或角落调整它的大小。双击标题栏可以最大化窗口，同时保持顶栏可见，再次双击则恢复到它原来的大小。Chrome 和其他基于 Chromium 的浏览器、Disks 和 Document Viewer 会跳过标题栏，转而使用它们自己的头部；`Super + Alt + F` 会最大化它们，`Super + M` 会最小化它们。

浮动工作区还会显示一个 dock，其中有你固定的应用、所有正在运行的应用，以及 apps 按钮后面的每个应用的网格，`Super + Alt + Space` 和 Omarchy 菜单中的 _Apps_ 也能打开它。右键点击网格上的应用，或按 `Delete`，即可卸载它。点击一个应用可以打开它，或将其窗口提到前面；再次点击可以循环切换它的各个窗口。Files 只会带回你当前所在工作区的一个窗口，否则会打开一个新窗口，Terminal 和 Agent 总是会再启动一个，不过最小化的窗口会先回来。中键点击会打开一个新窗口。沿着 dock 拖动一个图标来移动它；将一个正在运行的应用拖到其他应用中间，会让它保留在那里。右键点击可以将一个应用保留在 dock 中、将其从中移除或退出它。dock 会为全屏窗口让路。右键点击 apps 按钮，可以将 dock 移到另一条边上，或让它一直隐藏，直到指针到达它的边缘。其位置也可以在 _Appearance > Dock > Dock Position_ 下设置，而 `omarchy dock position left` 和 `omarchy dock autohide on` 从终端设置这两项。你保留在 dock 中的应用在未运行时会呈淡色。

新工作区，以及任何你没有用 `Super + L` 为其指定自己布局的工作区，都会使用默认布局。更改默认布局会将每个没有窗口的工作区重置为该布局，而其上有窗口的工作区则会保留它所拥有的布局。被最小化到 dock 的窗口仍计作它所离开的那个工作区上的一个窗口。在 _Appearance > Workspace Layout_ 下选择它：Tiling、Scrolling 或 Floating。`omarchy hyprland workspace layout default scrolling` 从终端设置它。

### 窗口分组

窗口可以用 `Super + G` 进行分组。一旦你进入一个组，在该组处于活动状态时你启动的每个窗口都会属于该组。你可以用 `Super + Ctrl + Arrow Left/Right` 在这些已分组的窗口之间移动，或用 `Super + Alt + 1/2/3/4` 按顺序直接前往已分组的窗口。

你可以用 `Super + Alt + G` 将一个窗口移出分组，或再次按 `Super + G` 解散整个组。最后，你可以用 `Super + Alt + Arrows` 将组外的窗口移入组中。

### 弹出窗口

你可以用 `Super + O` 将一个窗口从其工作区分配中弹出。那会将它固定为一个浮动窗口，无论你前往哪个工作区，它都会跟着你。非常适合视频播放器之类的东西。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad 工作区

有一个特殊的全尺寸 scratchpad 工作区，它覆盖在你当前所在的任何工作区之上。你使用 `Super + S` 访问其上的内容，你使用 `Super + Alt + S` 将窗口放置在那里。

它非常适合用于你想快速交互、又不离开当前工作区的控件或终端。

### Quake 控制台

最后，有一个半高高度的 Quake 控制台，它会下拉覆盖在你当前所在的任何工作区之上。用 `Super + Grave` 切换它，并用 `Super + Shift + Grave` 将窗口放置在那里。

第一次打开时，它会启动你的默认 agent，或者如果你尚未选择一个，则要求你选择一个。当控制台只容纳单个窗口时，它会以居中面板的形式下拉，而不是横跨整个屏幕。在其上放置第二个应用，它就会恢复到完整的宽度，这样两个应用就有空间并排摆放了。

要将窗口从 scratchpad 或控制台移走，用类似 `Super + Shift + 1` 的按键将其直接发送到另一个工作区。

### 需要一些时间来适应！

以这种方式导航你的桌面需要一点时间来适应，但一旦你适应了，你就很难再回到传统的鼠标驱动的桌面体验中去了！
