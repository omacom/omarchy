# 键盘、鼠标、触控板

Hyprland 让你非常详细地配置你所有的输入。你可以把键盘重复改得极快，或者让触控板使用自然滚动。你在 `~/.config/hypr/input.lua` 中更改所有这些，你也可以通过 Omarchy 菜单（`Super + Space`）中的 _Setup > Input_ 到达那里。你在那里设置的任何东西都会替换 Omarchy 的默认设置。

以下是一个示例：

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

你可以在 Hyprland wiki 上[查看所有的输入选项](https://wiki.hypr.land/Configuring/Basics/Variables/#input)。

CapsLock 作为正常的 Caps Lock 工作，`Shift + CapsLock` 是用于[快速表情符号](07-hotkeys.md#quick-emojis)和其他[补全](07-hotkeys.md#quick-completions)的组合键。如果你想把组合键放在别处，在 `kb_options` 中替换 `omarchy:shift_caps_compose`。例如，这将组合键移到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 触控板手势

你也可以开启[触摸板手势](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，如用三根手指滑动来更改工作区：

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

在带触觉触控板的 Dell XPS 笔记本电脑上，你也可以在 _Trigger > Hardware > Touchpad Haptics_ 下将点击强度设为低、中或高。

### 用中文、日文和其他语言打字

当安装程序询问你的键盘时，选择日文、韩文、中文（简体，拼音）或中文（繁体，注音）。Omarchy 自动配置键盘和匹配的输入法引擎，包括在离线首次启动设置期间。日文使用 Mozc，韩文使用标准两集式 Hangul，简体中文使用拼音，繁体中文使用 Chewing 的标准注音排列。日文（US keyboard）提供 Mozc 并使用美国键盘布局。

打字从拉丁模式开始。按 `Super + I` 循环浏览已配置的输入法，按 `Super + Shift + I` 向后循环。单独轻点 `Shift` 可走出像拼音这样的输入法进入拉丁字母，再点一次可回去，就像搜狗、微软拼音和 macOS 一样；`Shift` 加一个字母仍然打出大写字母。在日语键盘上，全角/半角切换输入，変換开启它，無変換关闭它。在韩语键盘布局上，专用的 한/영 和 한자 键切换 Hangul 并转换为 Hanja。`Ctrl + Space` 仍可用于 Tmux 和 Herdr；`Shift + CapsLock` 仍是组合键。

当你有多个键盘布局或输入法时，键盘指示器出现在栏的右侧。点击它切换输入语言；日文显示 あ 表示平假名。对于日文字选择，切换到日文，输入如 `nihongo` 这样的词，然后按两次 Space。按 Enter 接受你的选择。如果你也有多个键盘布局，右键点击指示器以循环它们。

使用 _Setup > Typing > Keyboard Layouts_ 选择布局，如英语和法语，选项与安装期间提供的相同。使用 _Setup > Typing > Input Methods_ 选择哪些合成引擎处于活动状态。两个选择器都在 Omarchy 菜单内部打开，并勾选你当前的选择。点击或按 Enter 切换某个选择；每个更改立即生效。取消选择某个输入法会将其从循环中移除，但不卸载它；键盘仍然可用。

运行 `omarchy setup keyboard` 或 `omarchy setup input` 打开相同的选择器。要从命令行追加一种语言，使用 `omarchy setup input mozc`、`hangul`、`pinyin` 或 `chewing`。你的自定义切换键会被保留。对于替代引擎布局或键，用 `omarchy pkg add fcitx5-configtool` 安装 `fcitx5-configtool` 并从终端启动它。选择输入语言不会更改桌面语言。

使用 `Super + I` 循环浏览输入法或键盘布局，使用 `Super + Shift + I` 向另一个方向，所以有三个配置时你可以在两个邻居之间移动。只有当配置了多个输入法或布局时，输入指示器才出现在栏的右侧。此桌面绑定与你现有的 Fcitx 切换键一起工作；你可以在 `~/.config/hypr/bindings.lua` 中覆盖它。输入法引擎和组合序列使用已经在每个会话中运行的 [Fcitx5](https://fcitx-im.org/) 服务。

### 将 ALT 用作 SUPER

在某些键盘上，使用主 meta 键（Windows/cmd 键）作为 SUPER 并不方便。你可以用此更改将其改为 ALT：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
