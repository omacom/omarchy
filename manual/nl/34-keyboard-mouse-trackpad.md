# Toetsenbord, muis, trackpad

Met Hyprland kun je al je invoerapparaten tot in detail configureren. Je kunt de toetsherhaling supersonisch snel maken of het trackpad natuurlijk laten scrollen. Dit alles wijzig je in `~/.config/hypr/input.lua`, dat je ook kunt bereiken via _Setup > Input_ in het Omarchy-menu (`Super + Space`). Alles wat je daar instelt, vervangt de standaardwaarden van Omarchy.

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

### Trackpadgebaren

Veeg over het trackpad om over het bureaublad te bewegen:

| Gebaar | Actie |
| --- | --- |
| Drie vingers naar links / rechts | Vorige / volgende werkruimte, inclusief lege |
| Drie vingers omhoog | De AI-console in-/uitschakelen |
| Drie vingers omlaag | Het Omarchy-menu openen |
| Vier vingers naar links / rechts | Het actieve venster naar de vorige / volgende werkruimte verplaatsen |
| Vier vingers omlaag | Volledig scherm in-/uitschakelen |

Om er een te wijzigen, schakel je deze eerst uit in `~/.config/hypr/input.lua` voordat je je eigen [trackpadgebaar](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) toevoegt, aangezien Hyprland geen twee gebaren met dezelfde vingers en richting accepteert:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Om alle gebaren van Omarchy uit te schakelen, stel je `omarchy_default_gestures = false` in bovenaan `~/.config/hypr/hyprland.lua`, voordat de standaardwaarden van Omarchy worden geladen.

Op Dell XPS-laptops met een haptisch touchpad kun je ook de klikkracht instellen op laag, gemiddeld of hoog onder _Trigger > Hardware > Touchpad Haptics_.

### Typen in het Chinees, Japans en andere talen

Selecteer Japans, Koreaans, Chinees (vereenvoudigd, Pinyin), Taiwan (Zhuyin) of Hong Kong (Cangjie) wanneer het installatieprogramma naar je toetsenbord vraagt. Omarchy configureert het toetsenbord en de bijbehorende invoerengine automatisch, ook tijdens de offline installatie bij de eerste keer opstarten. Japans gebruikt Mozc, Koreaans gebruikt de standaard Hangul met twee sets, vereenvoudigd Chinees gebruikt Pinyin, Taiwan gebruikt Chewing's standaard Zhuyin-indeling en Hong Kong gebruikt Cangjie met Hong Kong-tekenvormen. Japans (US-toetsenbord) biedt Mozc met een US-toetsenbordindeling. De toetsen voor Hangul, Zhuyin en Cangjie blijven op hun standaardposities staan, zelfs wanneer je Latijnse letters typt met Dvorak, Colemak of AZERTY. Als je Hangul of Chewing hiervóór hebt toegevoegd, deselecteer en selecteer het dan opnieuw onder _Setup > Typing > Input Methods_ om de toetsen daarheen te verplaatsen; Omarchy laat een engine waarmee je al typt met rust.

Typen begint in de Latijnse modus. Druk op `Super + I` om door de geconfigureerde invoermethoden te bladeren, en op `Super + Shift + I` om terug te bladeren. Tik op zichzelf op `Shift` om uit een invoermethode zoals Pinyin te stappen naar Latijnse letters, en tik er nogmaals op om terug te gaan, net zoals Sogou, Microsoft Pinyin en macOS werken; `Shift` plus een letter typt nog steeds een hoofdletter. Op Japanse toetsenborden schakelt 全角/半角 de invoer in en uit, zet 変換 deze aan en zet 無変換 deze uit. Bij Koreaans schakelt 한/영 tussen Hangul en zet 한자 om naar Hanja, ongeacht of je toetsenbord speciale toetsen heeft of daarvoor Right Alt en Right Ctrl stuurt, zoals veel laptops doen, dus Right Alt en Right Ctrl zijn daar geen gewone modificatietoetsen; dicteren met push-to-talk blijft op F9. `Ctrl + Space` blijft beschikbaar voor Tmux en Herdr; `Shift + CapsLock` blijft de compose-toets.

De toetsenbordindicator verschijnt rechts in de balk wanneer je meerdere toetsenbordindelingen of invoermethoden hebt. Klik erop om van invoertaal te wisselen; Japans toont あ voor hiragana. Voor Japanse tekenkeuzes schakel je over naar Japans, typ je een woord zoals `nihongo` en druk je vervolgens twee keer op Space. Druk op Enter om je keuze te accepteren. Als je ook meerdere toetsenbordindelingen hebt, klik je met de rechtermuisknop op de indicator om daardoorheen te bladeren.

Gebruik _Setup > Typing > Keyboard Layouts_ om indelingen zoals Engels en Frans te selecteren, uit dezelfde keuzes die tijdens de installatie worden aangeboden. Gebruik _Setup > Typing > Input Methods_ om te selecteren welke compositie-engines actief zijn. Beide kiezers openen in het Omarchy-menu met je huidige selecties aangevinkt. Klik of druk op Enter om een keuze in of uit te schakelen; elke wijziging wordt onmiddellijk toegepast. Het deselecteren van een invoermethode verwijdert deze uit de cyclus zonder deze te deïnstalleren; het toetsenbord blijft beschikbaar.

Voer `omarchy setup keyboard` of `omarchy setup input` uit om dezelfde kiezers te openen. Om één taal vanaf de opdrachtregel toe te voegen, gebruik je `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` of `cangjie5`. Quick, Boshiamy en Array zitten in hetzelfde pakket als Cangjie en verschijnen in de kiezer voor Input Methods. Je aangepaste wisseltoetsen blijven behouden. Voor alternatieve engine-indelingen of -toetsen installeer je `fcitx5-configtool` met `omarchy pkg add fcitx5-configtool` en start je het vanuit een terminal. Het selecteren van een invoertaal wijzigt de bureaubladtaal niet. Het kiezen van Japans, Koreaans of Chinees onder _Setup > Language_ voegt de bijbehorende invoermethode toe wanneer je er nog geen hebt.

Gebruik `Super + I` om door invoermethoden of toetsenbordindelingen te bladeren, en `Super + Shift + I` om de andere kant op terug te gaan, zodat je met drie geconfigureerde methoden tussen twee buren kunt bewegen. De invoerindicator verschijnt alleen rechts in de balk wanneer er meer dan één invoermethode of indeling is geconfigureerd. Deze bureaubladkoppeling werkt naast je bestaande Fcitx-wisseltoetsen; je kunt deze overschrijven in `~/.config/hypr/bindings.lua`. Invoerengines en compose-reeksen gebruiken de [Fcitx5](https://fcitx-im.org/)-service die al in elke sessie draait.

### Gebruik ALT als SUPER

Op sommige toetsenborden is het niet handig om de primaire metatoets (Windows/cmd-toets) als SUPER te gebruiken. Je kunt dit in plaats daarvan wijzigen naar ALT met deze wijziging:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
