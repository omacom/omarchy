# Toetsenbord, muis, trackpad

Met Hyprland kun je al je invoer tot in detail configureren. Je kunt de toetsenbordherhaling supersonisch snel maken of het trackpad natuurlijk laten scrollen. Je wijzigt dit allemaal in `~/.config/hypr/input.lua`, dat je ook kunt bereiken via _Setup > Input_ in het Omarchy-menu (`Super + Space`). Alles wat je daar instelt, vervangt de standaardwaarden van Omarchy.

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

CapsLock werkt als een normale Caps Lock, en `Shift + CapsLock` is de compose-toets voor [snelle emoji's](07-hotkeys.md#quick-emojis) en [andere aanvullingen](07-hotkeys.md#quick-completions). Als je de compose-toets liever ergens anders hebt, vervang dan `omarchy:shift_caps_compose` in `kb_options`. Met dit voorbeeld verplaats je de compose-toets bijvoorbeeld naar Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Functietoetsen

De bovenste rij van een laptoptoetsenbord stuurt standaard de mediatoetsen (volume, helderheid enzovoort), en als je `Fn` ingedrukt houdt, krijg je F1-F12; met `Fn + Esc` vergrendel je dat andersom totdat je er opnieuw op drukt. De meeste toetsenborden onthouden die vergrendeling zelf. ASUS-laptops en toetsenborden in Apple-stijl laten het over aan Linux, dat ze bij elke start met de mediatoetsen laat beginnen. Als je ze in plaats daarvan met F1-F12 wilt laten beginnen, voer je `omarchy device keyboard toprow fnkeys` uit (en `omarchy device keyboard toprow mediakeys` om terug te gaan); op sommige laptops wordt dit pas na een herstart van kracht. Apple Silicon Macs houden hun eigen instelling aan.

### Trackpadgebaren

Veeg over het trackpad om over het bureaublad te bewegen:

| Gebaar | Actie |
| --- | --- |
| Drie vingers naar links / rechts | Vorige / volgende werkruimte, inclusief lege |
| Drie vingers omhoog | AI-console in-/uitschakelen |
| Drie vingers omlaag | Het Omarchy-menu openen |
| Vier vingers naar links / rechts | Het actieve venster naar de vorige / volgende werkruimte verplaatsen |
| Vier vingers omlaag | Volledig scherm in-/uitschakelen |

Om er een te wijzigen, haal je hem eerst weg in `~/.config/hypr/input.lua` voordat je je eigen [touchpadgebaar](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) toevoegt, aangezien Hyprland geen twee gebaren met dezelfde vingers en richting accepteert:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Om alle gebaren van Omarchy uit te schakelen, stel je `omarchy_default_gestures = false` in bovenaan `~/.config/hypr/hyprland.lua`, voordat de standaardwaarden van Omarchy worden geladen.

Op Dell XPS-laptops met een haptisch touchpad kun je de kliksterkte ook instellen op laag, middel of hoog onder _Trigger > Hardware > Touchpad Haptics_.

### Typen in het Chinees, Japans en andere talen

Selecteer Japans, Koreaans, Chinees (Vereenvoudigd, Pinyin), Taiwan (Zhuyin) of Hong Kong (Cangjie) wanneer het installatieprogramma naar je toetsenbord vraagt. Omarchy configureert het toetsenbord en de bijpassende invoermotor automatisch, ook tijdens de offline configuratie bij de eerste start. Japans gebruikt Mozc, Koreaans gebruikt het standaard Hangul met twee sets, Vereenvoudigd Chinees gebruikt Pinyin, Taiwan gebruikt Chewings standaard Zhuyin-indeling en Hong Kong gebruikt Cangjie met Hong Kongse tekenvormen. Japans (US-toetsenbord) biedt Mozc met een Amerikaanse toetsenbordindeling. Hangul-, Zhuyin- en Cangjie-toetsen blijven op hun standaardposities, zelfs als je Latijnse letters typt met Dvorak, Colemak of AZERTY. Als je eerder Hangul of Chewing hebt toegevoegd, deselecteer en herselecteer je het onder _Setup > Keyboard > Input Methods_ om zijn toetsen daarheen te verplaatsen; Omarchy laat een motor waarmee je al typt met rust.

Typen begint in de Latijnse modus. Druk op `Super + I` om door geconfigureerde invoermethoden te bladeren, en op `Super + Shift + I` om terug te bladeren. Tik op zichzelf op `Shift` om uit een invoermethode zoals Pinyin te stappen naar Latijnse letters, en tik er opnieuw op om terug te gaan, zoals Sogou, Microsoft Pinyin en macOS werken; `Shift` plus een letter typt nog steeds een hoofdletter. Op Japanse toetsenborden schakelt 全角/半角 de invoer in/uit, zet 変換 hem aan en zet 無変換 hem uit. Bij Koreaans schakelt 한/영 tussen Hangul en zet 한자 om naar Hanja, of je toetsenbord nu speciale toetsen heeft of Right Alt en Right Ctrl daarvoor stuurt, zoals veel laptops doen, dus Right Alt en Right Ctrl zijn daar geen gewone modificatietoetsen; dicteren schakelt in plaats daarvan met Alt + Space. `Ctrl + Space` blijft beschikbaar voor Tmux en Herdr; `Shift + CapsLock` blijft de compose-toets.

De toetsenbordindicator verschijnt rechts in de balk wanneer je meerdere toetsenbordindelingen of invoermethoden hebt. Klik erop om van invoertaal te wisselen; Japans toont あ voor hiragana. Voor Japanse tekenkeuzes schakel je over naar Japans, typ je een woord zoals `nihongo` en druk je vervolgens twee keer op Space. Druk op Enter om je keuze te accepteren. Als je ook meerdere toetsenbordindelingen hebt, klik je met de rechtermuisknop op de indicator om daardoor te bladeren.

Gebruik _Setup > Keyboard > Keyboard Inputs_ om indelingen zoals Engels en Frans te selecteren, uit dezelfde keuzes die tijdens de installatie worden aangeboden. Gebruik _Setup > Keyboard > Input Methods_ om te selecteren welke compositiemotoren actief zijn. Beide kiezers openen in het Omarchy-menu met je huidige selecties aangevinkt. Klik of druk op Enter om een keuze in of uit te schakelen; elke wijziging wordt onmiddellijk toegepast. Als je een invoermethode deselecteert, wordt deze uit de cyclus verwijderd zonder hem te deinstalleren; het toetsenbord blijft beschikbaar.

Voer `omarchy setup keyboard` of `omarchy setup input` uit om dezelfde kiezers te openen. Om één taal vanaf de commandoregel toe te voegen, gebruik je `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` of `cangjie5`. Quick, Boshiamy en Array zitten in hetzelfde pakket als Cangjie en verschijnen in de kiezer voor Input Methods. Je aangepaste schakeltoetsen blijven behouden. Voor alternatieve motorindelingen of toetsen installeer je `fcitx5-configtool` met `omarchy pkg add fcitx5-configtool` en start je het vanuit een terminal. Een invoertaal selecteren verandert de bureaubladtaal niet. Als je Japans, Koreaans of Chinees kiest onder _Setup > Region > Language_, wordt zijn invoermethode toegevoegd wanneer je er nog geen hebt.

Gebruik `Super + I` om door invoermethoden of toetsenbordindelingen te bladeren, en `Super + Shift + I` om de andere kant op terug te gaan, dus met drie geconfigureerde opties kun je tussen twee buren bewegen. De invoerindicator verschijnt alleen rechts in de balk wanneer er meer dan één invoermethode of indeling is geconfigureerd. Deze bureaubladbinding werkt naast je bestaande Fcitx-schakeltoetsen; je kunt hem overschrijven in `~/.config/hypr/bindings.lua`. De invoermotoren en de compose-reeksen gebruiken de [Fcitx5](https://fcitx-im.org/)-service die al in elke sessie draait.

### ALT als SUPER gebruiken

Op sommige toetsenborden is het niet handig om de primaire metatoets (Windows/cmd-toets) als SUPER te gebruiken. Je kunt dit in plaats daarvan wijzigen in ALT met deze wijziging:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
