# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) 是 GitHub Desktop 这类应用的令人愉快的替代品，而且它运行在终端内。

你可以直接运行它：进入任意由 git 管理的目录并运行 `lazygit`。或者你可以在 Neovim 里运行它，在 Neovim 中可以用 `Space G G` 启动它。

你用 `Tab` 在不同窗格之间跳转。在 Files 窗格中，你用 `Space` 选择要暂存的文件，然后可以用 `c` 创建一个新的提交。你可以用 `?` 查看所有可用的命令。

## Btop

[Btop](https://github.com/aristocratos/btop) 是一个漂亮的资源管理器，显示内存、CPU、磁盘和网络使用情况。它还列出所有活跃进程，并允许你管理它们。

Omarchy 称它为 Activity，你按下 `Super + Ctrl + T` 启动它。它以浮动窗口打开，你可以用 `Super + T` 将其平铺。

## Herdr

[Herdr](https://github.com/omacom-io/herdr) 是一个终端工作区管理器，为你提供工作区、标签页和窗格，并让它们都在一个持久会话中运行，你可以断开连接稍后再回来。

你用 `Super + Ctrl + Return` 启动它（或重新连接到已有会话）。Omarchy 自带一份与 Tmux 配置相呼应的 Herdr 配置，所以这里的前缀键也是 `Ctrl + Space`。你可以用 `Super + Ctrl + K` 浏览所有快捷键。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) 显示系统信息，如内核版本、运行时间、主题、CPU、内存等。它是流行的 neofetch 工具的后继者。

Omarchy 在 Omarchy 菜单（`Super + Space`）中将其打包为 _About_。

## Cliamp

[Cliamp](https://www.cliamp.stream/) 是一款受 Winamp 2.x 启发的复古终端音乐播放器，内置 lo-fi 音乐电台。用 `Super + Shift + Alt + M` 启动它，或从 Omarchy 菜单的 _Apps_ 下启动。按 `?` 查看完整的快捷键列表。

## Wi-Fi 和蓝牙呢？

你找不到 Wi-Fi 和蓝牙的 TUI——这些工作属于 Omarchy shell。点击菜单栏中的 Wi-Fi 图标（或按 `Super + Ctrl + W`）查看网络并连接，点击蓝牙图标（或按 `Super + Ctrl + B`）配对和连接设备。完整说明见[网络](35-networking.md)。

## 添加你自己的

任何终端程序都可以得到完整的应用程序待遇。进入 Omarchy 菜单（`Super + Space`）中的 _安装 > TUI_，给它一个名称、一个启动命令、一种窗口样式和一个图标，它就会像任何其他应用程序一样出现在应用程序启动器中。你可以在 _移除 > TUI_ 下再次将其删除。
