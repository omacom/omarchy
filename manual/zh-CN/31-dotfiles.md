# Dotfiles

Omarchy 主要通过位于 `~/.config` 中的所谓 dotfiles 进行配置。那些文件被视为你的文件，供你进行更改。位于 `/usr/share/omarchy` 中的文件属于 Omarchy 本身，你不应该去动那些文件。如果你需要更改 `/usr/share/omarchy` 中的任何内容，你应该改为在 `~/.config` 中覆盖该值。

关键配置可以直接从 Omarchy 菜单（`Super + Space`）中编辑，例如 _Setup > Keyboard > Keybindings_、_Setup > Input_ 和 _Setup > Config > [file]_。当你以这种方式操作时，任何需要在配置编辑后重启的进程，都会在你退出编辑器后自动重启（默认是 Neovim——记住 `:wq`！——但你可以通过 _Setup > Defaults > Editor_ 更改这一点）。

以下是 `~/.config` 中的关键文件列表，以及它们各自控制的内容：

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | 主 Hyprland 配置。加载 Omarchy 默认设置以及你下面的覆盖文件。[了解有关 Hyprland 配置的更多信息](https://wiki.hypr.land/Configuring/)。  |
| `~/.config/hypr/bindings.lua` | 你自己的快捷键以及对默认值的覆盖。 |
| `~/.config/hypr/monitors.lua` | 显示器面板未涵盖的显示器设置，例如旋转、额外模式或保持显示器关闭。 |
| `~/.config/hypr/input.lua` | 控制你的键盘布局、鼠标和触控板设置。 |
| `~/.config/hypr/looknfeel.lua` | 控制间距、边框、动画和其余外观。 |
| `~/.config/hypr/autostart.lua` | 控制随会话一起启动的额外进程。 |
| `~/.config/omarchy/shell.json` | 控制 Omarchy shell：栏位置、布局和小部件，以及屏保、锁屏和空闲计时。 |
| `~/.config/foot/foot.ini` | 控制你的终端（foot 是默认终端）。 |
| `~/.XCompose` | 定义你的快速访问 emoji 和姓名/电子邮件自动补全。确保在进行更改后运行 `omarchy-restart-xcompose`。 |

如果你最终进行了大量更改来调整你自己的设置，最好备份所有这些 dotfiles。[Stow 是实现这一点的绝佳方法](https://www.youtube.com/watch?v=NoFiYOqnC4o)。

### 随会话启动你自己的应用

如果你希望某样东西在每次登录时运行——同步守护进程、聊天应用、你自己的脚本——将其放入 `~/.config/hypr/autostart.lua`：

```lua
o.launch_on_start("my-service")
```

这会将该命令作为会话的一部分启动，因此当你再次注销时，它会被妥善清理。

### 在系统事件上运行脚本

Omarchy 会在少数几个时刻触发钩子，你可以将自己的脚本挂载到它们上面。它们位于 `~/.config/omarchy/hooks/<event>.d/`，每个事件对应一个目录，当事件发生时，其中每个可执行文件都会运行：

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | 桌面刚启动之后 |
| `post-update` | 在 `omarchy update` 快结束时，软件包、迁移和服务重启之后，mise 工具更新之前 |
| `pre-refresh-pacman` | 在 `omarchy refresh pacman` 重新同步软件包配置之后、更新软件包之前；渠道切换会在同一次刷新步骤中运行它 |
| `theme-set` | 主题更改之后（主题名称位于 `$1` 中） |
| `font-set` | 字体更改之后（字体名称位于 `$1` 中） |
| `battery-low` | 电池电量低时（百分比位于 `$1` 中） |

`pre-refresh-pacman` 钩子是自定义仓库或 `IgnorePkg` 行应该放的地方，因为它在软件包事务之前运行。两个与更新相关的钩子都会在 Omarchy 清除其缓存的 sudo 授权之后以你的用户身份运行，因此使用 `sudo` 的钩子需要其自己的授权，并可能会要求你输入密码。

这些目录中的每一个都已经包含一个 `.sample` 文件，用来展示钩子的形式——去掉名称中的 `.sample` 即可让它开始工作。要安装你在其他地方编写的脚本，请使用 `omarchy hook install post-boot ~/my-hook`，它会将其复制进来并使其可执行。

### 添加你自己的菜单条目

Omarchy 菜单（`Super + Space`）可以通过编辑 `~/.config/omarchy/extensions/omarchy-menu.jsonc` 并添加你自己的行来扩展。条目以带点号的 id 为键，而这个 id 决定了它们在树中的位置，因此 `personal` 会出现在根菜单上，而 `personal.notes` 会出现在它内部：

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

复用现有的 id，你会覆盖该行，而不是添加新行。该文件附带了所有可用字段，并以注释形式记录了这些字段。

### 添加你自己的 shell 导出、函数和别名

Omarchy 附带了一大堆顺手的别名和有用的函数，但想要添加你自己的也很常见。你应该将别名、函数和导出都添加到 `~/.bashrc` 中。此文件在更新时不会被覆盖。如果你想更改任何 Omarchy 默认值，你也可以安全地在这里添加它们。

### 为桌面设置环境变量

桌面会话的导出属于 `~/.config/uwsm/env.d/`。这些文件在你的桌面启动之前运行，因此 shell 错误可能会将你送回登录屏幕。编辑它们时，请保持一个可用的终端打开。要禁用某个覆盖，请将其移出 `env.d`。如果某项更改导致无法登录，请参阅[登录恢复](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen)。

### 更改 Omarchy 内部文件

听着，这是你的电脑。你想对它做什么都可以，但我建议不要直接更改 `/usr/share/omarchy` 中的文件。它们属于 Omarchy pacman 软件包，因此你的更改只会在下次更新时被覆盖。你最好改为在 `~/.config/*` 文件夹中覆盖任何你不喜欢的默认值。

你可以用这种方式更改几乎所有内容，例如默认快捷键。只需编辑 `~/.config/hypr/bindings.lua`，比如将 [Obsidian](https://obsidian.md/) 替换为 [Joplin](https://joplinapp.org/)（使用 `omarchy-pkg-add joplin-bin` 安装）：

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` 会在添加其替换项之前移除现有的绑定。它接受与 `o.bind` 相同的参数，包括启动辅助函数和绑定选项。使用 `o.bind` 添加绑定，或使用 `hl.unbind` 移除某个绑定而不替换它。

如果你坚持要折腾 Omarchy 内部文件，请通过 _Update > Channel > Dev_ 切换到 dev 渠道。这会将 Omarchy 链接到位于 `~/omarchy` 的源代码 git 检出，你可以随心所欲地更改它。没人会在这里告诉你该怎么做！

### 重置任何更改

如果你最终把配置搞得一团糟，你随时可以通过 Omarchy 菜单中的 _Update > Config_ 将它们还原为默认值。或者运行 `omarchy reinstall configs` 来重置所有内容。
