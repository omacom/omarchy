# Dotfiles

Omarchy 主要通过位于 `~/.config` 中的所谓 dotfiles 进行配置。这些文件被视为你的文件，供你修改。位于 `/usr/share/omarchy` 中的文件属于 Omarchy 本身，你不应该去动它们。如果你需要更改 `/usr/share/omarchy` 中的任何内容，你应该改为在 `~/.config` 中覆盖该值。

关键配置可以直接从 Omarchy 菜单（`Super + Space`）中编辑，例如 _设置 > 键盘绑定_、_设置 > 输入_ 和 _设置 > 配置 > [文件]_。通过这种方式编辑时，任何需要在配置编辑后重启的进程，都会在你退出编辑器后自动重启（默认是 Neovim——记得 `:wq`！——但你可以通过 _设置 > 默认项 > 编辑器_ 更改它）。

以下是 `~/.config` 中的关键文件及其控制内容的列表：

| 文件 | 用途 |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprland 主配置文件。加载 Omarchy 默认设置以及你下面的覆盖文件。[进一步了解 Hyprland 配置](https://wiki.hypr.land/Configuring/)。 |
| `~/.config/hypr/bindings.lua` | 你自己的键盘绑定以及对默认值的覆盖。 |
| `~/.config/hypr/monitors.lua` | 显示器面板未涵盖的显示器设置，例如旋转、额外模式，或者让某台显示器保持关闭。 |
| `~/.config/hypr/input.lua` | 控制你的键盘布局、鼠标和触控板设置。 |
| `~/.config/hypr/looknfeel.lua` | 控制间距、边框、动画以及其余的外观设置。 |
| `~/.config/hypr/autostart.lua` | 控制随会话启动的额外进程。 |
| `~/.config/omarchy/shell.json` | 控制 Omarchy shell：栏的位置、布局和小部件，以及屏幕保护程序、锁定和闲置计时。 |
| `~/.config/foot/foot.ini` | 控制你的终端（默认是 foot）。 |
| `~/.XCompose` | 定义你的快捷表情符号以及姓名/邮箱自动补全。更改后务必运行 `omarchy-restart-xcompose`。 |

如果你最终做了很多更改来调整你自己的设置，最好备份所有这些 dotfiles。[Stow 是实现这一点的绝佳方式](https://www.youtube.com/watch?v=NoFiYOqnC4o)。

### 随会话启动你自己的应用

如果你希望某个东西在每次登录时都运行——同步守护进程、聊天应用、你自己的脚本——把它放进 `~/.config/hypr/autostart.lua`：

```lua
o.launch_on_start("my-service")
```

这会把该命令作为会话的一部分启动，因此当你再次注销时，它会被妥善清理。

### 在系统事件时运行脚本

Omarchy 会在少数几个时刻触发钩子，你可以把你自己的脚本挂到它们上面。它们位于 `~/.config/omarchy/hooks/<event>.d/`，每个事件一个目录，其中每个可执行文件都会在该事件发生时运行：

| 事件 | 运行时机 |
| ----- | ------------ |
| `post-boot` | 桌面启动后立即运行 |
| `post-update` | 在 `omarchy update` 接近结束时，在软件包、迁移和服务重启之后，在 mise 工具更新之前 |
| `pre-refresh-pacman` | 在 `omarchy refresh pacman` 重新同步软件包配置之后，在它更新软件包之前；切换频道会在同一次刷新步骤中运行它 |
| `theme-set` | 主题更改后（主题名称在 `$1` 中） |
| `font-set` | 字体更改后（字体名称在 `$1` 中） |
| `battery-low` | 电池电量低时（百分比在 `$1` 中） |

`pre-refresh-pacman` 钩子是放置自定义软件仓库或 `IgnorePkg` 行的地方，因为它在软件包事务之前运行。两个与更新相关的钩子都会在 Omarchy 清除其缓存的 sudo 授权后以你的用户身份运行，因此使用 `sudo` 的钩子需要自己的授权，并可能要求你输入密码。

这些目录中的每一个都已包含一个 `.sample` 文件，展示了钩子的结构——去掉名称中的 `.sample` 就能让它发挥作用。要安装你在别处编写的脚本，请使用 `omarchy hook install post-boot ~/my-hook`，它会把脚本复制进去并使其可执行。

### 添加你自己的菜单项

可以通过编辑 `~/.config/omarchy/extensions/omarchy-menu.jsonc`，为 Omarchy 菜单（`Super + Space`）扩展你自己的行。条目以带点的 id 为键，而 id 决定了它们在树中的位置，因此 `personal` 会显示在根菜单上，而 `personal.notes` 会显示在它内部：

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

重用已有的 id，你就会覆盖该行，而不是添加新行。该文件附带了以注释形式记录的所有可用字段。

### 添加你自己的 shell 导出、函数和别名

Omarchy 附带了一堆顺手的别名和有用的函数，但想要添加你自己的也很常见。你应该把别名、函数和导出都添加到 `~/.bashrc` 中。此文件在更新时不会被覆盖。如果你想更改任何 Omarchy 默认设置，你也可以安全地在这里添加。

### 为桌面设置环境变量

桌面会话的导出应放在 `~/.config/uwsm/env.d/` 中。这些文件在你的桌面启动之前运行，因此 shell 错误可能会把你送回登录屏幕。编辑它们时，请保持一个可用的终端打开。要禁用某个覆盖，请把它移出 `env.d`。如果某项更改导致无法登录，请参阅[登录恢复](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen)。

### 更改 Omarchy 内部文件

听着，这是你的电脑。你可以对它做任何你想做的事，但我建议不要直接更改 `/usr/share/omarchy` 中的文件。它们属于 Omarchy pacman 软件包，因此你的更改只会在下一次更新时被覆盖。你最好改为在 `~/.config/*` 文件夹中覆盖任何你不喜欢的默认值。

你几乎可以通过这种方式更改一切，例如默认键盘绑定。只需编辑 `~/.config/hypr/bindings.lua`，比如把 [Obsidian](https://obsidian.md/) 换成 [Joplin](https://joplinapp.org/)（使用 `omarchy-pkg-add joplin-bin` 安装）：

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` 会先移除已有的绑定，然后再添加其替代绑定。它接受与 `o.bind` 相同的参数，包括启动辅助函数和绑定选项。使用 `o.bind` 添加绑定，或者使用 `hl.unbind` 移除某个绑定而不替换它。

如果你坚持要折腾 Omarchy 内部文件，请通过 _更新 > 频道 > Dev_ 切换到 dev 频道。这会把 Omarchy 链接到位于 `~/omarchy` 的源代码 git 检出，你可以随心所欲地更改它。这里没人会告诉你该做什么！

### 重置任何更改

如果你最终把配置弄得一团糟，你随时可以通过 Omarchy 菜单中的 _更新 > 配置_ 将它们还原为默认设置。或者运行 `omarchy reinstall configs` 来重置一切。
