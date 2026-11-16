# Tastatur, mus, trackpad

Hyprland lader dig konfigurere alle dine input i mindste detalje. Du kan gøre tastaturgentagelsen supersonisk hurtig eller få trackpadden til at bruge naturlig rulning. Du ændrer det hele i `~/.config/hypr/input.lua`, som du også kan nå via _Setup > Input_ i Omarchy-menuen (`Super + Space`). Alt, hvad du angiver der, erstatter Omarchys standardindstillinger.

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

CapsLock fungerer som en normal Caps Lock, og `Shift + CapsLock` er compose-tasten til [hurtige emojis](07-hotkeys.md#quick-emojis) og [andre fuldførelser](07-hotkeys.md#quick-completions). Hvis du hellere vil have compose-tasten et andet sted, skal du erstatte `omarchy:shift_caps_compose` i `kb_options`. Dette flytter for eksempel compose-tasten til Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funktionstaster

Den øverste række på et laptoptastatur sender som standard medietasterne (lydstyrke, lysstyrke og så videre), og hvis du holder `Fn` nede, får du F1-F12; `Fn + Esc` låser den omvendt, indtil du trykker på den igen. De fleste tastaturer husker selv den lås. Bærbare ASUS-computere og tastaturer i Apple-stil overlader det til Linux, som starter dem på medietasterne ved hver opstart. For at få dem til at starte på F1-F12 i stedet skal du køre `omarchy keyboard toprow fnkeys` (og `omarchy keyboard toprow mediakeys` for at gå tilbage); på nogle bærbare træder det først i kraft efter en genstart. Apple Silicon-Macs beholder deres egen indstilling.

### Trackpad-bevægelser

Stryg på trackpadden for at bevæge dig rundt på skrivebordet:

| Bevægelse | Handling |
| --- | --- |
| Tre fingre til venstre / højre | Forrige / næste arbejdsområde, inklusive tomme |
| Tre fingre op | Slå AI-konsollen til/fra |
| Tre fingre ned | Åbn Omarchy-menuen |
| Fire fingre til venstre / højre | Flyt det aktive vindue til det forrige / næste arbejdsområde |
| Fire fingre ned | Slå fuldskærm til/fra |

Hvis du vil ændre en af dem, skal du fjerne den i `~/.config/hypr/input.lua`, før du tilføjer din egen [touchpad-bevægelse](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), da Hyprland ikke accepterer to bevægelser med samme fingre og retning:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

For at slå alle Omarchys bevægelser fra skal du sætte `omarchy_default_gestures = false` nær toppen af `~/.config/hypr/hyprland.lua`, før Omarchys standardindstillinger indlæses.

På Dell XPS-bærbare med en haptisk touchpad kan du også sætte klikstyrken til lav, mellem eller høj under _Trigger > Hardware > Touchpad Haptics_.

### Skrivning på kinesisk, japansk og andre sprog

Vælg Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) eller Hong Kong (Cangjie), når installationsprogrammet spørger til dit tastatur. Omarchy konfigurerer automatisk tastaturet og den tilsvarende inputmotor, også under offline opsætning ved første opstart. Japanese bruger Mozc, Korean bruger standard to-sæt Hangul, Simplified Chinese bruger Pinyin, Taiwan bruger Chewings standard Zhuyin-layout, og Hong Kong bruger Cangjie med tegnformer fra Hong Kong. Japanese (US keyboard) giver Mozc med et amerikansk tastaturlayout. Tasterne til Hangul, Zhuyin og Cangjie bliver på deres standardpositioner, selv når du skriver latinske bogstaver med Dvorak, Colemak eller AZERTY. Hvis du tidligere har tilføjet Hangul eller Chewing, skal du fravælge og vælge det igen under _Setup > Keyboard > Input Methods_ for at flytte dets taster dertil; Omarchy lader en motor, du allerede skriver med, være i fred.

Skrivningen starter i latinsk tilstand. Tryk på `Super + I` for at bladre gennem de konfigurerede inputmetoder, og `Super + Shift + I` for at bladre tilbage. Tryk på `Shift` alene for at træde ud af en inputmetode som Pinyin og over til latinske bogstaver, og tryk på den igen for at gå tilbage, på samme måde som Sogou, Microsoft Pinyin og macOS fungerer; `Shift` plus et bogstav skriver stadig et stort bogstav. På japanske tastaturer slår 全角/半角 input til/fra, 変換 slår det til, og 無変換 slår det fra. Med Korean skifter 한/영 Hangul, og 한자 konverterer til Hanja, uanset om dit tastatur har dedikerede taster eller sender Right Alt og Right Ctrl for dem, som mange bærbare gør, så Right Alt og Right Ctrl er ikke almindelige modifikatortaster der; diktering slås i stedet til/fra med Alt + Space. `Ctrl + Space` forbliver tilgængelig til Tmux og Herdr; `Shift + CapsLock` forbliver compose-tasten.

Tastaturindikatoren vises til højre på bjælken, når du har flere tastaturlayouter eller inputmetoder. Klik på den for at skifte inputsprog; Japanese viser あ for hiragana. For at vælge japanske tegn skal du skifte til Japanese, skrive et ord som `nihongo` og derefter trykke to gange på Space. Tryk på Enter for at acceptere dit valg. Hvis du også har flere tastaturlayouter, skal du højreklikke på indikatoren for at bladre gennem dem.

Brug _Setup > Keyboard > Keyboard Inputs_ til at vælge layouter som English og French blandt de samme valgmuligheder, der tilbydes under installationen. Brug _Setup > Keyboard > Input Methods_ til at vælge, hvilke kompositionsmotorer der er aktive. Begge vælgere åbner inde i Omarchy-menuen med dine nuværende valg markeret. Klik eller tryk på Enter for at slå et valg til/fra; hver ændring træder i kraft med det samme. Hvis du fravælger en inputmetode, fjernes den fra cyklussen uden at blive afinstalleret; tastaturet forbliver tilgængeligt.

Kør `omarchy setup keyboard` eller `omarchy setup input` for at åbne de samme vælgere. For at tilføje ét sprog fra kommandolinjen skal du bruge `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eller `cangjie5`. Quick, Boshiamy og Array følger med i samme pakke som Cangjie og vises i Input Methods-vælgeren. Dine brugerdefinerede skiftetaster bevares. Til alternative motorlayouter eller taster skal du installere `fcitx5-configtool` med `omarchy pkg add fcitx5-configtool` og starte det fra en terminal. At vælge et inputsprog ændrer ikke skrivebordssproget. Hvis du vælger Japanese, Korean eller Chinese under _Setup > Language_, tilføjes den tilhørende inputmetode, når du ikke har nogen endnu.

Brug `Super + I` til at bladre gennem inputmetoder eller tastaturlayouter, og `Super + Shift + I` til at gå den anden vej tilbage, så du med tre konfigurerede kan bevæge dig mellem to naboer. Inputindikatoren vises kun til højre på bjælken, når der er konfigureret mere end én inputmetode eller ét layout. Denne skrivebordsgenvej fungerer sammen med dine eksisterende Fcitx-skiftetaster; du kan tilsidesætte den i `~/.config/hypr/bindings.lua`. Inputmotorerne og compose-sekvenserne bruger [Fcitx5](https://fcitx-im.org/)-tjenesten, som allerede kører i hver session.

### Brug ALT som SUPER

På nogle tastaturer er det ikke praktisk at bruge den primære metatast (Windows/cmd-tasten) som SUPER. Du kan i stedet ændre den til ALT med denne ændring:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
