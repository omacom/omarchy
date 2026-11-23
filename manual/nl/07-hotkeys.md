# Sneltoetsen

Je kunt alle belangrijke toetsenbordbindingen zien met `Super + K` (Tmux-bindingen met `Super + Alt + K` en Herdr-bindingen met `Super + Ctrl + K`).

## Hoe sneltoetsen zijn ingedeeld

Elke sneltoets bevindt zich op een vlak, bepaald door de modificatietoetsen ervan, en elk vlak heeft één taak. Daardoor blijven de sneltoetsen overzichtelijk, en kun je meestal raden waar iets thuishoort.

| Vlak | Wat daar thuishoort | Voorbeelden |
| --- | --- | --- |
| `Super + key` | Het systeem: vensters, werkruimten, lay-outs en kernmenu's | `Super + Space` Omarchy-menu, `Super + W` venster sluiten, `Super + F` volledig scherm |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panelen en systeemmenu's | `Super + Ctrl + A` audio, `Super + Ctrl + N` netwerk, `Super + Ctrl + C` vastlegmenu |
| `Super + Ctrl + Alt + key` | Snelle acties en kennisgevingen | `Super + Ctrl + Alt + T` tijd weergeven, `Super + Ctrl + Alt + B` batterij, `Super + Ctrl + Alt + C` schermafbeelding |

`Alt` toevoegen aan een sneltoets geeft je een variant van hetzelfde, nooit iets dat er niets mee te maken heeft:

- `Super + Shift + B` opent de browser; `Super + Shift + Alt + B` opent een privévenster
- `Super + Shift + E` opent e-mail; `Super + Shift + Alt + E` start een nieuwe
- `Super + F` gaat naar volledig scherm; `Super + Alt + F` gaat naar volledige breedte
- `Super + Ctrl + C` opent het vastlegmenu; `Super + Ctrl + Alt + C` slaat het menu over en maakt een schermafbeelding

Bij het toevoegen van een sneltoets:

1. Kies het vlak op basis van wat hij doet, kies dan de toets.
2. Verplaats geen bestaande sneltoets om ruimte te maken. Zoek een vrije toets op het juiste vlak.
3. Gebruik `Alt` alleen voor een variant van de sneltoets zonder `Alt`.

Een paar sneltoetsen breken deze regels omdat ze handig zijn. `Shift` met een pijl of `Tab` verplaatst of keert om in plaats van een app te openen, en `Print`, de mediatoetsen, `Alt + Tab` en `Ctrl + Alt + Del` werken zoals ze overal elders werken. Het zijn uitzonderingen, geen patronen om te kopiëren.

Als een standaardinstelling je niet bevalt (bijvoorbeeld als je `Super + Shift + S` wilt voor schermafbeeldingen, zoals op Windows), bind hem dan opnieuw in `~/.config/hypr/bindings.lua`.

## Navigeren

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-menu (apps en alles andere)    |
| `Super + Alt + Space` | App-raster |
| `Super + Escape` | Systeemmenu (slaapstand, herstarten, enz.)  |
| `Super + Ctrl + L` | Computer vergrendelen |
| `Super + W` or `Super + Q` | Venster sluiten             |
| `Ctrl + Alt + Del` | Alle vensters sluiten |
| `Super + K` | Alle sneltoetsen weergeven |
| `Super + Alt + K` | Tmux-sneltoetsen weergeven |
| `Super + Ctrl + K` | Herdr-sneltoetsen weergeven |
| `Super + M` | Venster minimaliseren naar het dock |
| `Super + T`               | Venster schakelen tussen tegelen/zweven             |
| `Super + J` | Vensterpositie schakelen (horizontaal/verticaal) |
| `Super + O`               | Venster laten uitklappen naar sticky'n'floating in-/uitschakelen |
| `Super + L`               | Door de dwindle-, scrolling- en zwevende lay-outs bladeren |
| `Super + Alt + L`         | In omgekeerde volgorde door de lay-outs bladeren |
| `Super + P`               | Pseudovensterstijl schakelen (natuurlijk vs. uitrekken) |
| `Super + F`                 | Naar volledig scherm gaan              |
| `Super + Alt + F`                 | Naar volledige breedte gaan              |
| `Super + Ctrl + F`                 | Naar volledig scherm binnen het venster gaan              |
| `Super + 1…9/0`         | Naar specifieke werkruimte springen (0 is 10) op de monitor met de focus |
| `Super + Tab` | Naar volgende werkruimte springen op de monitor met de focus |
| `Super + Shift + Tab` | Naar vorige werkruimte springen op de monitor met de focus |
| `Super + Ctrl + Tab` | Naar voormalige werkruimte springen op de monitor met de focus |
| `Super + Shift + 1…9/0` | Venster verplaatsen naar werkruimte op de monitor met de focus |
| `Super + Shift + Alt + 1…9/0` | Venster verplaatsen naar werkruimte op de monitor met de focus zonder te volgen |
| `Super + S` | Volledig kladblok in-/uitschakelen |
| `Super + Alt + S` | Venster verplaatsen naar volledig kladblok |
| `Super + the key above Tab` (grave on US layouts) | Quake-console in-/uitschakelen |
| `Super + Shift + the key above Tab` (grave on US layouts) | Venster verplaatsen naar Quake-console |
| `Super + Shift + Ctrl + Arrows` | Venster verplaatsen naar de monitor in die richting |
| `Super + Shift + Alt + Arrows` | Werkruimte verplaatsen naar de monitor in die richting |
| `Super + Arrow`  | Focus verplaatsen naar venster in de richting van de pijl, aan de rand van het scherm oversteken naar de monitor aan die kant |
| `Super + Shift + Arrow`  | Venster verwisselen met een ander in de richting van de pijl, inclusief een op de monitor aan die kant |
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
| `Super + Scroll Wheel` | Door werkruimten scrollen op de monitor met de focus |
| `Super + G`               | Venstergroepering in-/uitschakelen      |
| `Super + Alt + G`               | Venster uit groepering verplaatsen      |
| `Super + Alt + Tab`               | Tussen vensters in een groepering bladeren      |
| `Super + Alt + Shift + Tab`               | Achterwaarts tussen vensters in een groepering bladeren      |
| `Super + Alt + Scroll Wheel` | Tussen vensters in een groepering bladeren |
| `Super + Alt + 1/2/3/4/5`               | Naar specifiek venster in een groepering springen      |
| `Super + Alt + Arrow`  | Venster in groepering verplaatsen in de richting van de pijl, inclusief een op de monitor aan die kant |
| `Super + Ctrl + Left/Right`  | Tussen vensters binnen een tegelgroep bewegen |
| `Super + Ctrl + Z` | Op het scherm inzoomen (herhalen voor meer zoom) |
| `Super + Ctrl + Alt + Z` | Volledig van het scherm uitzoomen |
| `Super + /` | Vooruit stappen door monitorschaalopties |
| `Super + Alt + /` | Achteruit stappen door monitorschaalopties |
| `Alt + Tab` | Vooruit bladeren door vensters op de actieve werkruimte |
| `Alt + Shift + Tab` | Achterwaarts bladeren door vensters op de actieve werkruimte |
| `Ctrl + Alt + Tab`| Focus vooruit bladeren door monitors |
| `Ctrl + Alt + Shift + Tab`| Focus achterwaarts bladeren door monitors |
| `Super + I` | Invoertaal wisselen (met meer dan één lay-out of invoermethode) |
| `Super + Shift + I` | Invoertaal terugwisselen |

Op een touchpad wisselen vegen met drie en vier vingers tussen werkruimten, verplaatsen ze vensters en openen ze het menu en de Quake-console; zie [toetsenbord, muis en trackpad](34-keyboard-mouse-trackpad.md) voor de gebaren.

Het wijzigen van het formaat gebruikt de twee toetsen rechts van 0, wat je toetsenbord er ook op afdrukt: `-` en `=` op Amerikaanse toetsenborden, `+` en `´` op Deense en Zweedse, `+` en `\` op Noorse, `ß` en `´` op Duitse, `'` en `¡` op Spaanse, en `-` en `^` op Japanse (JIS). `Super + K` geeft ze weer zoals je toetsenbord ze afdrukt. Op JIS is `Super + ^` gelijk aan `Super + Equal`, terwijl `Super + Shift + -` (die `=` typt) gelijk is aan `Super + Shift + Minus`. Monitorschaling en de wachtwoordmanager gebruiken `/`; op lay-outs die `/` alleen met Shift typen, zoals de meeste Europese dat doen, gebruiken ze in plaats daarvan de toets links van de rechter Shift (`-` op Deens en Duits).

## Systeemregelaars

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audiopaneel    |
| `Super + Ctrl + B`           | Bluetooth-paneel    |
| `Super + Ctrl + N`           | Wi-Fi/netwerkpaneel    |
| `Super + Ctrl + D`           | Beeldschermpaneel    |
| `Super + Ctrl + P`           | Energiepaneel    |
| `Super + Ctrl + X`           | Agents-paneel    |
| `Super + Ctrl + Alt + X`           | Paneel voor lokale modellen    |
| `Super + Ctrl + Alt + D`           | Kalenderpaneel    |
| `Super + Ctrl + Alt + E`           | Wereldklokpaneel    |
| `Super + Ctrl + 1-9`           | Balkpaneel op positie in-/uitschakelen    |
| `Super + Ctrl + S` | Deelmenu (via LocalSend) |
| `Super + Ctrl + C` | Vastlegregelaars (schermafbeelding/-opname/kiezer) |
| `Super + Ctrl + O` | Menu in-/uitschakelen |
| `Super + Ctrl + H` | Hardware-menu |
| `Super + Ctrl + E` | Emoji-kiezer |
| `Super + Ctrl + .` | Media transcoderen |
| `Super + Shift + Ctrl + A` | Je standaardagent starten |
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
| `Ctrl + Brightness Up/Down` | Toetsenbordverlichting helderder/donkerder, op toetsenborden zonder eigen toetsen |
| `Mic Mute` | De microfoon dempen |
| `Shift + Mute` | Audio-uitvoer wisselen |
| `Touchpad Toggle` | Het touchpad in- of uitschakelen |
| `Display` key | Door de werkruimtelayout bladeren |
| `Alt + Play` | Volgende nummer |
| `Alt + Shift + Play` | Vorige nummer |

## Apps starten

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agent manager) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (privé/incognito)    |
| `Super + Shift + F`           | Bestandsbeheer    |
| `Super + Shift + Alt + F`           | Bestandsbeheer in de cwd van de terminal    |
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
| `Super + Shift + A`           | Je standaardagent, of ChatGPT totdat je er een kiest |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Berichtenapp (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Berichtenapp (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Berichtenapp (Google)  |
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
| `Super + Ctrl + V`           | Klembordbeheer    |

Meestal heb je op Linux `Ctrl + Shift + C/V` nodig om te kopiëren-en-plakken in de terminal en `Ctrl + C/V` om dat overal elders te doen. Deze uniforme Omarchy-klembordsneltoetsen werken overal.

## Vastleggen

| Sneltoets              | Functie                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Schermafbeelding                      |
| `Super + Ctrl + Alt + C`            | Schermafbeelding (dezelfde opname, voor toetsenborden zonder Print Screen-toets) |
| `Super + Ctrl + C` | Vastlegmenu |
| `Alt + Print Screen`            | Schermopname                     |
| `Super + Shift + Ctrl + Alt + C` | Schermopname zonder audio, het menu overslaan (opnieuw indrukken om te stoppen) |
| `Super + Print Screen` | Kleurkiezer |
| `Super + Ctrl + Print Screen` | Tekstextractie naar klembord |
| `Super + Alt + [` | Webcam-overlay kleiner maken tijdens het opnemen |
| `Super + Alt + ]` | Webcam-overlay groter maken tijdens het opnemen |
| `Alt + Shift + L` | Huidige URL kopiëren uit webapp of browser |
| `Alt + Shift + D` | De video op de huidige pagina downloaden naar `~/Videos` |
| `Alt + Space` | Dicteren starten/stoppen (vereist _Setup > Defaults > Dictation_) |
| `Right Alt` | Ingedrukt houden om te dicteren (vereist _Setup > Defaults > Dictation_) |

Bij schermopnamen vraagt de sneltoets eerst welke audio je wilt, en begint dan met opnemen. Druk er opnieuw op om te stoppen. Zie [schermafbeeldingen en opname](12-screenshots-recording.md) voor de details.

Alle vastlegopties zijn ook toegankelijk onder _Trigger > Capture_ in het Omarchy-menu (`Super + Space`).

## Meldingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + ,` | Reageren op de nieuwste melding: deze openen of op de enige knop drukken, uit de keuzes kiezen, of deze negeren als er geen zijn  |
| `Super + Shift + ,` | Alle meldingen negeren |
| `Super + Ctrl + ,` | Meldingen bedienen met het toetsenbord  |
| `Super + Alt + ,` | Nieuwste melding negeren  |
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
| `Super + Shift + Space` | De bovenste balk in-/uitschakelen  |
| `Shift + Mute` | Naar volgende audio-uitvoer wisselen |
| `Shift + Play` | Naar volgende mediabron wisselen |
| `Super + Shift + Backspace` | Venstertussenruimten in-/uitschakelen |
| `Super + Ctrl + Alt + F` | Volledig-schermbureaublad in-/uitschakelen (bovenste balk + venstertussenruimten) |

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

De prefixtoets is `Ctrl + Space` (`Ctrl + B` werkt ook). Je kunt deze bindingen wijzigen in `~/.config/tmux/tmux.conf`.

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
| `Prefix + d` | Van sessie loskoppelen |

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

### Tmux-lay-outfuncties

Deze functies moeten binnen een Tmux-sessie worden uitgevoerd.

| Opdracht | Functie |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-lay-out maken met editor, AI en terminal |
| `tdlm <ai> [<second_ai>]` | Dev-lay-out per submap maken |
| `tsl <count> <command>` | Swarm-lay-out met meerdere panelen maken |

## Ghostty Terminal

Ghostty-terminal wordt geïnstalleerd met _Install > Terminal_ via het Omarchy-menu.

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
| `Ctrl + Left mouse` | Link in browser openen |

## Bestandsbeheer

| Sneltoets              | Functie                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Naar pad gaan                     |
| `Space`               | Bestand voorvertonen (pijlen navigeren) |
| `Alt + Up`       | Omhoog gaan naar bovenliggende map        |

## Neovim (w/ lazyvim)

### Navigatie

| Sneltoets                   | Functie                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Opdrachtopties weergeven            |
| `Space Space`              | Bestand openen via fuzzy zoeken      |
| `Space E`                  | Zijbalk in-/uitschakelen                  |
| `Space G G`                | Git-bediening weergeven               |
| `Space S G`                | Bestandsinhoud doorzoeken             |
| `Ctrl + W W`               | Tussen zijbalk en editor springen |
| `Ctrl + Left/right arrow`  | Grootte van de zijbalk wijzigen          |
| `Shift + H`                      | Naar linker bestandstabblad gaan             |
| `Shift + L`                      | Naar rechter bestandstabblad gaan            |
| `Space B D`                | Bestandstabblad sluiten                  |

### In de zijbalk

| Sneltoets                   | Functie                        |
| ------------------------ | ------------------------------- |
| `A`                        | Nieuw bestand toevoegen in bovenliggende map      |
| `Shift + A`                | Nieuwe submap toevoegen in bovenliggende map    |
| `D`                        | Geselecteerd bestand/map verwijderen     |
| `M`                        | Geselecteerd bestand/map verplaatsen       |
| `R`                        | Geselecteerd bestand/map hernoemen     |
| `?`                        | Help voor alle opdrachten weergeven      |

[Bekijk alle Neovim-sneltoetsen die door LazyVim zijn geconfigureerd](https://www.lazyvim.org/keymaps).

## Snelle emoji's

Je kunt `Super + Ctrl + E` gebruiken om een complete emoji-kiezer te tonen die de selectie op het klembord zet, of je kunt deze snelle toegangsopties gebruiken.

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
| `Shift + CapsLock M O` |👌 | oké |
| `Shift + CapsLock M G` |👋 | groet |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | ontploffen |

## Snelle aanvullingen

| Sneltoets       | Aanvulling       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Je naam (zoals ingevoerd tijdens de installatie)  |
| `Shift + CapsLock Space E` | Je e-mail (zoals ingevoerd tijdens de installatie)  |

Je kunt er meer van jezelf toevoegen door `~/.XCompose` te bewerken en vervolgens `omarchy restart xcompose` in de terminal uit te voeren om de wijzigingen te laten overnemen.
