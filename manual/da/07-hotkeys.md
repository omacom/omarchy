# Genvejstaster

Du kan se alle de vigtigste tastaturgenveje med `Super + K` (Tmux-genveje med `Super + Alt + K` og Herdr-genveje med `Super + Ctrl + K`).

## Sådan er genvejstasterne lagt ud

Hver genvejstast ligger på et plan, bestemt af dens modifikatortaster, og hvert plan har ét job. Det er det, der holder genvejstasterne fra at flyde sammen, og det betyder, at du som regel kan gætte, hvor noget hører hjemme.

| Plan | Hvad der hører hjemme der | Eksempler |
| --- | --- | --- |
| `Super + key` | Systemet: vinduer, arbejdsområder, layouts og kernemenuer | `Super + Space` Omarchy-menu, `Super + W` luk vindue, `Super + F` fuld skærm |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Paneler og systemmenuer | `Super + Ctrl + A` lyd, `Super + Ctrl + N` netværk, `Super + Ctrl + C` optagelsesmenu |
| `Super + Ctrl + Alt + key` | Hurtige handlinger og meddelelser | `Super + Ctrl + Alt + T` vis klokkeslæt, `Super + Ctrl + Alt + B` batteri, `Super + Ctrl + Alt + C` skærmbillede |

At tilføje `Alt` til en genvejstast giver dig en variant af det samme, aldrig noget urelateret:

- `Super + Shift + B` åbner browseren; `Super + Shift + Alt + B` åbner et privat vindue
- `Super + Shift + E` åbner e-mail; `Super + Shift + Alt + E` starter en ny
- `Super + F` går i fuld skærm; `Super + Alt + F` går i fuld bredde
- `Super + Ctrl + C` åbner optagelsesmenuen; `Super + Ctrl + Alt + C` springer menuen over og tager et skærmbillede

Når du tilføjer en genvejstast:

1. Vælg planet ud fra, hvad den gør, og vælg derefter tasten.
2. Flyt ikke en eksisterende genvejstast for at gøre plads. Find en ledig tast på det rigtige plan.
3. Brug kun `Alt` til en variant af genvejstasten uden den.

Nogle få genvejstaster bryder disse regler, fordi det er praktisk. `Shift` med en pil eller `Tab` flytter eller vender i stedet for at åbne en app, og `Print`, medietasterne, `Alt + Tab` og `Ctrl + Alt + Del` fungerer, som de gør alle andre steder. De er undtagelser, ikke mønstre, du skal kopiere.

Hvis en standard ikke passer dig (sig, du vil have `Super + Shift + S` til skærmbilleder som på Windows), så ombind den i `~/.config/hypr/bindings.lua`.

## Navigation

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-menu (apps og alt andet)    |
| `Super + Alt + Space` | App-oversigt |
| `Super + Escape` | Systemmenu (dvale, genstart osv.)  |
| `Super + Ctrl + L` | Lås computeren |
| `Super + W` or `Super + Q` | Luk vindue             |
| `Ctrl + Alt + Del` | Luk alle vinduer |
| `Super + T`               | Skift vindue mellem tiling/flydende             |
| `Super + J` | Skift vinduesposition (vandret/lodret) |
| `Super + O`               | Slå poppende vindue til sticky'n'floating til/fra |
| `Super + L`               | Skift gennem dwindle-, scrolling- og floating-layouts |
| `Super + Alt + L`         | Skift gennem layouts i omvendt rækkefølge |
| `Super + P`               | Slå pseudo-vinduesstil til/fra (naturlig vs. strakt) |
| `Super + F`                 | Gå i fuld skærm              |
| `Super + Alt + F`                 | Gå i fuld bredde              |
| `Super + Ctrl + F`                 | Gå i fuld skærm inde i vinduet              |
| `Super + 1/2/3/4`         | Spring til et bestemt arbejdsområde på den fokuserede skærm |
| `Super + Tab` | Spring til næste arbejdsområde på den fokuserede skærm |
| `Super + Shift + Tab` | Spring til forrige arbejdsområde på den fokuserede skærm |
| `Super + Ctrl + Tab` | Spring til tidligere arbejdsområde på den fokuserede skærm |
| `Super + Shift + 1/2/3/4` | Flyt vindue til arbejdsområde på den fokuserede skærm |
| `Super + Shift + Alt + 1/2/3/4` | Flyt vindue til arbejdsområde på den fokuserede skærm uden at følge med |
| `Super + S` | Slå fuld scratchpad til/fra |
| `Super + Alt + S` | Flyt vindue til fuld scratchpad |
| `Super + Grave` | Slå Quake-konsol til/fra |
| `Super + Shift + Grave` | Flyt vindue til Quake-konsol |
| `Super + Shift + Ctrl + Arrows` | Flyt vindue til skærmen i den retning |
| `Super + Shift + Alt + Arrows` | Flyt arbejdsområde til skærmen i den retning |
| `Super + Arrow`  | Flyt fokus til vindue i pilens retning, med krydsning til skærmen på den side ved skærmens kant |
| `Super + Shift + Arrow`  | Byt vindue med et andet i pilens retning, herunder et på skærmen på den side |
| `Super + Minus` | Udvid vindue til venstre |
| `Super + Equal` | Gør vindue mindre mod venstre |
| `Super + Shift + Minus` | Gør vindue mindre op |
| `Super + Shift + Equal` | Udvid vindue ned |
| `Super + Alt + Minus/Equal` | Samme størrelsesændring i mindre trin |
| `Super + Ctrl + Minus/Equal` | Samme størrelsesændring i større trin |
| `Super + Alt + Home` | Gem vinduesbredde |
| `Super + Home` | Gendan gemt vinduesbredde |
| `Super + Left Mouse` | Træk vindue rundt |
| `Super + Right Mouse` | Ændr vinduets størrelse |
| `Super + Scroll Wheel` | Rul gennem arbejdsområder på den fokuserede skærm |
| `Super + G`               | Slå vinduesgruppering til/fra      |
| `Super + Alt + G`               | Flyt vindue ud af gruppering      |
| `Super + Alt + Tab`               | Skift mellem vinduer i gruppering      |
| `Super + Alt + Shift + Tab`               | Skift baglæns mellem vinduer i gruppering      |
| `Super + Alt + Scroll Wheel` | Skift mellem vinduer i gruppering |
| `Super + Alt + 1/2/3/4/5`               | Spring til et bestemt vindue i gruppering      |
| `Super + Alt + Arrow`  | Flyt vindue ind i gruppering i pilens retning, herunder et på skærmen på den side |
| `Super + Ctrl + Left/Right`  | Flyt mellem vinduer inde i en tiling-gruppe |
| `Super + Ctrl + Z` | Zoom ind på skærmen (gentag for mere zoom) |
| `Super + Ctrl + Alt + Z` | Zoom helt ud fra skærmen |
| `Super + /` | Træd frem gennem muligheder for skærmskalering |
| `Super + Alt + /` | Træd tilbage gennem muligheder for skærmskalering |
| `Alt + Tab` | Skift frem gennem vinduer på det aktive arbejdsområde |
| `Alt + Shift + Tab` | Skift tilbage gennem vinduer på det aktive arbejdsområde |
| `Ctrl + Alt + Tab`| Skift fokus frem gennem skærme |
| `Ctrl + Alt + Shift + Tab`| Skift fokus tilbage gennem skærme |

Genveje til ændring af størrelse bruger de fysiske taster `code:20` og `code:21` (XKB `<AE11>` og `<AE12>`), uanset hvilke tegn der er trykt på tastaturet. På amerikanske tastaturer er disse taster `-` og `=`; på japanske (JIS) tastaturer er de `-` og `^`; på spanske tastaturer er de `'` og `¡`. På JIS er `Super + ^` det samme som `Super + Equal`, mens `Super + Shift + -` (som skriver `=`) er `Super + Shift + Minus`.

## Systemkontroller

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Lydpanel    |
| `Super + Ctrl + B`           | Bluetooth-panel    |
| `Super + Ctrl + N`           | Wi-Fi/netværkspanel    |
| `Super + Ctrl + D`           | Skærmpanel    |
| `Super + Ctrl + P`           | Strømpanel    |
| `Super + Ctrl + X`           | Agentpanel    |
| `Super + Ctrl + Alt + D`           | Kalenderpanel    |
| `Super + Ctrl + Alt + E`           | Verdensurpanel    |
| `Super + Ctrl + 1-9`           | Slå bjælkepanel til/fra efter position    |
| `Super + Ctrl + S` | Delingsmenu (via LocalSend) |
| `Super + Ctrl + C` | Optagelseskontroller (skærmbillede/-optagelse/vælger) |
| `Super + Ctrl + O` | Til/fra-menu |
| `Super + Ctrl + H` | Hardwaremenu |
| `Super + Ctrl + E` | Emoji-vælger |
| `Super + Ctrl + .` | Transkod medier |
| `Super + Shift + Ctrl + A` | Vælg en AI-agent |

## Justeringer

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimal skærmlysstyrke |
| `Shift + Brightness Down` | Minimal skærmlysstyrke |
| `Alt + Brightness Up/Down` | Præcise ændringer af lysstyrke på 1 % |
| `Alt + Volume Up/Down` | Præcise ændringer af lydstyrke på 1 % |
| `Keyboard Brightness Up/Down` | Tastaturbaggrundsbelysning lysere/mørkere |
| `Keyboard Backlight` | Skift mellem niveauerne for tastaturbaggrundsbelysning |
| `Alt + Play` | Næste nummer |
| `Alt + Shift + Play` | Forrige nummer |

## Start af apps

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agentmanager) |
| `Super + Shift + Return`           | Browser    |
| `Super + Shift + Alt + B`           | Browser (privat/inkognito)    |
| `Super + Shift + F`           | Filhåndtering    |
| `Super + Shift + Alt + F`           | Filhåndtering i terminalens cwd    |
| `Super + Shift + M`           | Musik (Spotify)    |
| `Super + Shift + Alt + M`           | Musik (cliamp)    |
| `Super + Shift + /`           | Adgangskodehåndtering (1password)    |
| `Super + Shift + Q`           | Lommeregner (Omacalc)    |
| `Super + Shift + T`           | Aktivitet (btop)    |
| `Super + Shift + N`           | Editor (Neovim)  |
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
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Ændr/tilføj bindinger i `~/.config/hypr/bindings.lua`.

## Universel udklipsholder

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + A`           | Markér alt i apps, der understøtter `Ctrl + A`    |
| `Super + C`           | Kopiér    |
| `Super + X`           | Klip (ikke i terminalen)    |
| `Super + V`           | Indsæt    |
| `Super + Ctrl + V`           | Udklipsholderhåndtering    |

Normalt på Linux skal du bruge `Ctrl + Shift + C/V` til at kopiere og indsætte i terminalen og `Ctrl + C/V` til at gøre det alle andre steder. Disse samlede Omarchy-genveje til udklipsholderen fungerer overalt.

## Optagelse

| Genvejstast              | Funktion                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skærmbillede                      |
| `Super + Ctrl + Alt + C`            | Skærmbillede (samme optagelse, til tastaturer uden en Print Screen-tast) |
| `Super + Ctrl + C` | Optagelsesmenu |
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

Med skærmoptagelser spørger genvejstasten først, hvilken lyd du vil have, og starter derefter optagelsen. Tryk på den igen for at stoppe. Se [skærmbilleder og optagelse](12-screenshots-recording.md) for detaljerne.

Alle optagelsesmuligheder er også tilgængelige under _Udløser > Optagelse_ i Omarchy-menuen (`Super + Space`).

## Notifikationer

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + ,` | Handl på den seneste notifikation: åbn den eller tryk på dens eneste knap, vælg blandt dens muligheder, eller afvis den, når den ingen har  |
| `Super + Shift + ,` | Afvis alle notifikationer |
| `Super + Ctrl + ,` | Styr notifikationer med tastaturet  |
| `Super + Alt + ,` | Afvis den seneste notifikation  |
| `Super + Shift + Alt + ,` | Åbn notifikationshistorik  |
| `Super + Ctrl + Alt + ,` | Slå lydløs tilstand for notifikationer til/fra  |

## Stil

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vælg et nyt tema (også `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vælg temabaggrund (også `Super + Ctrl + Space`) |
| `Super + Backspace` | Slå gennemsigtighed til/fra på et vindue |
| `Super + Ctrl + Backspace` | Slå kvadratisk format til/fra for et enkelt vindue |

Ekstra baggrundsbilleder ligger i `~/.config/omarchy/backgrounds/<theme name>`. Også tilgængelig via _Installer > Stil > Baggrund_ i Omarchy-menuen.

Alle stilmuligheder er også tilgængelige under _Stil_ i Omarchy-menuen (`Super + Space`).

## Til/fra-skift

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Slå låsning ved inaktivitet til/fra |
| `Super + Ctrl + Delete` | Slå bærbar skærm til/fra |
| `Super + Ctrl + Alt + Delete` | Slå spejling af bærbar skærm til/fra |
| `Super + Shift + Space` | Slå den øverste bjælke til/fra  |
| `Shift + Mute` | Skift til næste lydudgang |
| `Shift + Play` | Skift til næste mediekilde |
| `Super + Shift + Backspace` | Slå vinduesmellemrum til/fra |
| `Super + Ctrl + Alt + F` | Slå fuldskærms-skrivebord til/fra (øverste bjælke + vinduesmellemrum) |

## Påmindelser

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Indstil en påmindelse  |
| `Super + Ctrl + Alt + R` | Se alle påmindelser  |
| `Super + Ctrl + Shift + R` | Ryd alle påmindelser  |

## Meddelelser

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vis klokkeslættet som notifikation  |
| `Super + Ctrl + Alt + B` | Vis batteri som notifikation  |
| `Super + Ctrl + Alt + W` | Slå vejret til/fra som notifikation  |

## Tmux

Præfikstasten er `Ctrl + Space` (`Ctrl + B` fungerer også). Du kan ændre disse bindinger i `~/.config/tmux/tmux.conf`.

### Ruder

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + v` | Del rude ved siden af (lodret) |
| `Prefix + h` | Del rude nedenunder (vandret) |
| `Prefix + x` | Luk rude |
| `Prefix + z` | Slå rudezoom til/fra (fuld skærm) |
| `Alt + Enter` | Del rude nedenunder (uden præfiks) |
| `Alt + Shift + Enter` | Del rude ved siden af (uden præfiks) |
| `Alt + Escape` | Luk rude (uden præfiks) |
| `Ctrl + Alt + Arrows` | Flyt mellem ruder |
| `Ctrl + Alt + Shift + Arrows` | Ændr størrelse på ruder |

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
| `Prefix + K` | Afslut session |
| `Prefix + R` | Omdøb session |
| `Prefix + N` | Næste session |
| `Prefix + P` | Forrige session |
| `Alt + Arrow Up/Down` | Flyt mellem sessioner |
| `Prefix + s` | Vis sessioner |
| `Prefix + d` | Frigør fra sessionen |

### Kopieringstilstand (vi-stil)

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + [` | Gå til kopieringstilstand |
| `v` | Begynd markering (i kopieringstilstand) |
| `y` | Kopiér markering (i kopieringstilstand) |

### Generelt

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + q` | Genindlæs konfiguration |
| `Prefix + ?` | Vis Tmux-genvejstaster |
| `Prefix + :` | Kommandoprompt |

### Tmux-layoutfunktioner

Disse funktioner skal køres inde i en Tmux-session.

| Kommando | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Opret udviklingslayout med editor, AI og terminal |
| `tdlm <ai> [<second_ai>]` | Opret udviklingslayout pr. undermappe |
| `tsl <count> <command>` | Opret sværmlayout med flere ruder |

## Ghostty-terminal

Ghostty-terminalen installeres ved hjælp af _Installer > Terminal_ via Omarchy-menuen.

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
| `Ctrl + Left mouse` | Åbn link i browseren |

## Filhåndtering

| Genvejstast              | Funktion                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Gå til sti                     |
| `Space`               | Forhåndsvis fil (pilene navigerer) |
| `Alt + Up`       | Gå op til den overordnede mappe        |

## Neovim (med lazyvim)

### Navigation

| Genvejstast                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Vis kommandomuligheder            |
| `Space Space`              | Åbn fil via fuzzy-søgning      |
| `Space E`                  | Slå sidebjælke til/fra                  |
| `Space G G`                | Vis git-kontroller               |
| `Space S G`                | Søg i filindhold             |
| `Ctrl + W W`               | Skift mellem sidebjælke og editor |
| `Ctrl + Left/right arrow`  | Ændr sidebjælkens størrelse          |
| `Shift + H`                      | Gå til venstre filfane             |
| `Shift + L`                      | Gå til højre filfane            |
| `Space B D`                | Luk filfane                  |

### Mens du er i sidebjælken

| Genvejstast                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `A`                        | Tilføj ny fil i den overordnede mappe      |
| `Shift + A`                | Tilføj ny undermappe i den overordnede mappe    |
| `D`                        | Slet den fremhævede fil/mappe     |
| `M`                        | Flyt den fremhævede fil/mappe       |
| `R`                        | Omdøb den fremhævede fil/mappe     |
| `?`                        | Vis hjælp til alle kommandoer      |

[Se alle Neovim-genvejstasterne konfigureret af LazyVim](https://www.lazyvim.org/keymaps).

## Hurtige emojis

Du kan bruge `Super + Ctrl + E` til at vise en komplet emoji-vælger, som lægger valget på udklipsholderen, eller du kan bruge disse muligheder for hurtig adgang.

| Genvejstast       | EM | Ledetråd       |
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
| `Shift + CapsLock M B` |🤯 | eksploderende |

## Hurtige udvidelser

| Genvejstast       | Udvidelse       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (lang tankestreg)   |
| `Shift + CapsLock Space N` | Dit navn (som indtastet under opsætningen)  |
| `Shift + CapsLock Space E` | Din e-mail (som indtastet under opsætningen)  |

Du kan tilføje flere af dine egne ved at redigere `~/.XCompose` og derefter køre `omarchy-restart-xcompose` i terminalen for at få ændringerne indlæst.
