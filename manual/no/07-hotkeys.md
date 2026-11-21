# Hurtigtaster

Du kan se alle de viktigste tastebindingene med `Super + K` (Tmux-bindinger med `Super + Alt + K` og Herdr-bindinger med `Super + Ctrl + K`).

## Slik er hurtigtastene lagt opp

Hver hurtigtast sitter på et plan, bestemt av modifikatorene, og hvert plan har én jobb. Det er det som holder hurtigtastene fra å flyte sammen, og det betyr at du som regel kan gjette hvor noe hører hjemme.

| Plan | Hva som hører hjemme der | Eksempler |
| --- | --- | --- |
| `Super + key` | Systemet: vinduer, arbeidsområder, layouter og kjernemenyer | `Super + Space` Omarchy-meny, `Super + W` lukk vindu, `Super + F` fullskjerm |
| `Super + Shift + key` | Apper | `Super + Shift + B` nettleser, `Super + Shift + E` e-post, `Super + Shift + N` redigerer |
| `Super + Ctrl + key` | Paneler og systemmenyer | `Super + Ctrl + A` lyd, `Super + Ctrl + N` nettverk, `Super + Ctrl + C` fangstmeny |
| `Super + Ctrl + Alt + key` | Raske handlinger og merknader | `Super + Ctrl + Alt + T` vis klokkeslett, `Super + Ctrl + Alt + B` batteri, `Super + Ctrl + Alt + C` skjermbilde |

Å legge til `Alt` i en hurtigtast gir deg en variant av det samme, aldri noe helt annet:

- `Super + Shift + B` åpner nettleseren; `Super + Shift + Alt + B` åpner et privat vindu
- `Super + Shift + E` åpner e-post; `Super + Shift + Alt + E` starter en ny en
- `Super + F` går til fullskjerm; `Super + Alt + F` går til full bredde
- `Super + Ctrl + C` åpner fangstmenyen; `Super + Ctrl + Alt + C` hopper over menyen og tar et skjermbilde

Når du legger til en hurtigtast:

1. Velg planet ut fra hva den gjør, og velg deretter tasten.
2. Ikke flytt en eksisterende hurtigtast for å gjøre plass. Finn en ledig tast på riktig plan.
3. Bruk bare `Alt` for en variant av hurtigtasten uten den.

Noen få hurtigtaster bryter disse reglene fordi de er praktiske. `Shift` med en pil eller `Tab` flytter eller reverserer i stedet for å åpne en app, og `Print`, medietastene, `Alt + Tab` og `Ctrl + Alt + Del` fungerer slik de gjør alle andre steder. De er unntak, ikke mønstre du skal kopiere.

Hvis en standard ikke passer deg (for eksempel hvis du vil ha `Super + Shift + S` for skjermbilder som på Windows), binder du den på nytt i `~/.config/hypr/bindings.lua`.

## Navigering

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-meny (apper og alt annet)    |
| `Super + Alt + Space` | Appoversikt |
| `Super + Escape` | Systemmeny (hvilemodus, omstart osv.)  |
| `Super + Ctrl + L` | Lås datamaskinen |
| `Super + W` or `Super + Q` | Lukk vindu             |
| `Ctrl + Alt + Del` | Lukk alle vinduer |
| `Super + K` | Vis alle hurtigtaster |
| `Super + Alt + K` | Vis tmux-hurtigtaster |
| `Super + Ctrl + K` | Vis herdr-hurtigtaster |
| `Super + M` | Minimer vindu til dokken |
| `Super + T`               | Veksle vindu mellom flislagt/flytende             |
| `Super + J` | Veksle vindusposisjon (vannrett/loddrett) |
| `Super + O`               | Veksle vindu som spretter ut til sticky'n'floating |
| `Super + L`               | Bla gjennom layoutene dwindle, scrolling og floating |
| `Super + Alt + L`         | Bla gjennom layoutene i motsatt rekkefølge |
| `Super + P`               | Veksle pseudo-vindusstil (natural v stretch) |
| `Super + F`                 | Gå til fullskjerm              |
| `Super + Alt + F`                 | Gå til full bredde              |
| `Super + Ctrl + F`                 | Gå til fullskjerm inne i vinduet              |
| `Super + 1…9/0`         | Hopp til et bestemt arbeidsområde (0 er 10) på skjermen i fokus |
| `Super + Tab` | Hopp til neste arbeidsområde på skjermen i fokus |
| `Super + Shift + Tab` | Hopp til forrige arbeidsområde på skjermen i fokus |
| `Super + Ctrl + Tab` | Hopp til tidligere arbeidsområde på skjermen i fokus |
| `Super + Shift + 1…9/0` | Flytt vindu til arbeidsområde på skjermen i fokus |
| `Super + Shift + Alt + 1…9/0` | Flytt vindu til arbeidsområde på skjermen i fokus uten å følge etter |
| `Super + S` | Veksle full scratchpad |
| `Super + Alt + S` | Flytt vindu til full scratchpad |
| `Super + Grave` | Veksle Quake-konsollen |
| `Super + Shift + Grave` | Flytt vindu til Quake-konsollen |
| `Super + Shift + Ctrl + Arrows` | Flytt vindu til skjermen i den retningen |
| `Super + Shift + Alt + Arrows` | Flytt arbeidsområde til skjermen i den retningen |
| `Super + Arrow`  | Flytt fokus til vindu i pilens retning, og kryss til skjermen på den siden ved skjermkanten |
| `Super + Shift + Arrow`  | Bytt vindu med et annet i pilens retning, inkludert et på skjermen på den siden |
| `Super + Minus` | Utvid vindu til venstre |
| `Super + Equal` | Krymp vindu til venstre |
| `Super + Shift + Minus` | Krymp vindu oppover |
| `Super + Shift + Equal` | Utvid vindu nedover |
| `Super + Alt + Minus/Equal` | Samme størrelsesendring i mindre trinn |
| `Super + Ctrl + Minus/Equal` | Samme størrelsesendring i større trinn |
| `Super + Alt + Home` | Lagre vindusbredde |
| `Super + Home` | Gjenopprett lagret vindusbredde |
| `Super + Left Mouse` | Dra vinduet rundt |
| `Super + Right Mouse` | Endre størrelse på vindu |
| `Super + Scroll Wheel` | Bla gjennom arbeidsområder på skjermen i fokus |
| `Super + G`               | Veksle vindusgruppering      |
| `Super + Alt + G`               | Flytt vindu ut av gruppering      |
| `Super + Alt + Tab`               | Bla mellom vinduer i gruppering      |
| `Super + Alt + Shift + Tab`               | Bla bakover mellom vinduer i gruppering      |
| `Super + Alt + Scroll Wheel` | Bla mellom vinduer i gruppering |
| `Super + Alt + 1/2/3/4/5`               | Hopp til et bestemt vindu i gruppering      |
| `Super + Alt + Arrow`  | Flytt vindu inn i gruppering i pilens retning, inkludert et på skjermen på den siden |
| `Super + Ctrl + Left/Right`  | Flytt mellom vinduer inne i en flisleggingsgruppe |
| `Super + Ctrl + Z` | Zoom inn på skjermen (gjenta for mer zoom) |
| `Super + Ctrl + Alt + Z` | Zoom helt ut fra skjermen |
| `Super + /` | Gå fremover gjennom alternativer for skjermskalering |
| `Super + Alt + /` | Gå bakover gjennom alternativer for skjermskalering |
| `Alt + Tab` | Bla fremover gjennom vinduer på det aktive arbeidsområdet |
| `Alt + Shift + Tab` | Bla bakover gjennom vinduer på det aktive arbeidsområdet |
| `Ctrl + Alt + Tab`| Bla fokus fremover gjennom skjermer |
| `Ctrl + Alt + Shift + Tab`| Bla fokus bakover gjennom skjermer |
| `Super + I` | Bytt inndataspråk (med mer enn ett oppsett eller én inndatametode) |
| `Super + Shift + I` | Bytt inndataspråk tilbake |

På en styreflate bytter sveip med tre og fire fingre arbeidsområder, flytter vinduer og åpner menyen og Quake-konsollen; se [tastatur, mus og styreflate](34-keyboard-mouse-trackpad.md) for bevegelsene.

Hurtigtaster for størrelsesendring bruker de fysiske tastene `code:20` og `code:21` (XKB `<AE11>` og `<AE12>`), uansett hvilke tegn som er trykt på tastaturet. På amerikanske tastaturer er disse tastene `-` og `=`; på japanske (JIS) tastaturer er de `-` og `^`; på spanske tastaturer er de `'` og `¡`. På JIS er `Super + ^` det samme som `Super + Equal`, mens `Super + Shift + -` (som skriver `=`) er `Super + Shift + Minus`.

## Systemkontroller

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Lydpanel    |
| `Super + Ctrl + B`           | Bluetooth-panel    |
| `Super + Ctrl + N`           | Wi-Fi/nettverkspanel    |
| `Super + Ctrl + D`           | Skjermpanel    |
| `Super + Ctrl + P`           | Strømpanel    |
| `Super + Ctrl + X`           | Agentpanel    |
| `Super + Ctrl + Alt + D`           | Kalenderpanel    |
| `Super + Ctrl + Alt + E`           | Verdensklokkepanel    |
| `Super + Ctrl + 1-9`           | Veksle panelet i linjen etter posisjon    |
| `Super + Ctrl + S` | Delemeny (via LocalSend) |
| `Super + Ctrl + C` | Fangstkontroller (skjermbilde/-opptak/velger) |
| `Super + Ctrl + O` | Veksle meny |
| `Super + Ctrl + H` | Maskinvaremeny |
| `Super + Ctrl + E` | Emoji-velger |
| `Super + Ctrl + .` | Transkod medier |
| `Super + Shift + Ctrl + A` | Velg en AI-agent |
| `Power` key | Systemmeny |
| `Super + Shift + Copilot` key | Omarchy-meny |

## Justeringer

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimal skjermlysstyrke |
| `Shift + Brightness Down` | Minimal skjermlysstyrke |
| `Alt + Brightness Up/Down` | Presise endringer i lysstyrke på 1 % |
| `Alt + Volume Up/Down` | Presise endringer i volum på 1 % |
| `Keyboard Brightness Up/Down` | Tastaturets bakgrunnsbelysning lysere/dempere |
| `Keyboard Backlight` | Bla gjennom nivåene for tastaturets bakgrunnsbelysning |
| `Ctrl + Brightness Up/Down` | Tastaturets bakgrunnsbelysning lysere/dempere, på tastaturer uten egne taster |
| `Mic Mute` | Demp mikrofonen |
| `Shift + Mute` | Bytt lydutgang |
| `Touchpad Toggle` | Slå styreflaten av eller på |
| `Display` key | Bla gjennom arbeidsområdelayouten |
| `Alt + Play` | Neste spor |
| `Alt + Shift + Play` | Forrige spor |

## Starte apper

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agentbehandler) |
| `Super + Shift + Return` or `Super + Shift + B`  | Nettleser    |
| `Super + Shift + Alt + B`           | Nettleser (privat/inkognito)    |
| `Super + Shift + F`           | Filbehandler    |
| `Super + Shift + Alt + F`           | Filbehandler i terminalens cwd    |
| `Super + Shift + M`           | Musikk (Spotify)    |
| `Super + Shift + Alt + M`           | Musikk (cliamp)    |
| `Super + Shift + /`           | Passordbehandler (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, når den er installert)    |
| `Super + Shift + T`           | Aktivitet (btop)    |
| `Super + Shift + N`           | Redigerer (Plain, eller den du har valgt som standard)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-post ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Ny e-post ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Meldinger (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Meldinger (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Meldinger (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Skriving (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nytt innlegg) |
| `Super + Shift + Y`           | YouTube |

Endre/legg til bindinger i `~/.config/hypr/bindings.lua`.

## Universell utklippstavle

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + A`           | Velg alt i apper som støtter `Ctrl + A`    |
| `Super + C`           | Kopier    |
| `Super + X`           | Klipp ut (ikke i terminal)    |
| `Super + V`           | Lim inn    |
| `Super + Ctrl + V`           | Utklippstavlebehandler    |

Vanligvis på Linux trenger du `Ctrl + Shift + C/V` for å kopiere og lime inn i terminalen og `Ctrl + C/V` for å gjøre det alle andre steder. Disse enhetlige hurtigtastene for utklippstavlen i Omarchy fungerer overalt.

## Fangst

| Hurtigtast              | Funksjon                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skjermbilde                      |
| `Super + Ctrl + Alt + C`            | Skjermbilde (samme opptak, for tastaturer uten Print Screen-tast) |
| `Super + Ctrl + C` | Fangstmeny |
| `Alt + Print Screen`            | Skjermopptak                     |
| `Super + Shift + Ctrl + Alt + C` | Skjermopptak uten lyd, hopp over menyen (trykk igjen for å stoppe) |
| `Super + Print Screen` | Fargevelger |
| `Super + Ctrl + Print Screen` | Tekstuttrekk til utklippstavlen |
| `Super + Alt + [` | Gjør webkameraoverlegget mindre under opptak |
| `Super + Alt + ]` | Gjør webkameraoverlegget større under opptak |
| `Alt + Shift + L` | Kopier gjeldende URL fra webapp eller nettleser |
| `Alt + Shift + D` | Last ned videoen på gjeldende side til `~/Videos` |
| `Alt + Space` | Start/stopp diktering (krever _Oppsett > Standarder > Diktering_) |
| `Right Alt` | Hold for å diktere (krever _Oppsett > Standarder > Diktering_) |

Med skjermopptak spør hurtigtasten først hvilken lyd du vil ha, og starter deretter opptaket. Trykk den igjen for å stoppe. Se [skjermbilder og opptak](12-screenshots-recording.md) for detaljene.

Alle fangstalternativene er også tilgjengelige under _Utløser > Fangst_ i Omarchy-menyen (`Super + Space`).

## Varsler

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + ,` | Handle på siste varsel: åpne det eller trykk på den eneste knappen, velg blant valgene, eller avvis det når det ikke har noen  |
| `Super + Shift + ,` | Avvis alle varsler |
| `Super + Ctrl + ,` | Styr varsler med tastaturet  |
| `Super + Alt + ,` | Avvis siste varsel  |
| `Super + Shift + Alt + ,` | Åpne varselhistorikk  |
| `Super + Ctrl + Alt + ,` | Veksle demping av varsler  |

## Stil

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Velg et nytt tema (også `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Velg temabakgrunn (også `Super + Ctrl + Space`) |
| `Super + Backspace` | Veksle gjennomsiktighet på et vindu |
| `Super + Ctrl + Backspace` | Veksle kvadratisk format for enkeltvindu |

Ekstra bakgrunnsbilder ligger i `~/.config/omarchy/backgrounds/<theme name>`. Også tilgjengelig via _Installer > Stil > Bakgrunn_ i Omarchy-menyen.

Alle stilalternativene er også tilgjengelige under _Utseende_ i Omarchy-menyen (`Super + Space`).

## Brytere

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Veksle låsing ved inaktivitet |
| `Super + Ctrl + Delete` | Slå den bærbare skjermen av/på |
| `Super + Ctrl + Alt + Delete` | Veksle speiling av den bærbare skjermen |
| `Super + Shift + Space` | Veksle topplinjen  |
| `Shift + Mute` | Bytt til neste lydutgang |
| `Shift + Play` | Bytt til neste mediekilde |
| `Super + Shift + Backspace` | Veksle vindusavstand |
| `Super + Ctrl + Alt + F` | Veksle fullskjermsskrivebord (topplinje + vindusavstand) |

## Påminnelser

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Sett en påminnelse  |
| `Super + Ctrl + Alt + R` | Se alle påminnelser  |
| `Super + Ctrl + Shift + R` | Fjern alle påminnelser  |

## Merknader

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vis klokkeslett som varsel  |
| `Super + Ctrl + Alt + B` | Vis batteri som varsel  |
| `Super + Ctrl + Alt + W` | Veksle vær som varsel  |

## Tmux

Prefikstasten er `Ctrl + Space` (`Ctrl + B` fungerer også). Du kan endre disse bindingene i `~/.config/tmux/tmux.conf`.

### Ruter

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Prefix + v` | Del rute ved siden av (loddrett) |
| `Prefix + h` | Del rute under (vannrett) |
| `Prefix + x` | Avslutt rute |
| `Prefix + z` | Veksle rutezoom (fullskjerm) |
| `Alt + Enter` | Del rute under (uten prefiks) |
| `Alt + Shift + Enter` | Del rute ved siden av (uten prefiks) |
| `Alt + Escape` | Avslutt rute (uten prefiks) |
| `Ctrl + Alt + Arrows` | Flytt mellom ruter |
| `Ctrl + Alt + Shift + Arrows` | Endre størrelse på ruter |

### Vinduer

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nytt vindu |
| `Prefix + k` | Avslutt vindu |
| `Prefix + r` | Gi vindu nytt navn |
| `Alt + 1-9` | Gå til et bestemt vindu |
| `Alt + Arrow Left/Right` | Flytt mellom vinduer |
| `Alt + Shift + Arrow Left/Right` | Flytt vindu til venstre/høyre |

### Økter

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Prefix + C` | Ny økt |
| `Prefix + K` | Avslutt økt |
| `Prefix + R` | Gi økt nytt navn |
| `Prefix + N` | Neste økt |
| `Prefix + P` | Forrige økt |
| `Alt + Arrow Up/Down` | Flytt mellom økter |
| `Prefix + s` | List økter |
| `Prefix + d` | Koble fra økt |

### Kopieringsmodus (vi-stil)

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Prefix + [` | Gå inn i kopieringsmodus |
| `v` | Start markering (i kopieringsmodus) |
| `y` | Kopier markering (i kopieringsmodus) |

### Generelt

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Prefix + q` | Last konfigurasjon på nytt |
| `Prefix + ?` | Vis Tmux-tastebindinger |
| `Prefix + :` | Ledetekst |

### Tmux-layoutfunksjoner

Disse funksjonene må kjøres inne i en Tmux-økt.

| Kommando | Funksjon |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Lag utviklerlayout med redigerer, AI og terminal |
| `tdlm <ai> [<second_ai>]` | Lag utviklerlayout per undermappe |
| `tsl <count> <command>` | Lag svermlayout med flere ruter |

## Ghostty-terminal

Ghostty-terminalen installeres med _Installer > Terminal_ via Omarchy-menyen.

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ny deling under |
| `Ctrl + Shift + O` | Ny deling ved siden av |
| `Ctrl + Alt + Arrows` | Flytt mellom delinger |
| `Super + Ctrl + Shift + Arrows` | Endre deling med 10 linjer |
| `Super + Ctrl + Shift + Alt + Arrows` | Endre deling med 100 linjer |
| `Ctrl + Shift + T` | Ny fane  |
| `Ctrl + Shift + Arrows` | Flytt mellom faner |
| `Alt + Numbers` | Gå til en bestemt fane |
| `Shift + Pg Up/Down` | Bla i historikken |
| `Ctrl + Left mouse` | Åpne lenke i nettleser |

## Filbehandler

| Hurtigtast              | Funksjon                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Gå til sti                     |
| `Space`               | Forhåndsvis fil (piler navigerer) |
| `Alt + Up`       | Gå opp til overordnet mappe        |

## Neovim (w/ lazyvim)

### Navigasjon

| Hurtigtast                   | Funksjon                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Vis kommandoalternativer            |
| `Space Space`              | Åpne fil via fuzzysøk      |
| `Space E`                  | Veksle sidepanel                  |
| `Space G G`                | Vis git-kontroller               |
| `Space S G`                | Søk i filinnhold             |
| `Ctrl + W W`               | Hopp mellom sidepanel og redigerer |
| `Ctrl + Left/right arrow`  | Endre størrelse på sidepanel          |
| `Shift + H`                      | Gå til filfanen til venstre             |
| `Shift + L`                      | Gå til filfanen til høyre            |
| `Space B D`                | Lukk filfane                  |

### Mens du er i sidepanelet

| Hurtigtast                   | Funksjon                        |
| ------------------------ | ------------------------------- |
| `A`                        | Legg til ny fil i overordnet mappe      |
| `Shift + A`                | Legg til ny undermappe i overordnet mappe    |
| `D`                        | Slett uthevet fil/mappe     |
| `M`                        | Flytt uthevet fil/mappe       |
| `R`                        | Gi nytt navn til uthevet fil/mappe     |
| `?`                        | Vis hjelp for alle kommandoer      |

[Se alle Neovim-hurtigtastene som er konfigurert av LazyVim](https://www.lazyvim.org/keymaps).

## Raske emojier

Du kan bruke `Super + Ctrl + E` for å vise en komplett emoji-velger som legger valget på utklippstavlen, eller du kan bruke disse alternativene for rask tilgang.

| Hurtigtast       | EM | Stikkord       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smil      |
| `Shift + CapsLock M C` | 😂 | gråt        |
| `Shift + CapsLock M L` | 😍 | kjærlighet       |
| `Shift + CapsLock M V` | ✌️ | seier    |
| `Shift + CapsLock M H` | ❤️ | hjerte      |
| `Shift + CapsLock M Y` | 👍 | ja        |
| `Shift + CapsLock M N` | 👎 | nei         |
| `Shift + CapsLock M F` | 🖕 | faen       |
| `Shift + CapsLock M W` | 🤞 | ønske       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | kyss       |
| `Shift + CapsLock M E` | 🙄 | himling    |
| `Shift + CapsLock M I` | 😉 | blink       |
| `Shift + CapsLock M P` | 🙏 | be |
| `Shift + CapsLock M D` | 🤤 | sikle      |
| `Shift + CapsLock M M` | 💰 | penger      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | skål      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | hilsen |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | sprengt |

## Raske fullføringer

| Hurtigtast       | Fullføring       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (tankestrek)   |
| `Shift + CapsLock Space N` | Navnet ditt (som oppgitt under oppsettet)  |
| `Shift + CapsLock Space E` | E-postadressen din (som oppgitt under oppsettet)  |

Du kan legge til flere av dine egne ved å redigere `~/.XCompose` og deretter kjøre `omarchy restart xcompose` i terminalen for å få endringene plukket opp.
