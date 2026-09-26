# Keyboard, Mouse, Trackpad

Hyprland lets you configure all your inputs in great detail. You can change the keyboard repeat to be supersonically fast or make the trackpad use natural scrolling. You change all of it in `~/.config/hypr/input.lua`, which you can also reach via _Setup > Input_ in the Omarchy menu (`Super + Space`). Anything you set there replaces Omarchy's defaults.

Here's an example:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "compose:caps,shift:both_capslock_cancel,grp:alts_toggle",

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

You can [see all the input options](https://wiki.hypr.land/Configuring/Basics/Variables/#input) on the Hyprland wiki for inputs.

By default, Omarchy uses CapsLock as the compose key for [quick emojis](07-hotkeys.md#quick-emojis) and [other completions](07-hotkeys.md#quick-completions). If you'd rather use CapsLock as Caps Lock, move the compose key elsewhere by changing `compose:caps` in `kb_options`. For example, this moves the compose key to Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpad gestures

You can also turn on [touchpad gestures](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), like swiping with three fingers to change workspaces:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

On Dell XPS laptops with a haptic touchpad, you can also set the click strength to low, mid, or high under _Trigger > Hardware > Touchpad Haptics_.

### Typing in Chinese, Japanese, and other languages

Omarchy runs the [fcitx5](https://fcitx-im.org/) input method framework as part of every session — it's what powers the CapsLock compose sequences. That means the plumbing for non-Latin input is already in place: install an input engine like `fcitx5-mozc` (Japanese) or `fcitx5-chinese-addons` (Chinese) with `omarchy pkg add`, plus `fcitx5-configtool` to add the engine to your input methods and set the key that switches between them.

### Typing in Korean

Korean is one step away: pick _Setup > Input Method > Hangul (Korean)_ in the Omarchy menu (or run `omarchy setup input hangul`), and Omarchy installs the [fcitx5-hangul](https://github.com/fcitx/fcitx5-hangul) engine and adds it to your input methods. You keep typing English until you press the 한/영 key — or Ctrl+Space on keyboards without one — which toggles Hangul on and off. While typing Korean, the 한자 key (or F9) offers Hanja for what you just typed. Caps Lock stays the compose key, as on every other layout.

Keyboards without dedicated 한/영 and 한자 keys can put them on Right Alt and Right Ctrl, the way Korean Windows does, with an xkb option in `~/.config/hypr/input.lua`:

```lua
hl.config({
  input = {
    kb_options = "compose:caps,shift:both_capslock_cancel,korean:ralt_hangul,korean:rctrl_hanja",
  },
})
```

The engine reads letters rather than key positions, so on Dvorak or Colemak give Hangul its own QWERTY layout: run `omarchy pkg add fcitx5-configtool`, select Hangul under _Input Method_, and set its layout to English (US).

### Use ALT as SUPER

On some keyboards, it's not convenient to use the primary meta key (Windows/cmd key) as SUPER. You can change this to be ALT instead using this change:

```lua
hl.config({
  input = {
    kb_options = "compose:caps,shift:both_capslock_cancel,altwin:swap_alt_win",
  },
})
```
