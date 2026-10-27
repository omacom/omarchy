# Tastatur, mus, styreplate

Hyprland lar deg konfigurere alle inndataenhetene dine i stor detalj. Du kan gjøre tastaturrepetisjonen supersonisk rask eller få styreplaten til å bruke naturlig rulling. Du endrer alt i `~/.config/hypr/input.lua`, som du også kan nå via _Setup > Input_ i Omarchy-menyen (`Super + Space`). Alt du setter der, erstatter standardene fra Omarchy.

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

CapsLock fungerer som en vanlig Caps Lock, og `Shift + CapsLock` er komposisjonstasten for [raske emojier](07-hotkeys.md#quick-emojis) og [andre fullføringer](07-hotkeys.md#quick-completions). Hvis du heller vil ha komposisjonstasten et annet sted, bytt ut `omarchy:shift_caps_compose` i `kb_options`. Dette flytter for eksempel komposisjonstasten til Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Styreplatebevegelser

Du kan også slå på [styreplatebevegelser](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), som å sveipe med tre fingre for å bytte arbeidsområde:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

På Dell XPS-bærbare med en haptisk styreplate kan du også sette klikkstyrken til low, mid eller high under _Trigger > Hardware > Touchpad Haptics_.

### Skriving på kinesisk, japansk og andre språk

Velg Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) eller Hong Kong (Cangjie) når installasjonsprogrammet spør om tastaturet ditt. Omarchy konfigurerer tastaturet og den matchende inndatamotoren automatisk, også under offline oppsett ved første oppstart. Japanese bruker Mozc, Korean bruker standard Hangul med to sett, Simplified Chinese bruker Pinyin, Taiwan bruker Chewings standard Zhuyin-oppsett, og Hong Kong bruker Cangjie med Hong Kong-tegnformer. Japanese (US keyboard) gir Mozc med et amerikansk tastaturoppsett. Hangul-, Zhuyin- og Cangjie-taster blir stående i standardposisjonene sine selv når du skriver latinske bokstaver med Dvorak, Colemak eller AZERTY. Hvis du la til Hangul eller Chewing før dette, velg den bort og velg den på nytt under _Setup > Typing > Input Methods_ for å flytte tastene dit; Omarchy lar en motor du allerede skriver med, være i fred.

Skrivingen starter i latinsk modus. Trykk `Super + I` for å bla gjennom konfigurerte inndatametoder, og `Super + Shift + I` for å bla bakover. Trykk `Shift` alene for å gå ut av en inndatametode som Pinyin til latinske bokstaver, og trykk den igjen for å gå tilbake, slik Sogou, Microsoft Pinyin og macOS fungerer; `Shift` pluss en bokstav skriver fortsatt stor bokstav. På japanske tastaturer veksler 全角/半角 inndata, 変換 slår den på, og 無変換 slår den av. Med Korean bytter 한/영 Hangul og 한자 konverterer til Hanja, enten tastaturet ditt har dedikerte taster eller sender Right Alt og Right Ctrl for dem, slik mange bærbare gjør, så Right Alt og Right Ctrl er ikke vanlige modifikatorer der; diktat med push-to-talk forblir på F9. `Ctrl + Space` forblir tilgjengelig for Tmux og Herdr; `Shift + CapsLock` forblir komposisjonstasten.

Tastaturindikatoren vises til høyre på linjen når du har flere tastaturoppsett eller inndatametoder. Klikk den for å bytte inndataspråk; Japanese viser あ for hiragana. For japanske tegnvalg bytter du til Japanese, skriver et ord som `nihongo`, og trykker deretter Space to ganger. Trykk Enter for å godta valget. Hvis du også har flere tastaturoppsett, høyreklikk indikatoren for å bla gjennom dem.

Bruk _Setup > Typing > Keyboard Layouts_ til å velge oppsett som English og French, fra de samme valgene som tilbys under installasjonen. Bruk _Setup > Typing > Input Methods_ til å velge hvilke komposisjonsmotorer som er aktive. Begge velgerne åpnes inne i Omarchy-menyen med nåværende valg huket av. Klikk eller trykk Enter for å veksle et valg; hver endring trer i kraft umiddelbart. Å velge bort en inndatametode fjerner den fra syklusen uten å avinstallere den; tastaturet forblir tilgjengelig.

Kjør `omarchy setup keyboard` eller `omarchy setup input` for å åpne de samme velgerne. For å legge til ett språk fra kommandolinjen bruker du `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eller `cangjie5`. Quick, Boshiamy og Array kommer i samme pakke som Cangjie og vises i Input Methods-velgeren. Dine tilpassede byttetaster bevares. For alternative motoroppsett eller taster installerer du `fcitx5-configtool` med `omarchy pkg add fcitx5-configtool` og starter den fra en terminal. Å velge et inndataspråk endrer ikke skrivebordsspråket. Å velge Japanese, Korean eller Chinese under _Setup > Language_ legger til inndatametoden for det hvis du ikke har noen ennå.

Bruk `Super + I` til å bla gjennom inndatametoder eller tastaturoppsett, og `Super + Shift + I` for å gå baklengs den andre veien, så med tre konfigurerte kan du bevege deg mellom to naboer. Inndataindikatoren vises til høyre på linjen bare når mer enn én inndatametode eller ett oppsett er konfigurert. Denne skrivebordsbindingen fungerer ved siden av dine eksisterende Fcitx-byttetaster; du kan overstyre den i `~/.config/hypr/bindings.lua`. Inndatamotorene og komposisjonssekvensene bruker [Fcitx5](https://fcitx-im.org/)-tjenesten som allerede kjører i hver økt.

### Bruk ALT som SUPER

På noen tastaturer er det ikke praktisk å bruke den primære metatasten (Windows/cmd-tasten) som SUPER. Du kan endre dette til ALT i stedet med denne endringen:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
