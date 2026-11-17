# 打造你自己的主题

你可以把自己的主题添加到 `~/.config/omarchy/themes`。直接复制一个现有主题作为基础（到 `/usr/share/omarchy/themes` 里找），然后随心所欲地调整。只要你的主题放在那个文件夹里，它就会出现在主题选择菜单中。

你主要需要调整的文件是 `colors.toml`。它定义了颜色集合，之后会用它为终端（Foot/Alacritty/Ghostty/Kitty）、btop、Chromium、Hyprland、Neovim、Helix、VSCode、Obsidian 以及整个 Omarchy shell（顶栏、菜单、通知、OSD 和锁屏）生成配置。

你也可以使用随附的 Aether 应用程序来创建新主题，它有非常好用的 GUI 界面，可以让你玩转颜色并搜索背景。只需在 `Super + Alt + Space` 打开的应用网格中启动它。

### 已安装的主题可以包含什么

你自己在 `~/.config/omarchy/themes` 中编写的主题可以包含任何你想要的内容——这是你的机器、你的文件，Omarchy 会应用全部内容。

你用 `omarchy theme install` 从别人的仓库安装的主题会保留所有与颜色有关的内容，并丢弃少数几个会在你机器上运行代码的文件：任何 `.lua` 文件、终端配置（`alacritty.toml`、`foot.ini`、`ghostty.conf`、`kitty.conf`）以及 `vscode.json`。主题的 `hyprland.lua` 是你的合成器在登录时运行的 Lua，终端配置指定了你的终端启动的程序，而 `vscode.json` 指定了要安装的 VSCode 扩展。安装别人的主题应该改变的是你桌面的外观，永远不该改变它运行什么。

其他所有内容仍然完全按照主题作者编写的方式工作——`btop.theme`、`chromium.theme`、`helix.toml`、`shell.toml`、背景和预览都会保留。只有被丢弃的内容才会在你的机器上从 `colors.toml` 重新生成。

Omarchy 通过主题内部是否有自己的 git 仓库来区分这两种情况，这正是 `omarchy theme install` 克隆时留下的。所以你自己写的主题仍然完全归你所有，而你从互联网上拉下来的主题只保留颜色。

### 浅色模式

如果你在制作浅色模式主题，在你的 `colors.toml` 顶部设置 `mode = "light"`。然后它就会自动为所有应用配对浅色模式。（以前那种在主题根目录里放一个名为 `light.mode` 的空文件的做法也仍然有效。）

### 解锁图片

随附 `unlock.png` 和 `preview-unlock.png` 图片的主题会列在 _外观 > 解锁_ 下。你的 `unlock.png` 最好是一个透明的 png。你可以使用 `omarchy plymouth preview` 创建预览图片。

### 为 Omarchy 未覆盖的应用设置主题

如果你使用的某个应用不在那个列表中，你可以用模板自己教会 Omarchy 为它设置主题。在 `~/.config/omarchy/themed/` 中放一个文件，文件名以它生成的配置命名并加上 `.tpl` 扩展名，然后用 `{{ background }}`、`{{ foreground }}`、`{{ accent }}`、`{{ red }}`、`{{ color0 }}` 到 `{{ color15 }}` 以及调色板其余部分作为占位符来编写配置。每次你切换主题时，该文件都会用该主题的颜色重新生成。

那个文件夹里有一个带完整注释的 `alacritty.toml.tpl.sample` 可供你复制——它列出了你能使用的每一个变量，还有 `_strip` 和 `_rgb` 修饰符，供那些希望颜色不带 `#` 或以十进制 RGB 表示的应用使用。你的模板优先于 Omarchy 自带的模板，所以你也可以用它来覆盖内置应用的主题设置方式。

### 分发你的主题

如果你想分发你的主题让其他人使用，你需要把它放在一个公开的 git 服务器上，比如 GitHub。然后人们可以在 Omarchy 菜单中使用该 URL，通过 _安装 > 样式 > 主题_ 来安装它。建议你遵循 `omarchy-[themename]-theme` 的命名约定，因为安装后主题会在主题选择菜单中正确地只显示为 `[themename]`。

剩下的 `[themename]` 会成为主题的目录名，因此它必须是一个 Omarchy 可以安全传递的名称：它必须以字母、数字或下划线开头，其余部分可以包含字母、数字、`.`、`_`、`+` 和 `-`。大写字母会为你自动转换为小写，但其他任何字符——空格、引号、非英文字符——都会在安装时被拒绝，而不会被转换成目录名。所以 `omarchy-tokyo-night-theme`、`omarchy-flexoki_light-theme` 和 `omarchy-c++-theme` 都能正常安装。

请记住，一旦它从仓库安装，它随附的任何 `.lua`、终端配置或 `vscode.json` 都会被丢弃，所以不要围绕这些来构建主题。

你可以向 [omarchy-site 仓库](https://github.com/omacom-io/omarchy-site) 发送一个 pull request，将你的主题添加到 [额外主题页面](https://omarchy.org/themes/)。
