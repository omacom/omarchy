# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) 是 GitHub Desktop 这类应用的一个令人愉快的替代品，而且它运行在终端里。

你可以直接运行它：进入任何由 git 管理的目录，然后运行 `lazygit`。或者你也可以在 Neovim 里运行它，在那里可以用 `Space G G` 启动它。

你可以用 `Tab` 在不同的窗格之间跳转。在 Files 窗格中，你用 `Space` 选择要暂存的文件，然后用 `c` 创建一个新的提交。你可以用 `?` 查看所有可用的命令。

## Btop

[Btop](https://github.com/aristocratos/btop) 是一个漂亮的资源管理器，它会显示内存、CPU、磁盘和网络的使用情况。它还会列出所有活跃的进程，并允许你管理它们。

Omarchy 把它叫做 Activity Monitor，你可以从应用启动器启动它，或者按 `Super + Shift + T`。它会以浮动窗口的形式打开，你可以用 `Super + T` 把它平铺。

## Herdr

[Herdr](https://github.com/omacom-io/herdr) 是一个终端工作区管理器，它为你提供工作区、标签页和窗格，并让它们全部在一个持久会话中持续运行，你可以从会话中分离，稍后再回来。

你可以用 `Super + Ctrl + Return` 启动它（或者重新附加到你现有的会话）。Omarchy 附带了一份 Herdr 配置，它与自己的 Tmux 配置保持一致，所以这里的前缀键也是 `Ctrl + Space`。你可以用 `Super + Ctrl + K` 浏览所有快捷键绑定。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) 会显示系统信息，比如内核版本、运行时间、主题、CPU、内存等等。它是广受欢迎的 neofetch 工具的后继者。

Omarchy 已经把这个打包成了 Omarchy 菜单（`Super + Space`）中的 _About_。

## Cliamp

[Cliamp](https://www.cliamp.stream/) 是一个复古的终端音乐播放器，灵感来自 Winamp 2.x，还内置了用于 lo-fi 节拍的广播电台。用 `Super + Shift + Alt + M` 启动它，或者从 Omarchy 菜单的 _Apps_ 下启动它。按 `?` 查看完整的快捷键绑定列表。

## Wi-Fi 和 Bluetooth 怎么办？

你找不到用于 Wi-Fi 和 Bluetooth 的 TUI——这些工作属于 Omarchy shell。点击顶栏中的 Wi-Fi 图标（或者按 `Super + Ctrl + N`）查看网络并连接，点击 Bluetooth 图标（或者按 `Super + Ctrl + B`）配对并连接设备。完整介绍请参见[网络](35-networking.md)。

## 添加你自己的

任何终端程序都可以获得完整的应用待遇。转到 Omarchy 菜单（`Super + Space`）中的 _Install > TUI_，为它指定一个名称、一个启动命令、一个窗口样式和一个图标，它就会像任何其他应用一样出现在应用启动器中。你可以在 _Remove > TUI_ 下再次将它移除。
