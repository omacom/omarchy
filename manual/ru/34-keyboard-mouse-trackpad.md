# Клавиатура, мышь, тачпад

Hyprland даёт конфигурить все вводы в деталях. Повтор клавиатуры — суперсонически быстрым, тачпад — с natural-скроллом. Всё это — в `~/.config/hypr/input.lua`, туда же через _Настройки > Ввод_ в меню Omarchy (`Super + Space`). Что задал там — заменяет дефолты Omarchy.

Вот пример:

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
```

```lua
-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

Все опции вводов смотри на [вики Hyprland про вводы](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

По умолчанию Omarchy вешает compose-клавишу на CapsLock — под [быстрые эмодзи](07-hotkeys.md#быстрые-эмодзи) и [прочие подстановки](07-hotkeys.md#быстрые-подстановки). Хочешь CapsLock как Caps Lock — уведи compose-клавишу в другое место правкой `compose:caps` в `kb_options`. Например, так compose-клавиша переедет на правый Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Жесты тачпада

Можно включить [жесты тачпада](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) — вроде свайпа тремя пальцами под смену столов:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

На ноутах Dell XPS с хаптик-тачпадом силу клика ставят на low, mid или high в _Действия > Оборудование > Touchpad Haptics_.

### Печать на китайском, японском и других языках

Omarchy гоняет фреймворк методов ввода [fcitx5](https://fcitx-im.org/) частью каждой сессии — на нём едут compose-последовательности CapsLock. Значит, сантехника нелатинского ввода уже на месте: ставь движок ввода вроде `fcitx5-mozc` (японский) или `fcitx5-chinese-addons` (китайский) через `omarchy pkg add`, плюс `fcitx5-configtool`, чтобы добавить движок в методы ввода и задать клавишу переключения между ними.

### ALT вместо SUPER

На некоторых клавиатурах главной мета-клавишей (Windows/cmd) как SUPER неудобно. Меняется на ALT вот так:

```lua
hl.config({
  input = {
    kb_options = "compose:caps,shift:both_capslock_cancel,altwin:swap_alt_win",
  },
})
```
