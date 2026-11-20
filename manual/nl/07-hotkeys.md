# Sneltoetsen

Je kunt alle belangrijkste toetsenbordcombinaties zien met `Super + K` (Tmux-combinaties met `Super + Alt + K` en Herdr-combinaties met `Super + Ctrl + K`).

## Hoe sneltoetsen zijn ingedeeld

Elke sneltoets bevindt zich op een vlak, bepaald door de modificatietoetsen, en elk vlak heeft één taak. Daardoor vervagen de sneltoetsen niet in elkaar, en kun je meestal raden waar iets zit.

| Vlak | Wat daar zit | Voorbeelden |
| --- | --- | --- |
| `Super + key` | Het systeem: vensters, werkruimtes, indelingen en kernmenu's | `Super + Space` Omarchy-menu, `Super + W` venster sluiten, `Super + F` volledig scherm |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panelen en systeemmenu's | `Super + Ctrl + A` audio, `Super + Ctrl + N` netwerk, `Super + Ctrl + C` vastlegmenu |
| `Super + Ctrl + Alt + key` | Snelle acties en kennisgevingen | `Super + Ctrl + Alt + T` tijd tonen, `Super + Ctrl + Alt + B` batterij, `Super + Ctrl + Alt + C` schermafbeelding |

Door `Alt` aan een sneltoets toe te voegen krijg je een variant van hetzelfde, nooit iets dat er niets mee te maken heeft:

- `Super + Shift + B` opent de browser; `Super + Shift + Alt + B` opent een privévenster
- `Super + Shift + E` opent e-mail; `Super + Shift + Alt + E` begint een nieuwe e-mail
- `Super + F` gaat naar volledig scherm; `Super + Alt + F` gaat naar volledige breedte
- `Super + Ctrl + C` opent het vastlegmenu; `Super + Ctrl + Alt + C` slaat het menu over en maakt een schermafbeelding

Wanneer je een sneltoets toevoegt:

1. Kies het vlak op basis van wat de sneltoets doet, en kies daarna de toets.
2. Verplaats geen bestaande sneltoets om ruimte te maken. Zoek een vrije toets op het juiste vlak.
3. Gebruik `Alt` alleen voor een variant van de sneltoets zonder `Alt`.

Een paar sneltoetsen overtreden deze regels omdat dat handig is. `Shift` met een pijltjestoets of `Tab` verplaatst of keert om in plaats van een app te openen, en `Print`, de mediatoetsen, `Alt + Tab` en `Ctrl + Alt + Del` werken zoals ze overal elders werken. Het zijn uitzonderingen, geen patronen om te kopiëren.

Als een standaardinstelling je niet bevalt (stel dat je `Super + Shift + S` wilt voor schermafbeeldingen zoals in Windows), wijzig de toewijzing dan in `~/.config/hypr/bindings.lua`.

## Navigeren

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-menu (apps en al het andere)    |
| `Super + Alt + Space` | App-raster |
| `Super + Escape` | Systeemmenu (slaapstand, herstarten, enz.)  |
| `Super + Ctrl + L` | Computer vergrendelen |
| `Super + W` or `Super + Q` | Venster sluiten             |
| `Ctrl + Alt + Del` | Alle vensters sluiten |
| `Super + K` | Alle sneltoetsen tonen |
| `Super + Alt + K` | tmux-sneltoetsen tonen |
| `Super + Ctrl + K` | herdr-sneltoetsen tonen |
| `Super + M` | Venster minimaliseren naar het dock |
| `Super + T`               | Venster schakelen tussen tegelen/zwevend             |
| `Super + J` | Vensterpositie schakelen (horizontaal/verticaal) |
| `Super + O`               | Schakelen of het venster als sticky'n'floating naar voren springt |
| `Super + L`               | Door de dwindle-, scrolling- en floating-indelingen bladeren |
| `Super + Alt + L`         | In omgekeerde volgorde door de indelingen bladeren |
| `Super + P`               | Pseudo-vensterstijl schakelen (natural v stretch) |
| `Super + F`                 | Naar volledig scherm              |
| `Super + Alt + F`                 | Naar volledige breedte              |
| `Super + Ctrl + F`                 | Naar volledig scherm binnen het venster              |
| `Super + 1…9/0`         | Naar een specifieke werkruimte springen (0 is 10) op de monitor met de focus |
| `Super + Tab` | Naar de volgende werkruimte springen op de monitor met de focus |
| `Super + Shift + Tab` | Naar de vorige werkruimte springen op de monitor met de focus |
| `Super + Ctrl + Tab` | Naar de eerdere werkruimte springen op de monitor met de focus |
| `Super + Shift + 1…9/0` | Venster verplaatsen naar een werkruimte op de monitor met de focus |
| `Super + Shift + Alt + 1…9/0` | Venster verplaatsen naar een werkruimte op de monitor met de focus zonder mee te volgen |
| `Super + S` | Volledig scratchpad in-/uitschakelen |
| `Super + Alt + S` | Venster verplaatsen naar het volledige scratchpad |
| `Super + Grave` | Quake-console in-/uitschakelen |
| `Super + Shift + Grave` | Venster verplaatsen naar de Quake-console |
| `Super + Shift + Ctrl + Arrows` | Venster verplaatsen naar de monitor in die richting |
| `Super + Shift + Alt + Arrows` | Werkruimte verplaatsen naar de monitor in die richting |
| `Super + Arrow`  | Focus verplaatsen naar het venster in de richting van de pijl, aan de rand van het scherm oversteken naar de monitor aan die kant |
| `Super + Shift + Arrow`  | Venster verwisselen met een ander venster in de richting van de pijl, ook met een venster op de monitor aan die kant |
| `Super + Minus` | Venster naar links uitbreiden |
| `Super + Equal` | Venster naar links krimpen |
| `Super + Shift + Minus` | Venster naar boven krimpen |
| `Super + Shift + Equal` | Venster naar beneden uitbreiden |
| `Super + Alt + Minus/Equal` | Dezelfde formaatwijziging in kleinere stappen |
| `Super + Ctrl + Minus/Equal` | Dezelfde formaatwijziging in grotere stappen |
| `Super + Alt + Home` | Vensterbreedte opslaan |
| `Super + Home` | Opgeslagen vensterbreedte herstellen |
| `Super + Left Mouse` | Venster verslepen |
| `Super + Right Mouse` | Vensterformaat wijzigen |
| `Super + Scroll Wheel` | Door werkruimtes scrollen op de monitor met de focus |
| `Super + G`               | Venstergroepering in-/uitschakelen      |
| `Super + Alt + G`               | Venster uit de groepering verplaatsen      |
| `Super + Alt + Tab`               | Tussen vensters in de groepering bladeren      |
| `Super + Alt + Shift + Tab`               | Achteruit bladeren tussen vensters in de groepering      |
| `Super + Alt + Scroll Wheel` | Tussen vensters in de groepering bladeren |
| `Super + Alt + 1/2/3/4/5`               | Naar een specifiek venster in de groepering springen      |
| `Super + Alt + Arrow`  | Venster in de groepering plaatsen in de richting van de pijl, ook een venster op de monitor aan die kant |
| `Super + Ctrl + Left/Right`  | Tussen vensters binnen een tegelgroep bewegen |
| `Super + Ctrl + Z` | Inzoomen op het scherm (herhalen voor meer zoom) |
| `Super + Ctrl + Alt + Z` | Volledig uitzoomen van het scherm |
| `Super + /` | Vooruit door de schaalopties voor de monitor stappen |
| `Super + Alt + /` | Achteruit door de schaalopties voor de monitor stappen |
| `Alt + Tab` | Vooruit bladeren door vensters op de actieve werkruimte |
| `Alt + Shift + Tab` | Achteruit bladeren door vensters op de actieve werkruimte |
| `Ctrl + Alt + Tab`| Focus vooruit bladeren door monitors |
| `Ctrl + Alt + Shift + Tab`| Focus achteruit bladeren door monitors |
| `Super + I` | Invoertaal wisselen (met meer dan één indeling of invoermethode) |
| `Super + Shift + I` | Invoertaal terug wisselen |

Op een touchpad wisselen drie- en viervingerveegbewegingen tussen werkruimtes, verplaatsen ze vensters en openen ze het menu en de Quake-console; zie [toetsenbord, muis en trackpad](34-keyboard-mouse-trackpad.md) voor de gebaren.

Sneltoetsen voor formaatwijziging gebruiken de fysieke toetsen `code:20` en `code:21` (XKB `<AE11>` en `<AE12>`), ongeacht de tekens die op het toetsenbord zijn gedrukt. Op Amerikaanse toetsenborden zijn deze toetsen `-` en `=`; op Japanse (JIS) toetsenborden zijn ze `-` en `^`; op Spaanse toetsenborden zijn ze `'` en `¡`. Op JIS is `Super + ^` gelijk aan `Super + Equal`, terwijl `Super + Shift + -` (waarmee je `=` typt) gelijk is aan `Super + Shift + Minus`.

## Systeembediening

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audiopaneel    |
| `Super + Ctrl + B`           | Bluetooth-paneel    |
| `Super + Ctrl + N`           | Wifi-/netwerkpaneel    |
| `Super + Ctrl + D`           | Beeldschermpaneel    |
| `Super + Ctrl + P`           | Energiepaneel    |
| `Super + Ctrl + X`           | Agents-paneel    |
| `Super + Ctrl + Alt + D`           | Kalenderpaneel    |
| `Super + Ctrl + Alt + E`           | Wereldklokpaneel    |
| `Super + Ctrl + 1-9`           | Balkpaneel op positie in-/uitschakelen    |
| `Super + Ctrl + S` | Deelmenu (via LocalSend) |
| `Super + Ctrl + C` | Vastlegbediening (schermafbeelding/-opname/kiezer) |
| `Super + Ctrl + O` | Menu in-/uitschakelen |
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
| `Alt + Brightness Up/Down` | Nauwkeurige helderheidsaanpassingen van 1% |
| `Alt + Volume Up/Down` | Nauwkeurige volumeaanpassingen van 1% |
| `Keyboard Brightness Up/Down` | Toetsenbordverlichting helderder/donkerder |
| `Keyboard Backlight` | Door de niveaus van de toetsenbordverlichting bladeren |
| `Ctrl + Brightness Up/Down` | Toetsenbordverlichting helderder/donkerder, op toetsenborden zonder eigen toetsen daarvoor |
| `Mic Mute` | De microfoon dempen |
| `Shift + Mute` | Audio-uitvoer wisselen |
| `Touchpad Toggle` | Het touchpad in- of uitschakelen |
| `Display` key | Door de werkruimte-indeling bladeren |
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
| `Super + Shift + D`           | Docker (lazydocker, na installatie)    |
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

Wijzig/voeg toewijzingen toe in `~/.config/hypr/bindings.lua`.

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
| `Super + Ctrl + C` | Vastlegmenu |
| `Alt + Print Screen`            | Schermopname                     |
| `Super + Shift + Ctrl + Alt + C` | Schermopname zonder audio, zonder menu (druk opnieuw om te stoppen) |
| `Super + Print Screen` | Kleurkiezer |
| `Super + Ctrl + Print Screen` | Tekst extraheren naar het klembord |
| `Super + Alt + [` | Webcam-overlay kleiner maken tijdens het opnemen |
| `Super + Alt + ]` | Webcam-overlay groter maken tijdens het opnemen |
| `Alt + Shift + L` | Huidige URL kopiëren uit webapp of browser |
| `Alt + Shift + D` | De video op de huidige pagina downloaden naar `~/Videos` |
| `Alt + Space` | Dicteren starten/stoppen (vereist _Setup > Defaults > Dictation_) |
| `Right Alt` | Ingedrukt houden om te dicteren (vereist _Setup > Defaults > Dictation_) |

Bij schermopnames vraagt de sneltoets eerst welke audio je wilt, en start daarna de opname. Druk er opnieuw op om te stoppen. Zie [schermafbeeldingen en opname](12-screenshots-recording.md) voor de details.

Alle vastlegopties zijn ook beschikbaar onder _Trigger > Capture_ in het Omarchy-menu (`Super + Space`).

## Meldingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + ,` | Actie uitvoeren op de nieuwste melding: open deze of druk op de enige knop, kies uit de opties, of sluit deze als die er geen heeft  |
| `Super + Shift + ,` | Alle meldingen sluiten |
| `Super + Ctrl + ,` | Meldingen bedienen met het toetsenbord  |
| `Super + Alt + ,` | Nieuwste melding sluiten  |
| `Super + Shift + Alt + ,` | Meldingsgeschiedenis openen  |
| `Super + Ctrl + Alt + ,` | Meldingen dempen in-/uitschakelen  |

## Stijl

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Een nieuw thema kiezen (ook `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Thema-achtergrond kiezen (ook `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparantie van een venster in-/uitschakelen |
| `Super + Ctrl + Backspace` | Vierkante beeldverhouding voor één venster in-/uitschakelen |

Extra achtergrondafbeeldingen staan in `~/.config/omarchy/backgrounds/<theme name>`. Ook beschikbaar via _Install > Style > Background_ in het Omarchy-menu.

Alle stijlopties zijn ook beschikbaar onder _Appearance_ in het Omarchy-menu (`Super + Space`).

## Schakelaars

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Vergrendeling bij inactiviteit in-/uitschakelen |
| `Super + Ctrl + Delete` | Laptopscherm in-/uitschakelen |
| `Super + Ctrl + Alt + Delete` | Spiegelen van het laptopscherm in-/uitschakelen |
| `Super + Shift + Space` | De bovenbalk in-/uitschakelen  |
| `Shift + Mute` | Naar de volgende audio-uitvoer schakelen |
| `Shift + Play` | Naar de volgende mediabron schakelen |
| `Super + Shift + Backspace` | Vensterafstanden in-/uitschakelen |
| `Super + Ctrl + Alt + F` | Volledig scherm-bureaublad in-/uitschakelen (bovenbalk + vensterafstanden) |

## Herinneringen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Een herinnering instellen  |
| `Super + Ctrl + Alt + R` | Alle herinneringen bekijken  |
| `Super + Ctrl + Shift + R` | Alle herinneringen wissen  |

## Kennisgevingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Tijd tonen als melding  |
| `Super + Ctrl + Alt + B` | Batterij tonen als melding  |
| `Super + Ctrl + Alt + W` | Weer als melding in-/uitschakelen  |

## Tmux

De prefix-toets is `Ctrl + Space` (`Ctrl + B` werkt ook). Je kunt deze toewijzingen wijzigen in `~/.config/tmux/tmux.conf`.

### Deelvensters

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + v` | Deelvenster ernaast splitsen (verticaal) |
| `Prefix + h` | Deelvenster eronder splitsen (horizontaal) |
| `Prefix + x` | Deelvenster beëindigen |
| `Prefix + z` | Zoom van het deelvenster in-/uitschakelen (volledig scherm) |
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
| `Prefix + d` | Loskoppelen van de sessie |

### Kopieermodus (vi-stijl)

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopieermodus openen |
| `v` | Selectie beginnen (in kopieermodus) |
| `y` | Selectie kopiëren (in kopieermodus) |

### Algemeen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + q` | Configuratie opnieuw laden |
| `Prefix + ?` | Tmux-toetstoewijzingen tonen |
| `Prefix + :` | Opdrachtprompt |

### Tmux-indelingsfuncties

Deze functies moeten binnen een Tmux-sessie worden uitgevoerd.

| Opdracht | Functie |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-indeling maken met editor, AI en terminal |
| `tdlm <ai> [<second_ai>]` | Dev-indeling maken per submap |
| `tsl <count> <command>` | Swarm-indeling met meerdere deelvensters maken |

## Ghostty Terminal

De Ghostty-terminal wordt geïnstalleerd via _Install > Terminal_ in het Omarchy-menu.

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
| `Ctrl + Left mouse` | Link openen in de browser |

## Bestandsbeheerder

| Sneltoets              | Functie                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Naar pad gaan                     |
| `Space`               | Bestand voorvertonen (pijltjestoetsen navigeren) |
| `Alt + Up`       | Omhoog naar de bovenliggende map        |

## Neovim (w/ lazyvim)

### Navigatie

| Sneltoets                   | Functie                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Opdrachtopties tonen            |
| `Space Space`              | Bestand openen via fuzzy zoeken      |
| `Space E`                  | Zijbalk in-/uitschakelen                  |
| `Space G G`                | Git-bediening tonen               |
| `Space S G`                | Bestandsinhoud zoeken             |
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
| `D`                        | Gemarkeerd bestand/gemarkeerde map verwijderen     |
| `M`                        | Gemarkeerd bestand/gemarkeerde map verplaatsen       |
| `R`                        | Gemarkeerd bestand/gemarkeerde map hernoemen     |
| `?`                        | Help voor alle opdrachten tonen      |

[Bekijk alle Neovim-sneltoetsen die door LazyVim zijn geconfigureerd](https://www.lazyvim.org/keymaps).

## Snelle emoji's

Je kunt `Super + Ctrl + E` gebruiken om een volledige emoji-kiezer te tonen die de selectie op het klembord plaatst, of je kunt deze snelle toegangsopties gebruiken.

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
| `Shift + CapsLock M T` | 🥂 | toost      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | groet |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blazen |

## Snelle aanvullingen

| Sneltoets       | Aanvulling       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Je naam (zoals ingevoerd bij de installatie)  |
| `Shift + CapsLock Space E` | Je e-mail (zoals ingevoerd bij de installatie)  |

Je kunt er zelf meer toevoegen door `~/.XCompose` te bewerken en vervolgens `omarchy restart xcompose` in de terminal uit te voeren, zodat de wijzigingen worden overgenomen.
