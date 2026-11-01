# Tastatur, mus, trackpad

Hyprland lader dig konfigurere alle dine inputenheder ned til mindste detalje. Du kan gøre tastaturgentagelsen supersonisk hurtig eller få trackpad'en til at bruge naturlig rulning. Du ændrer det hele i `~/.config/hypr/input.lua`, som du også kan nå via _Setup > Input_ i Omarchy-menuen (`Super + Space`). Alt, hvad du indstiller der, erstatter Omarchys standardindstillinger.

Her er et eksempel:

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

Du kan [se alle inputindstillingerne](https://wiki.hypr.land/Configuring/Basics/Variables/#input) på Hyprland-wikien for input.

CapsLock fungerer som en normal Caps Lock, og `Shift + CapsLock` er compose-tasten til [hurtige emojier](07-hotkeys.md#quick-emojis) og [andre fuldførelser](07-hotkeys.md#quick-completions). Hvis du hellere vil have compose-tasten et andet sted, så udskift `omarchy:shift_caps_compose` i `kb_options`. For eksempel flytter dette compose-tasten til Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpad-bevægelser

Stryg på trackpad'en for at bevæge dig rundt på skrivebordet:

| Bevægelse | Handling |
| --- | --- |
| Tre fingre til venstre / højre | Forrige / næste arbejdsområde, inklusive tomme |
| Tre fingre op | Slå AI-konsollen til/fra |
| Tre fingre ned | Åbn Omarchy-menuen |
| Fire fingre til venstre / højre | Flyt det aktive vindue til forrige / næste arbejdsområde |
| Fire fingre ned | Slå fuldskærm til/fra |

For at ændre en af dem skal du fjerne den i `~/.config/hypr/input.lua`, før du tilføjer din egen [trackpad-bevægelse](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), da Hyprland ikke accepterer to bevægelser med samme fingre og retning:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

For at slå alle Omarchys bevægelser fra skal du indstille `omarchy_default_gestures = false` nær toppen af `~/.config/hypr/hyprland.lua`, før Omarchys standardindstillinger indlæses.

På Dell XPS-bærbare med en haptisk touchpad kan du også indstille klikstyrken til lav, mellem eller høj under _Trigger > Hardware > Touchpad Haptics_.

### Indtastning på kinesisk, japansk og andre sprog

Vælg japansk, koreansk, kinesisk (forenklet, Pinyin), Taiwan (Zhuyin) eller Hong Kong (Cangjie), når installationsprogrammet spørger om dit tastatur. Omarchy konfigurerer tastaturet og den tilsvarende inputmotor automatisk, også under offline opsætning ved første opstart. Japansk bruger Mozc, koreansk bruger standard to-sæt Hangul, forenklet kinesisk bruger Pinyin, Taiwan bruger Chewings standard Zhuyin-arrangement, og Hong Kong bruger Cangjie med Hong Kong-tegnformer. Japansk (amerikansk tastatur) giver Mozc med et amerikansk tastaturlayout. Hangul-, Zhuyin- og Cangjie-taster forbliver på deres standardpositioner, selv når du skriver latinske bogstaver med Dvorak, Colemak eller AZERTY. Hvis du har tilføjet Hangul eller Chewing før dette, skal du fravælge og genvælge det under _Setup > Typing > Input Methods_ for at flytte dets taster dertil; Omarchy lader en motor, du allerede skriver med, være i fred.

Indtastning starter i latinsk tilstand. Tryk på `Super + I` for at skifte mellem konfigurerede inputmetoder, og `Super + Shift + I` for at skifte tilbage. Tryk på `Shift` alene for at træde ud af en inputmetode som Pinyin til latinske bogstaver, og tryk på den igen for at gå tilbage, på samme måde som Sogou, Microsoft Pinyin og macOS fungerer; `Shift` plus et bogstav skriver stadig et stort bogstav. På japanske tastaturer slår 全角/半角 input til/fra, 変換 slår det til, og 無変換 slår det fra. På koreansk skifter 한/영 Hangul, og 한자 konverterer til Hanja, uanset om dit tastatur har dedikerede taster eller sender Right Alt og Right Ctrl for dem, som mange bærbare gør, så Right Alt og Right Ctrl er ikke almindelige modifikatortaster der; diktering slås i stedet til/fra med Alt + Space. `Ctrl + Space` forbliver tilgængelig til Tmux og Herdr; `Shift + CapsLock` forbliver compose-tasten.

Tastaturindikatoren vises til højre på linjen, når du har flere tastaturlayouter eller inputmetoder. Klik på den for at skifte inputsprog; japansk viser あ for hiragana. For japanske tegnvalg skal du skifte til japansk, skrive et ord som `nihongo` og derefter trykke to gange på Space. Tryk på Enter for at acceptere dit valg. Hvis du også har flere tastaturlayouter, skal du højreklikke på indikatoren for at skifte mellem dem.

Brug _Setup > Typing > Keyboard Layouts_ til at vælge layouter som engelsk og fransk, fra de samme valg, der tilbydes under installationen. Brug _Setup > Typing > Input Methods_ til at vælge, hvilke kompositionsmotorer der er aktive. Begge vælgere åbner inde i Omarchy-menuen med dine nuværende valg markeret. Klik eller tryk på Enter for at slå et valg til/fra; hver ændring træder i kraft med det samme. At fravælge en inputmetode fjerner den fra cyklussen uden at afinstallere den; tastaturet forbliver tilgængeligt.

Kør `omarchy setup keyboard` eller `omarchy setup input` for at åbne de samme vælgere. For at tilføje ét sprog fra kommandolinjen skal du bruge `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eller `cangjie5`. Quick, Boshiamy og Array leveres i samme pakke som Cangjie og vises i Input Methods-vælgeren. Dine brugerdefinerede skiftetaster bevares. For alternative motorlayouter eller -taster skal du installere `fcitx5-configtool` med `omarchy pkg add fcitx5-configtool` og starte det fra en terminal. At vælge et inputsprog ændrer ikke skrivebordssproget. At vælge japansk, koreansk eller kinesisk under _Setup > Language_ tilføjer dets inputmetode, når du endnu ikke har nogen.

Brug `Super + I` til at skifte mellem inputmetoder eller tastaturlayouter, og `Super + Shift + I` til at gå den anden vej tilbage, så du med tre konfigurerede kan bevæge dig mellem to naboer. Inputindikatoren vises kun til højre på linjen, når der er konfigureret mere end én inputmetode eller ét layout. Denne skrivebordsbinding fungerer sammen med dine eksisterende Fcitx-skiftetaster; du kan tilsidesætte den i `~/.config/hypr/bindings.lua`. Inputmotorer og compose-sekvenserne bruger [Fcitx5](https://fcitx-im.org/)-tjenesten, der allerede kører i hver session.

### Brug ALT som SUPER

På nogle tastaturer er det ikke praktisk at bruge den primære meta-tast (Windows/cmd-tasten) som SUPER. Du kan ændre dette til at være ALT i stedet med denne ændring:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
