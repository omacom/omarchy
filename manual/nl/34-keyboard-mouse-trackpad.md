# Toetsenbord, muis, trackpad

Hyprland laat je al je invoer in groot detail configureren. Je kunt de toetsenbordherhaling supersonisch snel maken of het trackpad natuurlijk scrollen laten gebruiken. Je wijzigt het allemaal in `~/.config/hypr/input.lua`, dat je ook kunt bereiken via _Instellen > Invoer_ in het Omarchy-menu (`Super + Space`). Alles wat je daar instelt, vervangt Omarchy's standaardwaarden.

Hier is een voorbeeld:

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

Je kunt [alle invoeropties zien](https://wiki.hypr.land/Configuring/Basics/Variables/#input) op de Hyprland-wiki voor invoer.

CapsLock werkt als een normale Caps Lock, en `Shift + CapsLock` is de compose-toets voor [snelle emoji's](07-hotkeys.md#quick-emojis) en [andere aanvullingen](07-hotkeys.md#quick-completions). Als je de compose-toets liever ergens anders hebt, vervang je `omarchy:shift_caps_compose` in `kb_options`. Bijvoorbeeld, dit verplaatst de compose-toets naar Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpadgebaren

Je kunt ook [touchpadgebaren](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) inschakelen, zoals vegen met drie vingers om van workspace te wisselen:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Op Dell XPS-laptops met een haptisch touchpad kun je de kliksterkte ook instellen op laag, midden of hoog onder _Activeren > Hardware > Touchpad-haptiek_.

### Typen in Chinees, Japans en andere talen

Selecteer Japans, Koreaans, Chinees (vereenvoudigd, Pinyin), of Chinees (traditioneel, Zhuyin) wanneer het installatieprogramma naar je toetsenbord vraagt. Omarchy configureert het toetsenbord en de bijpassende invoermotor automatisch, ook tijdens offline eerste-opstart-setup. Japans gebruikt Mozc, Koreaans gebruikt standaard two-set Hangul, vereenvoudigd Chinees gebruikt Pinyin, en traditioneel Chinees gebruikt Chewing's standaard Zhuyin-indeling. Japans (US-toetsenbord) biedt Mozc met een US-toetsenbordindeling.

Typen begint in Latin-modus. Druk op `Super + I` om door geconfigureerde invoermethoden te cyclen, en op `Super + Shift + I` om terug te cyclen. Tik op `Shift` op zichzelf om uit een invoermethode zoals Pinyin te stappen naar Latin-letters, en tik er nogmaals op om terug te gaan, zoals Sogou, Microsoft Pinyin en macOS werken; `Shift` plus een letter typt nog steeds een hoofdletter. Op Japanse toetsenborden schakelt 全角/半角 de invoer om, zet 変換 deze aan, en zet 無変換 deze uit. Op een Koreaanse toetsenbordindeling schakelen de speciale 한/영- en 한자-toetsen Hangul en converteren ze naar Hanja. `Ctrl + Space` blijft beschikbaar voor Tmux en Herdr; `Shift + CapsLock` blijft de compose-toets.

De toetsenbordindicator verschijnt rechts in de balk wanneer je meerdere toetsenbordindelingen of invoermethoden hebt. Klik erop om van invoertaal te wisselen; Japans toont あ voor hiragana. Voor Japanse tekenkeuzes schakel je over naar Japans, typ je een woord zoals `nihongo`, en druk je vervolgens twee keer op Space. Druk op Enter om je keuze te accepteren. Als je ook meerdere toetsenbordindelingen hebt, klik je met de rechtermuisknop op de indicator om daartussen te cyclen.

Gebruik _Instellen > Typen > Toetsenbordindelingen_ om indelingen zoals Engels en Frans te selecteren, uit dezelfde keuzes die tijdens de installatie worden aangeboden. Gebruik _Instellen > Typen > Invoermethoden_ om te selecteren welke compositiemotoren actief zijn. Beide pickers openen in het Omarchy-menu met je huidige selecties aangevinkt. Klik of druk op Enter om een keuze om te schakelen; elke wijziging is direct van toepassing. Het deselecteren van een invoermethode verwijdert deze uit de cyclus zonder deze te de-installeren; het toetsenbord blijft beschikbaar.

Voer `omarchy setup keyboard` of `omarchy setup input` uit om dezelfde pickers te openen. Om één taal vanaf de commandoregel toe te voegen, gebruik je `omarchy setup input mozc`, `hangul`, `pinyin` of `chewing`. Je aangepaste schakeltoetsen blijven behouden. Voor alternatieve motorindelingen of -toetsen installeer je `fcitx5-configtool` met `omarchy pkg add fcitx5-configtool` en start je het vanuit een terminal. Het selecteren van een invoertaal verandert de bureaubladtaal niet.

Gebruik `Super + I` om door invoermethoden of toetsenbordindelingen te cyclen, en `Super + Shift + I` om de andere kant op te gaan, zodat je met drie geconfigureerde tussen twee buren kunt bewegen. De invoerindicator verschijnt alleen rechts in de balk wanneer meer dan één invoermethode of indeling is geconfigureerd. Deze bureaubladbinding werkt naast je bestaande Fcitx-schakeltoetsen; je kunt deze overschrijven in `~/.config/hypr/bindings.lua`. Invoermotoren en de compose-sequenties gebruiken de [Fcitx5](https://fcitx-im.org/)-dienst die al in elke sessie draait.

### ALT als SUPER gebruiken

Op sommige toetsenborden is het niet handig om de primaire metatoets (Windows/cmd-toets) als SUPER te gebruiken. Je kunt dit veranderen in ALT met deze wijziging:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
