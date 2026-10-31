# Dotfiles

Omarchy 主要通过位于 `~/.config` 中的所谓 dotfiles 进行配置。这些被视为你自己的文件，供你更改。位于 `/usr/share/omarchy` 中的文件属于 Omarchy 本身，你不应该动那些。如果你需要更改 `/usr/share/omarchy` 中的任何内容，你应该改为在 `~/.config` 中覆盖该值。

关键配置可以直接从 Omarchy 菜单（`Super + Space`）编辑，如 _Setup > Monitors_、_Setup > Keybindings_、_Setup > Input_ 和 _Setup > Config > [file]_。当你以这种方式操作时，任何需要在配置编辑后重启的进程都会在你退出编辑器后自动重启（默认 Neovim——记住 `:wq`！——但你可以通过 _Setup > Defaults > Editor_ 更改）。

以下是 `~/.config` 中的关键文件及其控制内容的列表：

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | 主要的 Hyprland 配置。加载 Omarchy 默认值以及你下面的覆盖文件。[了解更多关于 Hyprland 配置的信息](https://wiki.hypr.land/Configuring/)。  |
| `~/.config/hypr/bindings.lua` | 你自己的快捷键和对默认设置的覆盖。 |
| `~/.config/hypr/monitors.lua` | 控制你的显示器、分辨率和位置。 |
| `~/.config/hypr/input.lua` | 控制你的键盘布局、鼠标和触控板设置。 |
| `~/.config/hypr/looknfeel.lua` | 控制间距、边框、动画和外观的其余部分。 |
| `~/.config/hypr/autostart.lua` | 控制随会话启动的额外进程。 |
| `~/.config/omarchy/shell.json` | 控制 Omarchy shell：栏位置、布局和小部件，加上屏保、锁定和空闲计时。 |
| `~/.config/foot/foot.ini` | 控制你的终端（foot 是默认终端）。 |
| `~/.XCompose` | 定义你的快速访问表情符号和姓名/邮箱自动完成。更改后务必运行 `omarchy-restart-xcompose`。 |

如果你最终对自己的设置做了很多微调，备份所有这些 dotfiles 是个好主意。[Stow 是一个很好的方法](https://www.youtube.com/watch?v=NoFiYOqnC4o)。

### 随会话启动你自己的应用

如果你想让某些东西在每次登录时运行——一个同步守护进程、一个聊天应用、你自己的脚本——将其放入 `~/.config/hypr/autostart.lua`：

```lua
o.launch_on_start("my-service")
```

这会将该命令作为会话的一部分启动，所以当你再次注销时，它会被妥善清理。

### 在系统事件上运行脚本

Omarchy 在几个时刻触发钩子，你可以将自己的脚本挂在它们上面。它们位于 `~/.config/omarchy/hooks/<event>.d/`，每个事件一个目录，事件发生时其中的每个可执行文件都会运行：

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | 就在桌面启动之后 |
| `post-update` | 在 `omarchy update` 快结束时，在软件包、迁移和服务重启之后，在 mise 工具更新之前 |
| `pre-refresh-pacman` | 在 `omarchy refresh pacman` 重新同步软件包配置之后，在它更新软件包之前；切换通道会在同一次刷新步骤中运行它 |
| `theme-set` | 在主题更改之后（主题名在 `$1` 中） |
| `font-set` | 在字体更改之后（字体名在 `$1` 中） |
| `battery-low` | 当电池电量低时（百分比在 `$1` 中） |

`pre-refresh-pacman` 钩子是自定义仓库或 `IgnorePkg` 行应该放的地方，因为它在软件包事务之前运行。这两个与更新相关的钩子都在 Omarchy 清除其缓存的 sudo 授权之后以你的用户身份运行，所以使用 `sudo` 的钩子需要自己的授权，可能会要求你输入密码。

这些目录中的每个都已包含一个 `.sample` 文件，展示了一个钩子的样子——从名称中去掉 `.sample` 就能让它工作。要安装你在别处写好的脚本，使用 `omarchy hook install post-boot ~/my-hook`，它会将其复制进去并使其可执行。

### 添加你自己的菜单条目

Omarchy 菜单（`Super + Space`）可以通过编辑 `~/.config/omarchy/extensions/omarchy-menu.jsonc` 来扩展，加入你自己的行。条目以点分隔的 id 为键，而正是这个 id 将它们放置在树中，所以 `personal` 显示在根菜单上，`personal.notes` 显示在它内部：

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

复用已有的 id，你就会覆盖那一行，而不是添加新的一行。该文件附带了以注释形式记录的所有可用字段。

### 添加你自己的 shell 导出、函数和别名

Omarchy 附带了一大堆人体工程学的别名和有用的函数，但想要添加你自己的非常常见。你应该将别名、函数和导出都添加到 `~/.bashrc`。此文件在更新时不会被覆盖。如果你想更改任何 Omarchy 默认值，你也可以安全地在这里添加。

### 更改内部 Omarchy 文件

听着，这是你的电脑。你可以随心所欲地使用它，但我建议不要直接更改 `/usr/share/omarchy` 中的文件。它们属于 Omarchy pacman 软件包，所以你的更改只会在下一次更新时被覆盖。你最好只在 `~/.config/*` 文件夹中覆盖任何你不喜欢的默认值。

你可以通过这种方式更改几乎一切，比如默认快捷键。只需编辑 `~/.config/hypr/bindings.lua`，例如将 [Obsidian](https://obsidian.md/) 替换为 [Joplin](https://joplinapp.org/)（用 `omarchy-pkg-add joplin-bin` 安装）：

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` 在添加其替代项之前删除现有的绑定。它接受与 `o.bind` 相同的参数，包括启动辅助函数和绑定选项。使用 `o.bind` 添加绑定，或使用 `hl.unbind` 删除绑定而不替换它。

如果你坚持要改内部 Omarchy 文件，通过 _Update > Channel > Dev_ 切换到 dev 通道。这将 Omarchy 链接到 `~/omarchy` 中源代码的 git 检出，你可以随心所欲地更改。这里没人会告诉你该做什么！

### 重置任何更改

如果你最终把配置弄得一团糟，你随时可以通过 Omarchy 菜单中的 _Update > Config_ 将它们还原为默认值。或者运行 `omarchy reinstall configs` 来重置一切。
