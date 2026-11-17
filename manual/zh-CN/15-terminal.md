# 终端

[Foot](https://codeberg.org/dnkl/foot) 是 Omarchy 的默认终端。它速度快、轻量，并且与旧计算机兼容。不过，它不支持原生选项卡或分割。

如果你使用 Tmux，你可能不会介意，但如果不是，我们也完全支持 _Alacritty_、_Ghostty_ 和 _Kitty_ 作为选项。在 Omarchy 菜单的_安装 > 终端_下选择你的偏好。

你使用 `Super + Return` 启动新终端。（此绑定会自动指向你通过_安装 > 终端_安装的任何终端，你可以在_设置 > 默认项 > 终端_下在已安装的终端之间切换。）

## Tmux

无论你使用何种终端，Tmux 都为窗格、窗口（即选项卡）和可恢复会话提供一致的、可编程的界面。它甚至可以在远程主机上工作，所以当你通过 SSH 连接到服务器时，你可以使用相同的方法。

你使用 `Super + Alt + Return` 在崭新的终端中启动新的 Tmux 会话，由于 Tmux 是一个持久进程，即使你关闭该终端，你也可以恢复会话。只需按 `Ctrl + Space`（称为前缀键），然后按 `s` 查看你所有的活动会话。

Omarchy 附带了经过人体工程学优化的 Tmux 配置，其中有很多键盘绑定需要学习，所以请[将备忘单放在手边](07-hotkeys.md#tmux)。

## Tmux 布局函数

由于 Tmux 是可编程的，我们可以使用函数来创建布局。Omarchy 附带了四个不同函数，用于常见的开发人员布局。

`tdl [agent]` 启动一个三分式 IDE 风格的界面，左侧是 `$EDITOR`，右侧是你选择的 AI 智能体（例如 `c` 代表 opencode，`cx` 代表 Claude，`codex` 代表 OpenAI），底部是终端。

所以 `tdl c` 会启动这个界面（或者直接用 `ic`）：

 ![tmux-tdl](images/tmux-tdl.webp)

你也可以用 `tdl c cx`（opencode + claude）启动第二个智能体（或者直接用 `icx`）：

 ![tmux-tdl2](images/tmux-tdl2.webp)

还有 `tds`，它启动一个四分方形布局，左上是编辑器，右上是实时差异监视器，左下是终端，右下是 opencode。

你也可以使用 `tdlm [agent]` 为当前目录中的每个子目录启动此布局配置，然后使用 `alt + 1/2/3/4/5/...` 进行导航：

 ![tmux-tdlm](images/tmux-tdlm.webp)

最后，你可以使用 `tsl [panes] [command]` 启动一群智能体。所以 `tsl 4 c` 会为你提供一个 opencode 智能体的四分网格：

 ![tmux-tsl](images/tmux-tsl.webp)
