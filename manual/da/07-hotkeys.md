# Genvejstaster

Du kan se alle de vigtigste tastaturgenveje med `Super + K` (Tmux-genveje med `Super + Alt + K` og Herdr-genveje med `Super + Ctrl + K`).

## Sådan er genvejstasterne opbygget

Hver genvejstast ligger på et plan, bestemt af dens modifikationstaster, og hvert plan har én opgave. Det er det, der holder genvejstasterne fra at flyde sammen, og det betyder, at du som regel kan gætte, hvor noget hører hjemme.

| Plan | Hvad der hører hjemme der | Eksempler |
| --- | --- | --- |
| `Super + key` | Systemet: vinduer, arbejdsområder, layouts og kernemenuer | `Super + Space` Omarchy-menu, `Super + W` luk vindue, `Super + F` fuld skærm |
| `Super + Shift + key` | Programmer | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` teksteditor |
| `Super + Ctrl + key` | Paneler og systemmenuer | `Super + Ctrl + A` lyd, `Super + Ctrl + N` netværk, `Super + Ctrl + C` optagemenu |
| `Super + Ctrl + Alt + key` | Hurtige handlinger og meddelelser | `Super + Ctrl + Alt + T` vis klokkeslæt, `Super + Ctrl + Alt + B` batteri, `Super + Ctrl + Alt + C` skærmbillede |

Tilføjer du `Alt` til en genvejstast, får du en variant af det samme, aldrig noget urelateret:

- `Super + Shift + B` åbner browseren; `Super + Shift + Alt + B` åbner et privat vindue
- `Super + Shift + E` åbner e-mail; `Super + Shift + Alt + E` starter en ny
- `Super + F` går i fuld skærm; `Super + Alt + F` går i fuld bredde
- `Super + Ctrl + C` åbner optagemenuen; `Super + Ctrl + Alt + C` springer menuen over og tager et skærmbillede

Når du tilføjer en genvejstast:

1. Vælg planet ud fra, hvad den gør, og vælg derefter tasten.
2. Flyt ikke en eksisterende genvejstast for at gøre plads. Find en ledig tast på det rigtige plan.
3. Brug kun `Alt` til en variant af genvejstasten uden den.

Nogle få genvejstaster bryder disse regler, fordi de er praktiske. `Shift` med en pil eller `Tab` flytter eller vender i stedet for at åbne et program, og `Print`, medietasterne, `Alt + Tab` og `Ctrl + Alt + Del` fungerer, som de gør alle andre steder. De er undtagelser, ikke mønstre, du skal kopiere.

Hvis en standard ikke passer dig (f.eks. hvis du vil have `Super + Shift + S` til skærmbilleder som på Windows), så bind den om i `~/.config/hypr/bindings.lua`.

## Navigation

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-menu (programmer og alt det andet)    |
| `Super + Alt + Space` | Programgitter |
| `Super + Escape` | Systemmenu (dvale, genstart osv.)  |
| `Super + Ctrl + L` | Lås computer |
| `Super + W` or `Super + Q` | Luk vindue             |
| `Ctrl + Alt + Del` | Luk alle vinduer |
| `Super + K` | Vis alle genvejstaster |
| `Super + Alt + K` | Vis tmux-genvejstaster |
| `Super + Ctrl + K` | Vis herdr-genvejstaster |
| `Super + M` | Minimér vindue til docken |
| `Super + T`               | Skift vindue mellem fliselægning/svævende             |
| `Super + J` | Skift vinduesposition (vandret/lodret) |
| `Super + O`               | Slå popping-vindue til/fra i sticky'n'floating |
| `Super + L`               | Skift mellem layoutene dwindle, scrolling og floating |
| `Super + Alt + L`         | Skift mellem layoutene i omvendt rækkefølge |
| `Super + P`               | Skift pseudo-vinduesstil (naturlig vs. stræk) |
| `Super + F`                 | Gå i fuld skærm              |
| `Super + Alt + F`                 | Gå i fuld bredde              |
| `Super + Ctrl + F`                 | Gå i fuld skærm inde i vinduet              |
| `Super + 1…9/0`         | Spring til et bestemt arbejdsområde (0 er 10) på den fokuserede skærm |
| `Super + Tab` | Spring til næste arbejdsområde på den fokuserede skærm |
| `Super + Shift + Tab` | Spring til forrige arbejdsområde på den fokuserede skærm |
| `Super + Ctrl + Tab` | Spring til tidligere arbejdsområde på den fokuserede skærm |
| `Super + Shift + 1…9/0` | Flyt vindue til arbejdsområde på den fokuserede skærm |
| `Super + Shift + Alt + 1…9/0` | Flyt vindue til arbejdsområde på den fokuserede skærm uden at følge med |
| `Super + S` | Slå fuld scratchpad til/fra |
| `Super + Alt + S` | Flyt vindue til fuld scratchpad |
| `Super + Grave` | Slå Quake-konsol til/fra |
| `Super + Shift + Grave` | Flyt vindue til Quake-konsol |
| `Super + Shift + Ctrl + Arrows` | Flyt vindue til skærmen i den retning |
| `Super + Shift + Alt + Arrows` | Flyt arbejdsområde til skærmen i den retning |
| `Super + Arrow`  | Flyt fokus til vindue i pilens retning, og kryds til skærmen på den side ved skærmens kant |
| `Super + Shift + Arrow`  | Byt vindue med et andet i pilens retning, herunder et på skærmen på den side |
| `Super + Minus` | Udvid vindue til venstre |
| `Super + Equal` | Formindsk vindue mod venstre |
| `Super + Shift + Minus` | Formindsk vindue opad |
| `Super + Shift + Equal` | Udvid vindue nedad |
| `Super + Alt + Minus/Equal` | Samme størrelsesændring i mindre trin |
| `Super + Ctrl + Minus/Equal` | Samme størrelsesændring i større trin |
| `Super + Alt + Home` | Gem vinduesbredde |
| `Super + Home` | Gendan gemt vinduesbredde |
| `Super + Left Mouse` | Træk vindue rundt |
| `Super + Right Mouse` | Ændr vinduesstørrelse |
| `Super + Scroll Wheel` | Rul gennem arbejdsområder på den fokuserede skærm |
| `Super + G`               | Slå vinduesgruppering til/fra      |
| `Super + Alt + G`               | Flyt vindue ud af gruppering      |
| `Super + Alt + Tab`               | Skift mellem vinduer i gruppering      |
| `Super + Alt + Shift + Tab`               | Skift baglæns mellem vinduer i gruppering      |
| `Super + Alt + Scroll Wheel` | Skift mellem vinduer i gruppering |
| `Super + Alt + 1/2/3/4/5`               | Spring til et bestemt vindue i gruppering      |
| `Super + Alt + Arrow`  | Flyt vindue ind i gruppering i pilens retning, herunder et på skærmen på den side |
| `Super + Ctrl + Left/Right`  | Flyt mellem vinduer i en flisegruppe |
| `Super + Ctrl + Z` | Zoom ind på skærmen (gentag for mere zoom) |
| `Super + Ctrl + Alt + Z` | Zoom helt ud fra skærmen |
| `Super + /` | Gå frem gennem skærmskaleringsmuligheder |
| `Super + Alt + /` | Gå tilbage gennem skærmskaleringsmuligheder |
| `Alt + Tab` | Skift frem gennem vinduer på det aktive arbejdsområde |
| `Alt + Shift + Tab` | Skift baglæns gennem vinduer på det aktive arbejdsområde |
| `Ctrl + Alt + Tab`| Skift fokus frem gennem skærme |
| `Ctrl + Alt + Shift + Tab`| Skift fokus baglæns gennem skærme |
| `Super + I` | Skift inputsprog (med mere end ét layout eller én inputmetode) |
| `Super + Shift + I` | Skift inputsprog tilbage |

På en pegeplade skifter stryg med tre og fire fingre arbejdsområder, flytter vinduer og åbner menuen og Quake-konsollen; se [tastatur, mus og pegefelt](34-keyboard-mouse-trackpad.md) for bevægelserne.

Genveje til størrelsesændring bruger de fysiske taster `code:20` og `code:21` (XKB `<AE11>` og `<AE12>`), uanset hvilke tegn der er trykt på tastaturet. På US-tastaturer er disse taster `-` og `=`; på japanske (JIS) tastaturer er de `-` og `^`; på spanske tastaturer er de `'` og `¡`. På JIS er `Super + ^` lig med `Super + Equal`, mens `Super + Shift + -` (som skriver `=`) er `Super + Shift + Minus`.

## Systemstyring

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Lydpanel    |
| `Super + Ctrl + B`           | Bluetooth-panel    |
| `Super + Ctrl + N`           | Wi-Fi/netværkspanel    |
| `Super + Ctrl + D`           | Skærmpanel    |
| `Super + Ctrl + P`           | Strømpanel    |
| `Super + Ctrl + X`           | Agentpanel    |
| `Super + Ctrl + Shift + X`           | Panel for lokale modeller    |
| `Super + Ctrl + Alt + D`           | Kalenderpanel    |
| `Super + Ctrl + Alt + E`           | Verdensurpanel    |
| `Super + Ctrl + 1-9`           | Slå bjælkepanel til/fra efter position    |
| `Super + Ctrl + S` | Delingsmenu (via LocalSend) |
| `Super + Ctrl + C` | Optagekontroller (skærmbillede/-optagelse/vælger) |
| `Super + Ctrl + O` | Slå menu til/fra |
| `Super + Ctrl + H` | Hardwaremenu |
| `Super + Ctrl + E` | Emoji-vælger |
| `Super + Ctrl + .` | Omkod medier |
| `Super + Shift + Ctrl + A` | Vælg en AI-agent |
| `Power`-tast | Systemmenu |
| `Super + Shift + Copilot`-tast | Omarchy-menu |

## Justeringer

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimal skærmlysstyrke |
| `Shift + Brightness Down` | Minimal skærmlysstyrke |
| `Alt + Brightness Up/Down` | Præcise ændringer af lysstyrken på 1 % |
| `Alt + Volume Up/Down` | Præcise ændringer af lydstyrken på 1 % |
| `Keyboard Brightness Up/Down` | Tastaturbaggrundsbelysning lysere/mørkere |
| `Keyboard Backlight` | Skift mellem niveauerne for tastaturbaggrundsbelysning |
| `Ctrl + Brightness Up/Down` | Tastaturbaggrundsbelysning lysere/mørkere, på tastaturer uden deres egne taster |
| `Mic Mute` | Slå mikrofonen fra |
| `Shift + Mute` | Skift lydudgang |
| `Touchpad Toggle` | Slå pegepladen til eller fra |
| `Display`-tast | Skift arbejdsområdelayout |
| `Alt + Play` | Næste nummer |
| `Alt + Shift + Play` | Forrige nummer |

## Start af programmer

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agentstyring) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (privat/inkognito)    |
| `Super + Shift + F`           | Filhåndtering    |
| `Super + Shift + Alt + F`           | Filhåndtering i terminalens cwd    |
| `Super + Shift + M`           | Musik (Spotify)    |
| `Super + Shift + Alt + M`           | Musik (cliamp)    |
| `Super + Shift + /`           | Adgangskodehåndtering (1password)    |
| `Super + Shift + Q` or `Calculator`-tast  | Lommeregner (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, når det er installeret)    |
| `Super + Shift + T`           | Aktivitet (btop)    |
| `Super + Shift + N`           | Teksteditor (Plain eller dit valgte standardprogram)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Ny e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Beskeder (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Beskeder (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Beskeder (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Skrivning (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nyt opslag) |
| `Super + Shift + Y`           | YouTube |

Skift/tilføj bindinger i `~/.config/hypr/bindings.lua`.

## Universel udklipsholder

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + A`           | Markér alt i programmer, der understøtter `Ctrl + A`    |
| `Super + C`           | Kopiér    |
| `Super + X`           | Klip (ikke i terminal)    |
| `Super + V`           | Indsæt    |
| `Super + Ctrl + V`           | Udklipsholderstyring    |

Normalt skal du på Linux bruge `Ctrl + Shift + C/V` til at kopiere/indsætte i terminalen og `Ctrl + C/V` til at gøre det alle andre steder. Disse ensartede Omarchy-genvejstaster til udklipsholderen virker overalt.

## Optagelse

| Genvejstast              | Funktion                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skærmbillede                      |
| `Super + Ctrl + Alt + C`            | Skærmbillede (samme optagelse til tastaturer uden en Print Screen-tast) |
| `Super + Ctrl + C` | Optagemenu |
| `Alt + Print Screen`            | Skærmoptagelse                     |
| `Super + Shift + Ctrl + Alt + C` | Skærmoptagelse uden lyd, spring menuen over (tryk igen for at stoppe) |
| `Super + Print Screen` | Farvevælger |
| `Super + Ctrl + Print Screen` | Tekstudtræk til udklipsholderen |
| `Super + Alt + [` | Gør webcam-overlay mindre under optagelse |
| `Super + Alt + ]` | Gør webcam-overlay større under optagelse |
| `Alt + Shift + L` | Kopiér den aktuelle URL fra webapp eller browser |
| `Alt + Shift + D` | Download videoen på den aktuelle side til `~/Videos` |
| `Alt + Space` | Start/stop diktering (kræver _Opsætning > Standarder > Diktering_) |
| `Right Alt` | Hold nede for at diktere (kræver _Opsætning > Standarder > Diktering_) |

Ved skærmoptagelser spørger genvejstasten først, hvilken lyd du vil have, og starter derefter optagelsen. Tryk på den igen for at stoppe. Se [skærmbilleder og optagelse](12-screenshots-recording.md) for detaljerne.

Alle optagemuligheder er også tilgængelige under _Udløser > Optagelse_ i Omarchy-menuen (`Super + Space`).

## Notifikationer

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + ,` | Handl på den seneste notifikation: åbn den, eller tryk på dens eneste knap, vælg blandt dens valgmuligheder, eller afvis den, når den ingen har  |
| `Super + Shift + ,` | Afvis alle notifikationer |
| `Super + Ctrl + ,` | Styr notifikationer med tastaturet  |
| `Super + Alt + ,` | Afvis seneste notifikation  |
| `Super + Shift + Alt + ,` | Åbn notifikationshistorik  |
| `Super + Ctrl + Alt + ,` | Slå lydløs tilstand for notifikationer til/fra  |

## Stil

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vælg et nyt tema (også `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vælg temabaggrund (også `Super + Ctrl + Space`) |
| `Super + Backspace` | Slå gennemsigtighed til/fra på et vindue |
| `Super + Ctrl + Backspace` | Slå kvadratisk format for enkeltvindue til/fra |

Ekstra baggrundsbilleder ligger i `~/.config/omarchy/backgrounds/<theme name>`. Fås også via _Installer > Stil > Baggrund_ i Omarchy-menuen.

Alle stilmuligheder er også tilgængelige under _Udseende_ i Omarchy-menuen (`Super + Space`).

## Skiftefunktioner

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Slå låsning ved inaktivitet til/fra |
| `Super + Ctrl + Delete` | Slå bærbar skærm til/fra |
| `Super + Ctrl + Alt + Delete` | Slå spejling af bærbar skærm til/fra |
| `Super + Shift + Space` | Slå den øverste bjælke til/fra  |
| `Shift + Mute` | Skift til næste lydudgang |
| `Shift + Play` | Skift til næste mediekilde |
| `Super + Shift + Backspace` | Slå vinduesafstande til/fra |
| `Super + Ctrl + Alt + F` | Slå fuldskærmsskrivebord til/fra (øverste bjælke + vinduesafstande) |

## Påmindelser

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Indstil en påmindelse  |
| `Super + Ctrl + Alt + R` | Se alle påmindelser  |
| `Super + Ctrl + Shift + R` | Ryd alle påmindelser  |

## Varsler

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vis klokkeslættet som notifikation  |
| `Super + Ctrl + Alt + B` | Vis batteri som notifikation  |
| `Super + Ctrl + Alt + W` | Slå vejr som notifikation til/fra  |

## Tmux

Præfikstasten er `Ctrl + Space` (`Ctrl + B` virker også). Du kan ændre disse bindinger i `~/.config/tmux/tmux.conf`.

### Ruder

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + v` | Opdel rude ved siden af (lodret) |
| `Prefix + h` | Opdel rude nedenunder (vandret) |
| `Prefix + x` | Luk rude |
| `Prefix + z` | Slå rudezoom til/fra (fuld skærm) |
| `Alt + Enter` | Opdel rude nedenunder (uden præfiks) |
| `Alt + Shift + Enter` | Opdel rude ved siden af (uden præfiks) |
| `Alt + Escape` | Luk rude (uden præfiks) |
| `Ctrl + Alt + Arrows` | Flyt mellem ruder |
| `Ctrl + Alt + Shift + Arrows` | Ændr ruders størrelse |

### Vinduer

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nyt vindue |
| `Prefix + k` | Luk vindue |
| `Prefix + r` | Omdøb vindue |
| `Alt + 1-9` | Gå til et bestemt vindue |
| `Alt + Arrow Left/Right` | Flyt mellem vinduer |
| `Alt + Shift + Arrow Left/Right` | Flyt vindue til venstre/højre |

### Sessioner

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + C` | Ny session |
| `Prefix + K` | Luk session |
| `Prefix + R` | Omdøb session |
| `Prefix + N` | Næste session |
| `Prefix + P` | Forrige session |
| `Alt + Arrow Up/Down` | Flyt mellem sessioner |
| `Prefix + s` | Vis sessioner |
| `Prefix + d` | Frigør fra session |

### Kopieringstilstand (vi-stil)

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + [` | Gå i kopieringstilstand |
| `v` | Begynd markering (i kopieringstilstand) |
| `y` | Kopiér markering (i kopieringstilstand) |

### Generelt

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + q` | Genindlæs konfiguration |
| `Prefix + ?` | Vis Tmux-tastebindinger |
| `Prefix + :` | Kommandoprompt |

### Tmux-layoutfunktioner

Disse funktioner skal køres inde i en Tmux-session.

| Kommando | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Opret udviklingslayout med teksteditor, AI og terminal |
| `tdlm <ai> [<second_ai>]` | Opret udviklingslayout pr. undermappe |
| `tsl <count> <command>` | Opret sværmlayout med flere ruder |

## Ghostty-terminal

Ghostty-terminalen installeres med _Installer > Terminal_ via Omarchy-menuen.

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ny opdeling nedenunder |
| `Ctrl + Shift + O` | Ny opdeling ved siden af |
| `Ctrl + Alt + Arrows` | Flyt mellem opdelinger |
| `Super + Ctrl + Shift + Arrows` | Ændr opdelingens størrelse med 10 linjer |
| `Super + Ctrl + Shift + Alt + Arrows` | Ændr opdelingens størrelse med 100 linjer |
| `Ctrl + Shift + T` | Ny fane  |
| `Ctrl + Shift + Arrows` | Flyt mellem faner |
| `Alt + Numbers` | Gå til en bestemt fane |
| `Shift + Pg Up/Down` | Rul gennem historikken |
| `Ctrl + Left mouse` | Åbn link i browser |

## Filhåndtering

| Genvejstast              | Funktion                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Gå til sti                     |
| `Space`               | Forhåndsvis fil (pile navigerer) |
| `Alt + Up`       | Gå op til overordnet mappe        |

## Neovim (med lazyvim)

### Navigation

| Genvejstast                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Vis kommandomuligheder            |
| `Space Space`              | Åbn fil via fuzzy-søgning      |
| `Space E`                  | Slå sidebjælke til/fra                  |
| `Space G G`                | Vis git-kontroller               |
| `Space S G`                | Søg i filindhold             |
| `Ctrl + W W`               | Spring mellem sidebjælke og teksteditor |
| `Ctrl + Left/right arrow`  | Ændr sidebjælkens størrelse          |
| `Shift + H`                      | Gå til venstre filfane             |
| `Shift + L`                      | Gå til højre filfane            |
| `Space B D`                | Luk filfane                  |

### Mens du er i sidebjælken

| Genvejstast                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `A`                        | Tilføj ny fil i overordnet mappe      |
| `Shift + A`                | Tilføj ny undermappe i overordnet mappe    |
| `D`                        | Slet fremhævet fil/mappe     |
| `M`                        | Flyt fremhævet fil/mappe       |
| `R`                        | Omdøb fremhævet fil/mappe     |
| `?`                        | Vis hjælp til alle kommandoer      |

[Se alle Neovim-genvejstasterne, som LazyVim konfigurerer](https://www.lazyvim.org/keymaps).

## Hurtige emojis

Du kan bruge `Super + Ctrl + E` til at vise en komplet emoji-vælger, som lægger det valgte på udklipsholderen, eller du kan bruge disse hurtige adgangsmuligheder.

| Genvejstast       | EM | Hint       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smil      |
| `Shift + CapsLock M C` | 😂 | gråd        |
| `Shift + CapsLock M L` | 😍 | kærlighed       |
| `Shift + CapsLock M V` | ✌️ | sejr    |
| `Shift + CapsLock M H` | ❤️ | hjerte      |
| `Shift + CapsLock M Y` | 👍 | ja        |
| `Shift + CapsLock M N` | 👎 | nej         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | ønske       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | kys       |
| `Shift + CapsLock M E` | 🙄 | øjenrul    |
| `Shift + CapsLock M I` | 😉 | blink       |
| `Shift + CapsLock M P` | 🙏 | bed |
| `Shift + CapsLock M D` | 🤤 | savl      |
| `Shift + CapsLock M M` | 💰 | penge      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | skål      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | hilsen |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blæst væk |

## Hurtige fuldførelser

| Genvejstast       | Fuldførelse       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (tankestreg)   |
| `Shift + CapsLock Space N` | Dit navn (som indtastet under opsætning)  |
| `Shift + CapsLock Space E` | Din e-mail (som indtastet under opsætning)  |

Du kan tilføje flere af dine egne ved at redigere `~/.XCompose` og derefter køre `omarchy restart xcompose` i terminalen for at få ændringerne registreret.
