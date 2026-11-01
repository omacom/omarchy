# Tastatur, mus, styreflate

Hyprland lar deg konfigurere alle inndataenhetene dine i stor detalj. Du kan gjøre tastaturrepetisjonen supersonisk rask eller få styreflaten til å bruke naturlig rulling. Du endrer alt i `~/.config/hypr/input.lua`, som du også når via _Setup > Input_ i Omarchy-menyen (`Super + Space`). Alt du setter der, erstatter standardene i Omarchy.

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

### Funksjonstaster

Den øverste raden på et laptoptastatur sender medietastene (volum, lysstyrke og så videre) som standard, og å holde `Fn` gir F1-F12; `Fn + Esc` låser den motsatt vei til du trykker den igjen. De fleste tastaturer husker den låsen selv. ASUS-laptoper og tastaturer i Apple-stil overlater det til Linux, som starter dem på medietastene ved hver oppstart. For å få dem til å starte på F1-F12 i stedet kjører du `omarchy keyboard toprow fnkeys` (og `omarchy keyboard toprow mediakeys` for å gå tilbake); på noen laptoper trer det i kraft etter en omstart. Apple Silicon-Mac-er beholder sin egen innstilling.

### Styreflategester

Sveip på styreflaten for å bevege deg rundt på skrivebordet:

| Gest | Handling |
| --- | --- |
| Tre fingre til venstre / høyre | Forrige / neste arbeidsområde, inkludert tomme |
| Tre fingre opp | Veksle AI-konsollen |
| Tre fingre ned | Åpne Omarchy-menyen |
| Fire fingre til venstre / høyre | Flytt det aktive vinduet til forrige / neste arbeidsområde |
| Fire fingre ned | Veksle fullskjerm |

For å endre én, opphev den i `~/.config/hypr/input.lua` før du legger til din egen [styreflategest](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), siden Hyprland ikke tar to gester på samme fingre og i samme retning:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

For å slå av alle gestene i Omarchy setter du `omarchy_default_gestures = false` nær toppen av `~/.config/hypr/hyprland.lua`, før standardene i Omarchy lastes inn.

På Dell XPS-laptoper med en haptisk styreflate kan du også sette klikkstyrken til low, mid eller high under _Trigger > Hardware > Touchpad Haptics_.

### Skriving på kinesisk, japansk og andre språk

Velg Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) eller Hong Kong (Cangjie) når installasjonsprogrammet spør om tastaturet ditt. Omarchy konfigurerer tastaturet og den tilhørende inndatamotoren automatisk, også under frakoblet oppsett ved første oppstart. Japansk bruker Mozc, koreansk bruker standard to-sett Hangul, forenklet kinesisk bruker Pinyin, Taiwan bruker Chewings standard Zhuyin-oppsett, og Hong Kong bruker Cangjie med tegnformer fra Hong Kong. Japanese (US keyboard) gir Mozc med et amerikansk tastaturoppsett. Tastene for Hangul, Zhuyin og Cangjie blir værende i standardposisjonene sine selv når du skriver latinske bokstaver med Dvorak, Colemak eller AZERTY. Hvis du la til Hangul eller Chewing før dette, velger du det bort og velger det på nytt under _Setup > Keyboard > Input Methods_ for å flytte tastene dit; Omarchy lar en motor du allerede skriver med, være i fred.

Skrivingen starter i latinsk modus. Trykk `Super + I` for å bla gjennom konfigurerte inndatametoder, og `Super + Shift + I` for å bla tilbake. Trykk `Shift` alene for å gå ut av en inndatametode som Pinyin og over til latinske bokstaver, og trykk den igjen for å gå tilbake, slik Sogou, Microsoft Pinyin og macOS fungerer; `Shift` pluss en bokstav skriver fortsatt en stor bokstav. På japanske tastaturer veksler 全角/半角 inndata, 変換 slår det på, og 無変換 slår det av. Med koreansk bytter 한/영 Hangul og 한자 konverterer til Hanja, enten tastaturet ditt har egne taster eller sender Right Alt og Right Ctrl for dem, slik mange laptoper gjør, så Right Alt og Right Ctrl er ikke vanlige modifikatorer der; diktering veksles med Alt + Space i stedet. `Ctrl + Space` forblir tilgjengelig for Tmux og Herdr; `Shift + CapsLock` forblir compose-tasten.

Tastaturindikatoren vises til høyre på linjen når du har flere tastaturoppsett eller inndatametoder. Klikk den for å bytte inndataspråk; japansk viser あ for hiragana. For japanske tegnvalg bytter du til japansk, skriver et ord som `nihongo`, og trykker deretter Space to ganger. Trykk Enter for å godta valget ditt. Hvis du også har flere tastaturoppsett, høyreklikker du indikatoren for å bla gjennom dem.

Bruk _Setup > Keyboard > Keyboard Inputs_ til å velge oppsett som English og French, fra de samme valgene som tilbys under installasjonen. Bruk _Setup > Keyboard > Input Methods_ til å velge hvilke komposisjonsmotorer som er aktive. Begge velgerne åpnes inne i Omarchy-menyen med de nåværende valgene dine avkrysset. Klikk eller trykk Enter for å veksle et valg; hver endring trer i kraft umiddelbart. Når du velger bort en inndatametode, fjernes den fra syklusen uten å avinstalleres; tastaturet forblir tilgjengelig.

Kjør `omarchy setup keyboard` eller `omarchy setup input` for å åpne de samme velgerne. For å legge til ett språk fra kommandolinjen bruker du `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eller `cangjie5`. Quick, Boshiamy og Array kommer i samme pakke som Cangjie og vises i Input Methods-velgeren. De egendefinerte byttetastene dine bevares. For alternative motoroppsett eller taster installerer du `fcitx5-configtool` med `omarchy pkg add fcitx5-configtool` og starter den fra en terminal. Å velge et inndataspråk endrer ikke skrivebordsspråket. Å velge Japanese, Korean eller Chinese under _Setup > Language_ legger til den tilhørende inndatametoden når du ikke har noen fra før.

Bruk `Super + I` til å bla gjennom inndatametoder eller tastaturoppsett, og `Super + Shift + I` til å gå tilbake den andre veien, så med tre konfigurerte kan du bevege deg mellom to naboer. Inndataindikatoren vises til høyre på linjen bare når mer enn én inndatametode eller ett oppsett er konfigurert. Denne skrivebordsbindingen fungerer ved siden av de eksisterende Fcitx-byttetastene dine; du kan overstyre den i `~/.config/hypr/bindings.lua`. Inndatamotorene og compose-sekvensene bruker [Fcitx5](https://fcitx-im.org/)-tjenesten som allerede kjører i hver økt.

### Bruk ALT som SUPER

På noen tastaturer er det ikke praktisk å bruke den primære metatasten (Windows/cmd-tasten) som SUPER. Du kan endre dette til å være ALT i stedet med denne endringen:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
