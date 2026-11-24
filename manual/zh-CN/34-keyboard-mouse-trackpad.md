# 键盘、鼠标、触控板

Hyprland 让你可以非常细致地配置所有输入设备。你可以把键盘重复速度调得快如超音速，也可以让触控板使用自然滚动。所有这些都在 `~/.config/hypr/input.lua` 中修改，你也可以通过 Omarchy 菜单（`Super + Space`）中的 _Setup > Input_ 进入。你在那里设置的任何内容都会取代 Omarchy 的默认设置。

下面是一个示例：

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

你可以在 Hyprland wiki 上[查看所有输入选项](https://wiki.hypr.land/Configuring/Basics/Variables/#input)。

CapsLock 的作用就是普通的 Caps Lock，而 `Shift + CapsLock` 是组合键，用于[快速输入表情符号](07-hotkeys.md#quick-emojis)和[其他补全](07-hotkeys.md#quick-completions)。如果你想把组合键放在别处，请替换 `kb_options` 中的 `omarchy:shift_caps_compose`。例如，下面这样可以把组合键移到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 功能键

笔记本键盘的顶排默认发送的是媒体键（音量、亮度等），按住 `Fn` 则可以输入 F1-F12；`Fn + Esc` 会将其锁定为相反的方式，直到你再次按下它。大多数键盘自身会记住该锁定状态。ASUS 笔记本和 Apple 风格的键盘则把这件事交给 Linux 处理，它们在每次开机时都会从媒体键开始。要让它们改为从 F1-F12 开始，请运行 `omarchy device keyboard toprow fnkeys`（运行 `omarchy device keyboard toprow mediakeys` 则可恢复）；在某些笔记本上，这会在重启后生效。Apple Silicon Mac 保留它们自己的设置。

### 触控板手势

在触控板上滑动即可在桌面中移动：

| 手势 | 操作 |
| --- | --- |
| 三指左滑 / 右滑 | 上一个 / 下一个工作区，包括空工作区 |
| 三指上滑 | 切换 AI 控制台 |
| 三指下滑 | 打开 Omarchy 菜单 |
| 四指左滑 / 右滑 | 将当前窗口移动到上一个 / 下一个工作区 |
| 四指下滑 | 切换全屏 |

要修改其中一个，请先在 `~/.config/hypr/input.lua` 中取消设置它，然后再添加你自己的[触控板手势](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，因为 Hyprland 不接受在相同手指数和相同方向上设置两个手势：

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

要关闭 Omarchy 的所有手势，请在 `~/.config/hypr/hyprland.lua` 的顶部附近、Omarchy 的默认设置加载之前，设置 `omarchy_default_gestures = false`。

在配备触觉触控板的 Dell XPS 笔记本上，你还可以在 _Trigger > Hardware > Touchpad Haptics_ 中将点按力度设置为低、中或高。

### 输入中文、日文和其他语言

当安装程序询问你的键盘时，请选择 Japanese、Korean、Chinese (Simplified, Pinyin)、Taiwan (Zhuyin) 或 Hong Kong (Cangjie)。Omarchy 会自动配置键盘和匹配的输入引擎，包括在离线首次启动设置期间也是如此。Japanese 使用 Mozc，Korean 使用标准的两套式 Hangul，Simplified Chinese 使用 Pinyin，Taiwan 使用 Chewing 的标准 Zhuyin 排列，Hong Kong 使用采用香港字形的 Cangjie。Japanese (US keyboard) 提供搭配美国键盘布局的 Mozc。即使你使用 Dvorak、Colemak 或 AZERTY 输入拉丁字母，Hangul、Zhuyin 和 Cangjie 的按键也会保持在标准位置。如果你之前添加过 Hangul 或 Chewing，请在 _Setup > Keyboard > Input Methods_ 中取消选择再重新选择它，以便将其按键移到那里；对于你已经在使用的输入引擎，Omarchy 不会去动它。

输入时默认从拉丁模式开始。按 `Super + I` 可以循环切换已配置的输入法，按 `Super + Shift + I` 可以反向循环。单独轻点 `Shift` 可以从 Pinyin 等输入法中脱离出来输入拉丁字母，再轻点一次即可返回，这与 Sogou、Microsoft Pinyin 和 macOS 的工作方式相同；`Shift` 加字母仍然会输入大写字母。在日文键盘上，全角/半角 切换输入，変換 开启输入，無変換 关闭输入。对于 Korean，한/영 切换 Hangul，한자 转换为 Hanja，无论你的键盘有专用键，还是像许多笔记本那样为它们发送 Right Alt 和 Right Ctrl，所以在那里 Right Alt 和 Right Ctrl 不是普通的修饰键；听写则改用 Alt + Space 切换。`Ctrl + Space` 仍然可供 Tmux 和 Herdr 使用；`Shift + CapsLock` 仍然是组合键。

当你有多个键盘布局或输入法时，键盘指示器会出现在状态栏右侧。点击它可以切换输入语言；Japanese 会显示 あ 来表示平假名。如需选择日文字符，请切换到 Japanese，输入例如 `nihongo` 这样的词，然后按两次 Space。按 Enter 确认你的选择。如果你同时有多个键盘布局，请右键点击该指示器来循环切换它们。

使用 _Setup > Keyboard > Keyboard Inputs_ 选择 English 和 French 等布局，其选项与安装期间提供的相同。使用 _Setup > Keyboard > Input Methods_ 选择要启用哪些组字引擎。这两个选择器都会在 Omarchy 菜单内打开，并勾选你当前的选择。点击或按 Enter 可以切换一个选项；每次更改都会立即生效。取消选择某个输入法会将其从循环中移除，但不会卸载它；键盘仍然可用。

运行 `omarchy setup keyboard` 或 `omarchy setup input` 可以打开相同的选择器。要从命令行追加一种语言，请使用 `omarchy setup input mozc`、`hangul`、`pinyin`、`chewing` 或 `cangjie5`。Quick、Boshiamy 和 Array 与 Cangjie 在同一个软件包中提供，并会出现在 Input Methods 选择器中。你自定义的切换键会被保留。如需其他引擎布局或按键，请使用 `omarchy pkg add fcitx5-configtool` 安装 `fcitx5-configtool`，并从终端启动它。选择输入语言不会更改桌面语言。在 _Setup > Region > Language_ 中选择 Japanese、Korean 或 Chinese 时，如果你还没有输入法，它会添加对应的输入法。

使用 `Super + I` 循环切换输入法或键盘布局，使用 `Super + Shift + I` 反方向切换，这样当你配置了三个时，你可以在相邻的两个之间移动。只有当配置了多个输入法或布局时，输入指示器才会出现在状态栏右侧。这个桌面快捷键与你现有的 Fcitx 切换键一起工作；你可以在 `~/.config/hypr/bindings.lua` 中覆盖它。输入引擎和组合序列使用每个会话中已经在运行的 [Fcitx5](https://fcitx-im.org/) 服务。

### 使用 ALT 作为 SUPER

在某些键盘上，使用主 Meta 键（Windows/cmd 键）作为 SUPER 并不方便。你可以通过下面的更改将其改为 ALT：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
