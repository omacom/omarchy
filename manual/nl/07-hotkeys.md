# Sneltoetsen

Je kunt alle belangrijke toetsbindingen zien met `Super + K` (Tmux-bindingen met `Super + Alt + K` en Herdr-bindingen met `Super + Ctrl + K`).

## Hoe sneltoetsen zijn ingedeeld

Elke sneltoets bevindt zich op een vlak, bepaald door de modificatietoetsen, en elk vlak heeft één taak. Daardoor blijven de sneltoetsen overzichtelijk en kun je meestal raden waar iets te vinden is.

| Vlak | Wat daar te vinden is | Voorbeelden |
| --- | --- | --- |
| `Super + key` | Het systeem: vensters, werkruimtes, lay-outs en kernmenu's | `Super + Space` Omarchy-menu, `Super + W` venster sluiten, `Super + F` volledig scherm |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panelen en systeemmenu's | `Super + Ctrl + A` audio, `Super + Ctrl + N` netwerk, `Super + Ctrl + C` menu voor vastleggen |
| `Super + Ctrl + Alt + key` | Snelle acties en mededelingen | `Super + Ctrl + Alt + T` tijd tonen, `Super + Ctrl + Alt + B` batterij, `Super + Ctrl + Alt + C` schermafbeelding |

Door `Alt` aan een sneltoets toe te voegen, krijg je een variant van hetzelfde, nooit iets dat er niets mee te maken heeft:

- `Super + Shift + B` opent de browser; `Super + Shift + Alt + B` opent een privévenster
- `Super + Shift + E` opent e-mail; `Super + Shift + Alt + E` begint een nieuwe e-mail
- `Super + F` gaat naar volledig scherm; `Super + Alt + F` gaat naar volledige breedte
- `Super + Ctrl + C` opent het menu voor vastleggen; `Super + Ctrl + Alt + C` slaat het menu over en maakt een schermafbeelding

Bij het toevoegen van een sneltoets:

1. Kies eerst het vlak op basis van wat de sneltoets doet, en kies daarna de toets.
2. Verplaats geen bestaande sneltoets om ruimte te maken. Zoek een vrije toets op het juiste vlak.
3. Gebruik `Alt` alleen voor een variant van de sneltoets zonder `Alt`.

Een paar sneltoetsen breken deze regels omdat dat handig is. `Shift` met een pijl of `Tab` verplaatst of keert om in plaats van een app te openen, en `Print`, de mediatoetsen, `Alt + Tab` en `Ctrl + Alt + Del` werken zoals overal elders. Dat zijn uitzonderingen, geen patronen om te kopiëren.

Als een standaardinstelling je niet bevalt (stel dat je `Super + Shift + S` wilt voor schermafbeeldingen, zoals op Windows), wijzig de binding dan in `~/.config/hypr/bindings.lua`.

## Navigeren

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-menu (apps en al het andere)    |
| `Super + Alt + Space` | App-raster |
| `Super + Escape` | Systeemmenu (sluimerstand, herstarten, enz.)  |
| `Super + Ctrl + L` | Computer vergrendelen |
| `Super + W` or `Super + Q` | Venster sluiten             |
| `Ctrl + Alt + Del` | Alle vensters sluiten |
| `Super + T`               | Venster schakelen tussen tiling/zwevend             |
| `Super + J` | Vensterpositie schakelen (horizontaal/verticaal) |
| `Super + O`               | Venster schakelen naar sticky'n'floating |
| `Super + L`               | Door de dwindle-, scrolling- en floating-lay-outs bladeren |
| `Super + Alt + L`         | In omgekeerde volgorde door de lay-outs bladeren |
| `Super + P`               | Pseudovensterstijl schakelen (natural v stretch) |
| `Super + F`                 | Naar volledig scherm              |
| `Super + Alt + F`                 | Naar volledige breedte              |
| `Super + Ctrl + F`                 | Naar volledig scherm binnen het venster              |
| `Super + 1/2/3/4`         | Naar een specifieke werkruimte op de gefocuste monitor springen |
| `Super + Tab` | Naar de volgende werkruimte op de gefocuste monitor springen |
| `Super + Shift + Tab` | Naar de vorige werkruimte op de gefocuste monitor springen |
| `Super + Ctrl + Tab` | Naar de eerdere werkruimte op de gefocuste monitor springen |
| `Super + Shift + 1/2/3/4` | Venster naar een werkruimte op de gefocuste monitor verplaatsen |
| `Super + Shift + Alt + 1/2/3/4` | Venster naar een werkruimte op de gefocuste monitor verplaatsen zonder te volgen |
| `Super + S` | Volledig scratchpad schakelen |
| `Super + Alt + S` | Venster naar het volledige scratchpad verplaatsen |
| `Super + Grave` | Quake-console schakelen |
| `Super + Shift + Grave` | Venster naar de Quake-console verplaatsen |
| `Super + Shift + Ctrl + Arrows` | Venster naar de monitor in die richting verplaatsen |
| `Super + Shift + Alt + Arrows` | Werkruimte naar de monitor in die richting verplaatsen |
| `Super + Arrow`  | Focus verplaatsen naar het venster in de richting van de pijl, aan de schermrand overgaand naar de monitor aan die kant |
| `Super + Shift + Arrow`  | Venster verwisselen met een ander venster in de richting van de pijl, inclusief een venster op de monitor aan die kant |
| `Super + Minus` | Venster naar links uitbreiden |
| `Super + Equal` | Venster naar links verkleinen |
| `Super + Shift + Minus` | Venster naar boven verkleinen |
| `Super + Shift + Equal` | Venster naar beneden uitbreiden |
| `Super + Alt + Minus/Equal` | Dezelfde formaatwijziging in kleinere stappen |
| `Super + Ctrl + Minus/Equal` | Dezelfde formaatwijziging in grotere stappen |
| `Super + Alt + Home` | Vensterbreedte opslaan |
| `Super + Home` | Opgeslagen vensterbreedte herstellen |
| `Super + Left Mouse` | Venster slepen |
| `Super + Right Mouse` | Formaat van het venster wijzigen |
| `Super + Scroll Wheel` | Door werkruimtes op de gefocuste monitor scrollen |
| `Super + G`               | Venstergroepering schakelen      |
| `Super + Alt + G`               | Venster uit de groepering halen      |
| `Super + Alt + Tab`               | Tussen vensters in de groepering bladeren      |
| `Super + Alt + Shift + Tab`               | Achterwaarts tussen vensters in de groepering bladeren      |
| `Super + Alt + Scroll Wheel` | Tussen vensters in de groepering bladeren |
| `Super + Alt + 1/2/3/4/5`               | Naar een specifiek venster in de groepering springen      |
| `Super + Alt + Arrow`  | Venster in de richting van de pijl in de groepering plaatsen, inclusief een venster op de monitor aan die kant |
| `Super + Ctrl + Left/Right`  | Tussen vensters binnen een tiling-groep bewegen |
| `Super + Ctrl + Z` | Op het scherm inzoomen (herhaal voor meer zoom) |
| `Super + Ctrl + Alt + Z` | Volledig van het scherm uitzoomen |
| `Super + /` | Vooruit door de opties voor monitorschaling stappen |
| `Super + Alt + /` | Achteruit door de opties voor monitorschaling stappen |
| `Alt + Tab` | Vooruit door de vensters op de actieve werkruimte bladeren |
| `Alt + Shift + Tab` | Achteruit door de vensters op de actieve werkruimte bladeren |
| `Ctrl + Alt + Tab`| Focus vooruit langs de monitoren laten rouleren |
| `Ctrl + Alt + Shift + Tab`| Focus achteruit langs de monitoren laten rouleren |

Sneltoetsen voor formaatwijziging gebruiken de fysieke toetsen `code:20` en `code:21` (XKB `<AE11>` en `<AE12>`), ongeacht de tekens die op het toetsenbord zijn gedrukt. Op Amerikaanse toetsenborden zijn deze toetsen `-` en `=`; op Japanse (JIS) toetsenborden zijn het `-` en `^`; op Spaanse toetsenborden zijn het `'` en `¡`. Op JIS is `Super + ^` gelijk aan `Super + Equal`, terwijl `Super + Shift + -` (waarmee je `=` typt) gelijk is aan `Super + Shift + Minus`.

## Systeemregeling

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audiopaneel    |
| `Super + Ctrl + B`           | Bluetooth-paneel    |
| `Super + Ctrl + N`           | Wifi-/netwerkpaneel    |
| `Super + Ctrl + D`           | Schermpaneel    |
| `Super + Ctrl + P`           | Energiepaneel    |
| `Super + Ctrl + Alt + D`           | Kalenderpaneel    |
| `Super + Ctrl + Alt + E`           | Wereldklokpaneel    |
| `Super + Ctrl + 1-9`           | Balkpaneel op positie schakelen    |
| `Super + Ctrl + S` | Deelmenu (via LocalSend) |
| `Super + Ctrl + C` | Bediening voor vastleggen (schermafbeelding/-opname/kiezer) |
| `Super + Ctrl + O` | Menu schakelen |
| `Super + Ctrl + H` | Hardwaremenu |
| `Super + Ctrl + E` | Emoji-kiezer |
| `Super + Ctrl + .` | Media transcoderen |
| `Super + Shift + Ctrl + A` | Een AI-agent kiezen |

## Aanpassingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximale schermhelderheid |
| `Shift + Brightness Down` | Minimale schermhelderheid |
| `Alt + Brightness Up/Down` | Nauwkeurige helderheidswijzigingen van 1% |
| `Alt + Volume Up/Down` | Nauwkeurige volumewijzigingen van 1% |
| `Keyboard Brightness Up/Down` | Toetsenbordverlichting feller/dimmer |
| `Keyboard Backlight` | Door de niveaus van de toetsenbordverlichting bladeren |
| `Alt + Play` | Volgend nummer |
| `Alt + Shift + Play` | Vorig nummer |

## Apps starten

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agentbeheerder) |
| `Super + Shift + Return`           | Browser    |
| `Super + Shift + Alt + B`           | Browser (privé/incognito)    |
| `Super + Shift + F`           | Bestandsbeheerder    |
| `Super + Shift + Alt + F`           | Bestandsbeheerder in de cwd van de terminal    |
| `Super + Shift + M`           | Muziek (Spotify)    |
| `Super + Shift + Alt + M`           | Muziek (cliamp)    |
| `Super + Shift + /`           | Wachtwoordbeheerder (1password)    |
| `Super + Shift + Q`           | Rekenmachine (Omacalc)    |
| `Super + Shift + T`           | Activiteit (btop)    |
| `Super + Shift + N`           | Editor (Neovim)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nieuwe e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Messenger (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Messenger (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Messenger (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Schrijven (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Wijzig/voeg bindingen toe in `~/.config/hypr/bindings.lua`.

## Universeel klembord

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + A`           | Alles selecteren in apps die `Ctrl + A` ondersteunen    |
| `Super + C`           | Kopiëren    |
| `Super + X`           | Knippen (niet in de terminal)    |
| `Super + V`           | Plakken    |
| `Super + Ctrl + V`           | Klembordbeheerder    |

Normaal heb je op Linux `Ctrl + Shift + C/V` nodig om in de terminal te kopiëren en plakken en `Ctrl + C/V` om dat overal elders te doen. Deze uniforme klembordsneltoetsen van Omarchy werken overal.

## Vastleggen

| Sneltoets              | Functie                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Schermafbeelding                      |
| `Super + Ctrl + Alt + C`            | Schermafbeelding (dezelfde opname, voor toetsenborden zonder Print Screen-toets) |
| `Super + Ctrl + C` | Menu voor vastleggen |
| `Alt + Print Screen`            | Schermopname                     |
| `Super + Print Screen` | Kleurkiezer |
| `Super + Ctrl + Print Screen` | Tekstextractie naar het klembord |
| `Super + Alt + [` | Webcam-overlay kleiner maken tijdens het opnemen |
| `Super + Alt + ]` | Webcam-overlay groter maken tijdens het opnemen |
| `Alt + Shift + L` | Huidige URL kopiëren uit een webapp of Chromium |
| `Alt + Shift + D` | De video op de huidige pagina downloaden naar `~/Videos` |
| `Alt + Space` | Dicteren starten/stoppen (vereist _Setup > Defaults > Dictation_) |
| `Right Alt` | Ingedrukt houden om te dicteren (vereist _Setup > Defaults > Dictation_) |

Bij schermopnames vraagt de sneltoets eerst welke audio je wilt en begint daarna met opnemen. Druk er nogmaals op om te stoppen. Zie [schermafbeeldingen en opnames](12-screenshots-recording.md) voor de details.

Alle opties voor vastleggen zijn ook toegankelijk onder _Trigger > Capture_ in het Omarchy-menu (`Super + Space`).

## Meldingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + ,` | Actie uitvoeren op de nieuwste melding: deze openen of op de enige knop drukken, uit de keuzes kiezen, of deze sluiten als er geen keuzes zijn  |
| `Super + Shift + ,` | Alle meldingen sluiten |
| `Super + Ctrl + ,` | Meldingen met het toetsenbord bedienen  |
| `Super + Alt + ,` | Nieuwste melding sluiten  |
| `Super + Shift + Alt + ,` | Meldingsgeschiedenis openen  |
| `Super + Ctrl + Alt + ,` | Meldingen dempen in-/uitschakelen  |

## Stijl

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Een nieuw thema kiezen (ook `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Achtergrond voor het thema kiezen (ook `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparantie op een venster schakelen |
| `Super + Ctrl + Backspace` | Vierkante beeldverhouding voor één venster schakelen |

Extra achtergrondafbeeldingen staan in `~/.config/omarchy/backgrounds/<theme name>`. Ook beschikbaar via _Install > Style > Background_ in het Omarchy-menu.

Alle stijlopties zijn ook toegankelijk onder _Style_ in het Omarchy-menu (`Super + Space`).

## Schakelopties

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Vergrendeling bij inactiviteit schakelen |
| `Super + Ctrl + Delete` | Laptopscherm aan/uit schakelen |
| `Super + Ctrl + Alt + Delete` | Spiegelen van het laptopscherm schakelen |
| `Super + Shift + Space` | De bovenbalk schakelen  |
| `Shift + Mute` | Naar de volgende audio-uitvoer schakelen |
| `Shift + Play` | Naar de volgende mediabron schakelen |
| `Super + Shift + Backspace` | Vensterruimtes schakelen |
| `Super + Ctrl + Alt + F` | Volledig scherm voor het bureaublad schakelen (bovenbalk + vensterruimtes) |

## Herinneringen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Een herinnering instellen  |
| `Super + Ctrl + Alt + R` | Alle herinneringen bekijken  |
| `Super + Ctrl + Shift + R` | Alle herinneringen wissen  |

## Mededelingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Tijd als melding tonen  |
| `Super + Ctrl + Alt + B` | Batterij als melding tonen  |
| `Super + Ctrl + Alt + W` | Weer als melding schakelen  |

## Tmux

De prefix-toets is `Ctrl + Space` (`Ctrl + B` werkt ook). Je kunt deze bindingen wijzigen in `~/.config/tmux/tmux.conf`.

### Deelvensters

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + v` | Deelvenster ernaast splitsen (verticaal) |
| `Prefix + h` | Deelvenster eronder splitsen (horizontaal) |
| `Prefix + x` | Deelvenster sluiten |
| `Prefix + z` | Zoom van het deelvenster schakelen (volledig scherm) |
| `Alt + Enter` | Deelvenster eronder splitsen (geen prefix) |
| `Alt + Shift + Enter` | Deelvenster ernaast splitsen (geen prefix) |
| `Alt + Escape` | Deelvenster sluiten (geen prefix) |
| `Ctrl + Alt + Arrows` | Tussen deelvensters bewegen |
| `Ctrl + Alt + Shift + Arrows` | Formaat van deelvensters wijzigen |

### Vensters

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nieuw venster |
| `Prefix + k` | Venster sluiten |
| `Prefix + r` | Venster hernoemen |
| `Alt + 1-9` | Naar een specifiek venster gaan |
| `Alt + Arrow Left/Right` | Tussen vensters bewegen |
| `Alt + Shift + Arrow Left/Right` | Venster naar links/rechts verplaatsen |

### Sessies

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nieuwe sessie |
| `Prefix + K` | Sessie beëindigen |
| `Prefix + R` | Sessie hernoemen |
| `Prefix + N` | Volgende sessie |
| `Prefix + P` | Vorige sessie |
| `Alt + Arrow Up/Down` | Tussen sessies bewegen |
| `Prefix + s` | Sessies weergeven |
| `Prefix + d` | Van de sessie loskoppelen |

### Kopieermodus (vi-stijl)

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopieermodus openen |
| `v` | Selectie beginnen (in de kopieermodus) |
| `y` | Selectie kopiëren (in de kopieermodus) |

### Algemeen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + q` | Configuratie opnieuw laden |
| `Prefix + ?` | Tmux-toetsbindingen tonen |
| `Prefix + :` | Opdrachtprompt |

### Tmux-lay-outfuncties

Deze functies moeten binnen een Tmux-sessie worden uitgevoerd.

| Opdracht | Functie |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-lay-out maken met editor, AI en terminal |
| `tdlm <ai> [<second_ai>]` | Dev-lay-out per submap maken |
| `tsl <count> <command>` | Swarm-lay-out met meerdere deelvensters maken |

## Ghostty Terminal

De Ghostty-terminal wordt geïnstalleerd met _Install > Terminal_ via het Omarchy-menu.

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nieuwe splitsing eronder |
| `Ctrl + Shift + O` | Nieuwe splitsing ernaast |
| `Ctrl + Alt + Arrows` | Tussen splitsingen bewegen |
| `Super + Ctrl + Shift + Arrows` | Formaat van de splitsing met 10 regels wijzigen |
| `Super + Ctrl + Shift + Alt + Arrows` | Formaat van de splitsing met 100 regels wijzigen |
| `Ctrl + Shift + T` | Nieuw tabblad  |
| `Ctrl + Shift + Arrows` | Tussen tabbladen bewegen |
| `Alt + Numbers` | Naar een specifiek tabblad gaan |
| `Shift + Pg Up/Down` | Door de geschiedenis scrollen |
| `Ctrl + Left mouse` | Link in de browser openen |

## Bestandsbeheerder

| Sneltoets              | Functie                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Naar een pad gaan                     |
| `Space`               | Bestand voorvertonen (pijlen om te navigeren) |
| `Alt + Up`       | Omhoog naar de bovenliggende map        |

## Neovim (met lazyvim)

### Navigatie

| Sneltoets                   | Functie                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Opdrachtopties tonen            |
| `Space Space`              | Bestand openen via fuzzy zoeken      |
| `Space E`                  | Zijbalk schakelen                  |
| `Space G G`                | Git-bediening tonen               |
| `Space S G`                | Inhoud van bestanden zoeken             |
| `Ctrl + W W`               | Tussen de zijbalk en de editor springen |
| `Ctrl + Left/right arrow`  | Formaat van de zijbalk wijzigen          |
| `Shift + H`                      | Naar het linker bestandstabblad gaan             |
| `Shift + L`                      | Naar het rechter bestandstabblad gaan            |
| `Space B D`                | Bestandstabblad sluiten                  |

### In de zijbalk

| Sneltoets                   | Functie                        |
| ------------------------ | ------------------------------- |
| `A`                        | Nieuw bestand toevoegen in de bovenliggende map      |
| `Shift + A`                | Nieuwe submap toevoegen in de bovenliggende map    |
| `D`                        | Gemarkeerd bestand/map verwijderen     |
| `M`                        | Gemarkeerd bestand/map verplaatsen       |
| `R`                        | Gemarkeerd bestand/map hernoemen     |
| `?`                        | Help voor alle opdrachten tonen      |

[Bekijk alle Neovim-sneltoetsen die door LazyVim zijn geconfigureerd](https://www.lazyvim.org/keymaps).

## Snelle emoji's

Je kunt `Super + Ctrl + E` gebruiken om een volledige emoji-kiezer te tonen die de selectie op het klembord zet, of je kunt deze snelle toegangsopties gebruiken.

| Sneltoets       | EM | Aanwijzing       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | glimlach      |
| `Shift + CapsLock M C` | 😂 | huilen        |
| `Shift + CapsLock M L` | 😍 | liefde       |
| `Shift + CapsLock M V` | ✌️ | overwinning    |
| `Shift + CapsLock M H` | ❤️ | hart      |
| `Shift + CapsLock M Y` | 👍 | ja        |
| `Shift + CapsLock M N` | 👎 | nee         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | wens       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | kus       |
| `Shift + CapsLock M E` | 🙄 | oogrol    |
| `Shift + CapsLock M I` | 😉 | knipoog       |
| `Shift + CapsLock M P` | 🙏 | bidden |
| `Shift + CapsLock M D` | 🤤 | kwijlen      |
| `Shift + CapsLock M M` | 💰 | geld      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | proost      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | begroeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | verbijsterend |

## Snelle aanvullingen

| Sneltoets       | Aanvulling       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Je naam (zoals ingevoerd tijdens de installatie)  |
| `Shift + CapsLock Space E` | Je e-mail (zoals ingevoerd tijdens de installatie)  |

Je kunt er zelf meer toevoegen door `~/.XCompose` te bewerken en daarna `omarchy-restart-xcompose` in de terminal uit te voeren, zodat de wijzigingen worden opgepikt.
