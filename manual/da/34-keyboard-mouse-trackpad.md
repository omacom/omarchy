# Tastatur, mus, pegefelt

Hyprland lader dig konfigurere alle dine input i stor detalje. Du kan ændre tastaturgentagelsen til at være supersonisk hurtig eller få pegefeltet til at bruge naturlig rulning. Du ændrer det hele i `~/.config/hypr/input.lua`, som du også kan nå via _Opsætning > Input_ i Omarchy-menuen (`Super + Space`). Alt, hvad du sætter der, erstatter Omarchys standarder.

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

Du kan [se alle inputmulighederne](https://wiki.hypr.land/Configuring/Basics/Variables/#input) på Hyprland-wikien for input.

CapsLock fungerer som en normal Caps Lock, og `Shift + CapsLock` er compose-tasten til [hurtige emojier](07-hotkeys.md#quick-emojis) og [andre fuldførelser](07-hotkeys.md#quick-completions). Hvis du hellere vil have compose-tasten et andet sted, skal du erstatte `omarchy:shift_caps_compose` i `kb_options`. For eksempel flytter dette compose-tasten til højre Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Pegefelt-bevægelser

Du kan også slå [pegefelt-bevægelser](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) til, som at stryge med tre fingre for at skifte arbejdsområder:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

På Dell XPS bærbare computere med et haptisk pegefelt kan du også indstille klikstyrken til lav, mellem eller høj under _Udløs > Hardware > Pegefelt-haptik_.

### Skrive på kinesisk, japansk og andre sprog

Vælg japansk, koreansk, kinesisk (forenklet, Pinyin) eller kinesisk (traditionel, Zhuyin), når installationsprogrammet spørger efter dit tastatur. Omarchy konfigurerer tastaturet og den matchende inputmotor automatisk, inklusive under offline førstestartsopsætning. Japansk bruger Mozc, koreansk bruger standard to-sæt Hangul, forenklet kinesisk bruger Pinyin, og traditionel kinesisk bruger Chewings standard Zhuyin-layout. Japansk (amerikansk tastatur) giver Mozc med et amerikansk tastaturlayout.

Skrivning starter i latinsk tilstand. Tryk på `Super + I` for at cykle gennem konfigurerede inputmetoder og `Super + Shift + I` for at cykle tilbage. Tryk på `Shift` alene for at træde ud af en inputmetode som Pinyin til latinske bogstaver, og tryk på den igen for at gå tilbage, på den måde Sogou, Microsoft Pinyin og macOS fungerer; `Shift` plus et bogstav skriver stadig et stort bogstav. På japanske tastaturer skifter 全角/半角 input, 変換 tænder det, og 無変換 slukker det. På et koreansk tastaturlayout skifter dedikerede 한/영- og 한자-taster Hangul og konverterer til Hanja. `Ctrl + Space` forbliver tilgængelig til Tmux og Herdr; `Shift + CapsLock` forbliver compose-tasten.

Tastaturindikatoren vises til højre i linjen, når du har flere tastaturlayouts eller inputmetoder. Klik på den for at skifte inputsprog; japansk viser あ for hiragana. For japanske tegnvalg skal du skifte til japansk, skrive et ord såsom `nihongo` og derefter trykke på Space to gange. Tryk på Enter for at acceptere dit valg. Hvis du også har flere tastaturlayouts, skal du højreklikke på indikatoren for at cykle mellem dem.

Brug _Opsætning > Skrivning > Tastaturlayout_ til at vælge layouts såsom engelsk og fransk fra de samme valg, der tilbydes under installationen. Brug _Opsætning > Skrivning > Inputmetoder_ til at vælge, hvilke kompositionsmotorer der er aktive. Begge vælgere åbner inde i Omarchy-menuen med dine aktuelle valg afkrydset. Klik eller tryk på Enter for at skifte et valg; hver ændring gælder øjeblikkeligt. At fravælge en inputmetode fjerner den fra cyklussen uden at afinstallere den; tastaturet forbliver tilgængeligt.

Kør `omarchy setup keyboard` eller `omarchy setup input` for at åbne de samme vælgere. For at tilføje ét sprog fra kommandolinjen skal du bruge `omarchy setup input mozc`, `hangul`, `pinyin` eller `chewing`. Dine brugerdefinerede skiftetaster bevares. Til alternative motorlayouts eller taster skal du installere `fcitx5-configtool` med `omarchy pkg add fcitx5-configtool` og starte den fra en terminal. At vælge et inputsprog ændrer ikke skrivebordssproget.

Brug `Super + I` til at cykle gennem inputmetoder eller tastaturlayouts og `Super + Shift + I` til at gå den anden vej tilbage, så med tre konfigurerede kan du bevæge dig mellem to naboer. Inputindikatoren vises kun til højre i linjen, når mere end én inputmetode eller ét layout er konfigureret. Denne skrivebordsbinding fungerer sammen med dine eksisterende Fcitx-skiftetaster; du kan tilsidesætte den i `~/.config/hypr/bindings.lua`. Inputmotorer og compose-sekvenserne bruger tjenesten [Fcitx5](https://fcitx-im.org/), der allerede kører i hver session.

### Brug ALT som SUPER

På nogle tastaturer er det ikke praktisk at bruge den primære metatast (Windows/cmd-tasten) som SUPER. Du kan ændre dette til i stedet at være ALT ved hjælp af denne ændring:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
