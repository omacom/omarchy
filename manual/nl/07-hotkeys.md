# Sneltoetsen

Je ziet alle belangrijke toetsenbordcombinaties met `Super + K` (Tmux-combinaties met `Super + Alt + K` en Herdr-combinaties met `Super + Ctrl + K`).

## Hoe sneltoetsen zijn ingedeeld

Elke sneltoets bevindt zich op een vlak, bepaald door de modificatietoetsen, en elk vlak heeft één taak. Daardoor blijven de sneltoetsen overzichtelijk en kun je meestal raden waar iets te vinden is.

| Vlak | Wat daar thuishoort | Voorbeelden |
| --- | --- | --- |
| `Super + key` | Het systeem: vensters, werkruimten, indelingen en kernmenu's | `Super + Space` Omarchy-menu, `Super + W` venster sluiten, `Super + F` volledig scherm |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panelen en systeemmenu's | `Super + Ctrl + A` audio, `Super + Ctrl + N` netwerk, `Super + Ctrl + C` vastlegmenu |
| `Super + Ctrl + Alt + key` | Snelle acties en meldingen | `Super + Ctrl + Alt + T` tijd weergeven, `Super + Ctrl + Alt + B` batterij, `Super + Ctrl + Alt + C` schermafbeelding |

`Alt` aan een sneltoets toevoegen geeft je een variant van hetzelfde, nooit iets totaal anders:

- `Super + Shift + B` opent de browser; `Super + Shift + Alt + B` opent een privévenster
- `Super + Shift + E` opent e-mail; `Super + Shift + Alt + E` begint een nieuwe e-mail
- `Super + F` gaat naar volledig scherm; `Super + Alt + F` gaat naar volledige breedte
- `Super + Ctrl + C` opent het vastlegmenu; `Super + Ctrl + Alt + C` slaat het menu over en maakt een schermafbeelding

Wanneer je een sneltoets toevoegt:

1. Kies het vlak op basis van wat de toets doet, kies daarna de toets.
2. Verplaats geen bestaande sneltoets om ruimte te maken. Zoek een vrije toets op het juiste vlak.
3. Gebruik `Alt` alleen voor een variant van de sneltoets zonder `Alt`.

Een paar sneltoetsen overtreden deze regels omdat dat handig is. `Shift` met een pijl of `Tab` verplaatst of keert om in plaats van een app te openen, en `Print`, de mediatoetsen, `Alt + Tab` en `Ctrl + Alt + Del` werken zoals overal elders. Het zijn uitzonderingen, geen patronen om te kopiëren.

Als een standaardinstelling je niet bevalt (stel dat je `Super + Shift + S` wilt voor schermafbeeldingen, zoals in Windows), wijzig de toewijzing dan in `~/.config/hypr/bindings.lua`.

## Navigeren

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-menu (apps en al het andere)    |
| `Super + Alt + Space` | App-raster |
| `Super + Escape` | Systeemmenu (slaapstand, herstarten, enz.)  |
| `Super + Ctrl + L` | Computer vergrendelen |
| `Super + W` or `Super + Q` | Venster sluiten             |
| `Ctrl + Alt + Del` | Alle vensters sluiten |
| `Super + T`               | Venster schakelen tussen tegelen/zwevend             |
| `Super + J` | Vensterpositie schakelen (horizontaal/verticaal) |
| `Super + O`               | Venster omzetten naar sticky'n'floating |
| `Super + L`               | Door de indelingen dwindle, scrolling en floating bladeren |
| `Super + Alt + L`         | In omgekeerde volgorde door de indelingen bladeren |
| `Super + P`               | Pseudo-vensterstijl schakelen (natuurlijk vs. uitgerekt) |
| `Super + F`                 | Volledig scherm              |
| `Super + Alt + F`                 | Volledige breedte              |
| `Super + Ctrl + F`                 | Volledig scherm binnen venster              |
| `Super + 1/2/3/4`         | Naar specifieke werkruimte op de gefocusde monitor springen |
| `Super + Tab` | Naar volgende werkruimte op de gefocusde monitor springen |
| `Super + Shift + Tab` | Naar vorige werkruimte op de gefocusde monitor springen |
| `Super + Ctrl + Tab` | Naar laatst gebruikte werkruimte op de gefocusde monitor springen |
| `Super + Shift + 1/2/3/4` | Venster verplaatsen naar werkruimte op de gefocusde monitor |
| `Super + Shift + Alt + 1/2/3/4` | Venster verplaatsen naar werkruimte op de gefocusde monitor zonder mee te gaan |
| `Super + S` | Volledige scratchpad in-/uitschakelen |
| `Super + Alt + S` | Venster verplaatsen naar volledige scratchpad |
| `Super + Grave` | Quake-console in-/uitschakelen |
| `Super + Shift + Grave` | Venster verplaatsen naar Quake-console |
| `Super + Shift + Ctrl + Arrows` | Venster verplaatsen naar de monitor in die richting |
| `Super + Shift + Alt + Arrows` | Werkruimte verplaatsen naar de monitor in die richting |
| `Super + Arrow`  | Focus verplaatsen naar venster in de richting van de pijl, aan de schermrand overstekend naar de monitor aan die kant |
| `Super + Shift + Arrow`  | Venster verwisselen met een ander in de richting van de pijl, inclusief een op de monitor aan die kant |
| `Super + Minus` | Venster naar links uitbreiden |
| `Super + Equal` | Venster naar links verkleinen |
| `Super + Shift + Minus` | Venster naar boven verkleinen |
| `Super + Shift + Equal` | Venster naar beneden uitbreiden |
| `Super + Alt + Minus/Equal` | Zelfde formaatwijziging in kleinere stappen |
| `Super + Ctrl + Minus/Equal` | Zelfde formaatwijziging in grotere stappen |
| `Super + Alt + Home` | Vensterbreedte opslaan |
| `Super + Home` | Opgeslagen vensterbreedte herstellen |
| `Super + Left Mouse` | Venster verslepen |
| `Super + Right Mouse` | Vensterformaat wijzigen |
| `Super + Scroll Wheel` | Door werkruimten op de gefocusde monitor scrollen |
| `Super + G`               | Venstergroepering in-/uitschakelen      |
| `Super + Alt + G`               | Venster uit groepering halen      |
| `Super + Alt + Tab`               | Tussen vensters in groepering bladeren      |
| `Super + Alt + Shift + Tab`               | Achterwaarts tussen vensters in groepering bladeren      |
| `Super + Alt + Scroll Wheel` | Tussen vensters in groepering bladeren |
| `Super + Alt + 1/2/3/4/5`               | Naar specifiek venster in groepering springen      |
| `Super + Alt + Arrow`  | Venster in groepering plaatsen in de richting van de pijl, inclusief een op de monitor aan die kant |
| `Super + Ctrl + Left/Right`  | Tussen vensters binnen een tegelgroep bewegen |
| `Super + Ctrl + Z` | Inzoomen op scherm (herhalen voor meer zoom) |
| `Super + Ctrl + Alt + Z` | Volledig uitzoomen van scherm |
| `Super + /` | Vooruit door monitorschaalopties stappen |
| `Super + Alt + /` | Achteruit door monitorschaalopties stappen |
| `Alt + Tab` | Vooruit bladeren door vensters op de actieve werkruimte |
| `Alt + Shift + Tab` | Achteruit bladeren door vensters op de actieve werkruimte |
| `Ctrl + Alt + Tab`| Focus vooruit door monitors bladeren |
| `Ctrl + Alt + Shift + Tab`| Focus achteruit door monitors bladeren |

Sneltoetsen voor formaatwijziging gebruiken de fysieke toetsen `code:20` en `code:21` (XKB `<AE11>` en `<AE12>`), ongeacht de tekens die op het toetsenbord staan gedrukt. Op Amerikaanse toetsenborden zijn deze toetsen `-` en `=`; op Japanse (JIS)-toetsenborden zijn het `-` en `^`; op Spaanse toetsenborden zijn het `'` en `¡`. Op JIS is `Super + ^` gelijk aan `Super + Equal`, terwijl `Super + Shift + -` (waarmee je `=` typt) gelijk is aan `Super + Shift + Minus`.

## Systeembediening

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audiopaneel    |
| `Super + Ctrl + B`           | Bluetooth-paneel    |
| `Super + Ctrl + N`           | Wifi-/netwerkpaneel    |
| `Super + Ctrl + D`           | Weergavepaneel    |
| `Super + Ctrl + P`           | Energiepaneel    |
| `Super + Ctrl + X`           | Agents-paneel    |
| `Super + Ctrl + Alt + D`           | Kalenderpaneel    |
| `Super + Ctrl + Alt + E`           | Wereldklokpaneel    |
| `Super + Ctrl + 1-9`           | Balkpaneel op positie in-/uitschakelen    |
| `Super + Ctrl + S` | Deelmenu (via LocalSend) |
| `Super + Ctrl + C` | Vastlegbediening (schermafbeelding/-opname/kiezer) |
| `Super + Ctrl + O` | Menu in-/uitschakelen |
| `Super + Ctrl + H` | Hardware-menu |
| `Super + Ctrl + E` | Emoji-kiezer |
| `Super + Ctrl + .` | Media transcoderen |
| `Super + Shift + Ctrl + A` | Een AI-agent kiezen |

## Aanpassingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximale schermhelderheid |
| `Shift + Brightness Down` | Minimale schermhelderheid |
| `Alt + Brightness Up/Down` | Nauwkeurige helderheidsaanpassingen van 1% |
| `Alt + Volume Up/Down` | Nauwkeurige volumeaanpassingen van 1% |
| `Keyboard Brightness Up/Down` | Toetsenbordachtergrondverlichting feller/dimmer |
| `Keyboard Backlight` | Door de niveaus van de toetsenbordachtergrondverlichting bladeren |
| `Alt + Play` | Volgende nummer |
| `Alt + Shift + Play` | Vorige nummer |

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

Wijzig/voeg toewijzingen toe in `~/.config/hypr/bindings.lua`.

## Universeel klembord

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + A`           | Alles selecteren in apps die `Ctrl + A` ondersteunen    |
| `Super + C`           | Kopiëren    |
| `Super + X`           | Knippen (niet in terminal)    |
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
| `Super + Print Screen` | Kleurenkiezer |
| `Super + Ctrl + Print Screen` | Tekstextractie naar klembord |
| `Super + Alt + [` | Webcam-overlay kleiner maken tijdens opname |
| `Super + Alt + ]` | Webcam-overlay groter maken tijdens opname |
| `Alt + Shift + L` | Huidige URL kopiëren uit webapp of Chromium |
| `Alt + Shift + D` | De video op de huidige pagina downloaden naar `~/Videos` |
| `Alt + Space` | Dicteren starten/stoppen (vereist _Setup > Defaults > Dictation_) |
| `Right Alt` | Ingedrukt houden om te dicteren (vereist _Setup > Defaults > Dictation_) |

Bij schermopnamen vraagt de sneltoets eerst welke audio je wilt, en begint daarna met opnemen. Druk er opnieuw op om te stoppen. Zie [schermafbeeldingen en opnamen](12-screenshots-recording.md) voor de details.

Alle vastlegopties zijn ook toegankelijk onder _Trigger > Capture_ in het Omarchy-menu (`Super + Space`).

## Meldingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + ,` | Actie uitvoeren op de nieuwste melding: open deze of druk op de enige knop, kies uit de opties, of sluit deze als er geen zijn  |
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

Alle stijlopties zijn ook toegankelijk onder _Style_ in het Omarchy-menu (`Super + Space`).

## In-/uitschakelen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Vergrendeling bij inactiviteit in-/uitschakelen |
| `Super + Ctrl + Delete` | Laptopscherm in-/uitschakelen |
| `Super + Ctrl + Alt + Delete` | Laptopscherm spiegelen in-/uitschakelen |
| `Super + Shift + Space` | De bovenbalk in-/uitschakelen  |
| `Shift + Mute` | Naar volgende audio-uitvoer schakelen |
| `Shift + Play` | Naar volgende mediabron schakelen |
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
| `Super + Ctrl + Alt + T` | Tijd weergeven als melding  |
| `Super + Ctrl + Alt + B` | Batterij weergeven als melding  |
| `Super + Ctrl + Alt + W` | Weer weergeven als melding in-/uitschakelen  |

## Tmux

De prefix-toets is `Ctrl + Space` (`Ctrl + B` werkt ook). Je kunt deze toewijzingen wijzigen in `~/.config/tmux/tmux.conf`.

### Panelen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + v` | Paneel ernaast splitsen (verticaal) |
| `Prefix + h` | Paneel eronder splitsen (horizontaal) |
| `Prefix + x` | Paneel beëindigen |
| `Prefix + z` | Paneelzoom in-/uitschakelen (volledig scherm) |
| `Alt + Enter` | Paneel eronder splitsen (geen prefix) |
| `Alt + Shift + Enter` | Paneel ernaast splitsen (geen prefix) |
| `Alt + Escape` | Paneel beëindigen (geen prefix) |
| `Ctrl + Alt + Arrows` | Tussen panelen bewegen |
| `Ctrl + Alt + Shift + Arrows` | Paneelformaat wijzigen |

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
| `Prefix + ?` | Tmux-toetsenbordcombinaties weergeven |
| `Prefix + :` | Opdrachtprompt |

### Tmux-indelingsfuncties

Deze functies moeten binnen een Tmux-sessie worden uitgevoerd.

| Commando | Functie |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-indeling maken met editor, AI en terminal |
| `tdlm <ai> [<second_ai>]` | Dev-indeling per submap maken |
| `tsl <count> <command>` | Swarm-indeling met meerdere panelen maken |

## Ghostty Terminal

De Ghostty-terminal wordt geïnstalleerd met _Install > Terminal_ via het Omarchy-menu.

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nieuwe splitsing eronder |
| `Ctrl + Shift + O` | Nieuwe splitsing ernaast |
| `Ctrl + Alt + Arrows` | Tussen splitsingen bewegen |
| `Super + Ctrl + Shift + Arrows` | Splitsingsformaat met 10 regels wijzigen |
| `Super + Ctrl + Shift + Alt + Arrows` | Splitsingsformaat met 100 regels wijzigen |
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
| `Alt + Up`       | Omhoog naar bovenliggende map        |

## Neovim (met lazyvim)

### Navigatie

| Sneltoets                   | Functie                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Commando-opties weergeven            |
| `Space Space`              | Bestand openen via fuzzy zoeken      |
| `Space E`                  | Zijbalk in-/uitschakelen                  |
| `Space G G`                | Git-bediening weergeven               |
| `Space S G`                | Bestandsinhoud doorzoeken             |
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
| `?`                        | Help voor alle commando's weergeven      |

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
| `Shift + CapsLock M T` | 🥂 | proost      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | groet |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | wegblazen |

## Snelle aanvullingen

| Sneltoets       | Aanvulling       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Je naam (zoals ingevoerd tijdens de setup)  |
| `Shift + CapsLock Space E` | Je e-mail (zoals ingevoerd tijdens de setup)  |

Je kunt er zelf meer toevoegen door `~/.XCompose` te bewerken en daarna `omarchy-restart-xcompose` in de terminal uit te voeren, zodat de wijzigingen worden overgenomen.
