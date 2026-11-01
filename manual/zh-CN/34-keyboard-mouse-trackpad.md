# 键盘、鼠标、触控板

Hyprland 让你可以非常细致地配置所有输入设备。你可以把键盘重复速度调得快如超音速，也可以让触控板使用自然滚动。你可以在 `~/.config/hypr/input.lua` 中更改这一切，也可以通过 Omarchy 菜单（`Super + Space`）中的 _Setup > Input_ 打开该文件。你在那里设置的任何内容都会取代 Omarchy 的默认值。

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

CapsLock 用作普通的 Caps Lock，而 `Shift + CapsLock` 是用于[快速表情符号](07-hotkeys.md#quick-emojis)和[其他补全](07-hotkeys.md#quick-completions)的 compose 键。如果你想把 compose 键放在其他位置，请替换 `kb_options` 中的 `omarchy:shift_caps_compose`。例如，下面将 compose 键移动到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 功能键

笔记本电脑键盘的顶排默认发送媒体键（音量、亮度等），按住 `Fn` 则可使用 F1-F12；`Fn + Esc` 会将其锁定为相反的状态，直到你再次按下它。大多数键盘会自行记住该锁定状态。ASUS 笔记本电脑和 Apple 风格键盘则将其交给 Linux 处理，因此每次启动时都从媒体键开始。要改为从 F1-F12 开始，请运行 `omarchy keyboard toprow fnkeys`（运行 `omarchy keyboard toprow mediakeys` 可改回去）；在某些笔记本电脑上，重启后才会生效。Apple Silicon Mac 保留其自身的设置。

### 触控板手势

在触控板上滑动即可在桌面上移动：

| 手势 | 操作 |
| --- | --- |
| 三指向左 / 向右滑动 | 上一个 / 下一个工作区，包括空工作区 |
| 三指向上滑动 | 切换 AI 控制台 |
| 三指向下滑动 | 打开 Omarchy 菜单 |
| 四指向左 / 向右滑动 | 将活动窗口移动到上一个 / 下一个工作区 |
| 四指向下滑动 | 切换全屏 |

要更改某个手势，请先在 `~/.config/hypr/input.lua` 中取消设置它，然后再添加你自己的[触控板手势](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，因为 Hyprland 不会接受相同手指数和相同方向的两个手势：

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

要关闭 Omarchy 的所有手势，请在 `~/.config/hypr/hyprland.lua` 靠近顶部的位置、在 Omarchy 的默认设置加载之前设置 `omarchy_default_gestures = false`。

在配备触觉触控板的 Dell XPS 笔记本电脑上，你还可以在 _Trigger > Hardware > Touchpad Haptics_ 下将点击力度设置为 low、mid 或 high。

### 输入中文、日语和其他语言

当安装程序询问你的键盘时，请选择 Japanese、Korean、Chinese (Simplified, Pinyin)、Taiwan (Zhuyin) 或 Hong Kong (Cangjie)。Omarchy 会自动配置键盘和匹配的输入引擎，包括在离线首次启动设置期间。日语使用 Mozc，韩语使用标准两套式 Hangul，简体中文使用 Pinyin，台湾使用 Chewing 的标准 Zhuyin 布局，香港使用采用香港字形的 Cangjie。Japanese (US keyboard) 提供搭配 US 键盘布局的 Mozc。即使你使用 Dvorak、Colemak 或 AZERTY 输入拉丁字母，Hangul、Zhuyin 和 Cangjie 键仍保持在标准位置。如果你以前添加过 Hangul 或 Chewing，请在 _Setup > Keyboard > Input Methods_ 下取消选择再重新选择它，以将其按键移动到那里；对于你已经在用其打字的引擎，Omarchy 不会动它。

输入以拉丁模式开始。按 `Super + I` 循环切换已配置的输入法，按 `Super + Shift + I` 反向循环。单独轻点 `Shift` 可退出 Pinyin 等输入法、进入拉丁字母输入，再轻点一次则返回，就像 Sogou、Microsoft Pinyin 和 macOS 的工作方式一样；`Shift` 加一个字母仍可输入大写字母。在日语键盘上，全角/半角 切换输入，変換 将其打开，無変換 将其关闭。对于韩语，한/영 切换 Hangul，한자 转换为 Hanja，无论你的键盘有专用键，还是像许多笔记本电脑那样为它们发送 Right Alt 和 Right Ctrl，因此在那里 Right Alt 和 Right Ctrl 不是普通修饰键；听写改为使用 Alt + Space 切换。`Ctrl + Space` 仍可用于 Tmux 和 Herdr；`Shift + CapsLock` 仍是 compose 键。

当你有多个键盘布局或输入法时，键盘指示器会出现在栏的右侧。点击它可切换输入语言；日语的平假名显示为 あ。要选择日语字符，请切换到日语，输入一个词，例如 `nihongo`，然后按两次 Space。按 Enter 接受你的选择。如果你还有多个键盘布局，请右键点击指示器以循环切换它们。

使用 _Setup > Keyboard > Keyboard Inputs_ 选择布局，例如 English 和 French，选项与安装期间提供的相同。使用 _Setup > Keyboard > Input Methods_ 选择哪些组字引擎处于活动状态。两个选择器都会在 Omarchy 菜单内打开，并勾选你当前的选择。点击或按 Enter 可切换某个选项；每次更改都会立即生效。取消选择某个输入法会将其从循环中移除，但不会卸载它；键盘仍可使用。

运行 `omarchy setup keyboard` 或 `omarchy setup input` 可打开相同的选择器。要从命令行追加一种语言，请使用 `omarchy setup input mozc`、`hangul`、`pinyin`、`chewing` 或 `cangjie5`。Quick、Boshiamy 和 Array 与 Cangjie 在同一个包中，并会出现在 Input Methods 选择器中。你的自定义切换键会被保留。对于其他引擎布局或按键，请使用 `omarchy pkg add fcitx5-configtool` 安装 `fcitx5-configtool`，并从终端启动它。选择输入语言不会更改桌面语言。在 _Setup > Language_ 下选择 Japanese、Korean 或 Chinese 时，如果你还没有输入法，则会添加其输入法。

使用 `Super + I` 循环切换输入法或键盘布局，使用 `Super + Shift + I` 反向切换，因此当你配置了三个时，你可以在两个相邻项之间移动。只有当配置了多个输入法或布局时，输入指示器才会出现在栏的右侧。这个桌面绑定与你现有的 Fcitx 切换键一起工作；你可以在 `~/.config/hypr/bindings.lua` 中覆盖它。输入引擎和 compose 序列使用每个会话中已在运行的 [Fcitx5](https://fcitx-im.org/) 服务。

### 使用 ALT 作为 SUPER

在某些键盘上，使用主 meta 键（Windows/cmd 键）作为 SUPER 并不方便。你可以使用以下更改将其改为 ALT：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
