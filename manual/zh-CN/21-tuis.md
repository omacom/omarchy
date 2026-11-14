# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) 是一款令人愉悦的替代品，可以替代 GitHub Desktop 这类应用，而且它运行在终端里。

你可以直接运行它：进入任何由 git 管理的目录，然后运行 `lazygit`。或者你也可以在 Neovim 里运行它，在 Neovim 中可以用 `Space G G` 启动它。

使用 `Tab` 在不同的窗格之间跳转。在 Files 窗格中，使用 `Space` 选择要暂存的文件，然后可以使用 `c` 创建一个新的提交。使用 `?` 可以查看所有可用的命令。

## Btop

[Btop](https://github.com/aristocratos/btop) 是一款漂亮的资源管理器，可以显示内存、CPU、磁盘和网络使用情况。它还会列出所有正在运行的进程，并允许你管理它们。

Omarchy 称它为 Activity，按 `Super + Shift + T` 即可启动它。它会以浮动窗口的形式打开，你可以用 `Super + T` 将它平铺。

## Herdr

[Herdr](https://github.com/omacom-io/herdr) 是一款终端工作区管理器，为你提供工作区、标签页和窗格，并让它们全部在一个持久会话中运行，你可以从会话中断开，之后再回来。

用 `Super + Ctrl + Return` 启动它（或重新连接到你现有的会话）。Omarchy 附带了一份 Herdr 配置，它与它的 Tmux 配置保持一致，所以这里的前缀键同样是 `Ctrl + Space`。你可以用 `Super + Ctrl + K` 浏览所有的键绑定。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) 显示系统信息，比如内核版本、运行时间、主题、CPU、内存等等。它是流行的 neofetch 工具的后继者。

在 Omarchy 菜单（`Super + Space`）中，Omarchy 已经把它打包为 _About_。

## Cliamp

[Cliamp](https://www.cliamp.stream/) 是一款受 Winamp 2.x 启发的复古终端音乐播放器，内置了 lo-fi beats 电台。用 `Super + Shift + Alt + M` 启动它，或者从 Omarchy 菜单的 _Apps_ 下启动。按 `?` 查看完整的键绑定列表。

## Wi-Fi 和 Bluetooth 呢？

你不会找到用于 Wi-Fi 和 Bluetooth 的 TUI——那些工作属于 Omarchy shell。点击顶栏中的 Wi-Fi 图标（或按 `Super + Ctrl + N`）来查看网络并连接，点击 Bluetooth 图标（或按 `Super + Ctrl + B`）来配对和连接设备。完整内容请参阅[网络](35-networking.md)。

## 添加你自己的

任何终端程序都可以获得完整的应用程序待遇。前往 Omarchy 菜单（`Super + Space`）中的 _Install > TUI_，给它一个名称、一个启动命令、一种窗口样式和一个图标，它就会像任何其他应用程序一样出现在应用启动器中。你可以在 _Remove > TUI_ 下再次将它移除。
