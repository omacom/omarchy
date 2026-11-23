# Hurtigtaster

Du kan se alle de viktigste tastaturbindingene med `Super + K` (Tmux-bindinger med `Super + Alt + K` og Herdr-bindinger med `Super + Ctrl + K`).

## Hvordan hurtigtaster er lagt ut

Hver hurtigtast ligger på et plan, bestemt av modifikatorene, og hvert plan har én jobb. Det er det som hindrer hurtigtastene i å flyte over i hverandre, og det betyr at du som regel kan gjette hvor noe hører hjemme.

| Plan | Hva som bor der | Eksempler |
| --- | --- | --- |
| `Super + key` | Systemet: vinduer, arbeidsområder, oppsett og kjernemenyer | `Super + Space` Omarchy-meny, `Super + W` lukk vindu, `Super + F` fullskjerm |
| `Super + Shift + key` | Apper | `Super + Shift + B` nettleser, `Super + Shift + E` e-post, `Super + Shift + N` tekstredigering |
| `Super + Ctrl + key` | Paneler og systemmenyer | `Super + Ctrl + A` lyd, `Super + Ctrl + N` nettverk, `Super + Ctrl + C` opptaksmeny |
| `Super + Ctrl + Alt + key` | Hurtighandlinger og beskjeder | `Super + Ctrl + Alt + T` vis klokkeslett, `Super + Ctrl + Alt + B` batteri, `Super + Ctrl + Alt + C` skjermbilde |

Å legge til `Alt` i en hurtigtast gir deg en variant av det samme, aldri noe helt annet:

- `Super + Shift + B` åpner nettleseren; `Super + Shift + Alt + B` åpner et privat vindu
- `Super + Shift + E` åpner e-post; `Super + Shift + Alt + E` starter en ny en
- `Super + F` går til fullskjerm; `Super + Alt + F` går til full bredde
- `Super + Ctrl + C` åpner opptaksmenyen; `Super + Ctrl + Alt + C` hopper over menyen og tar et skjermbilde

Når du legger til en hurtigtast:

1. Velg planet ut fra hva den gjør, og velg deretter tasten.
2. Ikke flytt en eksisterende hurtigtast for å lage plass. Finn en ledig tast på riktig plan.
3. Bruk `Alt` bare for en variant av hurtigtasten uten den.

Noen få hurtigtaster bryter disse reglene fordi det er praktisk. `Shift` med en piltast eller `Tab` flytter eller reverserer i stedet for å åpne en app, og `Print`, medietastene, `Alt + Tab` og `Ctrl + Alt + Del` fungerer slik de gjør overalt ellers. De er unntak, ikke mønstre du skal kopiere.

Hvis en standard ikke passer deg (for eksempel at du vil ha `Super + Shift + S` for skjermbilder som på Windows), binder du den på nytt i `~/.config/hypr/bindings.lua`.

## Navigering

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-meny (apper og alt annet)    |
| `Super + Alt + Space` | Apprutenett |
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
| `Super + O`               | Veksle å sprette vindu ut til klebrig og flytende |
| `Super + L`               | Bla gjennom oppsettene dwindle, scrolling og floating |
| `Super + Alt + L`         | Bla gjennom oppsettene i motsatt rekkefølge |
| `Super + P`               | Veksle pseudo-vindusstil (naturlig mot strukket) |
| `Super + F`                 | Gå til fullskjerm              |
| `Super + Alt + F`                 | Gå til full bredde              |
| `Super + Ctrl + F`                 | Gå til fullskjerm inne i vinduet              |
| `Super + 1…9/0`         | Hopp til bestemt arbeidsområde (0 er 10) på skjermen som har fokus |
| `Super + Tab` | Hopp til neste arbeidsområde på skjermen som har fokus |
| `Super + Shift + Tab` | Hopp til forrige arbeidsområde på skjermen som har fokus |
| `Super + Ctrl + Tab` | Hopp til tidligere arbeidsområde på skjermen som har fokus |
| `Super + Shift + 1…9/0` | Flytt vindu til arbeidsområde på skjermen som har fokus |
| `Super + Shift + Alt + 1…9/0` | Flytt vindu til arbeidsområde på skjermen som har fokus uten å følge etter |
| `Super + S` | Veksle full scratchpad |
| `Super + Alt + S` | Flytt vindu til full scratchpad |
| `Super + Grave` | Veksle Quake-konsoll |
| `Super + Shift + Grave` | Flytt vindu til Quake-konsoll |
| `Super + Shift + Ctrl + Arrows` | Flytt vindu til skjermen i den retningen |
| `Super + Shift + Alt + Arrows` | Flytt arbeidsområde til skjermen i den retningen |
| `Super + Arrow`  | Flytt fokus til vindu i piltastens retning, og kryss til skjermen på den siden ved skjermkanten |
| `Super + Shift + Arrow`  | Bytt vindu med et annet i piltastens retning, inkludert ett på skjermen på den siden |
| `Super + Minus` | Utvid vindu til venstre |
| `Super + Equal` | Krymp vindu til venstre |
| `Super + Shift + Minus` | Krymp vindu oppover |
| `Super + Shift + Equal` | Utvid vindu nedover |
| `Super + Alt + Minus/Equal` | Samme endring av størrelse i mindre trinn |
| `Super + Ctrl + Minus/Equal` | Samme endring av størrelse i større trinn |
| `Super + Alt + Home` | Lagre vindusbredde |
| `Super + Home` | Gjenopprett lagret vindusbredde |
| `Super + Left Mouse` | Dra vindu rundt |
| `Super + Right Mouse` | Endre størrelse på vindu |
| `Super + Scroll Wheel` | Rull gjennom arbeidsområder på skjermen som har fokus |
| `Super + G`               | Veksle vindusgruppering      |
| `Super + Alt + G`               | Flytt vindu ut av gruppering      |
| `Super + Alt + Tab`               | Bla mellom vinduer i gruppering      |
| `Super + Alt + Shift + Tab`               | Bla bakover mellom vinduer i gruppering      |
| `Super + Alt + Scroll Wheel` | Bla mellom vinduer i gruppering |
| `Super + Alt + 1/2/3/4/5`               | Hopp til bestemt vindu i gruppering      |
| `Super + Alt + Arrow`  | Flytt vindu inn i gruppering i piltastens retning, inkludert ett på skjermen på den siden |
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

Hurtigtaster for størrelse bruker de fysiske tastene `code:20` og `code:21` (XKB `<AE11>` og `<AE12>`), uansett hvilke tegn som er trykt på tastaturet. På amerikanske tastaturer er disse tastene `-` og `=`; på japanske (JIS) tastaturer er de `-` og `^`; på spanske tastaturer er de `'` og `¡`. På JIS er `Super + ^` det samme som `Super + Equal`, mens `Super + Shift + -` (som skriver `=`) er `Super + Shift + Minus`.

## Systemkontroller

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Lydpanel    |
| `Super + Ctrl + B`           | Bluetooth-panel    |
| `Super + Ctrl + N`           | Wifi/nettverkspanel    |
| `Super + Ctrl + D`           | Skjermpanel    |
| `Super + Ctrl + P`           | Strømpanel    |
| `Super + Ctrl + X`           | Agentpanel    |
| `Super + Ctrl + Alt + X`           | Panel for lokale modeller    |
| `Super + Ctrl + Alt + D`           | Kalenderpanel    |
| `Super + Ctrl + Alt + E`           | Verdensklokkepanel    |
| `Super + Ctrl + 1-9`           | Veksle panel på linjen etter posisjon    |
| `Super + Ctrl + S` | Delingsmeny (via LocalSend) |
| `Super + Ctrl + C` | Opptakskontroller (skjermbilde/-opptak/velger) |
| `Super + Ctrl + O` | Veksle meny |
| `Super + Ctrl + H` | Maskinvaremeny |
| `Super + Ctrl + E` | Emoji-velger |
| `Super + Ctrl + .` | Transkod medier |
| `Super + Shift + Ctrl + A` | Start standardagenten din |
| `Power` key | Systemmeny |
| `Super + Shift + Copilot` key | Omarchy-meny |

## Justeringer

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimal skjermlysstyrke |
| `Shift + Brightness Down` | Minimal skjermlysstyrke |
| `Alt + Brightness Up/Down` | Presise endringer i lysstyrke på 1 % |
| `Alt + Volume Up/Down` | Presise endringer i volum på 1 % |
| `Keyboard Brightness Up/Down` | Tastaturbaklys lysere/dempet |
| `Keyboard Backlight` | Bla gjennom nivåene for tastaturbaklys |
| `Ctrl + Brightness Up/Down` | Tastaturbaklys lysere/dempet, på tastaturer uten egne taster |
| `Mic Mute` | Demp mikrofonen |
| `Shift + Mute` | Bytt lydutgang |
| `Touchpad Toggle` | Slå styreflaten på eller av |
| `Display` key | Bla gjennom arbeidsområdeoppsettet |
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
| `Super + Shift + N`           | Tekstredigering (Plain, eller den du har valgt som standard)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-post ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Ny e-post ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Standardagenten din, eller ChatGPT til du velger en |
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

Vanligvis på Linux må du bruke `Ctrl + Shift + C/V` for å kopiere og lime inn i terminalen og `Ctrl + C/V` for å gjøre det overalt ellers. Disse enhetlige hurtigtastene for utklippstavlen i Omarchy fungerer overalt.

## Opptak

| Hurtigtast              | Funksjon                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skjermbilde                      |
| `Super + Ctrl + Alt + C`            | Skjermbilde (samme bilde, for tastaturer uten Print Screen-tast) |
| `Super + Ctrl + C` | Opptaksmeny |
| `Alt + Print Screen`            | Skjermopptak                     |
| `Super + Shift + Ctrl + Alt + C` | Skjermopptak uten lyd, uten menyen (trykk igjen for å stoppe) |
| `Super + Print Screen` | Fargevelger |
| `Super + Ctrl + Print Screen` | Tekstuttrekk til utklippstavlen |
| `Super + Alt + [` | Gjør webkameraoverlegget mindre under opptak |
| `Super + Alt + ]` | Gjør webkameraoverlegget større under opptak |
| `Alt + Shift + L` | Kopier gjeldende URL fra webapp eller nettleser |
| `Alt + Shift + D` | Last ned videoen på gjeldende side til `~/Videos` |
| `Alt + Space` | Start/stopp diktering (krever _Setup > Defaults > Dictation_) |
| `Right Alt` | Hold inne for å diktere (krever _Setup > Defaults > Dictation_) |

Med skjermopptak spør hurtigtasten først hvilken lyd du vil ha, og starter deretter opptaket. Trykk den igjen for å stoppe. Se [skjermbilder og opptak](12-screenshots-recording.md) for detaljene.

Alle opptaksalternativer er også tilgjengelige under _Trigger > Capture_ i Omarchy-menyen (`Super + Space`).

## Varsler

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + ,` | Handle nyeste varsel: åpne det eller trykk på den eneste knappen, velg blant valgene, eller avvis det når det ikke har noen  |
| `Super + Shift + ,` | Avvis alle varsler |
| `Super + Ctrl + ,` | Kontroller varsler med tastaturet  |
| `Super + Alt + ,` | Avvis nyeste varsel  |
| `Super + Shift + Alt + ,` | Åpne varselhistorikk  |
| `Super + Ctrl + Alt + ,` | Veksle demping av varsler  |

## Stil

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Velg et nytt tema (også `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Velg temabakgrunn (også `Super + Ctrl + Space`) |
| `Super + Backspace` | Veksle gjennomsiktighet på et vindu |
| `Super + Ctrl + Backspace` | Veksle kvadratisk format for enkeltvindu |

Ekstra bakgrunnsbilder ligger i `~/.config/omarchy/backgrounds/<theme name>`. Også tilgjengelig via _Install > Style > Background_ i Omarchy-menyen.

Alle stilalternativer er også tilgjengelige under _Appearance_ i Omarchy-menyen (`Super + Space`).

## Veksler

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Veksle låsing ved inaktivitet |
| `Super + Ctrl + Delete` | Slå bærbar-skjerm på/av |
| `Super + Ctrl + Alt + Delete` | Veksle speiling av bærbar-skjerm |
| `Super + Shift + Space` | Veksle topplinjen  |
| `Shift + Mute` | Bytt til neste lydutgang |
| `Shift + Play` | Bytt til neste mediekilde |
| `Super + Shift + Backspace` | Veksle vindusavstand |
| `Super + Ctrl + Alt + F` | Veksle fullskjermsskrivebord (topplinje + vindusavstand) |

## Påminnelser

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Angi en påminnelse  |
| `Super + Ctrl + Alt + R` | Se alle påminnelser  |
| `Super + Ctrl + Shift + R` | Tøm alle påminnelser  |

## Beskjeder

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
| `Alt + 1-9` | Gå til bestemt vindu |
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

### Kopimodus (vi-stil)

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Prefix + [` | Gå inn i kopimodus |
| `v` | Begynn markering (i kopimodus) |
| `y` | Kopier markering (i kopimodus) |

### Generelt

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Prefix + q` | Last konfigurasjon på nytt |
| `Prefix + ?` | Vis Tmux-tastebindinger |
| `Prefix + :` | Kommandolinje |

### Tmux-oppsettfunksjoner

Disse funksjonene må kjøres inne i en Tmux-økt.

| Kommando | Funksjon |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Opprett utvikleroppsett med tekstredigering, AI og terminal |
| `tdlm <ai> [<second_ai>]` | Opprett utvikleroppsett per undermappe |
| `tsl <count> <command>` | Opprett svermoppsett med flere ruter |

## Ghostty-terminal

Ghostty-terminal installeres med _Install > Terminal_ via Omarchy-menyen.

| Hurtigtast                  | Funksjon              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ny deling under |
| `Ctrl + Shift + O` | Ny deling ved siden av |
| `Ctrl + Alt + Arrows` | Flytt mellom delinger |
| `Super + Ctrl + Shift + Arrows` | Endre deling med 10 linjer |
| `Super + Ctrl + Shift + Alt + Arrows` | Endre deling med 100 linjer |
| `Ctrl + Shift + T` | Ny fane  |
| `Ctrl + Shift + Arrows` | Flytt mellom faner |
| `Alt + Numbers` | Gå til bestemt fane |
| `Shift + Pg Up/Down` | Rull i historikken |
| `Ctrl + Left mouse` | Åpne lenke i nettleser |

## Filbehandler

| Hurtigtast              | Funksjon                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Gå til sti                     |
| `Space`               | Forhåndsvis fil (piltaster navigerer) |
| `Alt + Up`       | Gå opp til overordnet mappe        |

## Neovim (med lazyvim)

### Navigasjon

| Hurtigtast                   | Funksjon                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Vis kommandoalternativer            |
| `Space Space`              | Åpne fil via fuzzy-søk      |
| `Space E`                  | Veksle sidepanel                  |
| `Space G G`                | Vis git-kontroller               |
| `Space S G`                | Søk i filinnhold             |
| `Ctrl + W W`               | Hopp mellom sidepanel og redigering |
| `Ctrl + Left/right arrow`  | Endre størrelse på sidepanel          |
| `Shift + H`                      | Gå til filfane til venstre             |
| `Shift + L`                      | Gå til filfane til høyre            |
| `Space B D`                | Lukk filfane                  |

### I sidepanelet

| Hurtigtast                   | Funksjon                        |
| ------------------------ | ------------------------------- |
| `A`                        | Legg til ny fil i overordnet mappe      |
| `Shift + A`                | Legg til ny undermappe i overordnet mappe    |
| `D`                        | Slett markert fil/mappe     |
| `M`                        | Flytt markert fil/mappe       |
| `R`                        | Gi markert fil/mappe nytt navn     |
| `?`                        | Vis hjelp for alle kommandoer      |

[Se alle Neovim-hurtigtastene som er konfigurert av LazyVim](https://www.lazyvim.org/keymaps).

## Hurtig-emojier

Du kan bruke `Super + Ctrl + E` for å vise en komplett emoji-velger som legger valget på utklippstavlen, eller du kan bruke disse hurtigvalgene.

| Hurtigtast       | EM | Hint       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smil      |
| `Shift + CapsLock M C` | 😂 | gråt        |
| `Shift + CapsLock M L` | 😍 | elsk       |
| `Shift + CapsLock M V` | ✌️ | seier    |
| `Shift + CapsLock M H` | ❤️ | hjerte      |
| `Shift + CapsLock M Y` | 👍 | ja        |
| `Shift + CapsLock M N` | 👎 | nei         |
| `Shift + CapsLock M F` | 🖕 | faen       |
| `Shift + CapsLock M W` | 🤞 | ønske       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | kyss       |
| `Shift + CapsLock M E` | 🙄 | øyerulling    |
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

## Hurtigfullføringer

| Hurtigtast       | Fullføring       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (lang tankestrek)   |
| `Shift + CapsLock Space N` | Navnet ditt (som angitt under oppsettet)  |
| `Shift + CapsLock Space E` | E-postadressen din (som angitt under oppsettet)  |

Du kan legge til flere selv ved å redigere `~/.XCompose`, og deretter kjøre `omarchy restart xcompose` i terminalen for å få endringene plukket opp.
