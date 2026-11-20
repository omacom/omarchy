# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) 是一款令人愉悦的替代品，可替代 GitHub Desktop 这类应用，而且它运行在终端内部。

你可以直接运行它：进入任意由 git 管理的目录并运行 `lazygit`。或者你可以在 Neovim 内部运行它，在 Neovim 中可以用 `Space G G` 启动它。

你使用 `Tab` 在不同窗格之间跳转。在 Files 窗格中，你使用 `Space` 选择要暂存的文件，然后可以使用 `c` 创建新的提交。你可以使用 `?` 查看所有可用命令。

## Btop

[Btop](https://github.com/aristocratos/btop) 是一款美观的资源管理器，可显示内存、CPU、磁盘和网络使用情况。它还会列出所有活动进程，并允许你管理它们。

Omarchy 将其称为 Activity Monitor，你可以从应用启动器启动它，或按 `Super + Shift + T`。它会以浮动窗口形式打开，你可以用 `Super + T` 将其平铺。

## Herdr

[Herdr](https://github.com/omacom-io/herdr) 是一款终端工作区管理器，为你提供工作区、标签页和窗格，并让它们全部运行在一个持久会话中，你可以从会话分离，稍后再回来。

你可以从应用启动器启动它（或重新连接到你现有的会话），或使用 `Super + Ctrl + Return`。Omarchy 附带了一份 Herdr 配置，它镜像了其 Tmux 配置，因此这里的前缀键同样是 `Ctrl + Space`。你可以使用 `Super + Ctrl + K` 浏览所有键绑定。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) 显示系统信息，如内核版本、运行时间、主题、CPU、内存等。它是流行的 neofetch 工具的后继者。

Omarchy 已将其打包为 Omarchy 菜单（`Super + Space`）中的 _System > About_。

## Cliamp

[Cliamp](https://www.cliamp.stream/) 是一款受 Winamp 2.x 启发的复古终端音乐播放器，内置了 lo-fi 节拍电台。使用 `Super + Shift + Alt + M` 启动它，或从 Omarchy 菜单的 _Apps_ 下启动它。按 `?` 查看完整的键绑定列表。

## Wi-Fi 和 Bluetooth 呢？

你不会找到用于 Wi-Fi 和 Bluetooth 的 TUIs——这些工作属于 Omarchy shell。点击顶栏中的 Wi-Fi 图标（或按 `Super + Ctrl + N`）查看网络并连接，点击 Bluetooth 图标（或按 `Super + Ctrl + B`）配对并连接设备。完整内容请参阅[网络](35-networking.md)。

## 添加你自己的

任何终端程序都可以获得完整的应用待遇。前往 Omarchy 菜单（`Super + Space`）中的 _Install > TUI_，为其指定一个名称、一个启动命令、一个窗口样式和一个图标，它就会像任何其他应用一样出现在应用启动器中。你可以在 _Remove > TUI_ 下再次将其移除。
