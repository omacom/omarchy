# 键盘、鼠标、触控板

Hyprland 让你可以非常细致地配置所有输入设备。你可以把键盘重复速度调得快得离谱，或者让触控板使用自然滚动。你可以在 `~/.config/hypr/input.lua` 中修改所有这些设置，也可以通过 Omarchy 菜单（`Super + Space`）中的 _Setup > Input_ 进入该文件。你在那里设置的任何内容都会取代 Omarchy 的默认设置。

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

CapsLock 的作用仍是普通的 Caps Lock，而 `Shift + CapsLock` 是组合键，用于[快速输入表情符号](07-hotkeys.md#quick-emojis)和[其他补全](07-hotkeys.md#quick-completions)。如果你想把组合键放在别的位置，请替换 `kb_options` 中的 `omarchy:shift_caps_compose`。例如，下面这段会把组合键移到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 触控板手势

在触控板上滑动，即可在桌面上四处操作：

| 手势 | 操作 |
| --- | --- |
| 三指向左 / 向右 | 上一个 / 下一个工作区，包括空工作区 |
| 三指向上 | 切换 AI 控制台 |
| 三指向下 | 打开 Omarchy 菜单 |
| 四指向左 / 向右 | 将活动窗口移到上一个 / 下一个工作区 |
| 四指向下 | 切换全屏 |

要更改其中一个手势，请先在 `~/.config/hypr/input.lua` 中将它取消，然后再添加你自己的[触控板手势](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，因为 Hyprland 不会接受相同手指数和相同方向上的两个手势：

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

要关闭 Omarchy 的全部手势，请在 `~/.config/hypr/hyprland.lua` 靠近顶部的位置、在 Omarchy 的默认设置加载之前，设置 `omarchy_default_gestures = false`。

在配备触觉触控板的 Dell XPS 笔记本电脑上，你还可以在 _Trigger > Hardware > Touchpad Haptics_ 下将点击力度设置为 low、mid 或 high。

### 输入中文、日语和其他语言

当安装程序询问你的键盘时，选择 Japanese、Korean、Chinese (Simplified, Pinyin)、Taiwan (Zhuyin) 或 Hong Kong (Cangjie)。Omarchy 会自动配置键盘和匹配的输入引擎，包括在离线首次启动设置期间。Japanese 使用 Mozc，Korean 使用标准两套式 Hangul，Simplified Chinese 使用 Pinyin，Taiwan 使用 Chewing 的标准 Zhuyin 排列，Hong Kong 使用采用香港字形的 Cangjie。Japanese (US keyboard) 提供配合 US 键盘布局的 Mozc。即便你使用 Dvorak、Colemak 或 AZERTY 输入 Latin 字母，Hangul、Zhuyin 和 Cangjie 的按键仍保持在标准位置。如果你在此之前已经添加了 Hangul 或 Chewing，请在 _Setup > Typing > Input Methods_ 下取消选择再重新选择它，以将其按键移到这些位置；对于你已经在用于输入的引擎，Omarchy 不会去动它。

输入默认从 Latin 模式开始。按 `Super + I` 可循环切换已配置的输入法，按 `Super + Shift + I` 则反向循环。单独轻按 `Shift` 可以从 Pinyin 这类输入法中暂时退出到 Latin 字母，再轻按一次即可返回，就像 Sogou、Microsoft Pinyin 和 macOS 的做法一样；`Shift` 加字母仍然输入大写字母。在 Japanese 键盘上，全角/半角 切换输入，変換 开启输入，無変換 关闭输入。对于 Korean，한/영 切换 Hangul，한자 转换为 Hanja，无论你的键盘有专用键，还是像许多笔记本电脑那样用 Right Alt 和 Right Ctrl 发送这些键，因此在那种情况下 Right Alt 和 Right Ctrl 不是普通的修饰键；听写的按住说话功能仍在 F9 上。`Ctrl + Space` 仍可用于 Tmux 和 Herdr；`Shift + CapsLock` 仍是组合键。

当你有多个键盘布局或输入法时，键盘指示器会出现在栏的右侧。点击它可以切换输入语言；Japanese 用 あ 表示平假名。对于 Japanese 汉字候选，切换到 Japanese，输入一个词如 `nihongo`，然后按两次 Space。按 Enter 确认你的选择。如果你还有多个键盘布局，右键点击该指示器可以循环切换它们。

使用 _Setup > Typing > Keyboard Layouts_ 选择 English 和 French 这类布局，选项与安装期间提供的相同。使用 _Setup > Typing > Input Methods_ 选择要启用的输入引擎。这两个选择器都会在 Omarchy 菜单内打开，并勾选你当前的选择。点击或按 Enter 可以切换某项；每项更改都会立即生效。取消选择某个输入法会将它从循环中移除，但不会卸载它；键盘仍可使用。

运行 `omarchy setup keyboard` 或 `omarchy setup input` 可以打开相同的选择器。要从命令行追加一种语言，使用 `omarchy setup input mozc`、`hangul`、`pinyin`、`chewing` 或 `cangjie5`。Quick、Boshiamy 和 Array 与 Cangjie 位于同一个软件包中，会出现在 Input Methods 选择器里。你的自定义切换键会得到保留。对于其他引擎布局或按键，使用 `omarchy pkg add fcitx5-configtool` 安装 `fcitx5-configtool`，并从终端启动它。选择输入语言不会更改桌面语言。在 _Setup > Language_ 下选择 Japanese、Korean 或 Chinese 时，如果你还没有输入法，它会添加相应的输入法。

使用 `Super + I` 循环切换输入法或键盘布局，使用 `Super + Shift + I` 反向切换，因此当你配置了三个时，你可以在相邻的两项之间移动。只有当配置了不止一个输入法或布局时，输入指示器才会出现在栏的右侧。这个桌面快捷键与你现有的 Fcitx 切换键一起工作；你可以在 `~/.config/hypr/bindings.lua` 中覆盖它。输入引擎和组合序列使用每个会话中已经在运行的 [Fcitx5](https://fcitx-im.org/) 服务。

### 使用 ALT 作为 SUPER

在某些键盘上，使用主 meta 键（Windows/cmd 键）作为 SUPER 并不方便。你可以通过以下更改，将其改为 ALT：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
