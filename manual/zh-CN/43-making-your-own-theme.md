# 制作你自己的主题

你可以将自己的主题添加到 `~/.config/omarchy/themes`。只需复制一个现有主题作为基础（在 `/usr/share/omarchy/themes` 中查看），然后随心所欲地调整。只要你的主题位于该文件夹中，它就会包含在主题选择菜单中。

你需要调整的主要文件是 `colors.toml`。它定义了颜色集，随后会用于生成以下内容的配置：终端（Foot/Alacritty/Ghostty/Kitty）、btop、Chromium、Hyprland、Neovim、Helix、VSCode、Obsidian、Qt 应用、键盘背光、输入法、屏幕共享选择器、应用图标、多款 AI 工具（Claude、Pi、Hermes、T3 Code、Herdr），以及整个 Omarchy shell（顶部栏、菜单、通知、OSD 和锁屏）。

你也可以使用随附的 Aether 应用，通过精美的 GUI 界面试玩颜色并搜索背景来创建新主题。只需通过 `Super + Alt + Space` 在应用网格中启动它。

### 已安装的主题可以包含什么

你在 `~/.config/omarchy/themes` 中自己编写的主题可以包含任何你想要的内容——这是你的机器和你的文件，Omarchy 会应用其中的全部内容。

通过 `omarchy theme install` 从他人的仓库安装的主题会保留所有与颜色有关的内容，并丢弃少数会在你的机器上运行代码的文件：任何 `.lua` 文件、终端配置（`alacritty.toml`、`foot.ini`、`ghostty.conf`、`kitty.conf`）以及 `vscode.json`。主题的 `hyprland.lua` 是合成器在登录时会运行的 Lua，终端配置指定了终端启动时运行的程序，而 `vscode.json` 指定了要安装的 VSCode 扩展。安装他人的主题应该只改变桌面的外观，永远不应改变它运行的内容。

其他一切仍会完全按照主题作者编写的方式工作——`btop.theme`、`chromium.theme`、`helix.toml`、`shell.toml`、背景和预览都会保留。只有被丢弃的部分才会根据你机器上的 `colors.toml` 重新生成。

Omarchy 通过主题内部是否包含自己的 git 仓库来区分这两种情况，而这正是 `omarchy theme install` 在克隆时留下的内容。因此，你自己编写的主题仍归你所有，而从互联网上获取的主题则只保留颜色。

### 浅色模式

如果你正在制作浅色模式主题，请在 `colors.toml` 顶部设置 `mode = "light"`。然后它会自动与所有应用的浅色模式配对。（旧方法——在主题根目录中放入一个名为 `light.mode` 的空文件——仍然有效。）

### 启动和登录屏幕

启动时询问驱动器密码的屏幕以及登录屏幕，会以主题的 `background` 为背景，用主题的 `accent` 颜色绘制 Omarchy 标志，密码字段使用 `foreground`，密码错误时使用 `red`。你无需为它们额外提供任何内容：Omarchy 不再使用主题的 `unlock.png` 或 `preview-unlock.png`。在 Apple Silicon Mac 上，无论使用什么主题，驱动器密码屏幕都会保留 Omarchy 的默认外观。

### 为 Omarchy 未涵盖的应用设置主题

如果你使用的应用不在该列表中，你可以用模板亲自教会 Omarchy 为它设置主题。在 `~/.config/omarchy/themed/` 中放入一个文件，以它生成的配置文件命名并加上 `.tpl` 扩展名，并使用 `{{ background }}`、`{{ foreground }}`、`{{ accent }}`、`{{ red }}`、`{{ color0 }}` 到 `{{ color15 }}` 以及调色板其余部分作为占位符来编写配置。每次切换主题时，该文件都会使用该主题的颜色重新生成。

该文件夹中有一个带有完整注释的 `alacritty.toml.tpl.sample` 可供复制——它列出了你可以使用的每个变量，以及 `_strip` 和 `_rgb` 修饰符，供希望以不带 `#` 的形式或十进制 RGB 形式获取颜色的应用使用。你的模板优先于 Omarchy 自带的模板，因此你也可以用它来覆盖内置应用的主题设置方式。

### 分发你的主题

如果你想分发你的主题以供他人使用，你需要将其放在公共 git 服务器上，如 GitHub。然后人们就可以在 Omarchy 菜单中使用该 URL，通过 _安装 > 样式 > 主题_ 安装它。建议你遵循 `omarchy-[themename]-theme` 的命名约定，因为安装后该主题会在主题选择菜单中正确显示为 `[themename]`。

剩下的 `[themename]` 会成为主题的目录名，因此它必须是 Omarchy 可以安全传递的名称：它必须以字母、数字或下划线开头，其余部分可以包含字母、数字、`.`、`_`、`+` 和 `-`。大写字母会为你转换为小写，但任何其他字符——空格、引号、非英文字符——都会在安装时被拒绝，而不是转换为目录名。因此，`omarchy-tokyo-night-theme`、`omarchy-flexoki_light-theme` 和 `omarchy-c++-theme` 都可以正常安装。

请记住，一旦从仓库安装，该主题随附的任何 `.lua`、终端配置或 `vscode.json` 都会被丢弃，因此不要围绕这些内容来构建主题。

你可以向 [omarchy-site 仓库](https://github.com/omacom-io/omarchy-site) 发送 pull request，将你的主题添加到[额外主题页面](https://omarchy.org/themes/)。
