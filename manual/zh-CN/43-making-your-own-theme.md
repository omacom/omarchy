# 制作你自己的主题

你可以将自己的主题添加到 `~/.config/omarchy/themes`。只需复制一个现有的主题作为基础（在 `/usr/share/omarchy/themes` 中查看），然后随心所欲地调整。只要你的主题位于该文件夹内，它就会被包含在主题选择菜单中。

你主要需要调整的文件是 `colors.toml`。它定义了颜色集，随后用于为终端（Foot/Alacritty/Ghostty/Kitty）、btop、Chromium、Hyprland、Neovim、Helix、VSCode、Obsidian 以及整个 Omarchy shell（顶部栏、菜单、通知、OSD 和锁屏）生成配置。

你也可以使用附带的 Aether 应用程序来创建新主题，通过一个可爱的 GUI 界面来调整颜色并搜索背景。只需通过 `Super + Alt + Space` 从应用程序网格中启动它。

### 已安装主题可以包含什么

你在 `~/.config/omarchy/themes` 中自己编写的主题可以包含任何你喜欢的内容——这是你的机器和你的文件，Omarchy 会应用其中的全部内容。

你使用 `omarchy theme install` 从别人的仓库安装的主题会保留所有与颜色相关的内容，并丢弃少数会在你的机器上运行代码的文件：任何 `.lua` 文件、终端配置（`alacritty.toml`、`foot.ini`、`ghostty.conf`、`kitty.conf`）以及 `vscode.json`。主题的 `hyprland.lua` 是你的合成器在登录时运行的 Lua，终端配置指定了你的终端启动的程序，而 `vscode.json` 指定了要安装的 VSCode 扩展。安装别人的主题应该改变你的桌面外观，绝不应该改变它运行的内容。

其他所有内容仍然完全按照主题作者编写的方式工作——`btop.theme`、`chromium.theme`、`helix.toml`、`icons.theme`、`shell.toml`、背景和预览都会被保留。只有被丢弃的内容才会在你的机器上从 `colors.toml` 重新生成。

Omarchy 通过主题内部是否有自己的 git 仓库来区分这两者，而这正是 `omarchy theme install` 克隆时留下的东西。所以你自己写的主题仍然属于你，而你从互联网上拉取的主题则只保留颜色。

### 浅色模式

如果你正在制作浅色模式主题，请在你的 `colors.toml` 顶部设置 `mode = "light"`。然后它会自动与所有应用程序的浅色模式配对。（旧方法——在你的主题根目录中放置一个名为 `light.mode` 的空文件——仍然有效。）

### 图标颜色

如果你想让文件管理器图标的颜色与你的主题匹配，请添加一个名为 `icons.theme` 的文件，其中写入你想要使用的图标集名称。默认情况下，选项为：`Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`。

### 解锁画面

提供 `unlock.png` 和 `preview-unlock.png` 图像的主题将列在 _Appearance > Unlock_ 下。你的 `unlock.png` 最好是一张透明的 png。你可以使用 `omarchy plymouth preview` 创建预览图像。

### 为 Omarchy 未涵盖的应用程序应用主题

如果你使用的应用程序不在该列表中，你可以用一个模板亲自教会 Omarchy 为它应用主题。在 `~/.config/omarchy/themed/` 中放入一个文件，其名称为它生成的配置加上 `.tpl` 扩展名，并使用 `{{ background }}`、`{{ foreground }}`、`{{ accent }}`、`{{ red }}`、`{{ color0 }}` 到 `{{ color15 }}` 以及调色板的其余部分作为占位符来编写配置。每次你切换主题时，该文件都会使用该主题的颜色重新生成。

该文件夹中有一个带有完整注释的 `alacritty.toml.tpl.sample` 可供复制——它列出了你可以使用的每个变量，以及 `_strip` 和 `_rgb` 修饰符，供那些希望颜色不带 `#` 或采用十进制 RGB 的应用程序使用。你的模板优先于 Omarchy 自带的模板，因此你也可以用此来覆盖内置应用程序应用主题的方式。

### 分发你的主题

如果你想分发你的主题以便其他人使用，你需要将其放在公共 git 服务器上，例如 GitHub。然后人们可以在 Omarchy 菜单中使用 _Install > Style > Theme_ 并通过该 URL 安装它。建议你遵循 `omarchy-[themename]-theme` 的命名约定，因为安装后，该主题将在主题选择菜单中正确显示为 `[themename]`。

剩下的 `[themename]` 会成为主题的目录名，因此它必须是一个 Omarchy 可以安全传递的名称：它必须以字母、数字或下划线开头，其余部分可以包含字母、数字、`.`、`_`、`+` 和 `-`。大写字母会为你转换为小写，但其他任何字符——空格、引号、非英文字符——都会在安装时被拒绝，而不是被转换成目录名。因此 `omarchy-tokyo-night-theme`、`omarchy-flexoki_light-theme` 和 `omarchy-c++-theme` 都可以正常安装。

请记住，一旦它从仓库安装，它附带的任何 `.lua`、终端配置或 `vscode.json` 都会被丢弃，因此不要围绕这些来构建主题。

你可以通过向 [omarchy-site 仓库](https://github.com/omacom-io/omarchy-site) 发送 pull request，将你的主题添加到[额外的主题页面](https://omarchy.org/themes/)。
