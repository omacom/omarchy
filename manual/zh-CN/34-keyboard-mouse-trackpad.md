# 键盘、鼠标、触控板

Hyprland 让你可以非常详细地配置所有输入设备。你可以将键盘重复速度调得快如闪电，也可以让触控板使用自然滚动。你可以在 `~/.config/hypr/input.lua` 中更改这一切，也可以通过 Omarchy 菜单（`Super + Space`）中的 _Setup > Input_ 到达该文件。你在那里设置的任何内容都会取代 Omarchy 的默认设置。

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

CapsLock 用作普通的 Caps Lock，而 `Shift + CapsLock` 是用于[快捷表情](07-hotkeys.md#quick-emojis)和[其他补全](07-hotkeys.md#quick-completions)的组合键。如果你更想把组合键放在别处，请替换 `kb_options` 中的 `omarchy:shift_caps_compose`。例如，这样会将组合键移到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 功能键

笔记本键盘的顶行默认发送媒体键（音量、亮度等），按住 `Fn` 则得到 F1-F12；`Fn + Esc` 会将其锁定为相反状态，直到你再次按下它。大多数键盘会自己记住该锁定状态。ASUS 笔记本和 Apple 风格的键盘将此交给 Linux 处理，因此每次启动时都会以媒体键开始。要让它们改为以 F1-F12 开始，请运行 `omarchy device keyboard toprow fnkeys`（使用 `omarchy device keyboard toprow mediakeys` 可切回）；在某些笔记本上，这会在重启后生效。Apple Silicon Mac 保留其自己的设置。

### 触控板手势

在触控板上滑动即可在桌面上移动：

| 手势 | 操作 |
| --- | --- |
| 三指左滑 / 右滑 | 上一个 / 下一个工作区，包括空工作区 |
| 三指上滑 | 切换 AI 控制台 |
| 三指下滑 | 打开 Omarchy 菜单 |
| 四指左滑 / 右滑 | 将活动窗口移到上一个 / 下一个工作区 |
| 四指下滑 | 切换全屏 |

若要更改其中一个手势，请先在 `~/.config/hypr/input.lua` 中取消设置它，然后再添加你自己的[触控板手势](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，因为 Hyprland 不会接受在相同手指数量和方向上的两个手势：

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

若要关闭 Omarchy 的所有手势，请在 `~/.config/hypr/hyprland.lua` 顶部附近、Omarchy 默认设置加载之前，设置 `omarchy_default_gestures = false`。

在配备触觉触控板的 Dell XPS 笔记本上，你还可以在 _Trigger > Hardware > Touchpad Haptics_ 下将点击力度设置为 low、mid 或 high。

### 输入中文、日语和其他语言

当安装程序询问你的键盘时，选择 Japanese、Korean、Chinese (Simplified, Pinyin)、Taiwan (Zhuyin) 或 Hong Kong (Cangjie)。Omarchy 会自动配置键盘和匹配的输入引擎，包括在离线首次启动设置期间。日语使用 Mozc，韩语使用标准两分式 Hangul，简体中文使用 Pinyin，台湾使用 Chewing 的标准 Zhuyin 排列，香港使用带有香港字形的 Cangjie。Japanese (US keyboard) 提供带 US 键盘布局的 Mozc。即使你使用 Dvorak、Colemak 或 AZERTY 输入拉丁字母，Hangul、Zhuyin 和 Cangjie 键也会保持在标准位置。如果你在此之前添加了 Hangul 或 Chewing，请在 _Setup > Keyboard > Input Methods_ 下取消选择并重新选择它，以将其按键移到那里；Omarchy 不会动你已经在使用的引擎。

输入以拉丁模式开始。按 `Super + I` 可循环切换已配置的输入法，按 `Super + Shift + I` 可反向循环。单独轻点 `Shift` 可从 Pinyin 等输入法中跳出到拉丁字母，再轻点一次可返回，就像 Sogou、Microsoft Pinyin 和 macOS 的工作方式一样；`Shift` 加字母仍会输入大写字母。在日语键盘上，全角/半角 切换输入，変換 将其打开，無変換 将其关闭。使用韩语时，한/영 切换 Hangul，한자 转换为 Hanja，无论你的键盘有专用键还是像许多笔记本那样为它们发送 Right Alt 和 Right Ctrl，因此在那里 Right Alt 和 Right Ctrl 不是普通的修饰键；听写则改用 Alt + Space 切换。`Ctrl + Space` 仍可用于 Tmux 和 Herdr；`Shift + CapsLock` 仍为组合键。

当你有多个键盘布局或输入法时，键盘指示器会出现在顶栏右侧。点击它可切换输入语言；日语会显示 あ 表示平假名。对于日语字符选择，切换到日语，输入一个词如 `nihongo`，然后按两次 Space。按 Enter 接受你的选择。如果你还有多个键盘布局，右键点击指示器可循环切换这些布局。

使用 _Setup > Keyboard > Keyboard Inputs_ 选择布局，如 English 和 French，这些与安装期间提供的选择相同。使用 _Setup > Keyboard > Input Methods_ 选择哪些组合引擎处于活动状态。两个选择器都会在 Omarchy 菜单内打开，并勾选你当前的选择。点击或按 Enter 可切换一个选择；每次更改都会立即生效。取消选择一个输入法会将其从循环中移除，但不会卸载它；键盘仍可用。

运行 `omarchy setup keyboard` 或 `omarchy setup input` 可打开相同的选择器。若要从命令行追加一种语言，请使用 `omarchy setup input mozc`、`hangul`、`pinyin`、`chewing` 或 `cangjie5`。Quick、Boshiamy 和 Array 与 Cangjie 在同一个软件包中，并会出现在 Input Methods 选择器中。你自定义的切换键会被保留。对于替代的引擎布局或按键，请使用 `omarchy pkg add fcitx5-configtool` 安装 `fcitx5-configtool` 并从终端启动它。选择输入语言不会更改桌面语言。在 _Setup > Language_ 下选择 Japanese、Korean 或 Chinese 时，如果你还没有任何输入法，它会添加其输入法。

使用 `Super + I` 循环切换输入法或键盘布局，使用 `Super + Shift + I` 反向切换，因此当你配置了三个时，可以在两个相邻项之间移动。只有当配置了多个输入法或布局时，输入指示器才会出现在顶栏右侧。这个桌面绑定可与你现有的 Fcitx 切换键共存；你可以在 `~/.config/hypr/bindings.lua` 中覆盖它。输入引擎和组合序列使用每个会话中已经运行的 [Fcitx5](https://fcitx-im.org/) 服务。

### 将 ALT 用作 SUPER

在某些键盘上，使用主 meta 键（Windows/cmd 键）作为 SUPER 并不方便。你可以使用此更改将其改为 ALT：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
