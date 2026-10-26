# 键盘、鼠标、触控板

Hyprland 让你可以非常细致地配置所有输入设备。你可以把键盘重复速度调得快如超音速，也可以让触控板使用自然滚动。你可以在 `~/.config/hypr/input.lua` 中修改这一切，也可以通过 Omarchy 菜单（`Super + Space`）中的 _Setup > Input_ 打开它。你在那里设置的任何内容都会替换 Omarchy 的默认设置。

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

你可以在 Hyprland wiki 上[查看所有输入选项](https://wiki.hypr.land/Configuring/Basics/Variables/#input)，了解输入的相关设置。

CapsLock 就是普通的 Caps Lock，而 `Shift + CapsLock` 是组合键，用于[快速输入表情符号](07-hotkeys.md#quick-emojis)和[其他补全](07-hotkeys.md#quick-completions)。如果你更想把组合键放在别处，请替换 `kb_options` 中的 `omarchy:shift_caps_compose`。例如，下面这样会把组合键移到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 触控板手势

你还可以开启[触控板手势](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，例如用三根手指滑动来切换工作区：

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

在配备触觉触控板的 Dell XPS 笔记本电脑上，你还可以在 _Trigger > Hardware > Touchpad Haptics_ 下将点击力度设置为 low、mid 或 high。

### 输入中文、日语和其他语言

当安装程序询问你的键盘时，选择 Japanese、Korean、Chinese (Simplified, Pinyin)、Taiwan (Zhuyin) 或 Hong Kong (Cangjie)。Omarchy 会自动配置键盘和匹配的输入引擎，包括在离线首次启动设置期间。Japanese 使用 Mozc，Korean 使用标准的两分式 Hangul，Simplified Chinese 使用 Pinyin，Taiwan 使用 Chewing 的标准 Zhuyin 布局，Hong Kong 使用采用 Hong Kong 字形的 Cangjie。Japanese (US keyboard) 提供搭配 US 键盘布局的 Mozc。即使你使用 Dvorak、Colemak 或 AZERTY 输入拉丁字母，Hangul、Zhuyin 和 Cangjie 的按键仍保持在它们的标准位置。如果你此前添加过 Hangul 或 Chewing，请在 _Setup > Typing > Input Methods_ 下取消选择它再重新选择，以将其按键移动到那里；对于你已经在用来打字的引擎，Omarchy 不会动它。

打字初始为拉丁字母模式。按 `Super + I` 循环切换已配置的输入法，按 `Super + Shift + I` 反向循环。单独轻点 `Shift` 可从 Pinyin 这样的输入法中暂时退出到拉丁字母，再轻点一次即可返回，就像 Sogou、Microsoft Pinyin 和 macOS 的做法一样；`Shift` 加字母仍然输入大写字母。在日语键盘上，全角/半角 切换输入，変換 开启输入，无変換 关闭输入。对于 Korean，한/영 切换 Hangul，한자 转换为 Hanja，无论你的键盘有专用按键，还是像许多笔记本电脑那样用 Right Alt 和 Right Ctrl 来发送它们，因此在那里 Right Alt 和 Right Ctrl 不是普通的修饰键；听写的按住说话功能仍在 F9 上。`Ctrl + Space` 仍可用于 Tmux 和 Herdr；`Shift + CapsLock` 仍是组合键。

当你有多个键盘布局或输入法时，键盘指示器会出现在栏的右侧。点击它可切换输入语言；Japanese 显示 あ 表示平假名。对于日语汉字选择，切换到 Japanese，输入一个词，例如 `nihongo`，然后按两次 Space。按 Enter 接受你的选择。如果你还有多个键盘布局，右键点击该指示器可循环切换它们。

使用 _Setup > Typing > Keyboard Layouts_ 选择布局，例如 English 和 French，可选的项目与安装时提供的相同。使用 _Setup > Typing > Input Methods_ 选择启用哪些组字引擎。两个选择器都会在 Omarchy 菜单内打开，并勾选你当前的选择。点击或按 Enter 可切换一个选项；每次更改都会立即生效。取消选择某个输入法会将其从循环中移除，但不会卸载它；键盘仍然可用。

运行 `omarchy setup keyboard` 或 `omarchy setup input` 可打开相同的选择器。要从命令行添加一种语言，使用 `omarchy setup input mozc`、`hangul`、`pinyin`、`chewing` 或 `cangjie5`。Quick、Boshiamy 和 Array 与 Cangjie 在同一个软件包中，并会出现在 Input Methods 选择器中。你自定义的切换键会被保留。对于其他引擎布局或按键，使用 `omarchy pkg add fcitx5-configtool` 安装 `fcitx5-configtool`，并从终端启动它。选择输入语言不会更改桌面语言。在 _Setup > Language_ 下选择 Japanese、Korean 或 Chinese 时，如果你还没有任何输入法，它会添加相应的输入法。

使用 `Super + I` 循环切换输入法或键盘布局，使用 `Super + Shift + I` 反向切换，因此当你配置了三个时，你可以在相邻的两个之间来回移动。只有当配置了不止一个输入法或布局时，输入指示器才会出现在栏的右侧。这个桌面绑定与你现有的 Fcitx 切换键同时工作；你可以在 `~/.config/hypr/bindings.lua` 中覆盖它。输入引擎和组合序列使用每个会话中已经在运行的 [Fcitx5](https://fcitx-im.org/) 服务。

### 将 ALT 用作 SUPER

在某些键盘上，把主 meta 键（Windows/cmd 键）用作 SUPER 并不方便。你可以改用 ALT 来代替，修改如下：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
