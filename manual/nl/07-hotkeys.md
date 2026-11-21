# Sneltoetsen

Je kunt alle belangrijke toetsenbordcombinaties zien met `Super + K` (Tmux-combinaties met `Super + Alt + K` en Herdr-combinaties met `Super + Ctrl + K`).

## Hoe sneltoetsen zijn ingedeeld

Elke sneltoets bevindt zich op een vlak, bepaald door de modificatietoetsen ervan, en elk vlak heeft één taak. Daardoor blijven de sneltoetsen niet in elkaar overlopen, en kun je meestal raden waar iets zit.

| Vlak | Wat daar thuishoort | Voorbeelden |
| --- | --- | --- |
| `Super + key` | Het systeem: vensters, werkruimtes, lay-outs en kernmenu's | `Super + Space` Omarchy-menu, `Super + W` venster sluiten, `Super + F` volledig scherm |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panelen en systeemmenu's | `Super + Ctrl + A` audio, `Super + Ctrl + N` netwerk, `Super + Ctrl + C` opnamemenu |
| `Super + Ctrl + Alt + key` | Snelle acties en meldingen | `Super + Ctrl + Alt + T` tijd weergeven, `Super + Ctrl + Alt + B` batterij, `Super + Ctrl + Alt + C` schermafbeelding |

Als je `Alt` aan een sneltoets toevoegt, krijg je een variant van hetzelfde ding, nooit iets dat er niets mee te maken heeft:

- `Super + Shift + B` opent de browser; `Super + Shift + Alt + B` opent een privévenster
- `Super + Shift + E` opent e-mail; `Super + Shift + Alt + E` begint een nieuwe
- `Super + F` gaat naar volledig scherm; `Super + Alt + F` gaat naar volledige breedte
- `Super + Ctrl + C` opent het opnamemenu; `Super + Ctrl + Alt + C` slaat het menu over en maakt een schermafbeelding

Bij het toevoegen van een sneltoets:

1. Kies het vlak op basis van wat het doet, en kies daarna de toets.
2. Verplaats geen bestaande sneltoets om ruimte te maken. Zoek een vrije toets op het juiste vlak.
3. Gebruik `Alt` alleen voor een variant van de sneltoets zonder `Alt`.

Een paar sneltoetsen breken met deze regels omdat ze handig zijn. `Shift` met een pijltoets of `Tab` verplaatst of keert om in plaats van een app te openen, en `Print`, de mediatoetsen, `Alt + Tab` en `Ctrl + Alt + Del` werken zoals overal elders. Het zijn uitzonderingen, geen patronen om te kopiëren.

Als een standaardinstelling je niet bevalt (stel dat je `Super + Shift + S` wilt voor schermafbeeldingen, zoals op Windows), koppel die dan opnieuw in `~/.config/hypr/bindings.lua`.

## Navigeren

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-menu (apps en al het andere)    |
| `Super + Alt + Space` | App-raster |
| `Super + Escape` | Systeemmenu (stand-by, herstarten, enz.)  |
| `Super + Ctrl + L` | Computer vergrendelen |
| `Super + W` or `Super + Q` | Venster sluiten             |
| `Ctrl + Alt + Del` | Alle vensters sluiten |
| `Super + K` | Alle sneltoetsen weergeven |
| `Super + Alt + K` | Tmux-sneltoetsen weergeven |
| `Super + Ctrl + K` | Herdr-sneltoetsen weergeven |
| `Super + M` | Venster minimaliseren naar het dock |
| `Super + T`               | Venster schakelen tussen tegelend/zwevend             |
| `Super + J` | Vensterpositie wisselen (horizontaal/verticaal) |
| `Super + O`               | Venster dat eruit springt, wisselen naar sticky'n'floating |
| `Super + L`               | Door de lay-outs dwindle, scrolling en floating bladeren |
| `Super + Alt + L`         | In omgekeerde volgorde door de lay-outs bladeren |
| `Super + P`               | Pseudovensterstijl wisselen (natuurlijk vs. uitgerekt) |
| `Super + F`                 | Naar volledig scherm gaan              |
| `Super + Alt + F`                 | Naar volledige breedte gaan              |
| `Super + Ctrl + F`                 | Naar volledig scherm binnen venster gaan              |
| `Super + 1…9/0`         | Naar specifieke werkruimte springen (0 is 10) op de monitor met focus |
| `Super + Tab` | Naar volgende werkruimte springen op de monitor met focus |
| `Super + Shift + Tab` | Naar vorige werkruimte springen op de monitor met focus |
| `Super + Ctrl + Tab` | Naar eerdere werkruimte springen op de monitor met focus |
| `Super + Shift + 1…9/0` | Venster verplaatsen naar werkruimte op de monitor met focus |
| `Super + Shift + Alt + 1…9/0` | Venster verplaatsen naar werkruimte op de monitor met focus, zonder mee te volgen |
| `Super + S` | Volledig scratchpad in-/uitschakelen |
| `Super + Alt + S` | Venster verplaatsen naar volledig scratchpad |
| `Super + Grave` | Quake-console in-/uitschakelen |
| `Super + Shift + Grave` | Venster verplaatsen naar Quake-console |
| `Super + Shift + Ctrl + Arrows` | Venster verplaatsen naar de monitor in die richting |
| `Super + Shift + Alt + Arrows` | Werkruimte verplaatsen naar de monitor in die richting |
| `Super + Arrow`  | Focus verplaatsen naar venster in de richting van de pijl, aan de schermrand overstekend naar de monitor aan die kant |
| `Super + Shift + Arrow`  | Venster wisselen met een ander in de richting van de pijl, ook met een op de monitor aan die kant |
| `Super + Minus` | Venster naar links uitbreiden |
| `Super + Equal` | Venster naar links verkleinen |
| `Super + Shift + Minus` | Venster naar boven verkleinen |
| `Super + Shift + Equal` | Venster naar beneden uitbreiden |
| `Super + Alt + Minus/Equal` | Dezelfde formaatwijziging in kleinere stappen |
| `Super + Ctrl + Minus/Equal` | Dezelfde formaatwijziging in grotere stappen |
| `Super + Alt + Home` | Vensterbreedte opslaan |
| `Super + Home` | Opgeslagen vensterbreedte herstellen |
| `Super + Left Mouse` | Venster rondslepen |
| `Super + Right Mouse` | Vensterformaat wijzigen |
| `Super + Scroll Wheel` | Door werkruimtes scrollen op de monitor met focus |
| `Super + G`               | Venstergroepering in-/uitschakelen      |
| `Super + Alt + G`               | Venster uit groepering verplaatsen      |
| `Super + Alt + Tab`               | Tussen vensters in groepering bladeren      |
| `Super + Alt + Shift + Tab`               | Achterwaarts tussen vensters in groepering bladeren      |
| `Super + Alt + Scroll Wheel` | Tussen vensters in groepering bladeren |
| `Super + Alt + 1/2/3/4/5`               | Naar specifiek venster in groepering springen      |
| `Super + Alt + Arrow`  | Venster in groepering verplaatsen in de richting van de pijl, ook met een op de monitor aan die kant |
| `Super + Ctrl + Left/Right`  | Tussen vensters binnen een tegelgroep bewegen |
| `Super + Ctrl + Z` | Inzoomen op scherm (herhalen voor meer zoom) |
| `Super + Ctrl + Alt + Z` | Volledig uitzoomen van scherm |
| `Super + /` | Vooruit door opties voor monitorschaling stappen |
| `Super + Alt + /` | Achteruit door opties voor monitorschaling stappen |
| `Alt + Tab` | Voorwaarts door vensters bladeren op de actieve werkruimte |
| `Alt + Shift + Tab` | Achterwaarts door vensters bladeren op de actieve werkruimte |
| `Ctrl + Alt + Tab`| Focus voorwaarts door monitors bladeren |
| `Ctrl + Alt + Shift + Tab`| Focus achterwaarts door monitors bladeren |
| `Super + I` | Invoertaal wisselen (met meer dan één lay-out of invoermethode) |
| `Super + Shift + I` | Invoertaal terugwisselen |

Op een touchpad wisselen vegen met drie en vier vingers van werkruimte, verplaatsen ze vensters en openen ze het menu en de Quake-console; zie [toetsenbord, muis en trackpad](34-keyboard-mouse-trackpad.md) voor de gebaren.

Sneltoetsen voor formaatwijziging gebruiken de fysieke toetsen `code:20` en `code:21` (XKB `<AE11>` en `<AE12>`), ongeacht de tekens die op het toetsenbord zijn gedrukt. Op Amerikaanse toetsenborden zijn deze toetsen `-` en `=`; op Japanse (JIS) toetsenborden zijn ze `-` en `^`; op Spaanse toetsenborden zijn ze `'` en `¡`. Op JIS is `Super + ^` gelijk aan `Super + Equal`, terwijl `Super + Shift + -` (waarmee je `=` typt) gelijk is aan `Super + Shift + Minus`.

## Systeembediening

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audiopaneel    |
| `Super + Ctrl + B`           | Bluetooth-paneel    |
| `Super + Ctrl + N`           | Wi-Fi/netwerkpaneel    |
| `Super + Ctrl + D`           | Beeldschermpaneel    |
| `Super + Ctrl + P`           | Energiepaneel    |
| `Super + Ctrl + X`           | Agents-paneel    |
| `Super + Ctrl + Shift + X`           | Paneel voor lokale modellen    |
| `Super + Ctrl + Alt + D`           | Kalenderpaneel    |
| `Super + Ctrl + Alt + E`           | Wereldklokpaneel    |
| `Super + Ctrl + 1-9`           | Balkpaneel in-/uitschakelen op positie    |
| `Super + Ctrl + S` | Deelmenu (via LocalSend) |
| `Super + Ctrl + C` | Opnamebediening (schermafbeelding/-opname/kiezer) |
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
| `Super + Ctrl + Return` | Herdr (agentbeheerder) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (privé/incognito)    |
| `Super + Shift + F`           | Bestandsbeheerder    |
| `Super + Shift + Alt + F`           | Bestandsbeheerder in de cwd van de terminal    |
| `Super + Shift + M`           | Muziek (Spotify)    |
| `Super + Shift + Alt + M`           | Muziek (cliamp)    |
| `Super + Shift + /`           | Wachtwoordbeheerder (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Rekenmachine (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, zodra geïnstalleerd)    |
| `Super + Shift + T`           | Activiteit (btop)    |
| `Super + Shift + N`           | Editor (Plain, of je gekozen standaard)  |
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
| `Super + Shift + Alt + X`           | X (nieuwe post) |
| `Super + Shift + Y`           | YouTube |

Wijzig/voeg koppelingen toe in `~/.config/hypr/bindings.lua`.

## Universeel klembord

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + A`           | Alles selecteren in apps die `Ctrl + A` ondersteunen    |
| `Super + C`           | Kopiëren    |
| `Super + X`           | Knippen (niet in terminal)    |
| `Super + V`           | Plakken    |
| `Super + Ctrl + V`           | Klembordbeheerder    |

Normaal gesproken heb je op Linux `Ctrl + Shift + C/V` nodig om te kopiëren en plakken in de terminal en `Ctrl + C/V` om dat overal anders te doen. Deze uniforme klembordsneltoetsen van Omarchy werken overal.

## Opname

| Sneltoets              | Functie                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Schermafbeelding                      |
| `Super + Ctrl + Alt + C`            | Schermafbeelding (dezelfde opname, voor toetsenborden zonder Print Screen-toets) |
| `Super + Ctrl + C` | Opnamemenu |
| `Alt + Print Screen`            | Schermopname                     |
| `Super + Shift + Ctrl + Alt + C` | Schermopname zonder audio, het menu overslaand (druk opnieuw om te stoppen) |
| `Super + Print Screen` | Kleurkiezer |
| `Super + Ctrl + Print Screen` | Tekstextractie naar klembord |
| `Super + Alt + [` | Webcam-overlay kleiner maken tijdens het opnemen |
| `Super + Alt + ]` | Webcam-overlay groter maken tijdens het opnemen |
| `Alt + Shift + L` | Huidige URL kopiëren uit webapp of browser |
| `Alt + Shift + D` | De video op de huidige pagina downloaden naar `~/Videos` |
| `Alt + Space` | Dicteren starten/stoppen (vereist _Setup > Defaults > Dictation_) |
| `Right Alt` | Ingedrukt houden om te dicteren (vereist _Setup > Defaults > Dictation_) |

Bij schermopnamen vraagt de sneltoets eerst welke audio je wilt, en begint daarna met opnemen. Druk er opnieuw op om te stoppen. Zie [schermafbeeldingen en opname](12-screenshots-recording.md) voor de details.

Alle opnameopties zijn ook toegankelijk onder _Trigger > Capture_ in het Omarchy-menu (`Super + Space`).

## Meldingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + ,` | Actie uitvoeren op de nieuwste melding: open deze of druk op de enige knop ervan, kies uit de opties ervan, of sluit deze als deze er geen heeft  |
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
| `Super + Backspace` | Transparantie op een venster in-/uitschakelen |
| `Super + Ctrl + Backspace` | Vierkante beeldverhouding voor één venster in-/uitschakelen |

Extra achtergrondafbeeldingen staan in `~/.config/omarchy/backgrounds/<theme name>`. Ook beschikbaar via _Install > Style > Background_ in het Omarchy-menu.

Alle stijlopties zijn ook toegankelijk onder _Appearance_ in het Omarchy-menu (`Super + Space`).

## Schakelaars

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Vergrendelen bij inactiviteit in-/uitschakelen |
| `Super + Ctrl + Delete` | Laptopscherm in-/uitschakelen |
| `Super + Ctrl + Alt + Delete` | Laptopscherm spiegelen in-/uitschakelen |
| `Super + Shift + Space` | De bovenbalk in-/uitschakelen  |
| `Shift + Mute` | Naar volgende audio-uitvoer wisselen |
| `Shift + Play` | Naar volgende mediabron wisselen |
| `Super + Shift + Backspace` | Venstertussenruimtes in-/uitschakelen |
| `Super + Ctrl + Alt + F` | Bureaublad op volledig scherm in-/uitschakelen (bovenbalk + venstertussenruimtes) |

## Herinneringen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Een herinnering instellen  |
| `Super + Ctrl + Alt + R` | Alle herinneringen bekijken  |
| `Super + Ctrl + Shift + R` | Alle herinneringen wissen  |

## Mededelingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Tijd weergeven als melding  |
| `Super + Ctrl + Alt + B` | Batterij weergeven als melding  |
| `Super + Ctrl + Alt + W` | Weer in-/uitschakelen als melding  |

## Tmux

De prefix-toets is `Ctrl + Space` (`Ctrl + B` werkt ook). Je kunt deze koppelingen wijzigen in `~/.config/tmux/tmux.conf`.

### Deelvensters

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + v` | Deelvenster ernaast splitsen (verticaal) |
| `Prefix + h` | Deelvenster eronder splitsen (horizontaal) |
| `Prefix + x` | Deelvenster beëindigen |
| `Prefix + z` | Deelvensterzoom in-/uitschakelen (volledig scherm) |
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
| `Alt + 1-9` | Naar specifiek venster gaan |
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
| `Prefix + d` | Loskoppelen van sessie |

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
| `Prefix + ?` | Tmux-toetskoppelingen weergeven |
| `Prefix + :` | Opdrachtprompt |

### Tmux-layoutfuncties

Deze functies moeten binnen een Tmux-sessie worden uitgevoerd.

| Opdracht | Functie |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-layout maken met editor, AI en terminal |
| `tdlm <ai> [<second_ai>]` | Dev-layout maken per submap |
| `tsl <count> <command>` | Swarm-layout met meerdere deelvensters maken |

## Ghostty-terminal

De Ghostty-terminal wordt geïnstalleerd met _Install > Terminal_ via het Omarchy-menu.

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nieuwe splitsing eronder |
| `Ctrl + Shift + O` | Nieuwe splitsing ernaast |
| `Ctrl + Alt + Arrows` | Tussen splitsingen bewegen |
| `Super + Ctrl + Shift + Arrows` | Splitsing formaat wijzigen met 10 regels |
| `Super + Ctrl + Shift + Alt + Arrows` | Splitsing formaat wijzigen met 100 regels |
| `Ctrl + Shift + T` | Nieuw tabblad  |
| `Ctrl + Shift + Arrows` | Tussen tabbladen bewegen |
| `Alt + Numbers` | Naar specifiek tabblad gaan |
| `Shift + Pg Up/Down` | Door de geschiedenis scrollen |
| `Ctrl + Left mouse` | Link openen in browser |

## Bestandsbeheerder

| Sneltoets              | Functie                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Naar pad gaan                     |
| `Space`               | Bestand voorvertonen (pijlen navigeren) |
| `Alt + Up`       | Omhoog naar bovenliggende map gaan        |

## Neovim (met lazyvim)

### Navigatie

| Sneltoets                   | Functie                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Opdrachtopties weergeven            |
| `Space Space`              | Bestand openen via fuzzy zoeken      |
| `Space E`                  | Zijbalk in-/uitschakelen                  |
| `Space G G`                | Git-bediening weergeven               |
| `Space S G`                | Bestandsinhoud zoeken               |
| `Ctrl + W W`               | Tussen zijbalk en editor springen |
| `Ctrl + Left/right arrow`  | Grootte van zijbalk wijzigen          |
| `Shift + H`                      | Naar linker bestandstabblad gaan             |
| `Shift + L`                      | Naar rechter bestandstabblad gaan            |
| `Space B D`                | Bestandstabblad sluiten                  |

### In de zijbalk

| Sneltoets                   | Functie                        |
| ------------------------ | ------------------------------- |
| `A`                        | Nieuw bestand toevoegen in bovenliggende map      |
| `Shift + A`                | Nieuwe submap toevoegen in bovenliggende map    |
| `D`                        | Gemarkeerd bestand/map verwijderen     |
| `M`                        | Gemarkeerd bestand/map verplaatsen       |
| `R`                        | Gemarkeerd bestand/map hernoemen     |
| `?`                        | Help voor alle opdrachten weergeven      |

[Bekijk alle Neovim-sneltoetsen die door LazyVim zijn geconfigureerd](https://www.lazyvim.org/keymaps).

## Snelle emoji's

Je kunt `Super + Ctrl + E` gebruiken om een volledige emoji-kiezer te weergeven die de selectie op het klembord zet, of je kunt deze snelle toegangsopties gebruiken.

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
| `Shift + CapsLock M X` | 🎉 | feest |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | proost      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | groet |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | ontploffend |

## Snelle aanvullingen

| Sneltoets       | Aanvulling       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (gedachtestreepje)   |
| `Shift + CapsLock Space N` | Je naam (zoals ingevoerd bij het instellen)  |
| `Shift + CapsLock Space E` | Je e-mail (zoals ingevoerd bij het instellen)  |

Je kunt er meer van jezelf toevoegen door `~/.XCompose` te bewerken en daarna `omarchy restart xcompose` in de terminal uit te voeren, zodat de wijzigingen worden opgepikt.
