# Tastatur, mus, styreflate

Hyprland lar deg konfigurere alle inndataene dine i stor detalj. Du kan gjøre tastaturgjentakelsen supersonisk rask eller få styreflaten til å bruke naturlig rulling. Du endrer alt i `~/.config/hypr/input.lua`, som du også kan nå via _Oppsett > Inndata_ i Omarchy-menyen (`Super + Space`). Alt du setter der erstatter Omarchys standarder.

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

Du kan [se alle inndatavalgene](https://wiki.hypr.land/Configuring/Basics/Variables/#input) på Hyprland-wikien for inndata.

CapsLock fungerer som en vanlig Caps Lock, og `Shift + CapsLock` er compose-tasten for [raske emojier](07-hotkeys.md#quick-emojis) og [andre fullføringer](07-hotkeys.md#quick-completions). Hvis du heller vil ha compose-tasten et annet sted, erstatt `omarchy:shift_caps_compose` i `kb_options`. For eksempel flytter dette compose-tasten til Høyre Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Berøringsflatebevegelser

Du kan også slå på [berøringsflatebevegelser](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), som å sveipe med tre fingre for å bytte arbeidsområde:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

På Dell XPS-bærbare med haptisk styreflate kan du også angi klikkstyrken til lav, middels eller høy under _Utløs > Maskinvare > Berøringsflate-haptikk_.

### Skrive på kinesisk, japansk og andre språk

Velg japansk, koreansk, kinesisk (forenklet, Pinyin) eller kinesisk (tradisjonell, Zhuyin) når installasjonsprogrammet spør om tastaturet ditt. Omarchy konfigurerer tastaturet og matchende innmatingsmotor automatisk, også under frakoblet førstegangsoppsett. Japansk bruker Mozc, koreansk bruker standard tosett-hangul, forenklet kinesisk bruker Pinyin, og tradisjonell kinesisk bruker Chewings standard Zhuyin-oppsett. Japansk (US-tastatur) gir Mozc med et US-tastaturoppsett.

Skriving starter i latinsk modus. Trykk `Super + I` for å bla gjennom konfigurerte inndatametoder, og `Super + Shift + I` for å bla tilbake. Trykk `Shift` alene for å tre ut av en inndatametode som Pinyin til latinske bokstaver, og trykk den igjen for å gå tilbake, på måten Sogou, Microsoft Pinyin og macOS fungerer; `Shift` pluss en bokstav skriver fortsatt en stor bokstav. På japanske tastaturer veksler 全角/半角 inndata, 変換 slår den på og 無変換 slår den av. På et koreansk tastaturoppsett bytter de dedikerte 한/영- og 한자-tastene Hangul og konverterer til Hanja. `Ctrl + Space` er fortsatt tilgjengelig for Tmux og Herdr; `Shift + CapsLock` er fortsatt compose-tasten.

Tastaturindikatoren vises til høyre i linjen når du har flere tastaturoppsett eller inndatametoder. Klikk på den for å bytte inndataspråk; japansk viser あ for hiragana. For japanske tegnvalg, bytt til japansk, skriv et ord som `nihongo`, og trykk deretter Space to ganger. Trykk Enter for å godta valget ditt. Hvis du også har flere tastaturoppsett, høyreklikk på indikatoren for å bla gjennom dem.

Bruk _Oppsett > Skriving > Tastaturoppsett_ for å velge oppsett som engelsk og fransk, fra de samme valgene som tilbys under installasjonen. Bruk _Oppsett > Skriving > Inndatametoder_ for å velge hvilke komposisjonsmotorer som er aktive. Begge velgerne åpnes inni Omarchy-menyen med dine nåværende valg huket av. Klikk eller trykk Enter for å veksle et valg; hver endring gjelder umiddelbart. Å velge bort en inndatametode fjerner den fra syklusen uten å avinstallere den; tastaturet er fortsatt tilgjengelig.

Kjør `omarchy setup keyboard` eller `omarchy setup input` for å åpne de samme velgerne. For å legge til ett språk fra kommandolinjen, bruk `omarchy setup input mozc`, `hangul`, `pinyin`, eller `chewing`. Dine egendefinerte byttetaster bevares. For alternative motoroppsett eller taster, installer `fcitx5-configtool` med `omarchy pkg add fcitx5-configtool` og start den fra en terminal. Å velge et inndataspråk endrer ikke skrivebordsspråket.

Bruk `Super + I` for å bla gjennom inndatametoder eller tastaturoppsett, og `Super + Shift + I` for å gå den andre veien tilbake, slik at du med tre konfigurerte kan flytte deg mellom to naboer. Inndataindikatoren vises til høyre i linjen bare når mer enn én inndatametode eller oppsett er konfigurert. Denne skrivebordsbindingen fungerer sammen med dine eksisterende Fcitx-bytte taster; du kan overstyre den i `~/.config/hypr/bindings.lua`. Inndatamotorene og compose-sekvensene bruker [Fcitx5](https://fcitx-im.org/)-tjenesten som allerede kjører i hver økt.

### Bruk ALT som SUPER

På noen tastaturer er det ikke praktisk å bruke den primære meta-tasten (Windows/cmd-tasten) som SUPER. Du kan endre dette til ALT i stedet med denne endringen:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
