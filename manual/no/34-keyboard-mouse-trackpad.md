# Tastatur, mus, styreplate

Hyprland lar deg konfigurere alle inndataenhetene dine i stor detalj. Du kan gjøre tastaturrepetisjonen supersonisk rask eller få styreplaten til å bruke naturlig rulling. Du endrer alt i `~/.config/hypr/input.lua`, som du også kan nå via _Oppsett > Inndata_ i Omarchy-menyen (`Super + Space`). Alt du angir der, erstatter standardinnstillingene i Omarchy.

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

CapsLock fungerer som en vanlig Caps Lock, og `Shift + CapsLock` er komposisjonstasten for [raske emojier](07-hotkeys.md#quick-emojis) og [andre fullføringer](07-hotkeys.md#quick-completions). Hvis du heller vil ha komposisjonstasten et annet sted, erstatter du `omarchy:shift_caps_compose` i `kb_options`. Dette flytter for eksempel komposisjonstasten til Høyre Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funksjonstaster

Den øverste raden på et laptoptastatur sender medietastene (volum, lysstyrke og så videre) som standard, og å holde inne `Fn` gir F1-F12; `Fn + Esc` låser den motsatt vei til du trykker på den igjen. De fleste tastaturer husker den låsen selv. ASUS-laptoper og tastaturer i Apple-stil overlater det til Linux, som starter dem på medietastene ved hver oppstart. For å få dem til å starte på F1-F12 i stedet kjører du `omarchy device keyboard toprow fnkeys` (og `omarchy device keyboard toprow mediakeys` for å gå tilbake); på noen laptoper trer det i kraft etter en omstart. Apple Silicon-Macer beholder sin egen innstilling.

### Styreplatebevegelser

Sveip på styreplaten for å bevege deg rundt på skrivebordet:

| Bevegelse | Handling |
| --- | --- |
| Tre fingre til venstre / høyre | Forrige / neste arbeidsområde, inkludert tomme |
| Tre fingre opp | Slå AI-konsollen av/på |
| Tre fingre ned | Åpne Omarchy-menyen |
| Fire fingre til venstre / høyre | Flytt det aktive vinduet til forrige / neste arbeidsområde |
| Fire fingre ned | Slå fullskjerm av/på |

For å endre en av dem avregistrerer du den i `~/.config/hypr/input.lua` før du legger til din egen [styreplatebevegelse](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), siden Hyprland ikke tar to bevegelser med samme fingre og retning:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

For å slå av alle bevegelsene i Omarchy setter du `omarchy_default_gestures = false` nær toppen av `~/.config/hypr/hyprland.lua`, før standardinnstillingene i Omarchy lastes inn.

På Dell XPS-laptoper med en haptisk styreplate kan du også sette klikkstyrken til lav, middels eller høy under _Utløser > Maskinvare > Styreplatehaptikk_.

### Å skrive på kinesisk, japansk og andre språk

Velg japansk, koreansk, kinesisk (forenklet, Pinyin), Taiwan (Zhuyin) eller Hongkong (Cangjie) når installasjonsprogrammet spør om tastaturet ditt. Omarchy konfigurerer tastaturet og den tilhørende inndatamotoren automatisk, også under frakoblet førstegangsoppsett ved oppstart. Japansk bruker Mozc, koreansk bruker standard Hangul med to sett, forenklet kinesisk bruker Pinyin, Taiwan bruker Chewings standard Zhuyin-oppsett, og Hongkong bruker Cangjie med tegnformer fra Hongkong. Japansk (amerikansk tastatur) gir Mozc med et amerikansk tastaturoppsett. Hangul-, Zhuyin- og Cangjie-taster blir værende i sine standardposisjoner selv når du skriver latinske bokstaver med Dvorak, Colemak eller AZERTY. Hvis du la til Hangul eller Chewing før dette, velger du den bort og velger den på nytt under _Oppsett > Tastatur > Inndatametoder_ for å flytte tastene dit; Omarchy lar en motor du allerede skriver med, være i fred.

Skriving starter i latinsk modus. Trykk `Super + I` for å bla gjennom konfigurerte inndatametoder, og `Super + Shift + I` for å bla tilbake. Trykk `Shift` alene for å gå ut av en inndatametode som Pinyin til latinske bokstaver, og trykk den igjen for å gå tilbake, slik Sogou, Microsoft Pinyin og macOS fungerer; `Shift` pluss en bokstav skriver fortsatt en stor bokstav. På japanske tastaturer slår 全角/半角 inndata av/på, 変換 slår den på, og 無変換 slår den av. Med koreansk bytter 한/영 Hangul og 한자 konverterer til Hanja, enten tastaturet ditt har dedikerte taster eller sender Høyre Alt og Høyre Ctrl for dem, slik mange laptoper gjør, så Høyre Alt og Høyre Ctrl er ikke vanlige modifikatorer der; diktering slås i stedet av/på med Alt + Space. `Ctrl + Space` forblir tilgjengelig for Tmux og Herdr; `Shift + CapsLock` forblir komposisjonstasten.

Tastaturindikatoren vises til høyre på linjen når du har flere tastaturoppsett eller inndatametoder. Klikk på den for å bytte inndataspråk; japansk viser あ for hiragana. For japanske tegnvalg bytter du til japansk, skriver et ord som `nihongo`, og trykker deretter Space to ganger. Trykk Enter for å godta valget ditt. Hvis du også har flere tastaturoppsett, høyreklikker du på indikatoren for å bla gjennom dem.

Bruk _Oppsett > Tastatur > Tastaturinndata_ for å velge oppsett som engelsk og fransk, fra de samme valgene som tilbys under installasjonen. Bruk _Oppsett > Tastatur > Inndatametoder_ for å velge hvilke komposisjonsmotorer som er aktive. Begge velgerne åpnes inne i Omarchy-menyen med de gjeldende valgene dine avkrysset. Klikk eller trykk Enter for å slå et valg av/på; hver endring trer i kraft umiddelbart. Å velge bort en inndatametode fjerner den fra syklusen uten å avinstallere den; tastaturet forblir tilgjengelig.

Kjør `omarchy setup keyboard` eller `omarchy setup input` for å åpne de samme velgerne. For å legge til ett språk fra kommandolinjen bruker du `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eller `cangjie5`. Quick, Boshiamy og Array kommer i samme pakke som Cangjie og vises i velgeren for inndatametoder. De egendefinerte byttetastene dine bevares. For alternative motoroppsett eller taster installerer du `fcitx5-configtool` med `omarchy pkg add fcitx5-configtool` og starter den fra en terminal. Å velge et inndataspråk endrer ikke skrivebordsspråket. Å velge japansk, koreansk eller kinesisk under _Oppsett > Region > Språk_ legger til inndatametoden når du ikke har noen ennå.

Bruk `Super + I` for å bla gjennom inndatametoder eller tastaturoppsett, og `Super + Shift + I` for å gå den andre veien tilbake, så med tre konfigurerte kan du bevege deg mellom to naboer. Inndataindikatoren vises til høyre på linjen bare når mer enn én inndatametode eller ett oppsett er konfigurert. Denne skrivebordsbindingen fungerer sammen med de eksisterende Fcitx-bytte tastene dine; du kan overstyre den i `~/.config/hypr/bindings.lua`. Inndatamotorene og komposisjonssekvensene bruker [Fcitx5](https://fcitx-im.org/)-tjenesten som allerede kjører i hver økt.

### Bruk ALT som SUPER

På noen tastaturer er det ikke praktisk å bruke den primære metatasten (Windows/cmd-tasten) som SUPER. Du kan endre dette til ALT i stedet med denne endringen:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
