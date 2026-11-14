# Hurtigtaster

Du kan se alle de viktigste tastaturbindingene med `Super + K` (Tmux-bindinger med `Super + Alt + K` og Herdr-bindinger med `Super + Ctrl + K`).

## Slik er hurtigtastene lagt opp

Hver hurtigtast ligger på et plan, bestemt av modifikatortastene, og hvert plan har én oppgave. Det er det som hindrer hurtigtastene i å flyte sammen, og det betyr at du som regel kan gjette hvor noe hører hjemme.

| Plan | Hva som hører hjemme der | Eksempler |
| --- | --- | --- |
| `Super + key` | Systemet: vinduer, arbeidsområder, oppsett og kjernemenyer | `Super + Space` Omarchy-meny, `Super + W` lukk vindu, `Super + F` fullskjerm |
| `Super + Shift + key` | Apper | `Super + Shift + B` nettleser, `Super + Shift + E` e-post, `Super + Shift + N` redigeringsprogram |
| `Super + Ctrl + key` | Paneler og systemmenyer | `Super + Ctrl + A` lyd, `Super + Ctrl + N` nettverk, `Super + Ctrl + C` opptaksmeny |
| `Super + Ctrl + Alt + key` | Hurtighandlinger og varsler | `Super + Ctrl + Alt + T` vis klokkeslett, `Super + Ctrl + Alt + B` batteri, `Super + Ctrl + Alt + C` skjermbilde |

Å legge til `Alt` på en hurtigtast gir deg en variant av det samme, aldri noe helt annet:

- `Super + Shift + B` åpner nettleseren; `Super + Shift + Alt + B` åpner et privat vindu
- `Super + Shift + E` åpner e-post; `Super + Shift + Alt + E` starter en ny en
- `Super + F` går til fullskjerm; `Super + Alt + F` går til full bredde
- `Super + Ctrl + C` åpner opptaksmenyen; `Super + Ctrl + Alt + C` hopper over menyen og tar et skjermbilde

Når du legger til en hurtigtast:

1. Velg planet ut fra hva den gjør, og velg deretter tasten.
2. Ikke flytt en eksisterende hurtigtast for å lage plass. Finn en ledig tast på riktig plan.
3. Bruk bare `Alt` for en variant av hurtigtasten uten den.

Noen få hurtigtaster bryter disse reglene fordi det er praktisk. `Shift` sammen med en pil eller `Tab` flytter eller reverserer i stedet for å åpne en app, og `Print`, mediatasteene, `Alt + Tab` og `Ctrl + Alt + Del` fungerer slik de gjør alle andre steder. De er unntak, ikke mønstre du skal kopiere.

Hvis en standard ikke passer deg (for eksempel at du vil ha `Super + Shift + S` for skjermbilder som på Windows), kan du binde den på nytt i `~/.config/hypr/bindings.lua`.

## Navigering

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-meny (apper og alt annet) |
| `Super + Alt + Space` | Appoversikt |
| `Super + Escape` | Systemmeny (hvilemodus, omstart osv.) |
| `Super + Ctrl + L` | Lås datamaskinen |
| `Super + W` or `Super + Q` | Lukk vindu |
| `Ctrl + Alt + Del` | Lukk alle vinduer |
| `Super + T` | Veksle vindu mellom flislagt/flytende |
| `Super + J` | Veksle vindusposisjon (vannrett/loddrett) |
| `Super + O` | Veksle vindu til sticky'n'floating |
| `Super + L` | Bla gjennom oppsettene dwindle, scrolling og floating |
| `Super + Alt + L` | Bla gjennom oppsettene i motsatt rekkefølge |
| `Super + P` | Veksle pseudo-vindusstil (naturlig mot strekk) |
| `Super + F` | Gå til fullskjerm |
| `Super + Alt + F` | Gå til full bredde |
| `Super + Ctrl + F` | Gå til fullskjerm inne i vindu |
| `Super + 1/2/3/4` | Hopp til bestemt arbeidsområde på den fokuserte skjermen |
| `Super + Tab` | Hopp til neste arbeidsområde på den fokuserte skjermen |
| `Super + Shift + Tab` | Hopp til forrige arbeidsområde på den fokuserte skjermen |
| `Super + Ctrl + Tab` | Hopp til tidligere arbeidsområde på den fokuserte skjermen |
| `Super + Shift + 1/2/3/4` | Flytt vindu til arbeidsområde på den fokuserte skjermen |
| `Super + Shift + Alt + 1/2/3/4` | Flytt vindu til arbeidsområde på den fokuserte skjermen uten å følge etter |
| `Super + S` | Veksle full scratchpad |
| `Super + Alt + S` | Flytt vindu til full scratchpad |
| `Super + Grave` | Veksle Quake-konsoll |
| `Super + Shift + Grave` | Flytt vindu til Quake-konsoll |
| `Super + Shift + Ctrl + Arrows` | Flytt vindu til skjermen i den retningen |
| `Super + Shift + Alt + Arrows` | Flytt arbeidsområde til skjermen i den retningen |
| `Super + Arrow` | Flytt fokus til vindu i pilens retning, og kryss til skjermen på den siden ved skjermkanten |
| `Super + Shift + Arrow` | Bytt vindu med et annet i pilens retning, inkludert et på skjermen på den siden |
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
| `Super + Scroll Wheel` | Rull gjennom arbeidsområder på den fokuserte skjermen |
| `Super + G` | Veksle vindusgruppering |
| `Super + Alt + G` | Flytt vindu ut av gruppering |
| `Super + Alt + Tab` | Bla mellom vinduer i gruppering |
| `Super + Alt + Shift + Tab` | Bla bakover mellom vinduer i gruppering |
| `Super + Alt + Scroll Wheel` | Bla mellom vinduer i gruppering |
| `Super + Alt + 1/2/3/4/5` | Hopp til bestemt vindu i gruppering |
| `Super + Alt + Arrow` | Flytt vindu inn i gruppering i pilens retning, inkludert et på skjermen på den siden |
| `Super + Ctrl + Left/Right` | Flytt mellom vinduer inne i en flisleggingsgruppe |
| `Super + Ctrl + Z` | Zoom inn på skjermen (gjenta for mer zoom) |
| `Super + Ctrl + Alt + Z` | Zoom helt ut fra skjermen |
| `Super + /` | Gå framover gjennom alternativer for skjermskalering |
| `Super + Alt + /` | Gå bakover gjennom alternativer for skjermskalering |
| `Alt + Tab` | Bla framover gjennom vinduer på det aktive arbeidsområdet |
| `Alt + Shift + Tab` | Bla bakover gjennom vinduer på det aktive arbeidsområdet |
| `Ctrl + Alt + Tab` | Bla fokus framover gjennom skjermer |
| `Ctrl + Alt + Shift + Tab` | Bla fokus bakover gjennom skjermer |

Snarveier for størrelsesendring bruker de fysiske tastene `code:20` og `code:21` (XKB `<AE11>` og `<AE12>`), uavhengig av tegnene som er trykt på tastaturet. På amerikanske tastaturer er disse tastene `-` og `=`; på japanske (JIS) tastaturer er de `-` og `^`; på spanske tastaturer er de `'` og `¡`. På JIS er `Super + ^` det samme som `Super + Equal`, mens `Super + Shift + -` (som skriver `=`) er `Super + Shift + Minus`.

## Systemkontroller

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Lydpanel |
| `Super + Ctrl + B` | Bluetooth-panel |
| `Super + Ctrl + N` | Wi-Fi-/nettverkspanel |
| `Super + Ctrl + D` | Skjermpanel |
| `Super + Ctrl + P` | Strømpanel |
| `Super + Ctrl + X` | Agentpanel |
| `Super + Ctrl + Alt + D` | Kalenderpanel |
| `Super + Ctrl + Alt + E` | Verdensklokkepanel |
| `Super + Ctrl + 1-9` | Veksle linjepanel etter posisjon |
| `Super + Ctrl + S` | Delingsmeny (via LocalSend) |
| `Super + Ctrl + C` | Opptakskontroller (skjermbilde/-opptak/velger) |
| `Super + Ctrl + O` | Vekslemeny |
| `Super + Ctrl + H` | Maskinvaremeny |
| `Super + Ctrl + E` | Emoji-velger |
| `Super + Ctrl + .` | Transkod medier |
| `Super + Shift + Ctrl + A` | Velg en AI-agent |

## Justeringer

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimal skjermlysstyrke |
| `Shift + Brightness Down` | Minimal skjermlysstyrke |
| `Alt + Brightness Up/Down` | Presise endringer av lysstyrke på 1 % |
| `Alt + Volume Up/Down` | Presise endringer av volum på 1 % |
| `Keyboard Brightness Up/Down` | Tastaturbaklys sterkere/svakere |
| `Keyboard Backlight` | Bla gjennom nivåene for tastaturbaklys |
| `Alt + Play` | Neste spor |
| `Alt + Shift + Play` | Forrige spor |

## Starte apper

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agentbehandler) |
| `Super + Shift + Return` | Nettleser |
| `Super + Shift + Alt + B` | Nettleser (privat/inkognito) |
| `Super + Shift + F` | Filbehandler |
| `Super + Shift + Alt + F` | Filbehandler i terminalens cwd |
| `Super + Shift + M` | Musikk (Spotify) |
| `Super + Shift + Alt + M` | Musikk (cliamp) |
| `Super + Shift + /` | Passordbehandler (1password) |
| `Super + Shift + Q` | Kalkulator (Omacalc) |
| `Super + Shift + T` | Aktivitet (btop) |
| `Super + Shift + N` | Redigeringsprogram (Neovim) |
| `Super + Shift + C` | Kalender ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-post ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Ny e-post ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Meldingstjeneste (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Meldingstjeneste (WhatsApp) |
| `Super + Shift + Ctrl + G` | Meldingstjeneste (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Skriving (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Endre/legg til bindinger i `~/.config/hypr/bindings.lua`.

## Universell utklippstavle

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Super + A` | Velg alt i apper som støtter `Ctrl + A` |
| `Super + C` | Kopier |
| `Super + X` | Klipp ut (ikke i terminal) |
| `Super + V` | Lim inn |
| `Super + Ctrl + V` | Utklippstavlebehandler |

Vanligvis på Linux må du bruke `Ctrl + Shift + C/V` for å kopiere og lime inn i terminalen og `Ctrl + C/V` for å gjøre det alle andre steder. Disse enhetlige hurtigtastene for utklippstavlen i Omarchy fungerer overalt.

## Opptak

| Hurtigtast | Funksjon |
| ------------------- | ------------------------------ |
| `Print Screen` | Skjermbilde |
| `Super + Ctrl + Alt + C` | Skjermbilde (samme bilde, for tastaturer uten Print Screen-tast) |
| `Super + Ctrl + C` | Opptaksmeny |
| `Alt + Print Screen` | Skjermopptak |
| `Super + Print Screen` | Fargevelger |
| `Super + Ctrl + Print Screen` | Tekstuttrekk til utklippstavlen |
| `Super + Alt + [` | Gjør webkameraoverlegget mindre under opptak |
| `Super + Alt + ]` | Gjør webkameraoverlegget større under opptak |
| `Alt + Shift + L` | Kopier gjeldende URL fra webapp eller nettleser |
| `Alt + Shift + D` | Last ned videoen på gjeldende side til `~/Videos` |
| `Alt + Space` | Start/stopp diktering (krever _Setup > Defaults > Dictation_) |
| `Right Alt` | Hold for å diktere (krever _Setup > Defaults > Dictation_) |

Med skjermopptak spør hurtigtasten først hvilken lyd du vil ha, og starter deretter opptaket. Trykk den igjen for å stoppe. Se [skjermbilder og opptak](12-screenshots-recording.md) for detaljene.

Alle opptaksalternativer er også tilgjengelige under _Trigger > Capture_ i Omarchy-menyen (`Super + Space`).

## Varsler

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Super + ,` | Handle på siste varsel: åpne det eller trykk på den eneste knappen, velg blant valgene, eller avvis det når det ikke har noen |
| `Super + Shift + ,` | Avvis alle varsler |
| `Super + Ctrl + ,` | Styr varsler med tastaturet |
| `Super + Alt + ,` | Avvis siste varsel |
| `Super + Shift + Alt + ,` | Åpne varselhistorikk |
| `Super + Ctrl + Alt + ,` | Veksle demping av varsler |

## Stil

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Velg et nytt tema (også `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Velg temabakgrunn (også `Super + Ctrl + Space`) |
| `Super + Backspace` | Veksle gjennomsiktighet på et vindu |
| `Super + Ctrl + Backspace` | Veksle kvadratisk format for enkeltvindu |

Ekstra bakgrunnsbilder ligger i `~/.config/omarchy/backgrounds/<theme name>`. Også tilgjengelig via _Install > Style > Background_ i Omarchy-menyen.

Alle stilalternativer er også tilgjengelige under _Style_ i Omarchy-menyen (`Super + Space`).

## Vekslinger

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Veksle låsing ved inaktivitet |
| `Super + Ctrl + Delete` | Veksle bærbar skjerm av/på |
| `Super + Ctrl + Alt + Delete` | Veksle speiling av bærbar skjerm |
| `Super + Shift + Space` | Veksle topplinjen |
| `Shift + Mute` | Bytt til neste lydutgang |
| `Shift + Play` | Bytt til neste mediekilde |
| `Super + Shift + Backspace` | Veksle avstand mellom vinduer |
| `Super + Ctrl + Alt + F` | Veksle fullskjermsskrivebord (topplinje + avstand mellom vinduer) |

## Påminnelser

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Sett en påminnelse |
| `Super + Ctrl + Alt + R` | Se alle påminnelser |
| `Super + Ctrl + Shift + R` | Fjern alle påminnelser |

## Meldinger

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vis klokkeslett som varsel |
| `Super + Ctrl + Alt + B` | Vis batteri som varsel |
| `Super + Ctrl + Alt + W` | Veksle vær som varsel |

## Tmux

Prefikstasten er `Ctrl + Space` (`Ctrl + B` fungerer også). Du kan endre disse bindingene i `~/.config/tmux/tmux.conf`.

### Ruter

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Prefix + v` | Del rute ved siden av (loddrett) |
| `Prefix + h` | Del rute under (vannrett) |
| `Prefix + x` | Lukk rute |
| `Prefix + z` | Veksle rutezoom (fullskjerm) |
| `Alt + Enter` | Del rute under (uten prefiks) |
| `Alt + Shift + Enter` | Del rute ved siden av (uten prefiks) |
| `Alt + Escape` | Lukk rute (uten prefiks) |
| `Ctrl + Alt + Arrows` | Flytt mellom ruter |
| `Ctrl + Alt + Shift + Arrows` | Endre størrelse på ruter |

### Vinduer

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Prefix + c` | Nytt vindu |
| `Prefix + k` | Lukk vindu |
| `Prefix + r` | Gi vindu nytt navn |
| `Alt + 1-9` | Gå til bestemt vindu |
| `Alt + Arrow Left/Right` | Flytt mellom vinduer |
| `Alt + Shift + Arrow Left/Right` | Flytt vindu til venstre/høyre |

### Økter

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Prefix + C` | Ny økt |
| `Prefix + K` | Lukk økt |
| `Prefix + R` | Gi økt nytt navn |
| `Prefix + N` | Neste økt |
| `Prefix + P` | Forrige økt |
| `Alt + Arrow Up/Down` | Flytt mellom økter |
| `Prefix + s` | List opp økter |
| `Prefix + d` | Koble fra økt |

### Kopimodus (vi-stil)

| Hurtigtast | Funksjon |
| ------------------------ | ------------------------------- |
| `Prefix + [` | Gå inn i kopimodus |
| `v` | Start markering (i kopimodus) |
| `y` | Kopier markering (i kopimodus) |

### Generelt

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Prefix + q` | Last konfigurasjon på nytt |
| `Prefix + ?` | Vis Tmux-tastaturbindinger |
| `Prefix + :` | Kommandoprompt |

### Tmux-oppsettfunksjoner

Disse funksjonene må kjøres inne i en Tmux-økt.

| Kommando | Funksjon |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Opprett utvikleroppsett med redigeringsprogram, AI og terminal |
| `tdlm <ai> [<second_ai>]` | Opprett utvikleroppsett per undermappe |
| `tsl <count> <command>` | Opprett svermeoppsett med flere ruter |

## Ghostty-terminal

Ghostty-terminal installeres med _Install > Terminal_ via Omarchy-menyen.

| Hurtigtast | Funksjon |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ny deling under |
| `Ctrl + Shift + O` | Ny deling ved siden av |
| `Ctrl + Alt + Arrows` | Flytt mellom delinger |
| `Super + Ctrl + Shift + Arrows` | Endre deling med 10 linjer |
| `Super + Ctrl + Shift + Alt + Arrows` | Endre deling med 100 linjer |
| `Ctrl + Shift + T` | Ny fane |
| `Ctrl + Shift + Arrows` | Flytt mellom faner |
| `Alt + Numbers` | Gå til bestemt fane |
| `Shift + Pg Up/Down` | Rull gjennom historikken |
| `Ctrl + Left mouse` | Åpne lenke i nettleser |

## Filbehandler

| Hurtigtast | Funksjon |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Gå til sti |
| `Space` | Forhåndsvis fil (piler navigerer) |
| `Alt + Up` | Gå opp til overordnet mappe |

## Neovim (med lazyvim)

### Navigering

| Hurtigtast | Funksjon |
| ------------------------ | ------------------------------- |
| `Space` | Vis kommandoalternativer |
| `Space Space` | Åpne fil via fuzzy-søk |
| `Space E` | Veksle sidefelt |
| `Space G G` | Vis git-kontroller |
| `Space S G` | Søk i filinnhold |
| `Ctrl + W W` | Hopp mellom sidefelt og redigeringsprogram |
| `Ctrl + Left/right arrow` | Endre størrelse på sidefelt |
| `Shift + H` | Gå til filfane til venstre |
| `Shift + L` | Gå til filfane til høyre |
| `Space B D` | Lukk filfane |

### Mens du er i sidefeltet

| Hurtigtast | Funksjon |
| ------------------------ | ------------------------------- |
| `A` | Legg til ny fil i overordnet mappe |
| `Shift + A` | Legg til ny undermappe i overordnet mappe |
| `D` | Slett merket fil/mappe |
| `M` | Flytt merket fil/mappe |
| `R` | Gi merket fil/mappe nytt navn |
| `?` | Vis hjelp for alle kommandoer |

[Se alle Neovim-hurtigtastene som er konfigurert av LazyVim](https://www.lazyvim.org/keymaps).

## Hurtig-emojier

Du kan bruke `Super + Ctrl + E` til å vise en komplett emoji-velger som legger valget på utklippstavlen, eller du kan bruke disse hurtigvalgene.

| Hurtigtast | EM | Hint |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smil |
| `Shift + CapsLock M C` | 😂 | gråt |
| `Shift + CapsLock M L` | 😍 | kjærlighet |
| `Shift + CapsLock M V` | ✌️ | seier |
| `Shift + CapsLock M H` | ❤️ | hjerte |
| `Shift + CapsLock M Y` | 👍 | ja |
| `Shift + CapsLock M N` | 👎 | nei |
| `Shift + CapsLock M F` | 🖕 | faen |
| `Shift + CapsLock M W` | 🤞 | ønske |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | kyss |
| `Shift + CapsLock M E` | 🙄 | himle med øynene |
| `Shift + CapsLock M I` | 😉 | blink |
| `Shift + CapsLock M P` | 🙏 | be |
| `Shift + CapsLock M D` | 🤤 | sikle |
| `Shift + CapsLock M M` | 💰 | penger |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | skål |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | hilsen |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | sprengt |

## Hurtigfullføringer

| Hurtigtast | Fullføring |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (lang tankestrek) |
| `Shift + CapsLock Space N` | Navnet ditt (som angitt under oppsett) |
| `Shift + CapsLock Space E` | E-postadressen din (som angitt under oppsett) |

Du kan legge til flere selv ved å redigere `~/.XCompose`, og deretter kjøre `omarchy-restart-xcompose` i terminalen for å få endringene plukket opp.
