# Toetsenbord, muis, trackpad

Hyprland laat je al je invoerapparaten tot in groot detail configureren. Je kunt de toetsenbordherhaling supersonisch snel maken of het trackpad natuurlijk laten scrollen. Je wijzigt dit allemaal in `~/.config/hypr/input.lua`, dat je ook kunt bereiken via _Setup > Input_ in het Omarchy-menu (`Super + Space`). Alles wat je daar instelt, vervangt de standaardinstellingen van Omarchy.

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

Je kunt [alle invoeropties bekijken](https://wiki.hypr.land/Configuring/Basics/Variables/#input) op de Hyprland-wiki voor invoer.

CapsLock werkt als een normale Caps Lock, en `Shift + CapsLock` is de compose-toets voor [snelle emoji's](07-hotkeys.md#quick-emojis) en [andere aanvullingen](07-hotkeys.md#quick-completions). Als je de compose-toets liever ergens anders hebt, vervang dan `omarchy:shift_caps_compose` in `kb_options`. Dit verplaatst de compose-toets bijvoorbeeld naar Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpadgebaren

Je kunt ook [touchpadgebaren](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) inschakelen, zoals met drie vingers vegen om van werkruimte te wisselen:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Op Dell XPS-laptops met een haptisch touchpad kun je de kliksterkte ook instellen op low, mid of high onder _Trigger > Hardware > Touchpad Haptics_.

### Typen in het Chinees, Japans en andere talen

Selecteer Japans, Koreaans, Chinees (Vereenvoudigd, Pinyin), Taiwan (Zhuyin) of Hongkong (Cangjie) wanneer het installatieprogramma naar je toetsenbord vraagt. Omarchy configureert het toetsenbord en de bijpassende invoerengine automatisch, ook tijdens de offline configuratie bij de eerste keer opstarten. Japans gebruikt Mozc, Koreaans gebruikt standaard tweedelige Hangul, Vereenvoudigd Chinees gebruikt Pinyin, Taiwan gebruikt de standaard Zhuyin-indeling van Chewing, en Hongkong gebruikt Cangjie met Hongkongse tekenvormen. Japans (US-toetsenbord) biedt Mozc met een US-toetsenbordindeling. De Hangul-, Zhuyin- en Cangjie-toetsen blijven op hun standaardposities, ook wanneer je Latijnse letters typt met Dvorak, Colemak of AZERTY. Als je Hangul of Chewing hiervoor al had toegevoegd, deselecteer en herselecteer het dan onder _Setup > Typing > Input Methods_ om zijn toetsen daarheen te verplaatsen; Omarchy laat een engine waarmee je al typt met rust.

Typen begint in de Latijnse modus. Druk op `Super + I` om door de geconfigureerde invoermethoden te bladeren, en op `Super + Shift + I` om terug te bladeren. Tik alleen op `Shift` om uit een invoermethode zoals Pinyin te stappen naar Latijnse letters, en tik er opnieuw op om terug te gaan, zoals Sogou, Microsoft Pinyin en macOS werken; `Shift` plus een letter typt nog steeds een hoofdletter. Op Japanse toetsenborden schakelt 全角/半角 de invoer om, zet 変換 hem aan en zet 無変換 hem uit. Bij Koreaans schakelt 한/영 om tussen Hangul en zet 한자 om naar Hanja, of je toetsenbord nu speciale toetsen heeft of daarvoor Right Alt en Right Ctrl stuurt, zoals veel laptops doen, dus Right Alt en Right Ctrl zijn daar geen gewone modificatietoetsen; push-to-talk voor dicteren blijft op F9. `Ctrl + Space` blijft beschikbaar voor Tmux en Herdr; `Shift + CapsLock` blijft de compose-toets.

De toetsenbordindicator verschijnt rechts op de balk wanneer je meerdere toetsenbordindelingen of invoermethoden hebt. Klik erop om van invoertaal te wisselen; Japans toont あ voor hiragana. Voor Japanse tekenkeuzes schakel je over naar Japans, typ je een woord zoals `nihongo` en druk je twee keer op Space. Druk op Enter om je keuze te accepteren. Als je ook meerdere toetsenbordindelingen hebt, klik je met de rechtermuisknop op de indicator om daardoorheen te bladeren.

Gebruik _Setup > Typing > Keyboard Layouts_ om indelingen zoals Engels en Frans te selecteren, uit dezelfde keuzes die tijdens de installatie worden aangeboden. Gebruik _Setup > Typing > Input Methods_ om te selecteren welke compositie-engines actief zijn. Beide kiezers openen in het Omarchy-menu met je huidige selecties aangevinkt. Klik of druk op Enter om een keuze in of uit te schakelen; elke wijziging wordt onmiddellijk toegepast. Het deselecteren van een invoermethode verwijdert hem uit de cyclus zonder hem te de-installeren; het toetsenbord blijft beschikbaar.

Voer `omarchy setup keyboard` of `omarchy setup input` uit om dezelfde kiezers te openen. Om één taal vanaf de opdrachtregel toe te voegen, gebruik je `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` of `cangjie5`. Quick, Boshiamy en Array zitten in hetzelfde pakket als Cangjie en verschijnen in de kiezer voor Input Methods. Je aangepaste wisseltoetsen blijven behouden. Voor alternatieve engine-indelingen of -toetsen installeer je `fcitx5-configtool` met `omarchy pkg add fcitx5-configtool` en start je het vanuit een terminal. Het selecteren van een invoertaal verandert de desktoptaal niet. Het kiezen van Japans, Koreaans of Chinees onder _Setup > Language_ voegt zijn invoermethode toe wanneer je er nog geen hebt.

Gebruik `Super + I` om door invoermethoden of toetsenbordindelingen te bladeren, en `Super + Shift + I` om de andere kant op terug te gaan, zodat je je met drie geconfigureerde opties tussen twee buren kunt bewegen. De invoerindicator verschijnt alleen rechts op de balk wanneer er meer dan één invoermethode of indeling is geconfigureerd. Deze desktopbinding werkt naast je bestaande Fcitx-wisseltoetsen; je kunt hem overschrijven in `~/.config/hypr/bindings.lua`. De invoerengines en de compose-reeksen gebruiken de [Fcitx5](https://fcitx-im.org/)-service die al in elke sessie draait.

### ALT als SUPER gebruiken

Op sommige toetsenborden is het niet handig om de primaire metatoets (Windows/cmd-toets) als SUPER te gebruiken. Je kunt dit in plaats daarvan wijzigen naar ALT met deze wijziging:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
