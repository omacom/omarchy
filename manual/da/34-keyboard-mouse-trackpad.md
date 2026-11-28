# Tastatur, mus, pegefelt

Hyprland lader dig konfigurere alle dine inputenheder i mindste detalje. Du kan gøre tastaturgentagelsen supersonisk hurtig eller få pegefeltet til at bruge naturlig rulning. Du ændrer det hele i `~/.config/hypr/input.lua`, som du også kan nå via _Setup > Input_ i Omarchy-menuen (`Super + Space`). Alt, hvad du indstiller der, erstatter Omarchys standardindstillinger.

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

CapsLock fungerer som en normal Caps Lock, og `Shift + CapsLock` er compose-tasten til [hurtige emojis](07-hotkeys.md#quick-emojis) og [andre fuldførelser](07-hotkeys.md#quick-completions). Hvis du hellere vil have compose-tasten et andet sted, skal du erstatte `omarchy:shift_caps_compose` i `kb_options`. For eksempel flytter dette compose-tasten til Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funktionstaster

Den øverste række på et bærbart tastatur sender som standard medietasterne (lydstyrke, lysstyrke osv.), og hvis du holder `Fn` nede, får du F1-F12; `Fn + Esc` låser det den anden vej rundt, indtil du trykker på den igen. De fleste tastaturer husker selv den lås. ASUS-bærbare og tastaturer i Apple-stil overlader det til Linux, som starter dem på medietasterne ved hver opstart. For i stedet at få dem til at starte på F1-F12 skal du køre `omarchy device keyboard toprow fnkeys` (og `omarchy device keyboard toprow mediakeys` for at gå tilbage); på nogle bærbare træder det først i kraft efter en genstart. Apple Silicon-Macs beholder deres egen indstilling.

### Bevægelser på pegefeltet

Stryg på pegefeltet for at bevæge dig rundt på skrivebordet:

| Bevægelse | Handling |
| --- | --- |
| Tre fingre til venstre / højre | Forrige / næste arbejdsområde, inklusive tomme |
| Tre fingre op | Slå AI-konsollen til og fra |
| Tre fingre ned | Åbn Omarchy-menuen |
| Fire fingre til venstre / højre | Flyt det aktive vindue til det forrige / næste arbejdsområde |
| Fire fingre ned | Slå fuldskærm til og fra |

For at ændre en af dem skal du fjerne den i `~/.config/hypr/input.lua`, før du tilføjer din egen [pegefeltbevægelse](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), da Hyprland ikke accepterer to bevægelser med de samme fingre og den samme retning:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

For at slå alle Omarchys bevægelser fra skal du indstille `omarchy_default_gestures = false` nær toppen af `~/.config/hypr/hyprland.lua`, før Omarchys standardindstillinger indlæses.

På Dell XPS-bærbare med et haptisk pegefelt kan du også indstille klikstyrken til lav, middel eller høj under _Trigger > Hardware > Touchpad Haptics_.

### Indtastning på kinesisk, japansk og andre sprog

Vælg japansk, koreansk, kinesisk (forenklet, Pinyin), Taiwan (Zhuyin) eller Hong Kong (Cangjie), når installationsprogrammet spørger til dit tastatur. Omarchy konfigurerer automatisk tastaturet og den tilsvarende inputmotor, også under offlineopsætningen ved første opstart. Japansk bruger Mozc, koreansk bruger standard Hangul med to sæt, forenklet kinesisk bruger Pinyin, Taiwan bruger Chewings standard Zhuyin-opstilling, og Hong Kong bruger Cangjie med Hong Kongs tegnformer. Japansk (amerikansk tastatur) giver Mozc med et amerikansk tastaturlayout. Hangul-, Zhuyin- og Cangjie-taster forbliver i deres standardpositioner, selv når du skriver latinske bogstaver med Dvorak, Colemak eller AZERTY. Hvis du tidligere har tilføjet Hangul eller Chewing, skal du fravælge og genvælge det under _Setup > Keyboard > Input Methods_ for at flytte dets taster dertil; Omarchy lader en motor, du allerede skriver med, være i fred.

Indtastning starter i latinsk tilstand. Tryk på `Super + I` for at bladre gennem de konfigurerede inputmetoder, og på `Super + Shift + I` for at bladre tilbage. Tryk på `Shift` alene for at træde ud af en inputmetode som Pinyin og over til latinske bogstaver, og tryk på den igen for at gå tilbage, ligesom Sogou, Microsoft Pinyin og macOS gør; `Shift` plus et bogstav skriver stadig et stort bogstav. På japanske tastaturer skifter 全角/半角 input, 変換 slår det til, og 無変換 slår det fra. Med koreansk skifter 한/영 Hangul, og 한자 konverterer til Hanja, uanset om dit tastatur har dedikerede taster eller sender Right Alt og Right Ctrl til dem, som mange bærbare gør, så Right Alt og Right Ctrl er ikke almindelige modifikatortaster der; diktering slås i stedet til og fra med Alt + Space. `Ctrl + Space` forbliver tilgængelig til Tmux og Herdr; `Shift + CapsLock` forbliver compose-tasten.

Tastaturindikatoren vises til højre på bjælken, når du har flere tastaturlayouts eller inputmetoder. Klik på den for at skifte inputsprog; japansk viser あ for hiragana. For at vælge japanske tegn skal du skifte til japansk, skrive et ord som `nihongo` og derefter trykke på Space to gange. Tryk på Enter for at acceptere dit valg. Hvis du også har flere tastaturlayouts, skal du højreklikke på indikatoren for at bladre igennem dem.

Brug _Setup > Keyboard > Keyboard Inputs_ til at vælge layouts som engelsk og fransk fra de samme valgmuligheder, der tilbydes under installationen. Brug _Setup > Keyboard > Input Methods_ til at vælge, hvilke kompositionsmotorer der er aktive. Begge vælgere åbner i Omarchy-menuen med dine nuværende valg markeret. Klik eller tryk på Enter for at slå et valg til eller fra; hver ændring træder i kraft med det samme. Hvis du fravælger en inputmetode, fjernes den fra cyklussen uden at afinstallere den; tastaturet forbliver tilgængeligt.

Kør `omarchy setup keyboard` eller `omarchy setup input` for at åbne de samme vælgere. For at tilføje ét sprog fra kommandolinjen skal du bruge `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eller `cangjie5`. Quick, Boshiamy og Array følger med i samme pakke som Cangjie og vises i Input Methods-vælgeren. Dine brugerdefinerede skiftetaster bevares. Til alternative motorlayouts eller taster skal du installere `fcitx5-configtool` med `omarchy pkg add fcitx5-configtool` og starte den fra en terminal. At vælge et inputsprog ændrer ikke skrivebordssproget. Hvis du vælger japansk, koreansk eller kinesisk under _Setup > Region > Language_, tilføjes dens inputmetode, når du endnu ikke har nogen.

Brug `Super + I` til at bladre gennem inputmetoder eller tastaturlayouts, og `Super + Shift + I` til at gå den anden vej tilbage, så du med tre konfigurerede kan bevæge dig mellem to naboer. Inputindikatoren vises kun til højre på bjælken, når der er konfigureret mere end én inputmetode eller ét layout. Denne skrivebordsgenvej fungerer sammen med dine eksisterende Fcitx-skiftetaster; du kan tilsidesætte den i `~/.config/hypr/bindings.lua`. Inputmotorerne og compose-sekvenserne bruger [Fcitx5](https://fcitx-im.org/)-tjenesten, der allerede kører i hver session.

### Brug ALT som SUPER

På nogle tastaturer er det ikke praktisk at bruge den primære meta-tast (Windows/cmd-tasten) som SUPER. Du kan i stedet ændre dette til ALT med denne ændring:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
