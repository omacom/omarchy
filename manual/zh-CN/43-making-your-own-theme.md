# 打造你自己的主题

你可以把自己的主题添加到 `~/.config/omarchy/themes`。直接复制一个现有的主题作为基础（去 `/usr/share/omarchy/themes` 里看），然后随心所欲地调整。只要你的主题放在那个文件夹里，它就会出现在主题选择菜单中。

你需要调整的主要文件是 `colors.toml`。它定义了配色方案，随后会被用来生成终端（Foot/Alacritty/Ghostty/Kitty）、btop、Chromium、Hyprland、Neovim、Helix、VSCode、Obsidian、Qt 应用、键盘背光、输入法、屏幕共享选择器、应用图标、几款 AI 工具（Claude、Pi、Hermes、T3 Code、Herdr）以及整个 Omarchy shell（顶栏、菜单、通知、OSD 和锁屏）的配置。

你也可以使用自带的 Aether 应用来创建新主题，它有可爱的 GUI 界面，可以让你玩转颜色并搜索背景。只需在应用网格里用 `Super + Alt + Space` 启动它。

### 已安装的主题可以包含什么

你在 `~/.config/omarchy/themes` 里自己写的主题可以包含任何你喜欢的内容——这是你的机器、你的文件，Omarchy 会全部应用。

你用 `omarchy theme install` 从别人的仓库安装的主题会保留所有与颜色有关的内容，但会丢掉那少数几个会在你机器上运行代码的文件：任何 `.lua` 文件、终端配置（`alacritty.toml`、`foot.ini`、`ghostty.conf`、`kitty.conf`）以及 `vscode.json`。主题的 `hyprland.lua` 是合成器在登录时运行的 Lua 代码，终端配置会指定你的终端要启动的程序，而 `vscode.json` 会指定要安装的 VSCode 扩展。安装别人的主题应该改变你的桌面外观，绝不应该改变它运行什么。

其他一切仍然会完全按照主题作者所写的那样工作——`btop.theme`、`chromium.theme`、`helix.toml`、`shell.toml`、背景和预览都会被保留。只有被丢掉的内容会在你的机器上根据 `colors.toml` 重新生成。

Omarchy 通过主题内部是否带有自己的 git 仓库来区分这两种情况，而这正是 `omarchy theme install` 克隆时留下的痕迹。所以你自己写的主题依然由你掌控，而你从互联网上拉下来的主题就只管颜色。

### 浅色模式

如果你在制作浅色模式主题，请在 `colors.toml` 顶部设置 `mode = "light"`。然后它会自动与所有应用的浅色模式配对。（旧的做法是在主题根目录里放一个名为 `light.mode` 的空文件，这种方式仍然有效。）

### 解锁图片

带有 `unlock.png` 和 `preview-unlock.png` 图片的主题会列在_外观 > 解锁_下。你的 `unlock.png` 最好是一个透明 png。你可以使用 `omarchy plymouth preview` 来创建预览图片。

### 为 Omarchy 未覆盖的应用设置主题

如果你使用的某个应用不在那个列表里，你可以自己用模板教 Omarchy 为它设置主题。在 `~/.config/omarchy/themed/` 里放一个文件，文件名以它生成的配置文件命名，再加上 `.tpl` 扩展名，并在配置中用 `{{ background }}`、`{{ foreground }}`、`{{ accent }}`、`{{ red }}`、`{{ color0 }}` 到 `{{ color15 }}` 以及调色板中的其他颜色作为占位符。每当你切换主题时，该文件都会用该主题的颜色重新生成。

那个文件夹里有一个带完整注释的 `alacritty.toml.tpl.sample` 可以复制——它列出了所有可用的变量，还有 `_strip` 和 `_rgb` 修饰符，供那些想要不带 `#` 的颜色或十进制 RGB 颜色的应用使用。你的模板优先级高于 Omarchy 自带的模板，所以你也可以用它来覆盖内置应用的主题设置方式。

### 发布你的主题

如果你想发布你的主题让其他人使用，你需要把它放到一个公共 git 服务器上，比如 GitHub。然后人们可以在 Omarchy 菜单里使用_安装 > 样式 > 主题_，通过那个 URL 来安装它。建议你遵循 `omarchy-[themename]-theme` 的命名惯例，这样安装后主题在主题选择菜单里会正确地只显示为 `[themename]`。

剩下的那个 `[themename]` 会成为主题的目录名，所以它必须是一个 Omarchy 可以安全传递的名称：它必须以字母、数字或下划线开头，其余部分可以包含字母、数字、`.`、`_`、`+` 和 `-`。大写字母会为你转换成小写，但其他任何字符——空格、引号、非英文字符——都会在安装时被拒绝，而不是被变成目录名。所以 `omarchy-tokyo-night-theme`、`omarchy-flexoki_light-theme` 和 `omarchy-c++-theme` 都可以正常安装。

请记住，一旦主题从仓库安装，它附带的任何 `.lua`、终端配置或 `vscode.json` 都会被丢掉，所以不要围绕这些文件来构建主题。

你可以通过向 [omarchy-site 仓库](https://github.com/omacom-io/omarchy-site) 发送 pull request，把你的主题添加到[额外主题页面](https://omarchy.org/themes/)。
