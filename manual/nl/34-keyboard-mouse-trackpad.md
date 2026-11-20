# Toetsenbord, muis, trackpad

Met Hyprland configureer je al je invoer tot in groot detail. Je kunt de toetsenbordherhaling supersonisch snel maken of het trackpad natuurlijk laten scrollen. Je wijzigt dit allemaal in `~/.config/hypr/input.lua`, dat je ook kunt bereiken via _Setup > Input_ in het Omarchy-menu (`Super + Space`). Alles wat je daar instelt, vervangt de standaardwaarden van Omarchy.

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

CapsLock werkt als een normale Caps Lock, en `Shift + CapsLock` is de compose-toets voor [snelle emoji's](07-hotkeys.md#quick-emojis) en [andere aanvullingen](07-hotkeys.md#quick-completions). Als je de compose-toets liever ergens anders hebt, vervang dan `omarchy:shift_caps_compose` in `kb_options`. Dit voorbeeld verplaatst de compose-toets bijvoorbeeld naar Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Functietoetsen

De bovenste rij van een laptoptoetsenbord stuurt standaard de mediatoetsen (volume, helderheid enzovoort), en met `Fn` ingedrukt krijg je F1-F12; `Fn + Esc` vergrendelt dat andersom totdat je er opnieuw op drukt. De meeste toetsenborden onthouden die vergrendeling zelf. ASUS-laptops en toetsenborden in Apple-stijl laten het aan Linux over, dat ze bij elke opstart op de mediatoetsen zet. Als je wilt dat ze in plaats daarvan op F1-F12 starten, voer dan `omarchy device keyboard toprow fnkeys` uit (en `omarchy device keyboard toprow mediakeys` om terug te gaan); op sommige laptops wordt dit pas na een herstart van kracht. Apple Silicon Macs behouden hun eigen instelling.

### Trackpadgebaren

Veeg over het trackpad om je over het bureaublad te bewegen:

| Gebaar | Actie |
| --- | --- |
| Drie vingers naar links / rechts | Vorige / volgende werkruimte, inclusief lege werkruimtes |
| Drie vingers omhoog | De AI-console in-/uitschakelen |
| Drie vingers omlaag | Het Omarchy-menu openen |
| Vier vingers naar links / rechts | Het actieve venster naar de vorige / volgende werkruimte verplaatsen |
| Vier vingers omlaag | Volledig scherm in-/uitschakelen |

Om er een te wijzigen, schakel je hem uit in `~/.config/hypr/input.lua` voordat je je eigen [touchpadgebaar](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) toevoegt, omdat Hyprland geen twee gebaren met dezelfde vingers en richting accepteert:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Om alle gebaren van Omarchy uit te schakelen, stel je `omarchy_default_gestures = false` in bovenaan `~/.config/hypr/hyprland.lua`, voordat de standaardwaarden van Omarchy worden geladen.

Op Dell XPS-laptops met een haptisch touchpad kun je de klikkracht ook instellen op laag, midden of hoog onder _Trigger > Hardware > Touchpad Haptics_.

### Typen in het Chinees, Japans en andere talen

Selecteer Japans, Koreaans, Chinees (vereenvoudigd, Pinyin), Taiwan (Zhuyin) of Hong Kong (Cangjie) wanneer het installatieprogramma om je toetsenbord vraagt. Omarchy configureert het toetsenbord en de bijpassende invoermotor automatisch, ook tijdens de offline installatie bij de eerste opstart. Japans gebruikt Mozc, Koreaans gebruikt standaard Hangul met twee sets, vereenvoudigd Chinees gebruikt Pinyin, Taiwan gebruikt de standaard Zhuyin-indeling van Chewing en Hong Kong gebruikt Cangjie met Hongkongse tekenvormen. Japans (VS-toetsenbord) biedt Mozc met een Amerikaanse toetsenbordindeling. De Hangul-, Zhuyin- en Cangjie-toetsen blijven op hun standaardposities, zelfs wanneer je Latijnse letters typt met Dvorak, Colemak of AZERTY. Als je hiervoor Hangul of Chewing hebt toegevoegd, deselecteer en herselecteer het dan onder _Setup > Keyboard > Input Methods_ om de toetsen daarnaartoe te verplaatsen; Omarchy laat een motor waarmee je al typt met rust.

Typen begint in de Latijnse modus. Druk op `Super + I` om door de geconfigureerde invoermethoden te bladeren, en op `Super + Shift + I` om terug te bladeren. Tik op `Shift` op zichzelf om uit een invoermethode zoals Pinyin naar Latijnse letters te stappen, en tik er opnieuw op om terug te gaan, zoals Sogou, Microsoft Pinyin en macOS werken; `Shift` plus een letter typt nog steeds een hoofdletter. Op Japanse toetsenborden schakelt 全角/半角 de invoer, zet 変換 hem aan en zet 無変換 hem uit. Bij Koreaans schakelt 한/영 Hangul en converteert 한자 naar Hanja, of je toetsenbord nu speciale toetsen heeft of daarvoor Right Alt en Right Ctrl stuurt, zoals veel laptops doen, dus Right Alt en Right Ctrl zijn daar geen gewone modificatietoetsen; dicteren schakelt in plaats daarvan met Alt + Space. `Ctrl + Space` blijft beschikbaar voor Tmux en Herdr; `Shift + CapsLock` blijft de compose-toets.

De toetsenbordindicator verschijnt rechts op de balk wanneer je meerdere toetsenbordindelingen of invoermethoden hebt. Klik erop om van invoertaal te wisselen; Japans toont あ voor hiragana. Voor Japanse tekenkeuzes schakel je over naar Japans, typ je een woord zoals `nihongo` en druk je twee keer op Space. Druk op Enter om je keuze te accepteren. Als je ook meerdere toetsenbordindelingen hebt, klik je met de rechtermuisknop op de indicator om daartussen te bladeren.

Gebruik _Setup > Keyboard > Keyboard Inputs_ om indelingen zoals Engels en Frans te selecteren, uit dezelfde keuzes die tijdens de installatie worden aangeboden. Gebruik _Setup > Keyboard > Input Methods_ om te selecteren welke compositiemotoren actief zijn. Beide kiezers worden geopend in het Omarchy-menu, met je huidige selecties aangevinkt. Klik of druk op Enter om een keuze in of uit te schakelen; elke wijziging wordt onmiddellijk toegepast. Het deselecteren van een invoermethode verwijdert hem uit de cyclus zonder hem te deïnstalleren; het toetsenbord blijft beschikbaar.

Voer `omarchy setup keyboard` of `omarchy setup input` uit om dezelfde kiezers te openen. Om één taal vanaf de opdrachtregel toe te voegen, gebruik je `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` of `cangjie5`. Quick, Boshiamy en Array zitten in hetzelfde pakket als Cangjie en verschijnen in de kiezer Input Methods. Je aangepaste schakeltoetsen blijven behouden. Voor alternatieve motorindelingen of -toetsen installeer je `fcitx5-configtool` met `omarchy pkg add fcitx5-configtool` en start je het vanuit een terminal. Het selecteren van een invoertaal verandert de bureaubladtaal niet. Als je Japans, Koreaans of Chinees kiest onder _Setup > Language_, wordt de bijbehorende invoermethode toegevoegd wanneer je er nog geen hebt.

Gebruik `Super + I` om door invoermethoden of toetsenbordindelingen te bladeren, en `Super + Shift + I` om de andere kant op terug te gaan, zodat je je met drie geconfigureerde methoden tussen twee buren kunt verplaatsen. De invoerindicator verschijnt alleen rechts op de balk wanneer er meer dan één invoermethode of indeling is geconfigureerd. Deze bureaubladbinding werkt naast je bestaande Fcitx-schakeltoetsen; je kunt hem overschrijven in `~/.config/hypr/bindings.lua`. De invoermotoren en de compose-reeksen gebruiken de [Fcitx5](https://fcitx-im.org/)-dienst die al in elke sessie draait.

### ALT als SUPER gebruiken

Op sommige toetsenborden is het niet handig om de primaire metatoets (Windows/cmd-toets) als SUPER te gebruiken. Je kunt dit met deze wijziging in plaats daarvan veranderen naar ALT:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
