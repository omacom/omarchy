# 键盘、鼠标、触控板

Hyprland 让你能非常细致地配置所有输入设备。你可以把键盘重复速度调得快如音速，也可以让触控板使用自然滚动。你可以在 `~/.config/hypr/input.lua` 中修改这一切，也可以通过 Omarchy 菜单（`Super + Space`）中的 _Setup > Input_ 打开这个文件。你在那里设置的任何内容都会取代 Omarchy 的默认设置。

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

CapsLock 用作普通的 Caps Lock，而 `Shift + CapsLock` 是撰写键，用于[快速表情符号](07-hotkeys.md#quick-emojis)和[其他补全](07-hotkeys.md#quick-completions)。如果你想把撰写键放在别处，请替换 `kb_options` 中的 `omarchy:shift_caps_compose`。例如，这样可以把撰写键移到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 触控板手势

在触控板上滑动，即可在桌面上移动：

| 手势 | 操作 |
| --- | --- |
| 三指向左 / 向右滑动 | 上一个 / 下一个工作区，包括空工作区 |
| 三指向上滑动 | 切换 AI 控制台 |
| 三指向下滑动 | 打开 Omarchy 菜单 |
| 四指向左 / 向右滑动 | 将活动窗口移到上一个 / 下一个工作区 |
| 四指向下滑动 | 切换全屏 |

要更改其中一个手势，请先在 `~/.config/hypr/input.lua` 中取消设置它，然后再添加你自己的[触控板手势](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，因为 Hyprland 不接受在相同手指数量和相同方向上设置两个手势：

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

要关闭 Omarchy 的所有手势，请在 `~/.config/hypr/hyprland.lua` 顶部附近、Omarchy 默认设置加载之前，设置 `omarchy_default_gestures = false`。

在配备触觉触控板的 Dell XPS 笔记本电脑上，你还可以在 _Trigger > Hardware > Touchpad Haptics_ 下将点击强度设置为 low、mid 或 high。

### 输入中文、日语和其他语言

当安装程序询问你的键盘时，请选择日语、韩语、中文（简体，拼音）、台湾（注音）或香港（仓颉）。Omarchy 会自动配置键盘和匹配的输入引擎，包括在离线首次启动设置期间。日语使用 Mozc，韩语使用标准的两套式 Hangul，简体中文使用拼音，台湾使用 Chewing 的标准注音排列，香港使用仓颉并采用香港字形。日语（US 键盘）提供搭配 US 键盘布局的 Mozc。即使你使用 Dvorak、Colemak 或 AZERTY 输入拉丁字母，Hangul、Zhuyin 和 Cangjie 按键仍保持在标准位置。如果你在此之前已经添加了 Hangul 或 Chewing，请在 _Setup > Typing > Input Methods_ 下取消选择再重新选择它，以将其按键移到这些位置；Omarchy 不会动你已经在使用的引擎。

输入默认从拉丁模式开始。按 `Super + I` 可循环切换已配置的输入法，按 `Super + Shift + I` 可反向循环。单独轻点 `Shift` 可以从拼音等输入法中跳出到拉丁字母，再轻点一次即可返回，就像搜狗、Microsoft Pinyin 和 macOS 的工作方式一样；`Shift` 加字母仍然输入大写字母。在日语键盘上，全角/半角 切换输入，変換 开启输入，無変換 关闭输入。对于韩语，한/영 切换 Hangul，한자 转换为 Hanja，无论你的键盘有专用按键，还是像许多笔记本电脑那样为它们发送 Right Alt 和 Right Ctrl，因此在那里 Right Alt 和 Right Ctrl 不是普通的修饰键；听写则改用 Alt + Space 切换。`Ctrl + Space` 仍可供 Tmux 和 Herdr 使用；`Shift + CapsLock` 仍是撰写键。

当你有多个键盘布局或输入法时，键盘指示器会出现在栏的右侧。点击它可切换输入语言；日语会显示 あ 表示平假名。对于日语字符选择，切换到日语，输入一个词，例如 `nihongo`，然后按两次 Space。按 Enter 接受你的选择。如果你还有多个键盘布局，右键点击该指示器可循环切换这些布局。

使用 _Setup > Typing > Keyboard Layouts_ 选择布局，例如 English 和 French，选项与安装时提供的相同。使用 _Setup > Typing > Input Methods_ 选择哪些输入引擎处于活动状态。两个选择器都会在 Omarchy 菜单内打开，并勾选你当前的选择。点击或按 Enter 可切换一个选项；每次更改都会立即生效。取消选择某个输入法会将其从循环中移除，但不会卸载它；键盘仍然可用。

运行 `omarchy setup keyboard` 或 `omarchy setup input` 可打开相同的选择器。要从命令行追加一种语言，请使用 `omarchy setup input mozc`、`hangul`、`pinyin`、`chewing` 或 `cangjie5`。Quick、Boshiamy 和 Array 与 Cangjie 包含在同一个软件包中，并会出现在 Input Methods 选择器中。你自定义的切换按键会被保留。对于其他引擎布局或按键，请使用 `omarchy pkg add fcitx5-configtool` 安装 `fcitx5-configtool`，并从终端启动它。选择输入语言不会更改桌面语言。在 _Setup > Language_ 下选择日语、韩语或中文时，如果你还没有任何输入法，会添加其输入法。

使用 `Super + I` 循环切换输入法或键盘布局，使用 `Super + Shift + I` 反向切换，因此当你配置了三个时，你可以在两个相邻项之间移动。只有当配置了多个输入法或布局时，输入指示器才会出现在栏的右侧。这个桌面绑定与你现有的 Fcitx 切换按键配合工作；你可以在 `~/.config/hypr/bindings.lua` 中覆盖它。输入引擎和撰写序列使用每个会话中已经在运行的 [Fcitx5](https://fcitx-im.org/) 服务。

### 将 ALT 用作 SUPER

在某些键盘上，使用主 meta 键（Windows/cmd 键）作为 SUPER 并不方便。你可以使用以下更改将其改为 ALT：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
