# Sneltoetsen

Je ziet alle belangrijkste toetscombinaties met `Super + K` (Tmux-bindingen met `Super + Alt + K` en Herdr-bindingen met `Super + Ctrl + K`).

## Hoe sneltoetsen zijn ingedeeld

Elke sneltoets zit op een vlak, bepaald door zijn modificatietoetsen, en elk vlak heeft één taak. Daardoor blijven de sneltoetsen uit elkaar te houden, en kun je meestal raden waar iets zit.

| Vlak | Wat daar hoort | Voorbeelden |
| --- | --- | --- |
| `Super + key` | Het systeem: vensters, werkruimtes, indelingen en kernmenu's | `Super + Space` Omarchy-menu, `Super + W` venster sluiten, `Super + F` volledig scherm |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panelen en systeemmenu's | `Super + Ctrl + A` audio, `Super + Ctrl + N` netwerk, `Super + Ctrl + C` vastlegmenu |
| `Super + Ctrl + Alt + key` | Snelle acties en mededelingen | `Super + Ctrl + Alt + T` tijd weergeven, `Super + Ctrl + Alt + B` accu, `Super + Ctrl + Alt + C` schermafbeelding |

`Alt` toevoegen aan een sneltoets geeft je een variant van hetzelfde, nooit iets dat er niets mee te maken heeft:

- `Super + Shift + B` opent de browser; `Super + Shift + Alt + B` opent een privévenster
- `Super + Shift + E` opent e-mail; `Super + Shift + Alt + E` start een nieuwe
- `Super + F` gaat naar volledig scherm; `Super + Alt + F` gaat naar volledige breedte
- `Super + Ctrl + C` opent het vastlegmenu; `Super + Ctrl + Alt + C` slaat het menu over en maakt een schermafbeelding

Wanneer je een sneltoets toevoegt:

1. Kies het vlak op basis van wat hij doet, kies dan de toets.
2. Verplaats geen bestaande sneltoets om ruimte te maken. Zoek een vrije toets op het juiste vlak.
3. Gebruik `Alt` alleen voor een variant van de sneltoets zonder `Alt`.

Een paar sneltoetsen breken deze regels omdat ze handig zijn. `Shift` met een pijl of `Tab` verplaatst of keert om in plaats van een app te openen, en `Print`, de mediatoetsen, `Alt + Tab` en `Ctrl + Alt + Del` werken zoals ze overal elders werken. Het zijn uitzonderingen, geen patronen om te kopiëren.

Als een standaardtoets je niet bevalt (stel dat je `Super + Shift + S` wilt voor schermafbeeldingen zoals op Windows), koppel hem dan opnieuw in `~/.config/hypr/bindings.lua`.

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
| `Super + T`               | Venster schakelen tussen tegelen/zwevend             |
| `Super + J` | Vensterpositie schakelen (horizontaal/verticaal) |
| `Super + O`               | Venster in sticky'n'floating zetten of eruit halen |
| `Super + L`               | Door de indelingen dwindle, scrolling en floating bladeren |
| `Super + Alt + L`         | Omgekeerd door de indelingen bladeren |
| `Super + P`               | Pseudo-vensterstijl schakelen (natuurlijk vs. uitgerekt) |
| `Super + F`                 | Naar volledig scherm              |
| `Super + Alt + F`                 | Naar volledige breedte              |
| `Super + Ctrl + F`                 | Naar volledig scherm binnen venster              |
| `Super + 1…9/0`         | Spring naar specifieke werkruimte (0 is 10) op de monitor met focus |
| `Super + Tab` | Spring naar volgende werkruimte op de monitor met focus |
| `Super + Shift + Tab` | Spring naar vorige werkruimte op de monitor met focus |
| `Super + Ctrl + Tab` | Spring naar eerdere werkruimte op de monitor met focus |
| `Super + Shift + 1…9/0` | Venster verplaatsen naar werkruimte op de monitor met focus |
| `Super + Shift + Alt + 1…9/0` | Venster verplaatsen naar werkruimte op de monitor met focus zonder mee te gaan |
| `Super + S` | Volledig scratchpad schakelen |
| `Super + Alt + S` | Venster verplaatsen naar volledig scratchpad |
| `Super + the key above Tab` (grave on US layouts) | Quake-console schakelen |
| `Super + Shift + the key above Tab` (grave on US layouts) | Venster verplaatsen naar Quake-console |
| `Super + Shift + Ctrl + Arrows` | Venster verplaatsen naar de monitor in die richting |
| `Super + Shift + Alt + Arrows` | Werkruimte verplaatsen naar de monitor in die richting |
| `Super + Arrow`  | Focus verplaatsen naar venster in richting van pijl, aan de schermrand overstekend naar de monitor aan die kant |
| `Super + Shift + Arrow`  | Venster wisselen met een ander in richting van pijl, inclusief een op de monitor aan die kant |
| `Super + Minus` | Venster naar links uitbreiden |
| `Super + Equal` | Venster naar links verkleinen |
| `Super + Shift + Minus` | Venster naar boven verkleinen |
| `Super + Shift + Equal` | Venster naar beneden uitbreiden |
| `Super + Alt + Minus/Equal` | Zelfde formaatwijziging in kleinere stappen |
| `Super + Ctrl + Minus/Equal` | Zelfde formaatwijziging in grotere stappen |
| `Super + Alt + Home` | Vensterbreedte opslaan |
| `Super + Home` | Opgeslagen vensterbreedte herstellen |
| `Super + Left Mouse` | Venster rondslepen |
| `Super + Right Mouse` | Vensterformaat wijzigen |
| `Super + Scroll Wheel` | Door werkruimtes bladeren op de monitor met focus |
| `Super + G`               | Venstergroepering schakelen      |
| `Super + Alt + G`               | Venster uit groepering halen      |
| `Super + Alt + Tab`               | Tussen vensters in groepering bladeren      |
| `Super + Alt + Shift + Tab`               | Achteruit tussen vensters in groepering bladeren      |
| `Super + Alt + Scroll Wheel` | Tussen vensters in groepering bladeren |
| `Super + Alt + 1/2/3/4/5`               | Spring naar specifiek venster in groepering      |
| `Super + Alt + Arrow`  | Venster in groepering plaatsen in richting van pijl, inclusief een op de monitor aan die kant |
| `Super + Ctrl + Left/Right`  | Tussen vensters binnen een tegelgroep bewegen |
| `Super + Ctrl + Z` | Inzoomen op scherm (herhaal voor meer zoom) |
| `Super + Ctrl + Alt + Z` | Volledig uitzoomen van scherm |
| `Super + /` | Stap vooruit door opties voor monitorschaling |
| `Super + Alt + /` | Stap achteruit door opties voor monitorschaling |
| `Alt + Tab` | Vooruit bladeren door vensters op de actieve werkruimte |
| `Alt + Shift + Tab` | Achteruit bladeren door vensters op de actieve werkruimte |
| `Ctrl + Alt + Tab`| Focus vooruit bladeren door monitors |
| `Ctrl + Alt + Shift + Tab`| Focus achteruit bladeren door monitors |
| `Super + I` | Invoertaal wisselen (met meer dan één indeling of invoermethode) |
| `Super + Shift + I` | Invoertaal terug wisselen |

Op een touchpad wisselen vegen met drie en vier vingers van werkruimte, verplaatsen ze vensters en openen ze het menu en de Quake-console; zie [toetsenbord, muis en trackpad](34-keyboard-mouse-trackpad.md) voor de gebaren.

Voor formaat wijzigen gebruik je de twee toetsen rechts van 0, wat je toetsenbord er ook op drukt: `-` en `=` op Amerikaanse toetsenborden, `+` en `´` op Deens en Zweeds, `+` en `\` op Noors, `ß` en `´` op Duits, `'` en `¡` op Spaans, en `-` en `^` op Japans (JIS). `Super + K` toont ze zoals je toetsenbord ze drukt. Op JIS is `Super + ^` gelijk aan `Super + Equal`, terwijl `Super + Shift + -` (waarmee je `=` typt) gelijk is aan `Super + Shift + Minus`. Monitorschaling en de wachtwoordmanager gebruiken `/`; op indelingen die `/` alleen met Shift typen, zoals de meeste Europese, gebruiken ze in plaats daarvan de toets links van de rechter Shift (`-` op Deens en Duits).

## Systeemregeling

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audiopaneel    |
| `Super + Ctrl + B`           | Bluetooth-paneel    |
| `Super + Ctrl + N`           | Wifi/netwerkpaneel    |
| `Super + Ctrl + D`           | Weergavepaneel    |
| `Super + Ctrl + P`           | Energiepaneel    |
| `Super + Ctrl + X`           | Agents-paneel    |
| `Super + Ctrl + Alt + D`           | Kalenderpaneel    |
| `Super + Ctrl + Alt + E`           | Wereldklokpaneel    |
| `Super + Ctrl + 1-9`           | Balkpaneel schakelen op positie    |
| `Super + Ctrl + S` | Deelmenu (via LocalSend) |
| `Super + Ctrl + C` | Vastlegregeling (schermafbeelding/-opname/kiezer) |
| `Super + Ctrl + O` | Menu schakelen |
| `Super + Ctrl + H` | Hardwaremenu |
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
| `Super + Ctrl + Return` | Herdr (agent manager) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (privé/incognito)    |
| `Super + Shift + F`           | Bestandsbeheer    |
| `Super + Shift + Alt + F`           | Bestandsbeheer in cwd van terminal    |
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
| `Super + Shift + Alt + X`           | X (nieuwe post) |
| `Super + Shift + Y`           | YouTube |

Wijzig/voeg bindingen toe in `~/.config/hypr/bindings.lua`.

## Universeel klembord

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + A`           | Alles selecteren in apps die `Ctrl + A` ondersteunen    |
| `Super + C`           | Kopiëren    |
| `Super + X`           | Knippen (niet in terminal)    |
| `Super + V`           | Plakken    |
| `Super + Ctrl + V`           | Klembordbeheer    |

Meestal heb je op Linux `Ctrl + Shift + C/V` nodig om te kopiëren-en-plakken in de terminal en `Ctrl + C/V` om dat overal elders te doen. Deze uniforme klembord-sneltoetsen van Omarchy werken overal.

## Vastleggen

| Sneltoets              | Functie                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Schermafbeelding                      |
| `Super + Ctrl + Alt + C`            | Schermafbeelding (dezelfde opname, voor toetsenborden zonder Print Screen-toets) |
| `Super + Ctrl + C` | Vastlegmenu |
| `Alt + Print Screen`            | Schermopname                     |
| `Super + Shift + Ctrl + Alt + C` | Schermopname zonder audio, menu overslaan (druk opnieuw om te stoppen) |
| `Super + Print Screen` | Kleurenkiezer |
| `Super + Ctrl + Print Screen` | Tekstextractie naar klembord |
| `Super + Alt + [` | Webcam-overlay kleiner maken tijdens opname |
| `Super + Alt + ]` | Webcam-overlay groter maken tijdens opname |
| `Alt + Shift + L` | Huidige URL kopiëren uit webapp of browser |
| `Alt + Shift + D` | De video op de huidige pagina downloaden naar `~/Videos` |
| `Alt + Space` | Dicteren starten/stoppen (vereist _Setup > Defaults > Dictation_) |
| `Right Alt` | Ingedrukt houden om te dicteren (vereist _Setup > Defaults > Dictation_) |

Bij schermopnames vraagt de sneltoets eerst welke audio je wilt, en start dan de opname. Druk er opnieuw op om te stoppen. Zie [schermafbeeldingen en opname](12-screenshots-recording.md) voor de details.

Alle vastlegopties zijn ook toegankelijk onder _Trigger > Capture_ in het Omarchy-menu (`Super + Space`).

## Meldingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + ,` | Nieuwste melding gebruiken: open deze of druk op de enige knop, kies uit de opties, of negeer deze als er geen zijn  |
| `Super + Shift + ,` | Alle meldingen sluiten |
| `Super + Ctrl + ,` | Meldingen bedienen met het toetsenbord  |
| `Super + Alt + ,` | Nieuwste melding sluiten  |
| `Super + Shift + Alt + ,` | Meldingsgeschiedenis openen  |
| `Super + Ctrl + Alt + ,` | Meldingen dempen in-/uitschakelen  |

## Stijl

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Kies een nieuw thema (ook `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Kies thema-achtergrond (ook `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparantie op een venster schakelen |
| `Super + Ctrl + Backspace` | Vierkante verhouding voor één venster schakelen |

Extra achtergrondafbeeldingen staan in `~/.config/omarchy/backgrounds/<theme name>`. Ook beschikbaar via _Install > Style > Background_ in het Omarchy-menu.

Alle stijlopties zijn ook toegankelijk onder _Appearance_ in het Omarchy-menu (`Super + Space`).

## Schakelaars

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Vergrendeling bij inactiviteit schakelen |
| `Super + Ctrl + Delete` | Laptopscherm in-/uitschakelen |
| `Super + Ctrl + Alt + Delete` | Laptopscherm spiegelen schakelen |
| `Super + Shift + Space` | De bovenbalk schakelen  |
| `Shift + Mute` | Wisselen naar volgende audio-uitvoer |
| `Shift + Play` | Wisselen naar volgende mediabron |
| `Super + Shift + Backspace` | Venstertussenruimtes schakelen |
| `Super + Ctrl + Alt + F` | Volledig scherm-bureaublad schakelen (bovenbalk + venstertussenruimtes) |

## Herinneringen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Een herinnering instellen  |
| `Super + Ctrl + Alt + R` | Alle herinneringen bekijken  |
| `Super + Ctrl + Shift + R` | Alle herinneringen wissen  |

## Mededelingen

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Tijd weergeven als mededeling  |
| `Super + Ctrl + Alt + B` | Accu weergeven als mededeling  |
| `Super + Ctrl + Alt + W` | Weer schakelen als mededeling  |

## Tmux

De prefix-toets is `Ctrl + Space` (`Ctrl + B` werkt ook). Je kunt deze bindingen wijzigen in `~/.config/tmux/tmux.conf`.

### Deelvensters

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Prefix + v` | Deelvenster ernaast splitsen (verticaal) |
| `Prefix + h` | Deelvenster eronder splitsen (horizontaal) |
| `Prefix + x` | Deelvenster beëindigen |
| `Prefix + z` | Zoom van deelvenster schakelen (volledig scherm) |
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
| `Prefix + q` | Configuratie herladen |
| `Prefix + ?` | Tmux-toetsbindingen weergeven |
| `Prefix + :` | Opdrachtprompt |

### Tmux-indelingsfuncties

Deze functies moet je uitvoeren binnen een Tmux-sessie.

| Opdracht | Functie |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-indeling maken met editor, AI en terminal |
| `tdlm <ai> [<second_ai>]` | Dev-indeling maken per submap |
| `tsl <count> <command>` | Swarm-indeling met meerdere deelvensters maken |

## Ghostty Terminal

Ghostty-terminal wordt geïnstalleerd met _Install > Terminal_ via het Omarchy-menu.

| Sneltoets                  | Functie              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nieuwe splitsing eronder |
| `Ctrl + Shift + O` | Nieuwe splitsing ernaast |
| `Ctrl + Alt + Arrows` | Tussen splitsingen bewegen |
| `Super + Ctrl + Shift + Arrows` | Formaat van splitsing wijzigen met 10 regels |
| `Super + Ctrl + Shift + Alt + Arrows` | Formaat van splitsing wijzigen met 100 regels |
| `Ctrl + Shift + T` | Nieuw tabblad  |
| `Ctrl + Shift + Arrows` | Tussen tabbladen bewegen |
| `Alt + Numbers` | Naar specifiek tabblad gaan |
| `Shift + Pg Up/Down` | Door de geschiedenis bladeren |
| `Ctrl + Left mouse` | Link openen in browser |

## Bestandsbeheer

| Sneltoets              | Functie                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Naar pad gaan                     |
| `Space`               | Bestand voorvertonen (pijlen navigeren) |
| `Alt + Up`       | Omhoog naar bovenliggende map        |

## Neovim (w/ lazyvim)

### Navigatie

| Sneltoets                   | Functie                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Opdrachtopties weergeven            |
| `Space Space`              | Bestand openen via fuzzy zoeken      |
| `Space E`                  | Zijbalk schakelen                  |
| `Space G G`                | Git-regeling weergeven               |
| `Space S G`                | Bestandsinhoud zoeken             |
| `Ctrl + W W`               | Springen tussen zijbalk en editor |
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

[Bekijk alle Neovim-sneltoetsen die LazyVim configureert](https://www.lazyvim.org/keymaps).

## Snelle emoji's

Je kunt `Super + Ctrl + E` gebruiken om een complete emoji-kiezer te tonen die de selectie op het klembord zet, of je kunt deze snelle toegangsopties gebruiken.

| Sneltoets       | EM | Hint       |
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
| `Shift + CapsLock M B` |🤯 | blazen |

## Snelle aanvullingen

| Sneltoets       | Aanvulling       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Je naam (zoals ingevoerd bij installatie)  |
| `Shift + CapsLock Space E` | Je e-mail (zoals ingevoerd bij installatie)  |

Je kunt er meer van jezelf toevoegen door `~/.XCompose` te bewerken en daarna `omarchy restart xcompose` uit te voeren in de terminal om de wijzigingen te laten oppikken.
