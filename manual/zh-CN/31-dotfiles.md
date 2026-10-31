# Dotfiles

Omarchy 主要通过位于 `~/.config` 中的所谓 dotfiles 进行配置。那些文件是属于你的，供你更改。位于 `/usr/share/omarchy` 中的文件属于 Omarchy 本身，你不应该去动它们。如果你需要更改 `/usr/share/omarchy` 中的任何内容，你应该改为在 `~/.config` 中覆盖对应的值。

关键配置可以直接从 Omarchy 菜单（`Super + Space`）中编辑，例如 _Setup > Keybindings_、_Setup > Input_ 和 _Setup > Config > [file]_。通过这种方式编辑时，任何需要在修改配置后重启的进程，都会在你退出编辑器后自动重启（默认是 Neovim——记住 `:wq`！——但你可以通过 _Setup > Defaults > Editor_ 更改它）。

以下是 `~/.config` 中的关键文件及其控制内容的列表：

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprland 主配置文件。加载 Omarchy 默认设置以及下面的你的覆盖文件。[了解有关 Hyprland 配置的更多信息](https://wiki.hypr.land/Configuring/)。  |
| `~/.config/hypr/bindings.lua` | 你自己的键绑定，以及对默认键绑定的覆盖。 |
| `~/.config/hypr/monitors.lua` | 显示器面板未涵盖的显示器设置，例如旋转、额外模式，或让某台显示器保持关闭。 |
| `~/.config/hypr/input.lua` | 控制你的键盘布局、鼠标和触控板设置。 |
| `~/.config/hypr/looknfeel.lua` | 控制间距、边框、动画和其余外观设置。 |
| `~/.config/hypr/autostart.lua` | 控制随会话启动的额外进程。 |
| `~/.config/omarchy/shell.json` | 控制 Omarchy shell：栏的位置、布局和小部件，以及屏幕保护程序、锁定和闲置计时。 |
| `~/.config/foot/foot.ini` | 控制你的终端（foot 是默认终端）。 |
| `~/.XCompose` | 定义你的快速访问 emoji 和姓名/邮箱自动补全。更改后务必运行 `omarchy-restart-xcompose`。 |

如果你最终做了很多更改来调整自己的设置，最好备份所有这些 dotfiles。[Stow 是完成这件事的好方法](https://www.youtube.com/watch?v=NoFiYOqnC4o)。

### 让自己的应用随会话启动

如果你想让某些东西在每次登录时运行——同步守护进程、聊天应用、你自己的脚本——把它放进 `~/.config/hypr/autostart.lua`：

```lua
o.launch_on_start("my-service")
```

这会把该命令作为会话的一部分启动，所以当你再次注销时，它会被妥善清理。

### 在系统事件时运行脚本

Omarchy 会在几个时刻触发钩子，你可以把自己的脚本挂到它们上面。它们位于 `~/.config/omarchy/hooks/<event>.d/`，每个事件一个目录，事件发生时其中每个可执行文件都会运行：

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | 桌面刚启动之后 |
| `post-update` | 在 `omarchy update` 接近结束时，在软件包、迁移和服务重启之后，在 mise 工具更新之前 |
| `pre-refresh-pacman` | 在 `omarchy refresh pacman` 重新同步软件包配置之后，在它更新软件包之前；切换频道会在同一次刷新步骤中运行它 |
| `theme-set` | 主题更改后（主题名称位于 `$1`） |
| `font-set` | 字体更改后（字体名称位于 `$1`） |
| `battery-low` | 电池电量低时（百分比位于 `$1`） |

`pre-refresh-pacman` 钩子是放置自定义仓库或 `IgnorePkg` 行的地方，因为它在软件包事务之前运行。两个与更新相关的钩子都会在 Omarchy 清除其缓存的 sudo 授权后以你的用户身份运行，因此使用 `sudo` 的钩子需要自己的授权，可能会要求你输入密码。

每个目录中都已有一个 `.sample` 文件，展示钩子的形式——去掉名称中的 `.sample` 就能让它生效。要安装你在别处编写的脚本，请使用 `omarchy hook install post-boot ~/my-hook`，它会把脚本复制进去并使其可执行。

### 添加你自己的菜单条目

Omarchy 菜单（`Super + Space`）可以通过编辑 `~/.config/omarchy/extensions/omarchy-menu.jsonc` 来扩展，加入你自己的行。条目以点分 id 为键，而 id 决定它们在树中的位置，所以 `personal` 会显示在根菜单上，而 `personal.notes` 会显示在它里面：

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

复用现有 id，你就会覆盖那一行，而不是添加新的一行。该文件附带了所有可用字段，并以注释形式记录了它们。

### 添加你自己的 shell 导出变量、函数和别名

Omarchy 自带了一堆符合人体工学的别名和实用的函数，但想添加自己的也很常见。你应该把别名、函数和导出变量都添加到 `~/.bashrc` 中。这个文件在更新时不会被覆盖。如果你想更改任何 Omarchy 默认设置，也可以安全地在这里添加。

### 更改 Omarchy 内部文件

听着，这是你的电脑。你想怎么做都行，但我建议不要直接更改 `/usr/share/omarchy` 中的文件。它们属于 Omarchy pacman 软件包，所以你的更改只会在下一次更新时被覆盖。你最好改为直接在 `~/.config/*` 文件夹中覆盖任何你不喜欢的默认值。

你几乎可以用这种方式更改一切，例如默认键绑定。只需编辑 `~/.config/hypr/bindings.lua`，比如把 [Obsidian](https://obsidian.md/) 换成 [Joplin](https://joplinapp.org/)（使用 `omarchy-pkg-add joplin-bin` 安装）：

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` 会在添加替代绑定之前移除现有绑定。它接受与 `o.bind` 相同的参数，包括启动辅助函数和绑定选项。使用 `o.bind` 添加绑定，或使用 `hl.unbind` 移除绑定而不替换它。

如果你坚持要折腾 Omarchy 内部文件，请通过 _Update > Channel > Dev_ 切换到 dev 频道。这会把 Omarchy 链接到位于 `~/omarchy` 的源代码 git 检出，你可以随心所欲地更改。这里没人会对你指手画脚！

### 重置任何更改

如果你最终把配置搞得一团糟，你随时可以通过 Omarchy 菜单中的 _Update > Config_ 把它们恢复为默认设置。或者运行 `omarchy reinstall configs` 来重置一切。
