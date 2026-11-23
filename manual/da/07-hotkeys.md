# Genvejstaster

Du kan se alle de vigtigste tastaturgenveje med `Super + K` (Tmux-genveje med `Super + Alt + K` og Herdr-genveje med `Super + Ctrl + K`).

## Sådan er genvejstaster opbygget

Hver genvejstast ligger på et plan, der bestemmes af dens modificeringstaster, og hvert plan har én opgave. Det er det, der holder genvejstasterne fra at flyde sammen, og det betyder, at du som regel kan gætte, hvor noget hører hjemme.

| Plan | Hvad der hører hjemme der | Eksempler |
| --- | --- | --- |
| `Super + key` | Systemet: vinduer, arbejdsområder, layouts og kernemenuer | `Super + Space` Omarchy-menu, `Super + W` luk vindue, `Super + F` fuld skærm |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Paneler og systemmenuer | `Super + Ctrl + A` lyd, `Super + Ctrl + N` netværk, `Super + Ctrl + C` optagelsesmenu |
| `Super + Ctrl + Alt + key` | Hurtige handlinger og beskeder | `Super + Ctrl + Alt + T` vis klokkeslæt, `Super + Ctrl + Alt + B` batteri, `Super + Ctrl + Alt + C` skærmbillede |

Når du føjer `Alt` til en genvejstast, får du en variant af det samme, aldrig noget helt urelateret:

- `Super + Shift + B` åbner browseren; `Super + Shift + Alt + B` åbner et privat vindue
- `Super + Shift + E` åbner e-mail; `Super + Shift + Alt + E` starter en ny
- `Super + F` går til fuld skærm; `Super + Alt + F` går til fuld bredde
- `Super + Ctrl + C` åbner optagelsesmenuen; `Super + Ctrl + Alt + C` springer menuen over og tager et skærmbillede

Når du tilføjer en genvejstast:

1. Vælg planet ud fra, hvad den gør, og vælg derefter tasten.
2. Flyt ikke en eksisterende genvejstast for at gøre plads. Find en ledig tast på det rigtige plan.
3. Brug kun `Alt` til en variant af genvejstasten uden den.

Nogle få genvejstaster bryder disse regler, fordi det er praktisk. `Shift` med en pil eller `Tab` flytter eller går baglæns i stedet for at åbne en app, og `Print`, medietasterne, `Alt + Tab` og `Ctrl + Alt + Del` fungerer på samme måde som alle andre steder. De er undtagelser, ikke mønstre, du skal kopiere.

Hvis en standardindstilling ikke passer dig (f.eks. hvis du vil have `Super + Shift + S` til skærmbilleder som på Windows), kan du ombinde den i `~/.config/hypr/bindings.lua`.

## Navigering

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-menu (apps og alt andet)    |
| `Super + Alt + Space` | Appoversigt |
| `Super + Escape` | Systemmenu (dvale, genstart osv.)  |
| `Super + Ctrl + L` | Lås computeren |
| `Super + W` or `Super + Q` | Luk vindue             |
| `Ctrl + Alt + Del` | Luk alle vinduer |
| `Super + K` | Vis alle genvejstaster |
| `Super + Alt + K` | Vis tmux-genvejstaster |
| `Super + Ctrl + K` | Vis herdr-genvejstaster |
| `Super + M` | Minimér vindue til docken |
| `Super + T`               | Skift vindue mellem fliselægning/flydende             |
| `Super + J` | Skift vinduesposition (vandret/lodret) |
| `Super + O`               | Sæt vindue til klæbende og flydende |
| `Super + L`               | Skift mellem layoutene dwindle, scrolling og floating |
| `Super + Alt + L`         | Skift mellem layoutene i omvendt rækkefølge |
| `Super + P`               | Skift pseudo-vinduesstil (naturlig vs. strakt) |
| `Super + F`                 | Gå til fuld skærm              |
| `Super + Alt + F`                 | Gå til fuld bredde              |
| `Super + Ctrl + F`                 | Gå til fuld skærm inde i vinduet              |
| `Super + 1…9/0`         | Hop til et bestemt arbejdsområde (0 er 10) på den fokuserede skærm |
| `Super + Tab` | Hop til næste arbejdsområde på den fokuserede skærm |
| `Super + Shift + Tab` | Hop til forrige arbejdsområde på den fokuserede skærm |
| `Super + Ctrl + Tab` | Hop til det tidligere arbejdsområde på den fokuserede skærm |
| `Super + Shift + 1…9/0` | Flyt vindue til arbejdsområde på den fokuserede skærm |
| `Super + Shift + Alt + 1…9/0` | Flyt vindue til arbejdsområde på den fokuserede skærm uden at følge med |
| `Super + S` | Slå fuld scratchpad til/fra |
| `Super + Alt + S` | Flyt vindue til fuld scratchpad |
| `Super + the key above Tab` (grave on US layouts) | Slå Quake-konsol til/fra |
| `Super + Shift + the key above Tab` (grave on US layouts) | Flyt vindue til Quake-konsol |
| `Super + Shift + Ctrl + Arrows` | Flyt vindue til skærmen i den retning |
| `Super + Shift + Alt + Arrows` | Flyt arbejdsområde til skærmen i den retning |
| `Super + Arrow`  | Flyt fokus til vindue i pilens retning, og kryds til skærmen på den side ved skærmkanten |
| `Super + Shift + Arrow`  | Byt vindue med et andet i pilens retning, herunder et på skærmen på den side |
| `Super + Minus` | Udvid vindue til venstre |
| `Super + Equal` | Formindsk vindue til venstre |
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
| `Super + Alt + 1/2/3/4/5`               | Hop til et bestemt vindue i gruppering      |
| `Super + Alt + Arrow`  | Flyt vindue ind i gruppering i pilens retning, herunder et på skærmen på den side |
| `Super + Ctrl + Left/Right`  | Flyt mellem vinduer i en flisegruppe |
| `Super + Ctrl + Z` | Zoom ind på skærmen (gentag for mere zoom) |
| `Super + Ctrl + Alt + Z` | Zoom helt ud fra skærmen |
| `Super + /` | Gå frem gennem indstillinger for skærmskalering |
| `Super + Alt + /` | Gå baglæns gennem indstillinger for skærmskalering |
| `Alt + Tab` | Skift fremad gennem vinduer på det aktive arbejdsområde |
| `Alt + Shift + Tab` | Skift baglæns gennem vinduer på det aktive arbejdsområde |
| `Ctrl + Alt + Tab`| Skift fokus fremad gennem skærme |
| `Ctrl + Alt + Shift + Tab`| Skift fokus baglæns gennem skærme |
| `Super + I` | Skift inputsprog (med mere end ét layout eller én inputmetode) |
| `Super + Shift + I` | Skift inputsprog tilbage |

På en touchpad skifter stryg med tre og fire fingre arbejdsområder, flytter vinduer og åbner menuen og Quake-konsollen; se [tastatur, mus og trackpad](34-keyboard-mouse-trackpad.md) for bevægelserne.

Størrelsesændring bruger de to taster til højre for 0, uanset hvad dit tastatur har trykt på dem: `-` og `=` på amerikanske tastaturer, `+` og `´` på dansk og svensk, `+` og `\` på norsk, `ß` og `´` på tysk, `'` og `¡` på spansk og `-` og `^` på japansk (JIS). `Super + K` viser dem, som dit tastatur skriver dem. På JIS er `Super + ^` lig med `Super + Equal`, mens `Super + Shift + -` (som skriver `=`) er `Super + Shift + Minus`. Skærmskalering og adgangskodehåndteringen bruger `/`; på layouts, der kun skriver `/` med Shift, som de fleste europæiske gør, bruger de i stedet tasten til venstre for højre Shift (`-` på dansk og tysk).

## Systemstyring

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Lydpanel    |
| `Super + Ctrl + B`           | Bluetooth-panel    |
| `Super + Ctrl + N`           | Wi-Fi/netværkspanel    |
| `Super + Ctrl + D`           | Skærmpanel    |
| `Super + Ctrl + P`           | Strømpanel    |
| `Super + Ctrl + X`           | Agentpanel    |
| `Super + Ctrl + Alt + D`           | Kalenderpanel    |
| `Super + Ctrl + Alt + E`           | Verdensurepanel    |
| `Super + Ctrl + 1-9`           | Slå bjælkepanel til/fra efter position    |
| `Super + Ctrl + S` | Delingsmenu (via LocalSend) |
| `Super + Ctrl + C` | Optagelsesstyring (skærmbillede/-optagelse/vælger) |
| `Super + Ctrl + O` | Slå menu til/fra |
| `Super + Ctrl + H` | Hardwaremenu |
| `Super + Ctrl + E` | Emojivælger |
| `Super + Ctrl + .` | Omkod medier |
| `Super + Shift + Ctrl + A` | Start din standardagent |
| `Power` key | Systemmenu |
| `Super + Shift + Copilot` key | Omarchy-menu |

## Justeringer

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimal skærmlysstyrke |
| `Shift + Brightness Down` | Minimal skærmlysstyrke |
| `Alt + Brightness Up/Down` | Præcise ændringer af lysstyrke på 1 % |
| `Alt + Volume Up/Down` | Præcise ændringer af lydstyrke på 1 % |
| `Keyboard Brightness Up/Down` | Tastaturbaggrundslys lysere/mørkere |
| `Keyboard Backlight` | Skift mellem niveauer for tastaturbaggrundslys |
| `Ctrl + Brightness Up/Down` | Tastaturbaggrundslys lysere/mørkere på tastaturer uden deres egne taster |
| `Mic Mute` | Slå mikrofonen fra |
| `Shift + Mute` | Skift lydudgang |
| `Touchpad Toggle` | Slå touchpaden til eller fra |
| `Display` key | Skift arbejdsområdets layout |
| `Alt + Play` | Næste nummer |
| `Alt + Shift + Play` | Forrige nummer |

## Start af apps

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agent manager) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (privat/inkognito)    |
| `Super + Shift + F`           | Filhåndtering    |
| `Super + Shift + Alt + F`           | Filhåndtering i terminalens cwd    |
| `Super + Shift + M`           | Musik (Spotify)    |
| `Super + Shift + Alt + M`           | Musik (cliamp)    |
| `Super + Shift + /`           | Adgangskodehåndtering (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Lommeregner (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, når det er installeret)    |
| `Super + Shift + T`           | Aktivitet (btop)    |
| `Super + Shift + N`           | Editor (Plain eller dit valgte standardprogram)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Ny e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Din standardagent eller ChatGPT, indtil du vælger en |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Messenger (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Messenger (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Messenger (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Skrivning (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nyt opslag) |
| `Super + Shift + Y`           | YouTube |

Du kan ændre/tilføje bindinger i `~/.config/hypr/bindings.lua`.

## Universel udklipsholder

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + A`           | Markér alt i apps, der understøtter `Ctrl + A`    |
| `Super + C`           | Kopiér    |
| `Super + X`           | Klip (ikke i terminalen)    |
| `Super + V`           | Indsæt    |
| `Super + Ctrl + V`           | Udklipsholderhåndtering    |

På Linux skal du normalt bruge `Ctrl + Shift + C/V` for at kopiere og indsætte i terminalen og `Ctrl + C/V` for at gøre det alle andre steder. Disse samlede Omarchy-genvejstaster til udklipsholderen fungerer overalt.

## Optagelse

| Genvejstast              | Funktion                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skærmbillede                      |
| `Super + Ctrl + Alt + C`            | Skærmbillede (det samme billede til tastaturer uden en Print Screen-tast) |
| `Super + Ctrl + C` | Optagelsesmenu |
| `Alt + Print Screen`            | Skærmoptagelse                     |
| `Super + Shift + Ctrl + Alt + C` | Skærmoptagelse uden lyd, uden om menuen (tryk igen for at stoppe) |
| `Super + Print Screen` | Farvevælger |
| `Super + Ctrl + Print Screen` | Tekstudtræk til udklipsholderen |
| `Super + Alt + [` | Gør webcam-overlay mindre under optagelse |
| `Super + Alt + ]` | Gør webcam-overlay større under optagelse |
| `Alt + Shift + L` | Kopiér den aktuelle URL fra webapp eller browser |
| `Alt + Shift + D` | Download videoen på den aktuelle side til `~/Videos` |
| `Alt + Space` | Start/stop diktering (kræver _Setup > Defaults > Dictation_) |
| `Right Alt` | Hold inde for at diktere (kræver _Setup > Defaults > Dictation_) |

Ved skærmoptagelser spørger genvejstasten først, hvilken lyd du vil have, og starter derefter optagelsen. Tryk på den igen for at stoppe. Se [skærmbilleder og optagelse](12-screenshots-recording.md) for detaljerne.

Alle optagelsesmuligheder er også tilgængelige under _Trigger > Capture_ i Omarchy-menuen (`Super + Space`).

## Notifikationer

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + ,` | Handl på den seneste notifikation: Åbn den, eller tryk på dens eneste knap, vælg blandt dens valgmuligheder, eller afvis den, når den ingen har  |
| `Super + Shift + ,` | Afvis alle notifikationer |
| `Super + Ctrl + ,` | Styr notifikationer med tastaturet  |
| `Super + Alt + ,` | Afvis den seneste notifikation  |
| `Super + Shift + Alt + ,` | Åbn notifikationshistorik  |
| `Super + Ctrl + Alt + ,` | Slå dæmpning af notifikationer til/fra  |

## Stil

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Vælg et nyt tema (også `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Vælg temabaggrund (også `Super + Ctrl + Space`) |
| `Super + Backspace` | Slå gennemsigtighed til/fra på et vindue |
| `Super + Ctrl + Backspace` | Slå kvadratisk format til/fra for et enkelt vindue |

Ekstra baggrundsbilleder ligger i `~/.config/omarchy/backgrounds/<theme name>`. De er også tilgængelige via _Install > Style > Background_ i Omarchy-menuen.

Alle stilmuligheder er også tilgængelige under _Appearance_ i Omarchy-menuen (`Super + Space`).

## Skifter

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Slå låsning ved inaktivitet til/fra |
| `Super + Ctrl + Delete` | Slå den bærbare computers skærm til/fra |
| `Super + Ctrl + Alt + Delete` | Slå spejling af den bærbare computers skærm til/fra |
| `Super + Shift + Space` | Slå den øverste bjælke til/fra  |
| `Shift + Mute` | Skift til næste lydudgang |
| `Shift + Play` | Skift til næste mediekilde |
| `Super + Shift + Backspace` | Slå vinduesmellemrum til/fra |
| `Super + Ctrl + Alt + F` | Slå fuldskærmsskrivebord til/fra (øverste bjælke + vinduesmellemrum) |

## Påmindelser

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Indstil en påmindelse  |
| `Super + Ctrl + Alt + R` | Se alle påmindelser  |
| `Super + Ctrl + Shift + R` | Ryd alle påmindelser  |

## Beskeder

| Genvejstast                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Vis klokkeslættet som notifikation  |
| `Super + Ctrl + Alt + B` | Vis batteriet som notifikation  |
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
| `Prefix + [` | Aktivér kopieringstilstand |
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

## Ghostty Terminal

Ghostty-terminalen installeres ved hjælp af _Install > Terminal_ via Omarchy-menuen.

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
| `Space`               | Forhåndsvis fil (pile navigerer) |
| `Alt + Up`       | Gå op til overordnet mappe        |

## Neovim (w/ lazyvim)

### Navigation

| Genvejstast                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Vis kommandoindstillinger            |
| `Space Space`              | Åbn fil via fuzzy-søgning      |
| `Space E`                  | Slå sidebjælke til/fra                  |
| `Space G G`                | Vis git-kontroller               |
| `Space S G`                | Søg i filindhold             |
| `Ctrl + W W`               | Hop mellem sidebjælke og editor |
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

[Se alle Neovim-genvejstaster, der er konfigureret af LazyVim](https://www.lazyvim.org/keymaps).

## Hurtige emojis

Du kan bruge `Super + Ctrl + E` til at vise en komplet emojivælger, som lægger det valgte på udklipsholderen, eller du kan bruge disse hurtige adgangsmuligheder.

| Genvejstast       | EM | Ledetråd       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smile      |
| `Shift + CapsLock M C` | 😂 | cry        |
| `Shift + CapsLock M L` | 😍 | love       |
| `Shift + CapsLock M V` | ✌️ | victory    |
| `Shift + CapsLock M H` | ❤️ | heart      |
| `Shift + CapsLock M Y` | 👍 | yes        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | wish       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | kiss       |
| `Shift + CapsLock M E` | 🙄 | eyeroll    |
| `Shift + CapsLock M I` | 😉 | wink       |
| `Shift + CapsLock M P` | 🙏 | pray |
| `Shift + CapsLock M D` | 🤤 | drool      |
| `Shift + CapsLock M M` | 💰 | money      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | greeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Hurtige fuldførelser

| Genvejstast       | Fuldførelse       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Dit navn (som indtastet under opsætningen)  |
| `Shift + CapsLock Space E` | Din e-mail (som indtastet under opsætningen)  |

Du kan tilføje flere af dine egne ved at redigere `~/.XCompose` og derefter køre `omarchy restart xcompose` i terminalen for at få ændringerne registreret.
