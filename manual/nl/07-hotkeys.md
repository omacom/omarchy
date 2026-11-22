# Sneltoetsen

Je kunt alle belangrijkste toetsenbordbindingen zien met `Super + K` (Tmux-bindingen met `Super + Alt + K` en Herdr-bindingen met `Super + Ctrl + K`).

## Hoe sneltoetsen zijn ingedeeld

Elke sneltoets bevindt zich op een vlak, bepaald door de modificatietoetsen, en elk vlak heeft één taak. Daardoor blijven de sneltoetsen niet in elkaar overlopen, en kun je meestal raden waar iets thuishoort.

| Vlak | Wat daar thuishoort | Voorbeelden |
| --- | --- | --- |
| `Super + key` | Het systeem: vensters, werkruimtes, lay-outs en kernmenu's | `Super + Space` Omarchy-menu, `Super + W` venster sluiten, `Super + F` volledig scherm |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panelen en systeemmenu's | `Super + Ctrl + A` audio, `Super + Ctrl + N` netwerk, `Super + Ctrl + C` vastlegmenu |
| `Super + Ctrl + Alt + key` | Snelle acties en kennisgevingen | `Super + Ctrl + Alt + T` tijd weergeven, `Super + Ctrl + Alt + B` batterij, `Super + Ctrl + Alt + C` schermafbeelding |

Door `Alt` aan een sneltoets toe te voegen, krijg je een variant van hetzelfde, nooit iets dat er niets mee te maken heeft:

- `Super + Shift + B` opent de browser; `Super + Shift + Alt + B` opent een privévenster
- `Super + Shift + E` opent e-mail; `Super + Shift + Alt + E` start een nieuwe
- `Super + F` gaat naar volledig scherm; `Super + Alt + F` gaat naar volledige breedte
- `Super + Ctrl + C` opent het vastlegmenu; `Super + Ctrl + Alt + C` slaat het menu over en maakt een schermafbeelding

Bij het toevoegen van een sneltoets:

1. Kies het vlak op basis van wat deze doet, kies dan de toets.
2. Verplaats geen bestaande sneltoets om ruimte te maken. Zoek een vrije toets op het juiste vlak.
3. Gebruik `Alt` alleen voor een variant van de sneltoets zonder `Alt`.

Een paar sneltoetsen breken deze regels omdat ze handig zijn. `Shift` met een pijl of `Tab` verplaatst of keert om in plaats van een app te openen, en `Print`, de mediatoetsen, `Alt + Tab` en `Ctrl + Alt + Del` werken zoals ze overal elders doen. Het zijn uitzonderingen, geen patronen om te kopiëren.

Als een standaardinstelling je niet bevalt (bijvoorbeeld als je `Super + Shift + S` wilt voor schermafbeeldingen zoals op Windows), pas deze dan aan in `~/.config/hypr/bindings.lua`.

## Navigeren

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-menu (apps en al het andere)    |
| `Super + Alt + Space` | App-raster |
| `Super + Escape` | Systeemmenu (slaapstand, herstarten, enz.)  |
| `Super + Ctrl + L` | Computer vergrendelen |
| `Super + W` or `Super + Q` | Venster sluiten             |
| `Ctrl + Alt + Del` | Alle vensters sluiten |
| `Super + K` | Alle sneltoetsen weergeven |
| `Super + Alt + K` | Tmux-sneltoetsen weergeven |
| `Super + Ctrl + K` | Herdr-sneltoetsen weergeven |
| `Super + M` | Venster minimaliseren naar het dock |
| `Super + T`               | Venster schakelen tussen betegeld en zwevend             |
| `Super + J` | Vensterpositie schakelen (horizontaal/verticaal) |
| `Super + O`               | Schakelen of een venster sticky'n'floating wordt |
| `Super + L`               | Door de lay-outs dwindle, scrolling en floating bladeren |
| `Super + Alt + L`         | In omgekeerde volgorde door de lay-outs bladeren |
| `Super + P`               | Pseudo-vensterstijl schakelen (natural vs. stretch) |
| `Super + F`                 | Naar volledig scherm gaan              |
| `Super + Alt + F`                 | Naar volledige breedte gaan              |
| `Super + Ctrl + F`                 | Naar volledig scherm binnen het venster gaan              |
| `Super + 1…9/0`         | Naar een specifieke werkruimte springen (0 is 10) op de monitor met focus |
| `Super + Tab` | Naar de volgende werkruimte springen op de monitor met focus |
| `Super + Shift + Tab` | Naar de vorige werkruimte springen op de monitor met focus |
| `Super + Ctrl + Tab` | Naar de eerdere werkruimte springen op de monitor met focus |
| `Super + Shift + 1…9/0` | Venster naar een werkruimte verplaatsen op de monitor met focus |
| `Super + Shift + Alt + 1…9/0` | Venster naar een werkruimte verplaatsen op de monitor met focus zonder te volgen |
| `Super + S` | Volledig scratchpad schakelen |
| `Super + Alt + S` | Venster naar volledig scratchpad verplaatsen |
| `Super + Grave` | Quake-console schakelen |
| `Super + Shift + Grave` | Venster naar Quake-console verplaatsen |
| `Super + Shift + Ctrl + Arrows` | Venster naar de monitor in die richting verplaatsen |
| `Super + Shift + Alt + Arrows` | Werkruimte naar de monitor in die richting verplaatsen |
| `Super + Arrow`  | Focus verplaatsen naar het venster in de richting van de pijl, aan de schermrand overstekend naar de monitor aan die kant |
| `Super + Shift + Arrow`  | Venster verwisselen met een ander in de richting van de pijl, inclusief een op de monitor aan die kant |
| `Super + Minus` | Venster naar links uitbreiden |
| `Super + Equal` | Venster naar links krimpen |
| `Super + Shift + Minus` | Venster naar boven krimpen |
| `Super + Shift + Equal` | Venster naar beneden uitbreiden |
| `Super + Alt + Minus/Equal` | Dezelfde formaatwijziging in kleinere stappen |
| `Super + Ctrl + Minus/Equal` | Dezelfde formaatwijziging in grotere stappen |
| `Super + Alt + Home` | Vensterbreedte opslaan |
| `Super + Home` | Opgeslagen vensterbreedte herstellen |
| `Super + Left Mouse` | Venster verslepen |
| `Super + Right Mouse` | Formaat van venster wijzigen |
| `Super + Scroll Wheel` | Door werkruimtes scrollen op de monitor met focus |
| `Super + G`               | Venstergroepering schakelen      |
| `Super + Alt + G`               | Venster uit de groepering verplaatsen      |
| `Super + Alt + Tab`               | Tussen vensters in de groepering bladeren      |
| `Super + Alt + Shift + Tab`               | Achterwaarts tussen vensters in de groepering bladeren      |
| `Super + Alt + Scroll Wheel` | Tussen vensters in de groepering bladeren |
| `Super + Alt + 1/2/3/4/5`               | Naar een specifiek venster in de groepering springen      |
| `Super + Alt + Arrow`  | Venster in de groepering verplaatsen in de richting van de pijl, inclusief een op de monitor aan die kant |
| `Super + Ctrl + Left/Right`  | Tussen vensters binnen een tiling-groep bewegen |
| `Super + Ctrl + Z` | Op het scherm inzoomen (herhalen voor meer zoom) |
| `Super + Ctrl + Alt + Z` | Volledig van het scherm uitzoomen |
| `Super + /` | Vooruit door de monitorschaalopties stappen |
| `Super + Alt + /` | Achteruit door de monitorschaalopties stappen |
| `Alt + Tab` | Voorwaarts door vensters op de actieve werkruimte bladeren |
| `Alt + Shift + Tab` | Achterwaarts door vensters op de actieve werkruimte bladeren |
| `Ctrl + Alt + Tab`| Focus voorwaarts door monitors bladeren |
| `Ctrl + Alt + Shift + Tab`| Focus achterwaarts door monitors bladeren |
| `Super + I` | Invoertaal wisselen (met meer dan één lay-out of invoermethode) |
| `Super + Shift + I` | Invoertaal terug wisselen |

Op een touchpad schakelen vegen met drie en vier vingers tussen werkruimtes, verplaatsen ze vensters en openen ze het menu en de Quake-console; zie [toetsenbord, muis en trackpad](34-keyboard-mouse-trackpad.md) voor de gebaren.

Sneltoetsen voor formaatwijziging gebruiken de fysieke toetsen `code:20` en `code:21` (XKB `<AE11>` en `<AE12>`), ongeacht de tekens die op het toetsenbord staan gedrukt. Op Amerikaanse toetsenborden zijn deze toetsen `-` en `=`; op Japanse (JIS) toetsenborden zijn het `-` en `^`; op Spaanse toetsenborden zijn het `'` en `¡`. Op JIS is `Super + ^` gelijk aan `Super + Equal`, terwijl `Super + Shift + -` (waarmee `=` wordt getypt) gelijk is aan `Super + Shift + Minus`.

## Systeembediening

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audiopaneel    |
| `Super + Ctrl + B`           | Bluetooth-paneel    |
| `Super + Ctrl + N`           | Wifi-/netwerkpaneel    |
| `Super + Ctrl + D`           | Beeldschermpaneel    |
| `Super + Ctrl + P`           | Energiepaneel    |
| `Super + Ctrl + X`           | Agents-paneel    |
| `Super + Ctrl + Alt + X`           | Lokale-modellenpaneel    |
| `Super + Ctrl + Alt + D`           | Kalenderpaneel    |
| `Super + Ctrl + Alt + E`           | Wereldklokpaneel    |
| `Super + Ctrl + 1-9`           | Balkpaneel op positie schakelen    |
| `Super + Ctrl + S` | Deelmenu (via LocalSend) |
| `Super + Ctrl + C` | Vastlegbediening (schermafbeelding/-opname/kiezer) |
| `Super + Ctrl + O` | Menu schakelen |
| `Super + Ctrl + H` | Hardwaremenu |
| `Super + Ctrl + E` | Emoji-kiezer |
| `Super + Ctrl + .` | Media transcoderen |
| `Super + Shift + Ctrl + A` | Een AI-agent kiezen |
| `Power` key | Systeemmenu |
| `Super + Shift + Copilot` key | Omarchy-menu |

## Aanpassingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximale schermhelderheid |
| `Shift + Brightness Down` | Minimale schermhelderheid |
| `Alt + Brightness Up/Down` | Nauwkeurige helderheidswijzigingen van 1% |
| `Alt + Volume Up/Down` | Nauwkeurige volumewijzigingen van 1% |
| `Keyboard Brightness Up/Down` | Toetsenbordverlichting helderder/donkerder |
| `Keyboard Backlight` | Door de niveaus van de toetsenbordverlichting bladeren |
| `Ctrl + Brightness Up/Down` | Toetsenbordverlichting helderder/donkerder, op toetsenborden zonder eigen toetsen daarvoor |
| `Mic Mute` | De microfoon dempen |
| `Shift + Mute` | Audio-uitvoer wisselen |
| `Touchpad Toggle` | Het touchpad in- of uitschakelen |
| `Display` key | Door de werkruimtelayout bladeren |
| `Alt + Play` | Volgend nummer |
| `Alt + Shift + Play` | Vorig nummer |

## Apps starten

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agentmanager) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (privé/incognito)    |
| `Super + Shift + F`           | Bestandsbeheerder    |
| `Super + Shift + Alt + F`           | Bestandsbeheerder in de cwd van de terminal    |
| `Super + Shift + M`           | Muziek (Spotify)    |
| `Super + Shift + Alt + M`           | Muziek (cliamp)    |
| `Super + Shift + /`           | Wachtwoordmanager (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Rekenmachine (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, zodra geïnstalleerd)    |
| `Super + Shift + T`           | Activiteit (btop)    |
| `Super + Shift + N`           | Editor (Plain, of je gekozen standaard)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nieuwe e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Berichten (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Berichten (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Berichten (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Schrijven (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nieuw bericht) |
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

Normaal gesproken heb je op Linux `Ctrl + Shift + C/V` nodig om te kopiëren en plakken in de terminal en `Ctrl + C/V` om dat overal elders te doen. Deze uniforme klembordsneltoetsen van Omarchy werken overal.

## Vastleggen

| Sneltoets              | Functie                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Schermafbeelding                      |
| `Super + Ctrl + Alt + C`            | Schermafbeelding (dezelfde opname, voor toetsenborden zonder Print Screen-toets) |
| `Super + Ctrl + C` | Vastlegmenu |
| `Alt + Print Screen`            | Schermopname                     |
| `Super + Shift + Ctrl + Alt + C` | Schermopname zonder audio, het menu overslaan (opnieuw indrukken om te stoppen) |
| `Super + Print Screen` | Kleurkiezer |
| `Super + Ctrl + Print Screen` | Tekstextractie naar het klembord |
| `Super + Alt + [` | Webcam-overlay kleiner maken tijdens het opnemen |
| `Super + Alt + ]` | Webcam-overlay groter maken tijdens het opnemen |
| `Alt + Shift + L` | Huidige URL kopiëren uit webapp of browser |
| `Alt + Shift + D` | De video op de huidige pagina downloaden naar `~/Videos` |
| `Alt + Space` | Dicteren starten/stoppen (vereist _Setup > Defaults > Dictation_) |
| `Right Alt` | Ingedrukt houden om te dicteren (vereist _Setup > Defaults > Dictation_) |

Bij schermopnames vraagt de sneltoets eerst welke audio je wilt, en start dan de opname. Druk er opnieuw op om te stoppen. Zie [schermafbeeldingen en opname](12-screenshots-recording.md) voor de details.

Alle vastlegopties zijn ook toegankelijk onder _Trigger > Capture_ in het Omarchy-menu (`Super + Space`).

## Meldingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + ,` | Op de nieuwste melding reageren: deze openen of op de enige knop drukken, uit de keuzes kiezen, of deze verwijderen als deze er geen heeft  |
| `Super + Shift + ,` | Alle meldingen verwijderen |
| `Super + Ctrl + ,` | Meldingen met het toetsenbord bedienen  |
| `Super + Alt + ,` | Nieuwste melding verwijderen  |
| `Super + Shift + Alt + ,` | Meldingsgeschiedenis openen  |
| `Super + Ctrl + Alt + ,` | Het dempen van meldingen schakelen  |

## Stijl

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Een nieuw thema kiezen (ook `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Achtergrond van het thema kiezen (ook `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparantie op een venster schakelen |
| `Super + Ctrl + Backspace` | Vierkante beeldverhouding voor één venster schakelen |

Extra achtergrondafbeeldingen staan in `~/.config/omarchy/backgrounds/<theme name>`. Ook beschikbaar via _Install > Style > Background_ in het Omarchy-menu.

Alle stijlopties zijn ook toegankelijk onder _Appearance_ in het Omarchy-menu (`Super + Space`).

## Schakelaars

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Vergrendelen bij inactiviteit schakelen |
| `Super + Ctrl + Delete` | Laptopscherm in-/uitschakelen |
| `Super + Ctrl + Alt + Delete` | Spiegelen van het laptopscherm schakelen |
| `Super + Shift + Space` | De bovenbalk schakelen  |
| `Shift + Mute` | Naar de volgende audio-uitvoer schakelen |
| `Shift + Play` | Naar de volgende mediabron schakelen |
| `Super + Shift + Backspace` | Venstertussenruimtes schakelen |
| `Super + Ctrl + Alt + F` | Bureaublad op volledig scherm schakelen (bovenbalk + venstertussenruimtes) |

## Herinneringen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Een herinnering instellen  |
| `Super + Ctrl + Alt + R` | Alle herinneringen bekijken  |
| `Super + Ctrl + Shift + R` | Alle herinneringen wissen  |

## Kennisgevingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Tijd als melding weergeven  |
| `Super + Ctrl + Alt + B` | Batterij als melding weergeven  |
| `Super + Ctrl + Alt + W` | Weer als melding schakelen  |

## Tmux

De prefixtoets is `Ctrl + Space` (`Ctrl + B` werkt ook). Je kunt deze bindingen wijzigen in `~/.config/tmux/tmux.conf`.

### Deelvensters

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + v` | Deelvenster ernaast splitsen (verticaal) |
| `Prefix + h` | Deelvenster eronder splitsen (horizontaal) |
| `Prefix + x` | Deelvenster beëindigen |
| `Prefix + z` | Zoom van het deelvenster schakelen (volledig scherm) |
| `Alt + Enter` | Deelvenster eronder splitsen (geen prefix) |
| `Alt + Shift + Enter` | Deelvenster ernaast splitsen (geen prefix) |
| `Alt + Escape` | Deelvenster beëindigen (geen prefix) |
| `Ctrl + Alt + Arrows` | Tussen deelvensters bewegen |
| `Ctrl + Alt + Shift + Arrows` | Formaat van deelvensters wijzigen |

### Vensters

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nieuw venster |
| `Prefix + k` | Venster beëindigen |
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
| `v` | Selectie starten (in kopieermodus) |
| `y` | Selectie kopiëren (in kopieermodus) |

### Algemeen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + q` | Configuratie opnieuw laden |
| `Prefix + ?` | Tmux-toetsbindingen weergeven |
| `Prefix + :` | Opdrachtprompt |

### Tmux-layoutfuncties

Deze functies moeten binnen een Tmux-sessie worden uitgevoerd.

| Opdracht | Functie |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-layout maken met editor, AI en terminal |
| `tdlm <ai> [<second_ai>]` | Dev-layout maken per submap |
| `tsl <count> <command>` | Swarm-layout met meerdere deelvensters maken |

## Ghostty Terminal

Ghostty-terminal wordt geïnstalleerd met _Install > Terminal_ via het Omarchy-menu.

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
| `Alt + Up`       | Omhoog naar de bovenliggende map gaan        |

## Neovim (met lazyvim)

### Navigatie

| Sneltoets                   | Functie                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Opdrachtopties weergeven            |
| `Space Space`              | Bestand openen via fuzzy search      |
| `Space E`                  | Zijbalk schakelen                  |
| `Space G G`                | Git-bediening weergeven               |
| `Space S G`                | Bestandsinhoud doorzoeken             |
| `Ctrl + W W`               | Tussen zijbalk en editor springen |
| `Ctrl + Left/right arrow`  | Grootte van de zijbalk wijzigen          |
| `Shift + H`                      | Naar het linker bestandstabblad gaan             |
| `Shift + L`                      | Naar het rechter bestandstabblad gaan            |
| `Space B D`                | Bestandstabblad sluiten                  |

### In de zijbalk

| Sneltoets                   | Functie                        |
| ------------------------ | ------------------------------- |
| `A`                        | Nieuw bestand toevoegen in de bovenliggende map      |
| `Shift + A`                | Nieuwe submap toevoegen in de bovenliggende map    |
| `D`                        | Gemarkeerde bestand/map verwijderen     |
| `M`                        | Gemarkeerde bestand/map verplaatsen       |
| `R`                        | Gemarkeerde bestand/map hernoemen     |
| `?`                        | Help voor alle opdrachten weergeven      |

[Bekijk alle Neovim-sneltoetsen die door LazyVim zijn geconfigureerd](https://www.lazyvim.org/keymaps).

## Snelle emoji's

Je kunt `Super + Ctrl + E` gebruiken om een volledige emoji-kiezer weer te geven die de selectie op het klembord plaatst, of je kunt deze snelle toegangsopties gebruiken.

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
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | begroeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blazen |

## Snelle aanvullingen

| Sneltoets       | Aanvulling       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Je naam (zoals ingevoerd tijdens de configuratie)  |
| `Shift + CapsLock Space E` | Je e-mail (zoals ingevoerd tijdens de configuratie)  |

Je kunt er meer van jezelf toevoegen door `~/.XCompose` te bewerken en vervolgens `omarchy restart xcompose` in de terminal uit te voeren om de wijzigingen te laten doorvoeren.
