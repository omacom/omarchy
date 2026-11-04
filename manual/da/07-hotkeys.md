# Genvejstaster

Du kan se alle de vigtigste tastaturgenveje med `Super + K` (Tmux-genveje med `Super + Alt + K` og Herdr-genveje med `Super + Ctrl + K`).

## Sådan er genvejstaster lagt ud

Hver genvejstast ligger på et plan, bestemt af dens modifikatortaster, og hvert plan har én opgave. Det er det, der holder genvejstasterne fra at flyde sammen, og det betyder, at du som regel kan gætte, hvor noget hører hjemme.

| Plan | Hvad der hører hjemme der | Eksempler |
| --- | --- | --- |
| `Super + key` | Systemet: vinduer, arbejdsområder, layouts og kernemenuer | `Super + Space` Omarchy-menu, `Super + W` luk vindue, `Super + F` fuld skærm |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Paneler og systemmenuer | `Super + Ctrl + A` lyd, `Super + Ctrl + N` netværk, `Super + Ctrl + C` optagelsesmenu |
| `Super + Ctrl + Alt + key` | Hurtige handlinger og meddelelser | `Super + Ctrl + Alt + T` vis klokkeslæt, `Super + Ctrl + Alt + B` batteri, `Super + Ctrl + Alt + C` skærmbillede |

At tilføje `Alt` til en genvejstast giver dig en variant af det samme, aldrig noget ubeslægtet:

- `Super + Shift + B` åbner browseren; `Super + Shift + Alt + B` åbner et privat vindue
- `Super + Shift + E` åbner e-mail; `Super + Shift + Alt + E` starter en ny
- `Super + F` går i fuld skærm; `Super + Alt + F` går i fuld bredde
- `Super + Ctrl + C` åbner optagelsesmenuen; `Super + Ctrl + Alt + C` springer menuen over og tager et skærmbillede

Når du tilføjer en genvejstast:

1. Vælg planet ud fra, hvad den gør, og vælg derefter tasten.
2. Flyt ikke en eksisterende genvejstast for at gøre plads. Find en fri tast på det rigtige plan.
3. Brug kun `Alt` til en variant af genvejstasten uden den.

Nogle få genvejstaster bryder disse regler, fordi de er praktiske. `Shift` med en pil eller `Tab` flytter eller vender i stedet for at åbne en app, og `Print`, medietasterne, `Alt + Tab` og `Ctrl + Alt + Del` virker på samme måde som alle andre steder. De er undtagelser, ikke mønstre, du skal kopiere.

Hvis en standard ikke passer dig (f.eks. hvis du vil have `Super + Shift + S` til skærmbilleder som på Windows), skal du ombinde den i `~/.config/hypr/bindings.lua`.

## Navigation

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-menu (apps og alt andet) |
| `Super + Alt + Space` | Appgitter |
| `Super + Escape` | Systemmenu (dvale, genstart osv.) |
| `Super + Ctrl + L` | Lås computer |
| `Super + W` eller `Super + Q` | Luk vindue |
| `Ctrl + Alt + Del` | Luk alle vinduer |
| `Super + T` | Skift vindue mellem tiling/flydende |
| `Super + J` | Skift vinduesposition (vandret/lodret) |
| `Super + O` | Slå vindue til/fra som sticky'n'floating |
| `Super + L` | Bladr gennem dwindle-, scrolling- og floating-layouts |
| `Super + Alt + L` | Bladr gennem layouts i omvendt rækkefølge |
| `Super + P` | Skift pseudo-vinduesstil (naturlig vs. stræk) |
| `Super + F` | Gå i fuld skærm |
| `Super + Alt + F` | Gå i fuld bredde |
| `Super + Ctrl + F` | Gå i fuld skærm inde i vinduet |
| `Super + 1/2/3/4` | Hop til bestemt arbejdsområde på den fokuserede skærm |
| `Super + Tab` | Hop til næste arbejdsområde på den fokuserede skærm |
| `Super + Shift + Tab` | Hop til forrige arbejdsområde på den fokuserede skærm |
| `Super + Ctrl + Tab` | Hop til tidligere arbejdsområde på den fokuserede skærm |
| `Super + Shift + 1/2/3/4` | Flyt vindue til arbejdsområde på den fokuserede skærm |
| `Super + Shift + Alt + 1/2/3/4` | Flyt vindue til arbejdsområde på den fokuserede skærm uden at følge med |
| `Super + S` | Slå fuld scratchpad til/fra |
| `Super + Alt + S` | Flyt vindue til fuld scratchpad |
| `Super + Grave` | Slå Quake-konsol til/fra |
| `Super + Shift + Grave` | Flyt vindue til Quake-konsol |
| `Super + Shift + Ctrl + Arrows` | Flyt vindue til skærmen i den retning |
| `Super + Shift + Alt + Arrows` | Flyt arbejdsområde til skærmen i den retning |
| `Super + Arrow` | Flyt fokus til vindue i pilens retning, kryds til skærmen på den side ved skærmkanten |
| `Super + Shift + Arrow` | Byt vindue med et andet i pilens retning, inklusive et på skærmen på den side |
| `Super + Minus` | Udvid vindue til venstre |
| `Super + Equal` | Krymp vindue til venstre |
| `Super + Shift + Minus` | Krymp vindue opad |
| `Super + Shift + Equal` | Udvid vindue nedad |
| `Super + Alt + Minus/Equal` | Samme ændring af størrelse i mindre trin |
| `Super + Ctrl + Minus/Equal` | Samme ændring af størrelse i større trin |
| `Super + Alt + Home` | Gem vinduesbredde |
| `Super + Home` | Gendan gemt vinduesbredde |
| `Super + Left Mouse` | Træk vindue rundt |
| `Super + Right Mouse` | Ændr vinduesstørrelse |
| `Super + Scroll Wheel` | Rul gennem arbejdsområder på den fokuserede skærm |
| `Super + G` | Slå vinduesgruppering til/fra |
| `Super + Alt + G` | Flyt vindue ud af gruppering |
| `Super + Alt + Tab` | Bladr mellem vinduer i gruppering |
| `Super + Alt + Shift + Tab` | Bladr baglæns mellem vinduer i gruppering |
| `Super + Alt + Scroll Wheel` | Bladr mellem vinduer i gruppering |
| `Super + Alt + 1/2/3/4/5` | Hop til bestemt vindue i gruppering |
| `Super + Alt + Arrow` | Flyt vindue ind i gruppering i pilens retning, inklusive et på skærmen på den side |
| `Super + Ctrl + Left/Right` | Flyt mellem vinduer i en tiling-gruppe |
| `Super + Ctrl + Z` | Zoom ind på skærmen (gentag for mere zoom) |
| `Super + Ctrl + Alt + Z` | Zoom helt ud fra skærmen |
| `Super + /` | Gå frem gennem skærmskaleringsmuligheder |
| `Super + Alt + /` | Gå tilbage gennem skærmskaleringsmuligheder |
| `Alt + Tab` | Bladr frem gennem vinduer på det aktive arbejdsområde |
| `Alt + Shift + Tab` | Bladr tilbage gennem vinduer på det aktive arbejdsområde |
| `Ctrl + Alt + Tab` | Bladr fokus frem gennem skærme |
| `Ctrl + Alt + Shift + Tab` | Bladr fokus tilbage gennem skærme |

Genveje til ændring af størrelse bruger de fysiske taster `code:20` og `code:21` (XKB `<AE11>` og `<AE12>`), uanset hvilke tegn der er trykt på tastaturet. På amerikanske tastaturer er disse taster `-` og `=`; på japanske (JIS) tastaturer er de `-` og `^`; på spanske tastaturer er de `'` og `¡`. På JIS er `Super + ^` `Super + Equal`, mens `Super + Shift + -` (som skriver `=`) er `Super + Shift + Minus`.

## Systemkontroller

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Lydpanel |
| `Super + Ctrl + B` | Bluetooth-panel |
| `Super + Ctrl + N` | Wi-Fi/netværkspanel |
| `Super + Ctrl + D` | Skærmpanel |
| `Super + Ctrl + P` | Strømpanel |
| `Super + Ctrl + Alt + D` | Kalenderpanel |
| `Super + Ctrl + Alt + E` | Verdensurpanel |
| `Super + Ctrl + 1-9` | Slå bjælkepanel til/fra efter position |
| `Super + Ctrl + S` | Delingsmenu (via LocalSend) |
| `Super + Ctrl + C` | Optagelseskontroller (skærmbillede/-optagelse/vælger) |
| `Super + Ctrl + O` | Slå menu til/fra |
| `Super + Ctrl + H` | Hardwaremenu |
| `Super + Ctrl + E` | Emoji-vælger |
| `Super + Ctrl + .` | Transkod medier |
| `Super + Shift + Ctrl + A` | Vælg en AI-agent |

## Justeringer

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimal skærmlysstyrke |
| `Shift + Brightness Down` | Minimal skærmlysstyrke |
| `Alt + Brightness Up/Down` | Præcise ændringer af lysstyrke på 1 % |
| `Alt + Volume Up/Down` | Præcise ændringer af lydstyrke på 1 % |
| `Keyboard Brightness Up/Down` | Tastaturbaggrundslys lysere/mørkere |
| `Keyboard Backlight` | Bladr gennem niveauer for tastaturbaggrundslys |
| `Alt + Play` | Næste nummer |
| `Alt + Shift + Play` | Forrige nummer |

## Start af apps

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agentmanager) |
| `Super + Shift + Return` | Browser |
| `Super + Shift + Alt + B` | Browser (privat/inkognito) |
| `Super + Shift + F` | Filhåndtering |
| `Super + Shift + Alt + F` | Filhåndtering i terminalens cwd |
| `Super + Shift + M` | Musik (Spotify) |
| `Super + Shift + Alt + M` | Musik (cliamp) |
| `Super + Shift + /` | Adgangskodehåndtering (1password) |
| `Super + Shift + Q` | Lommeregner (Omacalc) |
| `Super + Shift + T` | Aktivitet (btop) |
| `Super + Shift + N` | Editor (Neovim) |
| `Super + Shift + C` | Kalender ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Ny e-mail ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Beskeder (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Beskeder (WhatsApp) |
| `Super + Shift + Ctrl + G` | Beskeder (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Skrivning (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Skift/tilføj genveje i `~/.config/hypr/bindings.lua`.

## Universel udklipsholder

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Super + A` | Markér alt i apps, der understøtter `Ctrl + A` |
| `Super + C` | Kopiér |
| `Super + X` | Klip (ikke i terminal) |
| `Super + V` | Sæt ind |
| `Super + Ctrl + V` | Udklipsholderhåndtering |

Normalt på Linux skal du bruge `Ctrl + Shift + C/V` for at kopiere og sætte ind i terminalen og `Ctrl + C/V` for at gøre det alle andre steder. Disse samlede Omarchy-genveje til udklipsholderen virker overalt.

## Optagelse

| Genvejstast | Funktion |
| ------------------- | ------------------------------ |
| `Print Screen` | Skærmbillede |
| `Super + Ctrl + Alt + C` | Skærmbillede (samme optagelse, til tastaturer uden Print Screen-tast) |
| `Super + Ctrl + C` | Optagelsesmenu |
| `Alt + Print Screen` | Skærmoptagelse |
| `Super + Print Screen` | Farvevælger |
| `Super + Ctrl + Print Screen` | Tekstudtræk til udklipsholder |
| `Super + Alt + [` | Gør webcam-overlay mindre under optagelse |
| `Super + Alt + ]` | Gør webcam-overlay større under optagelse |
| `Alt + Shift + L` | Kopiér aktuel URL fra webapp eller Chromium |
| `Alt + Shift + D` | Download videoen på den aktuelle side til `~/Videos` |
| `Alt + Space` | Start/stop diktering (kræver _Setup > Defaults > Dictation_) |
| `Right Alt` | Hold nede for at diktere (kræver _Setup > Defaults > Dictation_) |

Ved skærmoptagelser spørger genvejstasten først, hvilken lyd du vil have, og starter derefter optagelsen. Tryk på den igen for at stoppe. Se [skærmbilleder og optagelse](12-screenshots-recording.md) for detaljerne.

Alle optagelsesmuligheder er også tilgængelige under _Trigger > Capture_ i Omarchy-menuen (`Super + Space`).

## Notifikationer

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Super + ,` | Handl på seneste notifikation: åbn den eller tryk på dens eneste knap, vælg blandt dens valgmuligheder, eller afvis den, når den ingen har |
| `Super + Shift + ,` | Afvis alle notifikationer |
| `Super + Ctrl + ,` | Styr notifikationer med tastaturet |
| `Super + Alt + ,` | Afvis seneste notifikation |
| `Super + Shift + Alt + ,` | Åbn notifikationshistorik |
| `Super + Ctrl + Alt + ,` | Slå stilhed for notifikationer til/fra |

## Stil

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vælg et nyt tema (også `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vælg temabaggrund (også `Super + Ctrl + Space`) |
| `Super + Backspace` | Slå gennemsigtighed til/fra på et vindue |
| `Super + Ctrl + Backspace` | Slå kvadratisk format for enkelt vindue til/fra |

Ekstra baggrundsbilleder ligger i `~/.config/omarchy/backgrounds/<theme name>`. Også tilgængelig via _Install > Style > Background_ i Omarchy-menuen.

Alle stilmuligheder er også tilgængelige under _Style_ i Omarchy-menuen (`Super + Space`).

## Til/fra

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Slå låsning ved inaktivitet til/fra |
| `Super + Ctrl + Delete` | Slå bærbar skærm til/fra |
| `Super + Ctrl + Alt + Delete` | Slå spejling af bærbar skærm til/fra |
| `Super + Shift + Space` | Slå topbjælken til/fra |
| `Shift + Mute` | Skift til næste lydudgang |
| `Shift + Play` | Skift til næste mediekilde |
| `Super + Shift + Backspace` | Slå vinduesmellemrum til/fra |
| `Super + Ctrl + Alt + F` | Slå fuldskærmsskrivebord til/fra (topbjælke + vinduesmellemrum) |

## Påmindelser

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Sæt en påmindelse |
| `Super + Ctrl + Alt + R` | Se alle påmindelser |
| `Super + Ctrl + Shift + R` | Ryd alle påmindelser |

## Meddelelser

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vis klokkeslæt som notifikation |
| `Super + Ctrl + Alt + B` | Vis batteri som notifikation |
| `Super + Ctrl + Alt + W` | Slå vejr som notifikation til/fra |

## Tmux

Præfikstasten er `Ctrl + Space` (`Ctrl + B` virker også). Du kan ændre disse genveje i `~/.config/tmux/tmux.conf`.

### Ruder

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Prefix + v` | Opdel rude ved siden af (lodret) |
| `Prefix + h` | Opdel rude nedenunder (vandret) |
| `Prefix + x` | Luk rude |
| `Prefix + z` | Slå rudezoom til/fra (fuld skærm) |
| `Alt + Enter` | Opdel rude nedenunder (uden præfiks) |
| `Alt + Shift + Enter` | Opdel rude ved siden af (uden præfiks) |
| `Alt + Escape` | Luk rude (uden præfiks) |
| `Ctrl + Alt + Arrows` | Flyt mellem ruder |
| `Ctrl + Alt + Shift + Arrows` | Ændr størrelse på ruder |

### Vinduer

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Prefix + c` | Nyt vindue |
| `Prefix + k` | Luk vindue |
| `Prefix + r` | Omdøb vindue |
| `Alt + 1-9` | Gå til bestemt vindue |
| `Alt + Arrow Left/Right` | Flyt mellem vinduer |
| `Alt + Shift + Arrow Left/Right` | Flyt vindue til venstre/højre |

### Sessioner

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Prefix + C` | Ny session |
| `Prefix + K` | Luk session |
| `Prefix + R` | Omdøb session |
| `Prefix + N` | Næste session |
| `Prefix + P` | Forrige session |
| `Alt + Arrow Up/Down` | Flyt mellem sessioner |
| `Prefix + s` | Vis sessioner |
| `Prefix + d` | Kobl fra session |

### Kopieringstilstand (vi-stil)

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Prefix + [` | Gå i kopieringstilstand |
| `v` | Begynd markering (i kopieringstilstand) |
| `y` | Kopiér markering (i kopieringstilstand) |

### Generelt

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Prefix + q` | Genindlæs konfiguration |
| `Prefix + ?` | Vis Tmux-genvejstaster |
| `Prefix + :` | Kommandoprompt |

### Tmux-layoutfunktioner

Disse funktioner skal køres inde i en Tmux-session.

| Kommando | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Opret dev-layout med editor, AI og terminal |
| `tdlm <ai> [<second_ai>]` | Opret dev-layout pr. undermappe |
| `tsl <count> <command>` | Opret swarm-layout med flere ruder |

## Ghostty Terminal

Ghostty-terminal installeres med _Install > Terminal_ via Omarchy-menuen.

| Genvejstast | Funktion |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ny opdeling nedenunder |
| `Ctrl + Shift + O` | Ny opdeling ved siden af |
| `Ctrl + Alt + Arrows` | Flyt mellem opdelinger |
| `Super + Ctrl + Shift + Arrows` | Ændr opdeling med 10 linjer |
| `Super + Ctrl + Shift + Alt + Arrows` | Ændr opdeling med 100 linjer |
| `Ctrl + Shift + T` | Ny fane |
| `Ctrl + Shift + Arrows` | Flyt mellem faner |
| `Alt + Numbers` | Gå til bestemt fane |
| `Shift + Pg Up/Down` | Rul i historikken |
| `Ctrl + Left mouse` | Åbn link i browser |

## Filhåndtering

| Genvejstast | Funktion |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Gå til sti |
| `Space` | Forhåndsvis fil (pile navigerer) |
| `Alt + Up` | Gå op til overordnet mappe |

## Neovim (med lazyvim)

### Navigation

| Genvejstast | Funktion |
| ------------------------ | ------------------------------- |
| `Space` | Vis kommandomuligheder |
| `Space Space` | Åbn fil via fuzzy-søgning |
| `Space E` | Slå sidebjælke til/fra |
| `Space G G` | Vis git-kontroller |
| `Space S G` | Søg i filindhold |
| `Ctrl + W W` | Hop mellem sidebjælke og editor |
| `Ctrl + Left/right arrow` | Ændr størrelse på sidebjælke |
| `Shift + H` | Gå til venstre filfane |
| `Shift + L` | Gå til højre filfane |
| `Space B D` | Luk filfane |

### Mens du er i sidebjælken

| Genvejstast | Funktion |
| ------------------------ | ------------------------------- |
| `A` | Tilføj ny fil i overordnet mappe |
| `Shift + A` | Tilføj ny undermappe i overordnet mappe |
| `D` | Slet fremhævet fil/mappe |
| `M` | Flyt fremhævet fil/mappe |
| `R` | Omdøb fremhævet fil/mappe |
| `?` | Vis hjælp til alle kommandoer |

[Se alle Neovim-genvejstaster konfigureret af LazyVim](https://www.lazyvim.org/keymaps).

## Hurtige emojis

Du kan bruge `Super + Ctrl + E` til at vise en komplet emoji-vælger, der lægger det valgte på udklipsholderen, eller du kan bruge disse hurtigadgangsmuligheder.

| Genvejstast | EM | Vink |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smil |
| `Shift + CapsLock M C` | 😂 | græd |
| `Shift + CapsLock M L` | 😍 | kærlighed |
| `Shift + CapsLock M V` | ✌️ | sejr |
| `Shift + CapsLock M H` | ❤️ | hjerte |
| `Shift + CapsLock M Y` | 👍 | ja |
| `Shift + CapsLock M N` | 👎 | nej |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | ønske |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | kys |
| `Shift + CapsLock M E` | 🙄 | øjenrul |
| `Shift + CapsLock M I` | 😉 | blink |
| `Shift + CapsLock M P` | 🙏 | bed |
| `Shift + CapsLock M D` | 🤤 | savl |
| `Shift + CapsLock M M` | 💰 | penge |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | skål |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | hilsen |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Hurtige fuldførelser

| Genvejstast | Fuldførelse |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Dit navn (som indtastet under opsætning) |
| `Shift + CapsLock Space E` | Din e-mail (som indtastet under opsætning) |

Du kan tilføje flere af dine egne ved at redigere `~/.XCompose` og derefter køre `omarchy-restart-xcompose` i terminalen for at få ændringerne registreret.
