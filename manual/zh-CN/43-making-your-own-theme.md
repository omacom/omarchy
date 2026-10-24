# 制作你自己的主题

你可以将自己的主题添加到 `~/.config/omarchy/themes`。只需复制一个现有的主题作为基础（在 `/usr/share/omarchy/themes` 里找），然后尽情调整。只要你的主题在那个文件夹里，它就会被包含在主题选择菜单中。

你必须调整的主要文件是 `colors.toml`。它定义了一套颜色，随后用于生成终端（Foot/Alacritty/Ghostty/Kitty）、btop、Chromium、Hyprland、Neovim、Helix、VSCode、Obsidian 和整个 Omarchy shell（菜单栏、菜单、通知、OSD 和锁定屏幕）的配置。

你也可以使用附带的 Aether 应用程序，通过一个很棒的 GUI 界面来玩弄颜色并搜索背景，从而创建一个新主题。只需用 `Super + Alt + Space` 从应用网格启动它。

### 一个已安装的主题可以包含什么

你在 `~/.config/omarchy/themes` 里自己编写的主题可以包含任何你喜欢的东西——这是你的机器、你的文件，Omarchy 会应用其中的一切。

你用 `omarchy theme install` 从别人的仓库安装的主题会保留所有与颜色相关的内容，只去掉少数几个会在你机器上运行代码的文件：任何 `.lua` 文件、终端配置（`alacritty.toml`、`foot.ini`、`ghostty.conf`、`kitty.conf`）和 `vscode.json`。主题的 `hyprland.lua` 是你的合成器在登录时运行的 Lua，终端配置指名了你的终端启动的程序，而 `vscode.json` 指名了一个要安装的 VSCode 扩展。安装别人的主题应该改变你的桌面外观，绝不能改变它运行什么。

其他一切仍然完全按照主题作者编写的那样工作——`btop.theme`、`chromium.theme`、`helix.toml`、`icons.theme`、`shell.toml`、背景和预览全部保留。只有被丢弃的部分会在你的机器上根据 `colors.toml` 重新生成。

Omarchy 通过主题内是否有自己的 git 仓库来区分这两者，这正是 `omarchy theme install` 克隆时留下的东西。所以你自己写的主题仍然是你的，而你从网上拉来的主题仍然只是颜色。

### 浅色模式

如果你要制作一个浅色模式主题，请在你的 `colors.toml` 顶部设置 `mode = "light"`。然后，它会自动与所有应用的浅色模式配对。（在主题根目录放置一个名为 `light.mode` 的空文件的旧方法也仍然有效。）

### 图标颜色

如果你想让文件管理器的图标与你的主题颜色匹配，请添加一个名为 `icons.theme` 的文件，其中包含你想要使用的图标集的名称。默认选项是：`Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`。

### 解锁图片

随附 `unlock.png` 和 `preview-unlock.png` 图片的主题会列在 _样式 > 解锁_ 下。你的 `unlock.png` 最好是一张透明 png。你可以使用 `omarchy plymouth preview` 创建预览图。

### 为 Omarchy 未涵盖的应用设置主题

如果你使用的一款应用不在那个列表里，你可以用一个模板亲自教 Omarchy 为其设置主题。在 `~/.config/omarchy/themed/` 里放入一个文件，命名为它所生成的配置再加上 `.tpl` 扩展名，并用 `{{ background }}`、`{{ foreground }}`、`{{ accent }}`、`{{ red }}`、`{{ color0 }}` 到 `{{ color15 }}` 以及调色板的其余部分作为占位符来编写配置。每当你切换主题时，该文件都会用该主题的颜色重新生成。

那个文件夹里有一个带完整注释的 `alacritty.toml.tpl.sample` 可以供你复制——它列出了你可以使用的每一个变量，外加 `_strip` 和 `_rgb` 修饰符，适用于那些想要不带 `#` 或使用十进制 RGB 颜色的应用。你的模板优先于 Omarchy 自己的模板，所以你也可以用它来覆盖内置应用的主题化方式。

### 分发你的主题

如果你想分发你的主题以便他人使用，你需要把它放在一个公共的 git 服务器上，比如 GitHub。然后人们可以使用那个 URL，通过 Omarchy 菜单中的 _安装 > 样式 > 主题_ 安装它。建议你遵循 `omarchy-[themename]-theme` 的命名约定，因为安装后主题会在主题选择菜单中正确显示为只是 `[themename]`。

那余下的 `[themename]` 会成为主题的目录名，所以它必须是 Omarchy 可以安全传递的：它必须以字母、数字或下划线开头，其余部分可以包含字母、数字、`.`、`_`、`+` 和 `-`。大写字母会被转换为小写，但其他任何字符——空格、引号、非英文字符——都会在安装时被拒绝，而不是被变成目录名。所以 `omarchy-tokyo-night-theme`、`omarchy-flexoki_light-theme` 和 `omarchy-c++-theme` 都可以正常安装。

请记住，一旦从仓库安装，它所附带的任何 `.lua`、终端配置或 `vscode.json` 都会被丢弃，所以不要围绕这些来构建主题。

你可以通过向 [omarchy-site 仓库](https://github.com/omacom-io/omarchy-site) 发送一个合并请求，把你的主题添加到[额外主题页面](https://omarchy.org/themes/)。
