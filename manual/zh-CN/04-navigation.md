# 导航

Omarchy 里的一切都通过键盘完成——_一切！_ 系统刚启动时，你真的没法只靠鼠标做任何事。但你可以按 `Super + Space` 唤出 Omarchy Menu，从这里出发，你几乎能做所有事。

但 Omarchy 菜单甚至都不打算成为大多数时候操作系统的主要方式。我们还能更快！所有最重要的应用都直接绑定到了单独的快捷键上。你用 `Super + Return` 启动终端，用 `Super + Shift + Return` 启动浏览器。一个接一个试试，你就会看到 Hyprland 平铺的魔力在发挥作用：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

然后你可以按 `Super + J` 把它们堆叠起来，而不是并排排列：

 ![navigation-stacked](images/navigation-stacked.webp)

再按一次 `Super + J`，让它们回到并排位置。然后在浏览器中试试 `Super + Shift + Arrow Right`，交换窗口位置。

现在试试 `Super + Shift + T` 启动活动监视器。它会以浮动窗口的形式出现。你可以用 `Super + T` 让它平铺（再按一次又会让它重新浮动）。现在按 `Super + Shift + F` 打开文件管理器。你会得到一个整齐的四分布局：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你可以用 `Super + Arrow` 在你想激活的窗口之间导航。这会切换焦点，并把光标移动到新应用的中央。在屏幕边缘时，它会继续移动到那一侧的显示器上。

如果你按 `Super + Shift + 2`，你会把当前聚焦的应用移动到第二个工作区。`Super + Shift + 1` 会把它移回来。（而 `Super + Shift + Alt + 2` 会把当前聚焦的应用移动到第二个工作区，但不切换过去）。

有多个显示器时，每个显示器都有自己的 1 到 10 号工作区。`Super + 2` 会前往你所在显示器的第二个工作区，每个显示器的顶栏都会显示自己的工作区以及正在显示的那个。`Super + Tab` 会在你所在显示器的工作区之间循环。`Super + Shift + Ctrl + Arrows` 会把你所在的窗口移动到那个方向的显示器上，放到它正在显示的工作区上，而 `Super + Shift + Alt + Arrows` 会把你所在的工作区移到那个方向的显示器上，如果那个编号空着，它在那里会占用同一个编号。显示器被拔掉时，它会保留自己的工作区：它们会加入另一个屏幕的工作区，编号排在它已有工作区的后面，并在显示器回来时回到它们原来的编号下。

如果你按住 `Super` 并用鼠标点击一个窗口，你就能重新安排它的位置。如果你按住 `Super` 并用鼠标右键，你可以自由调整窗口大小。

你可以用 `Super + W` 或 `Super + Q` 关闭一个窗口（用 `Ctrl + Alt + Delete` 关闭所有窗口）。

你还可以用 `Super + F` 全屏，甚至可以用 `Super + Alt + F` 只全宽（保留顶栏），或用 `Super + Ctrl + F` 在窗口内全屏（非常适合 YouTube！）。

### Dwindle 与滚动布局

Omarchy 的默认布局叫 dwindle。它会让单个工作区上打开的所有窗口始终可见，哪怕不得不把它们缩小。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以选择把一个工作区变成滚动布局，在这种布局下窗口并排排列，延伸到显示屏的可见边缘之外。你用 `Super + L` 把单个工作区变成这种布局。

再按一次 `Super + L` 会把工作区变成浮动布局，窗口在其中自由重叠，由你自己摆放，第三次按下则回到 dwindle。`Super + Alt + L` 会朝相反方向依次切换。反正已经浮动的窗口——你用 `Super + T` 弹出来的窗口，或者总是以浮动方式打开的应用——在工作区回到平铺时会保持浮动。顶栏会用一个标记标出你所在工作区的布局：正方形代表 dwindle，圆形代表滚动，三角形代表浮动。点击那个标记也会循环切换布局。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

这个选择是按工作区生效的，而且会保持不变。所以你可以让工作区 1 保持 dwindle 用于浏览，工作区 2 保持滚动用于写代码，重启后它们还会以那种方式回来。

如果你希望把滚动布局用作默认布局，你可以在 `~/.config/hypr/looknfeel.lua` 中这样设置：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮动工作区

浮动工作区的工作方式像传统桌面：窗口重叠，由你自己移动和调整大小。每个窗口都会得到一个以你的主题颜色显示的标题栏，带有最小化、最大化和关闭按钮。`Super + M` 也会最小化聚焦的窗口。最小化的窗口会在程序坞中等着；点击它的应用把它带回来。点击一个窗口把它带到前面。从任意边缘或角落调整它的大小。双击标题栏让窗口最大化，同时保持顶栏可见，再双击一次恢复它原来的大小。Chrome 和其他基于 Chromium 的浏览器、Disks 和 Document Viewer 会跳过标题栏，改用它们自己的标题区；`Super + Alt + F` 最大化它们，`Super + M` 最小化它们。

浮动工作区还会显示一个程序坞，带有你固定的应用、所有正在运行的应用，以及应用按钮后面的一个包含每个应用的网格，`Super + Alt + Space` 和 Omarchy 菜单中的 _Apps_ 也会打开它。在网格上右键点击一个应用，或者按 `Delete`，可以卸载它。点击一个应用打开它，或者把它的窗口带到前面；再次点击会在它的窗口之间循环。Files 只会带回你所在工作区的一个窗口，否则会打开一个新的，而 Terminal 和 Agent 总是会启动另一个，不过最小化的窗口会先回来。中键点击会打开一个新窗口。沿着程序坞拖动一个图标来移动它；把一个正在运行的应用拖到其他应用中间会让它留在那里。右键点击可以把一个应用保留在程序坞中、把它从中取出，或者退出它。程序坞会为全屏窗口让路。右键点击应用按钮，可以把程序坞移到另一条边上，或者让它隐藏起来，直到指针到达它的边缘。这个位置也在 _Appearance > Dock > Dock Position_ 下，而 `omarchy dock position left` 和 `omarchy dock autohide on` 可以从终端设置这两项。你保留在程序坞中的应用在没有运行时会变淡。

新的工作区，以及任何你没有用 `Super + L` 为其单独指定布局的工作区，会使用默认布局。更改默认布局会把每个没有窗口的工作区重置为该布局，而有窗口的工作区会保留它现有的布局。最小化到程序坞的窗口仍然算作它离开的那个工作区上的一个窗口。在 _Appearance > Workspace Layout_ 下选择它：Tiling、Scrolling 或 Floating。`omarchy-hyprland-workspace-layout-default scrolling` 可以从终端设置它。

### 对窗口分组

你可以用 `Super + G` 对窗口分组。一旦你进入一个组，在该组处于活动状态时，你启动的每个窗口都会属于这个组。你可以用 `Super + Ctrl + Arrow Left/Right` 在这些分组窗口之间移动，或者用 `Super + Alt + 1/2/3/4` 按顺序直接前往分组窗口。

你可以用 `Super + Alt + G` 把一个窗口移出分组，或者再按一次 `Super + G` 拆解整个组。最后，你可以用 `Super + Alt + Arrows` 把组外的窗口移进组里。

### 弹出窗口

你可以用 `Super + O` 把一个窗口从它所在的工作区分配中弹出。那会把它固定为一个浮动窗口，无论你到哪个工作区，都跟着你。非常适合视频播放器之类的应用。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad 工作区

有一个特殊的全尺寸 scratchpad 工作区，它会叠加在你当前所在的任何工作区之上。你用 `Super + S` 访问上面的内容，用 `Super + Alt + S` 把窗口放到那里。

它很适合放控制工具，或者一个你想快速交互又不想离开当前工作区的终端。

### Quake 控制台

最后，还有一个半高尺寸的 Quake 控制台，它会从你当前所在工作区的上方落下。用 `Super + Grave` 切换它，用 `Super + Shift + Grave` 把一个窗口放到那里。

它打开时，你的默认 agent 已经准备就绪。当控制台只容纳单个窗口时，它落下时是居中的面板，而不是横跨整块屏幕。在上面放第二个应用，它就会回到全宽，好让这两个应用有空间并排摆放。

要把一个窗口从 scratchpad 或控制台上移走，用类似 `Super + Shift + 1` 的按键把它直接发送到另一个工作区。

### 确实需要一点时间适应！

习惯像这样导航你的桌面确实需要一点时间，但一旦你习惯了，就很难再回到传统的、用鼠标驱动的桌面体验了！
