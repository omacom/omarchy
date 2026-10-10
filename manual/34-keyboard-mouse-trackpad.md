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

Select Japanese, Korean, Chinese (Simplified, Pinyin), or Chinese (Traditional, Zhuyin) when the installer asks for your keyboard. Omarchy configures the keyboard and matching input engine automatically, including during offline first-boot setup. Japanese uses Mozc, Korean uses standard two-set Hangul, Simplified Chinese uses Pinyin, and Traditional Chinese uses Chewing's standard Zhuyin arrangement. Japanese (US keyboard) provides Mozc with a US keyboard layout.

Typing starts in Latin mode. Press `Super + I` to cycle through configured input methods, and `Super + Shift + I` to cycle back. On Japanese keyboards, 全角/半角 toggles input, 変換 turns it on, and 無変換 turns it off. On a Korean keyboard layout, dedicated 한/영 and 한자 keys switch Hangul and convert to Hanja. `Ctrl + Space` stays available for Tmux and Herdr; CapsLock stays the compose key.

The keyboard indicator appears on the right of the bar when you have multiple keyboard layouts or input methods. Click it to switch input languages; Japanese displays あ for hiragana. For Japanese character choices, switch to Japanese, type a word such as `nihongo`, then press Space twice. Press Enter to accept your choice. If you also have multiple keyboard layouts, right-click the indicator to cycle those.

Use _Setup > Typing > Keyboard Layouts_ to select layouts such as English and French, from the same choices offered during installation. Use _Setup > Typing > Input Methods_ to select which composition engines are active. Both pickers open inside the Omarchy menu with your current selections checked. Click or press Enter to toggle a choice; each change applies immediately. Deselecting an input method removes it from the cycle without uninstalling it; the keyboard remains available.

Run `omarchy setup keyboard` or `omarchy setup input` to open the same pickers. To append one language from the command line, use `omarchy setup input mozc`, `hangul`, `pinyin`, or `chewing`. Your custom switching keys are preserved. For alternative engine layouts or keys, install `fcitx5-configtool` with `omarchy pkg add fcitx5-configtool` and launch it from a terminal. Selecting an input language does not change the desktop language.

Use `Super + I` to cycle through input methods or keyboard layouts, and `Super + Shift + I` to go back the other way, so with three configured you can move between two neighbours. The input indicator appears on the right of the bar only when more than one input method or layout is configured. This desktop binding works alongside your existing Fcitx switching keys; you can override it in `~/.config/hypr/bindings.lua`. Tapping Shift alone is not an input switch: Omarchy uses both Shift keys for CapsLock, which changes how input methods see Shift release. Input engines and the CapsLock compose sequences use the [Fcitx5](https://fcitx-im.org/) service already running in every session.

### Use ALT as SUPER

On some keyboards, it's not convenient to use the primary meta key (Windows/cmd key) as SUPER. You can change this to be ALT instead using this change:

```lua
hl.config({
  input = {
    kb_options = "compose:caps,shift:both_capslock_cancel,altwin:swap_alt_win",
  },
})
```
