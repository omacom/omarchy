# 导航

在 Omarchy 中，一切都通过键盘完成——_一切！_ 系统刚启动时，你真的无法仅靠鼠标做任何事。但你可以按 `Super + Space` 调出 Omarchy Menu，从这里你可以完成几乎所有事情。

但在大多数时候，Omarchy 菜单甚至都不打算成为操作系统的主要方式。我们还能更快！所有最重要的应用程序都直接绑定到了单个快捷键上。你用 `Super + Return` 启动终端，用 `Super + Shift + Return` 启动浏览器。试着一个接一个地打开，你就会看到 Hyprland 平铺的魔力在发挥作用：

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

然后你可以按 `Super + J`，将它们上下堆叠，而不是并排排列：

 ![navigation-stacked](images/navigation-stacked.webp)

再次按 `Super + J`，将它们恢复到并排位置。然后在浏览器上试试 `Super + Shift + Arrow Right`，交换这些窗口。

现在试试 `Super + Shift + T` 启动 Activity 监视器。它会以浮动窗口的形式出现。你可以用 `Super + T` 将它平铺（再次按该组合键可让它重新浮动）。现在按 `Super + Shift + F` 打开文件管理器。你将得到一个整洁的四窗口布局：

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

你用 `Super + Arrow` 在你想要激活的窗口之间导航。这将切换焦点，并将光标移动到新应用程序的中心。在屏幕边缘，它会继续移动到那一侧的显示器上。

如果你按 `Super + Shift + 2`，你会将当前聚焦的应用程序移动到第二个工作区。`Super + Shift + 1` 将它移回来。（而 `Super + Shift + Alt + 2` 会将当前聚焦的应用程序移动到第二个工作区，但不会切换到那里）。

使用多个显示器时，每个显示器都有自己的 1 到 10 号工作区。`Super + 2` 会前往你所在显示器的第二个工作区，并且每个显示器的顶栏都会显示自己的工作区，以及它当前正在显示的工作区。`Super + Tab` 在你所在显示器的工作区之间循环。`Super + Shift + Ctrl + Arrows` 将你所在的窗口移动到那个方向的显示器上，放到它正在显示的工作区上，而 `Super + Shift + Alt + Arrows` 将你所在的工作区移动到那个方向的显示器上，在那里，如果编号空闲，它会保持相同的编号。拔掉一个显示器时，它会保留自己的工作区：它们会加入另一个屏幕，编号排在它已有的工作区之后，并在显示器回来时回到它们原来的编号之下。

如果你按住 `Super` 并用鼠标点击一个窗口，你将能够重新安排它的位置。如果你按住 `Super` 并使用鼠标右键，你可以自由调整窗口大小。

你用 `Super + W` 或 `Super + Q` 关闭一个窗口（并用 `Ctrl + Alt + Delete` 关闭所有窗口）。

你还可以用 `Super + F` 全屏，甚至可以用 `Super + Alt + F` 仅全宽（保留顶栏），或者用 `Super + Ctrl + F` 在窗口内全屏（非常适合 YouTube！）。

### Dwindle 与滚动布局

Omarchy 的默认布局称为 dwindle。它让你在单个工作区上打开的所有窗口始终可见，即使这意味着必须将它们缩小。

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

但你也可以选择将一个工作区变成滚动布局，在这种布局中，窗口并排排列，延伸到显示器可见边缘之外。你通过 `Super + L` 将单个工作区变成这种布局。

再次按 `Super + L` 会将工作区变为浮动布局，在这种布局中，窗口自由重叠，并由你自己放置它们，第三次按下会将它恢复为 dwindle。`Super + Alt + L` 会以相反的方向在它们之间循环。一个本来就浮动的窗口——用 `Super + T` 弹出的窗口，或者一个始终以浮动方式打开的应用——在工作区恢复为平铺时仍会保持浮动。顶栏会用其布局标记你所在的工作区：正方形代表 dwindle，圆形代表滚动，三角形代表浮动。点击该标记也会循环切换布局。

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

这一选择以工作区为单位，并且会保留。所以你可以让 1 号工作区保持 dwindle 用于浏览，让 2 号工作区保持滚动用于写代码，并且它们在重启后会以同样的方式回来。

如果你希望将滚动布局用作默认布局，你可以在 `~/.config/hypr/looknfeel.lua` 中设置它：

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### 浮动工作区

浮动工作区的工作方式像传统桌面一样：窗口相互重叠，并由你自己移动和调整它们的大小。每个窗口都有一个使用你的主题颜色的标题栏，带有最小化、最大化和关闭按钮。`Super + M` 也会最小化聚焦的窗口。最小化的窗口会在 dock 中等待；点击它的应用可以将它带回来。点击一个窗口可以将它带到前面。从任何边缘或角落调整它的大小。双击标题栏可以最大化窗口，同时保持顶栏可见，再次双击可以恢复它的原来的大小。

浮动工作区还会显示一个 dock，其中包含你固定的应用、所有正在运行的应用，以及 apps 按钮后面的所有应用网格，`Super + Alt + Space` 和 Omarchy 菜单中的 _Apps_ 也可以打开它。右键点击网格上的一个应用，或按 `Delete`，可以卸载它。点击一个应用可以打开它，或者将其窗口带到前面；再次点击可以在它的窗口之间循环。中键点击会打开一个新窗口。沿着 dock 拖动一个图标可以移动它；将一个正在运行的应用拖到其他应用之中会将它保留在那里。右键点击可以将一个应用保留在 dock 中、将它移出，或者退出它。dock 会为全屏窗口让路。右键点击 apps 按钮可以将 dock 移动到另一条边缘，或者让它一直隐藏，直到指针到达其边缘。该位置也位于 _Appearance > Dock > Dock Position_ 之下，并且 `omarchy dock position left` 和 `omarchy dock autohide on` 可以从终端设置这两者。你保留在 dock 中的应用在未运行时会变暗。

新的工作区，以及任何你没有用 `Super + L` 为其赋予自己布局的工作区，都会使用默认布局。更改默认布局会将每个没有窗口的工作区重置为该布局，而有窗口的工作区会保留它现有的布局。最小化到 dock 的窗口仍算作它离开的工作区上的一个窗口。在 _Appearance > Workspace Layout_ 之下选择它：平铺、滚动或浮动。`omarchy-hyprland-workspace-layout-default scrolling` 从终端设置它。

### 分组窗口

可以使用 `Super + G` 对窗口进行分组。一旦你进入一个组，在该组处于活动状态时启动的每个窗口都会属于该组。你可以使用 `Super + Ctrl + Arrow Left/Right` 在这些分组窗口之间移动，或者使用 `Super + Alt + 1/2/3/4` 按顺序直接前往分组窗口。

你可以用 `Super + Alt + G` 将一个窗口移出分组，或者再次按 `Super + G` 解散整个组。最后，你可以用 `Super + Alt + Arrows` 将组外的窗口移入组中。

### 弹出窗口

你可以用 `Super + O` 将一个窗口从其工作区分配中弹出。这会将它固定为一个浮动窗口，无论你前往哪个工作区，它都会跟随你。非常适合视频播放器之类的东西。

 ![navigation-popped-window](images/navigation-popped-window.webp)

### 暂存工作区

有一个特殊的全尺寸暂存工作区，它会覆盖在你当前所在的工作区之上。你用 `Super + S` 访问上面的内容，并用 `Super + Alt + S` 将窗口放置在那里。

它非常适合控件或你想要快速交互而不离开当前工作区的终端。

### Quake 控制台

最后，有一个半高的 Quake 控制台，它会下拉覆盖在你当前所在的工作区之上。用 `Super + Grave` 切换它，并用 `Super + Shift + Grave` 将一个窗口放置在那里。

它打开时，你的默认 agent 已经准备就绪。当控制台只容纳一个窗口时，它会以居中面板的形式下拉，而不是横跨整个屏幕。在其上放置第二个应用，它会恢复为全宽，这样两者就有空间并排摆放。

要将窗口从暂存区或控制台上移走，请用类似 `Super + Shift + 1` 的组合键将它直接发送到另一个工作区。

### 需要一些时间来适应！

习惯以这种方式导航你的桌面需要一点时间，但一旦你习惯了，就很难再回到传统的鼠标驱动桌面体验了！
