# Tastatur, mus, styreplate

Hyprland lar deg konfigurere alle inndataenhetene dine i stor detalj. Du kan gjøre tastaturrepetisjonen supersonisk rask eller få styreplaten til å bruke naturlig rulling. Du endrer alt dette i `~/.config/hypr/input.lua`, som du også kan nå via _Setup > Input_ i Omarchy-menyen (`Super + Space`). Alt du setter der, erstatter standardverdiene i Omarchy.

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

Du kan [se alle inndataalternativene](https://wiki.hypr.land/Configuring/Basics/Variables/#input) på Hyprland-wikien for inndata.

CapsLock fungerer som en vanlig Caps Lock, og `Shift + CapsLock` er compose-tasten for [raske emojier](07-hotkeys.md#quick-emojis) og [andre fullføringer](07-hotkeys.md#quick-completions). Hvis du heller vil ha compose-tasten et annet sted, erstatter du `omarchy:shift_caps_compose` i `kb_options`. Dette flytter for eksempel compose-tasten til Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Bevegelser på styreplaten

Sveip på styreplaten for å bevege deg rundt på skrivebordet:

| Bevegelse | Handling |
| --- | --- |
| Tre fingre til venstre / høyre | Forrige / neste arbeidsområde, inkludert tomme |
| Tre fingre opp | Veksle AI-konsollen |
| Tre fingre ned | Åpne Omarchy-menyen |
| Fire fingre til venstre / høyre | Flytt det aktive vinduet til forrige / neste arbeidsområde |
| Fire fingre ned | Veksle fullskjerm |

For å endre en av dem opphever du den i `~/.config/hypr/input.lua` før du legger til din egen [styreplatebevegelse](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), siden Hyprland ikke godtar to bevegelser på samme fingre og i samme retning:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

For å slå av alle bevegelsene i Omarchy setter du `omarchy_default_gestures = false` nær toppen av `~/.config/hypr/hyprland.lua`, før standardverdiene i Omarchy lastes inn.

På Dell XPS-bærbare med haptisk styreplate kan du også sette klikkstyrken til lav, midt eller høy under _Trigger > Hardware > Touchpad Haptics_.

### Skriving på kinesisk, japansk og andre språk

Velg japansk, koreansk, kinesisk (forenklet, Pinyin), Taiwan (Zhuyin) eller Hong Kong (Cangjie) når installasjonsprogrammet spør om tastaturet ditt. Omarchy konfigurerer tastaturet og den tilhørende inndatamotoren automatisk, også under frakoblet oppsett ved første oppstart. Japansk bruker Mozc, koreansk bruker standard to-sett Hangul, forenklet kinesisk bruker Pinyin, Taiwan bruker Chewings standard Zhuyin-oppsett, og Hong Kong bruker Cangjie med Hong Kong-tegnformer. Japanese (US keyboard) gir Mozc med et US-tastaturoppsett. Tastene for Hangul, Zhuyin og Cangjie blir værende i standardposisjonene sine selv når du skriver latinske bokstaver med Dvorak, Colemak eller AZERTY. Hvis du la til Hangul eller Chewing før dette, fjerner du valget og velger det på nytt under _Setup > Typing > Input Methods_ for å flytte tastene dit; Omarchy lar en motor du allerede skriver med, være i fred.

Skrivingen starter i latinsk modus. Trykk `Super + I` for å bla gjennom konfigurerte inndatametoder, og `Super + Shift + I` for å bla tilbake. Trykk `Shift` alene for å gå ut av en inndatametode som Pinyin og over til latinske bokstaver, og trykk den igjen for å gå tilbake, slik Sogou, Microsoft Pinyin og macOS fungerer; `Shift` pluss en bokstav skriver fortsatt en stor bokstav. På japanske tastaturer veksler 全角/半角 inndata, 変換 slår det på, og 無変換 slår det av. Med koreansk bytter 한/영 Hangul og 한자 konverterer til Hanja, enten tastaturet ditt har egne taster eller sender Right Alt og Right Ctrl for dem, slik mange bærbare gjør, så Right Alt og Right Ctrl er ikke vanlige modifikasjonstaster der; diktering med push-to-talk forblir på F9. `Ctrl + Space` forblir tilgjengelig for Tmux og Herdr; `Shift + CapsLock` forblir compose-tasten.

Tastaturindikatoren vises til høyre på linjen når du har flere tastaturoppsett eller inndatametoder. Klikk på den for å bytte inndataspråk; japansk viser あ for hiragana. For valg av japanske tegn bytter du til japansk, skriver et ord som `nihongo`, og trykker deretter Space to ganger. Trykk Enter for å godta valget ditt. Hvis du også har flere tastaturoppsett, høyreklikker du på indikatoren for å bla gjennom dem.

Bruk _Setup > Typing > Keyboard Layouts_ for å velge oppsett som engelsk og fransk, fra de samme valgene som tilbys under installasjonen. Bruk _Setup > Typing > Input Methods_ for å velge hvilke komposisjonsmotorer som er aktive. Begge velgerne åpnes inne i Omarchy-menyen med de nåværende valgene dine avkrysset. Klikk eller trykk Enter for å veksle et valg; hver endring trer i kraft umiddelbart. Når du fjerner valget av en inndatametode, fjernes den fra syklusen uten å avinstalleres; tastaturet forblir tilgjengelig.

Kjør `omarchy setup keyboard` eller `omarchy setup input` for å åpne de samme velgerne. For å legge til ett språk fra kommandolinjen bruker du `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eller `cangjie5`. Quick, Boshiamy og Array leveres i samme pakke som Cangjie og vises i Input Methods-velgeren. De egendefinerte byttetastene dine bevares. For alternative motoroppsett eller taster installerer du `fcitx5-configtool` med `omarchy pkg add fcitx5-configtool` og starter det fra en terminal. Å velge et inndataspråk endrer ikke skrivebordsspråket. Å velge japansk, koreansk eller kinesisk under _Setup > Language_ legger til den tilhørende inndatametoden når du ikke har noen ennå.

Bruk `Super + I` for å bla gjennom inndatametoder eller tastaturoppsett, og `Super + Shift + I` for å gå tilbake den andre veien, så med tre konfigurerte kan du bevege deg mellom to naboer. Inndataindikatoren vises til høyre på linjen bare når mer enn én inndatametode eller ett oppsett er konfigurert. Denne skrivebordsbindingen fungerer sammen med de eksisterende Fcitx-bytte­tastene dine; du kan overstyre den i `~/.config/hypr/bindings.lua`. Inndatamotorene og compose-sekvensene bruker [Fcitx5](https://fcitx-im.org/)-tjenesten som allerede kjører i hver økt.

### Bruk ALT som SUPER

På noen tastaturer er det ikke praktisk å bruke den primære metatasten (Windows/cmd-tasten) som SUPER. Du kan endre dette til å være ALT i stedet med denne endringen:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
