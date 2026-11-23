# Sneltoetsen

Je kunt alle belangrijke toetskoppelingen zien met `Super + K` (Tmux-koppelingen met `Super + Alt + K` en Herdr-koppelingen met `Super + Ctrl + K`).

## Hoe sneltoetsen zijn ingedeeld

Elke sneltoets zit op een vlak, bepaald door zijn modifiers, en elk vlak heeft één taak. Daardoor vervagen de sneltoetsen niet tot één brij, en kun je meestal raden waar iets thuishoort.

| Vlak | Wat daar thuishoort | Voorbeelden |
| --- | --- | --- |
| `Super + key` | Het systeem: vensters, werkruimtes, lay-outs en kernmenu's | `Super + Space` Omarchy-menu, `Super + W` venster sluiten, `Super + F` volledig scherm |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panelen en systeemmenu's | `Super + Ctrl + A` audio, `Super + Ctrl + N` netwerk, `Super + Ctrl + C` opnamemenu |
| `Super + Ctrl + Alt + key` | Snelle acties en meldingen | `Super + Ctrl + Alt + T` tijd tonen, `Super + Ctrl + Alt + B` batterij, `Super + Ctrl + Alt + C` schermafbeelding |

`Alt` toevoegen aan een sneltoets geeft je een variant van hetzelfde, nooit iets totaal anders:

- `Super + Shift + B` opent de browser; `Super + Shift + Alt + B` opent een privévenster
- `Super + Shift + E` opent e-mail; `Super + Shift + Alt + E` start een nieuwe
- `Super + F` gaat volledig scherm; `Super + Alt + F` gaat volledige breedte
- `Super + Ctrl + C` opent het opnamemenu; `Super + Ctrl + Alt + C` slaat het menu over en maakt een schermafbeelding

Bij het toevoegen van een sneltoets:

1. Kies het vlak op basis van wat hij doet, kies dan de toets.
2. Verplaats geen bestaande sneltoets om ruimte te maken. Zoek een vrije toets op het juiste vlak.
3. Gebruik `Alt` alleen voor een variant van de sneltoets zonder `Alt`.

Een paar sneltoetsen breken met deze regels omdat ze handig zijn. `Shift` met een pijl of `Tab` verplaatst of keert om in plaats van een app te openen, en `Print`, de mediatoetsen, `Alt + Tab` en `Ctrl + Alt + Del` werken zoals overal elders. Het zijn uitzonderingen, geen patronen om te kopiëren.

Als een standaardtoets je niet bevalt (stel dat je `Super + Shift + S` wilt voor schermafbeeldingen zoals op Windows), koppel hem dan opnieuw in `~/.config/hypr/bindings.lua`.

## Navigeren

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-menu (apps en al het andere) |
| `Super + Alt + Space` | App-raster |
| `Super + Escape` | Systeemmenu (slaapstand, herstarten, enz.) |
| `Super + Ctrl + L` | Computer vergrendelen |
| `Super + W` or `Super + Q` | Venster sluiten |
| `Ctrl + Alt + Del` | Alle vensters sluiten |
| `Super + K` | Alle sneltoetsen tonen |
| `Super + Alt + K` | tmux-sneltoetsen tonen |
| `Super + Ctrl + K` | herdr-sneltoetsen tonen |
| `Super + M` | Venster minimaliseren naar het dock |
| `Super + T` | Venster wisselen tussen tiling/floating |
| `Super + J` | Vensterpositie wisselen (horizontaal/verticaal) |
| `Super + O` | Venster in sticky'n'floating pop-out wisselen |
| `Super + L` | Door de dwindle-, scrolling- en floating-lay-outs bladeren |
| `Super + Alt + L` | In omgekeerde volgorde door de lay-outs bladeren |
| `Super + P` | Pseudo-vensterstijl wisselen (natuurlijk vs. uitgerekt) |
| `Super + F` | Volledig scherm |
| `Super + Alt + F` | Volledige breedte |
| `Super + Ctrl + F` | Volledig scherm binnen het venster |
| `Super + 1…9/0` | Naar specifieke werkruimte (0 is 10) op de gefocuste monitor springen |
| `Super + Tab` | Naar volgende werkruimte op de gefocuste monitor springen |
| `Super + Shift + Tab` | Naar vorige werkruimte op de gefocuste monitor springen |
| `Super + Ctrl + Tab` | Naar eerdere werkruimte op de gefocuste monitor springen |
| `Super + Shift + 1…9/0` | Venster naar werkruimte op de gefocuste monitor verplaatsen |
| `Super + Shift + Alt + 1…9/0` | Venster naar werkruimte op de gefocuste monitor verplaatsen zonder mee te gaan |
| `Super + S` | Volledig scratchpad in-/uitschakelen |
| `Super + Alt + S` | Venster naar volledig scratchpad verplaatsen |
| `Super + the key above Tab` (grave op US-lay-outs) | Quake-console in-/uitschakelen |
| `Super + Shift + the key above Tab` (grave op US-lay-outs) | Venster naar Quake-console verplaatsen |
| `Super + Shift + Ctrl + Arrows` | Venster naar de monitor in die richting verplaatsen |
| `Super + Shift + Alt + Arrows` | Werkruimte naar de monitor in die richting verplaatsen |
| `Super + Arrow` | Focus naar venster in pijlrichting verplaatsen, aan de schermrand oversteken naar de monitor aan die kant |
| `Super + Shift + Arrow` | Venster wisselen met een ander in pijlrichting, inclusief een op de monitor aan die kant |
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
| `Super + Scroll Wheel` | Door werkruimtes op de gefocuste monitor scrollen |
| `Super + G` | Venstergroepering in-/uitschakelen |
| `Super + Alt + G` | Venster uit groepering verplaatsen |
| `Super + Alt + Tab` | Tussen vensters in groepering bladeren |
| `Super + Alt + Shift + Tab` | Achterwaarts tussen vensters in groepering bladeren |
| `Super + Alt + Scroll Wheel` | Tussen vensters in groepering bladeren |
| `Super + Alt + 1/2/3/4/5` | Naar specifiek venster in groepering springen |
| `Super + Alt + Arrow` | Venster in pijlrichting in groepering verplaatsen, inclusief een op de monitor aan die kant |
| `Super + Ctrl + Left/Right` | Tussen vensters binnen een tegelgroep bewegen |
| `Super + Ctrl + Z` | Inzoomen op scherm (herhalen voor meer zoom) |
| `Super + Ctrl + Alt + Z` | Volledig uitzoomen van scherm |
| `Super + /` | Vooruit door monitor-schaalopties stappen |
| `Super + Alt + /` | Achteruit door monitor-schaalopties stappen |
| `Alt + Tab` | Vooruit bladeren door vensters op de actieve werkruimte |
| `Alt + Shift + Tab` | Achteruit bladeren door vensters op de actieve werkruimte |
| `Ctrl + Alt + Tab` | Focus vooruit door monitors bladeren |
| `Ctrl + Alt + Shift + Tab` | Focus achteruit door monitors bladeren |
| `Super + I` | Invoertaal wisselen (met meer dan één lay-out of invoermethode) |
| `Super + Shift + I` | Invoertaal terugwisselen |

Op een touchpad wisselen vegen met drie en vier vingers tussen werkruimtes, verplaatsen ze vensters en openen ze het menu en de Quake-console; zie [toetsenbord, muis en trackpad](34-keyboard-mouse-trackpad.md) voor de gebaren.

Sneltoetsen voor formaatwijziging gebruiken fysieke toetsen `code:20` en `code:21` (XKB `<AE11>` en `<AE12>`), ongeacht de tekens die op het toetsenbord zijn gedrukt. Op Amerikaanse toetsenborden zijn deze toetsen `-` en `=`; op Japanse (JIS) toetsenborden zijn ze `-` en `^`; op Spaanse toetsenborden zijn ze `'` en `¡`. Op JIS is `Super + ^` `Super + Equal`, terwijl `Super + Shift + -` (waarmee `=` wordt getypt) `Super + Shift + Minus` is.

## Systeembediening

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Audiopaneel |
| `Super + Ctrl + B` | Bluetooth-paneel |
| `Super + Ctrl + N` | Wifi/netwerkpaneel |
| `Super + Ctrl + D` | Beeldschermpaneel |
| `Super + Ctrl + P` | Energiepaneel |
| `Super + Ctrl + X` | Agents-paneel |
| `Super + Ctrl + Alt + X` | Lokale-modellenpaneel |
| `Super + Ctrl + Alt + D` | Kalenderpaneel |
| `Super + Ctrl + Alt + E` | Wereldklokpaneel |
| `Super + Ctrl + 1-9` | Balkpaneel op positie in-/uitschakelen |
| `Super + Ctrl + S` | Deelmenu (via LocalSend) |
| `Super + Ctrl + C` | Opnamebediening (schermafbeelding/-opname/kiezer) |
| `Super + Ctrl + O` | Menu in-/uitschakelen |
| `Super + Ctrl + H` | Hardwaremenu |
| `Super + Ctrl + E` | Emoji-kiezer |
| `Super + Ctrl + .` | Media transcoderen |
| `Super + Shift + Ctrl + A` | Je standaardagent starten |
| `Power` toets | Systeemmenu |
| `Super + Shift + Copilot` toets | Omarchy-menu |

## Aanpassingen

| Sneltoets | Functie |
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
| `Display` toets | Door de werkruimte-lay-out bladeren |
| `Alt + Play` | Volgend nummer |
| `Alt + Shift + Play` | Vorig nummer |

## Apps starten

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agentmanager) |
| `Super + Shift + Return` or `Super + Shift + B` | Browser |
| `Super + Shift + Alt + B` | Browser (privé/incognito) |
| `Super + Shift + F` | Bestandsbeheerder |
| `Super + Shift + Alt + F` | Bestandsbeheerder in de cwd van de terminal |
| `Super + Shift + M` | Muziek (Spotify) |
| `Super + Shift + Alt + M` | Muziek (cliamp) |
| `Super + Shift + /` | Wachtwoordmanager (1password) |
| `Super + Shift + Q` or `Calculator` toets | Rekenmachine (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, zodra geïnstalleerd) |
| `Super + Shift + T` | Activiteit (btop) |
| `Super + Shift + N` | Editor (Plain, of je gekozen standaard) |
| `Super + Shift + C` | Kalender ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Nieuwe e-mail ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Je standaardagent, of ChatGPT totdat je er een kiest |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Berichten (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Berichten (WhatsApp) |
| `Super + Shift + Ctrl + G` | Berichten (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Schrijven (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (nieuwe post) |
| `Super + Shift + Y` | YouTube |

Wijzig/voeg koppelingen toe in `~/.config/hypr/bindings.lua`.

## Universeel klembord

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + A` | Alles selecteren in apps die `Ctrl + A` ondersteunen |
| `Super + C` | Kopiëren |
| `Super + X` | Knippen (niet in terminal) |
| `Super + V` | Plakken |
| `Super + Ctrl + V` | Klembordbeheerder |

Op Linux heb je meestal `Ctrl + Shift + C/V` nodig om te kopiëren en plakken in de terminal en `Ctrl + C/V` om het overal elders te doen. Deze uniforme klembordsneltoetsen van Omarchy werken overal.

## Opname

| Sneltoets | Functie |
| ------------------- | ------------------------------ |
| `Print Screen` | Schermafbeelding |
| `Super + Ctrl + Alt + C` | Schermafbeelding (dezelfde opname, voor toetsenborden zonder Print Screen-toets) |
| `Super + Ctrl + C` | Opnamemenu |
| `Alt + Print Screen` | Scherm opnemen |
| `Super + Shift + Ctrl + Alt + C` | Scherm opnemen zonder audio, het menu overslaan (opnieuw indrukken om te stoppen) |
| `Super + Print Screen` | Kleurkiezer |
| `Super + Ctrl + Print Screen` | Tekstextractie naar klembord |
| `Super + Alt + [` | Webcam-overlay kleiner maken tijdens het opnemen |
| `Super + Alt + ]` | Webcam-overlay groter maken tijdens het opnemen |
| `Alt + Shift + L` | Huidige URL uit webapp of browser kopiëren |
| `Alt + Shift + D` | De video op de huidige pagina downloaden naar `~/Videos` |
| `Alt + Space` | Dicteren starten/stoppen (vereist _Setup > Defaults > Dictation_) |
| `Right Alt` | Ingedrukt houden om te dicteren (vereist _Setup > Defaults > Dictation_) |

Bij schermopnames vraagt de sneltoets eerst welke audio je wilt, en start dan de opname. Druk er opnieuw op om te stoppen. Zie [schermafbeeldingen en opname](12-screenshots-recording.md) voor de details.

Alle opname-opties zijn ook toegankelijk onder _Trigger > Capture_ in het Omarchy-menu (`Super + Space`).

## Meldingen

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + ,` | Handelen op nieuwste melding: open hem of druk op zijn enige knop, kies uit zijn opties, of sluit hem als hij er geen heeft |
| `Super + Shift + ,` | Alle meldingen sluiten |
| `Super + Ctrl + ,` | Meldingen met het toetsenbord bedienen |
| `Super + Alt + ,` | Nieuwste melding sluiten |
| `Super + Shift + Alt + ,` | Meldingsgeschiedenis openen |
| `Super + Ctrl + Alt + ,` | Meldingen stilzetten in-/uitschakelen |

## Stijl

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Een nieuw thema kiezen (ook `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Thema-achtergrond kiezen (ook `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparantie op een venster in-/uitschakelen |
| `Super + Ctrl + Backspace` | Vierkante beeldverhouding voor één venster in-/uitschakelen |

Extra achtergrondafbeeldingen staan in `~/.config/omarchy/backgrounds/<theme name>`. Ook beschikbaar via _Install > Style > Background_ in het Omarchy-menu.

Alle stijlopties zijn ook toegankelijk onder _Appearance_ in het Omarchy-menu (`Super + Space`).

## Schakelaars

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Vergrendelen bij inactiviteit in-/uitschakelen |
| `Super + Ctrl + Delete` | Laptopscherm aan/uit schakelen |
| `Super + Ctrl + Alt + Delete` | Laptopscherm spiegelen in-/uitschakelen |
| `Super + Shift + Space` | De bovenste balk in-/uitschakelen |
| `Shift + Mute` | Naar volgende audio-uitvoer wisselen |
| `Shift + Play` | Naar volgende mediabron wisselen |
| `Super + Shift + Backspace` | Tussenruimte tussen vensters in-/uitschakelen |
| `Super + Ctrl + Alt + F` | Volledig scherm-bureaublad in-/uitschakelen (bovenste balk + tussenruimte tussen vensters) |

## Herinneringen

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Een herinnering instellen |
| `Super + Ctrl + Alt + R` | Alle herinneringen bekijken |
| `Super + Ctrl + Shift + R` | Alle herinneringen wissen |

## Kennisgevingen

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Tijd als melding tonen |
| `Super + Ctrl + Alt + B` | Batterij als melding tonen |
| `Super + Ctrl + Alt + W` | Weer als melding in-/uitschakelen |

## Tmux

De prefix-toets is `Ctrl + Space` (`Ctrl + B` werkt ook). Je kunt deze koppelingen wijzigen in `~/.config/tmux/tmux.conf`.

### Deelvensters

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Prefix + v` | Deelvenster ernaast splitsen (verticaal) |
| `Prefix + h` | Deelvenster eronder splitsen (horizontaal) |
| `Prefix + x` | Deelvenster beëindigen |
| `Prefix + z` | Deelvensterzoom in-/uitschakelen (volledig scherm) |
| `Alt + Enter` | Deelvenster eronder splitsen (geen prefix) |
| `Alt + Shift + Enter` | Deelvenster ernaast splitsen (geen prefix) |
| `Alt + Escape` | Deelvenster beëindigen (geen prefix) |
| `Ctrl + Alt + Arrows` | Tussen deelvensters bewegen |
| `Ctrl + Alt + Shift + Arrows` | Deelvensters van formaat wijzigen |

### Vensters

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Prefix + c` | Nieuw venster |
| `Prefix + k` | Venster beëindigen |
| `Prefix + r` | Venster hernoemen |
| `Alt + 1-9` | Naar specifiek venster gaan |
| `Alt + Arrow Left/Right` | Tussen vensters bewegen |
| `Alt + Shift + Arrow Left/Right` | Venster naar links/rechts verplaatsen |

### Sessies

| Sneltoets | Functie |
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

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Prefix + [` | Kopieermodus openen |
| `v` | Selectie beginnen (in kopieermodus) |
| `y` | Selectie kopiëren (in kopieermodus) |

### Algemeen

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Prefix + q` | Configuratie opnieuw laden |
| `Prefix + ?` | Tmux-toetskoppelingen tonen |
| `Prefix + :` | Opdrachtprompt |

### Tmux-lay-outfuncties

Deze functies moeten binnen een Tmux-sessie worden uitgevoerd.

| Opdracht | Functie |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-lay-out maken met editor, AI en terminal |
| `tdlm <ai> [<second_ai>]` | Dev-lay-out per submap maken |
| `tsl <count> <command>` | Swarm-lay-out met meerdere deelvensters maken |

## Ghostty Terminal

Ghostty terminal wordt geïnstalleerd met _Install > Terminal_ via het Omarchy-menu.

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nieuwe splitsing eronder |
| `Ctrl + Shift + O` | Nieuwe splitsing ernaast |
| `Ctrl + Alt + Arrows` | Tussen splitsingen bewegen |
| `Super + Ctrl + Shift + Arrows` | Splitsing met 10 regels van formaat wijzigen |
| `Super + Ctrl + Shift + Alt + Arrows` | Splitsing met 100 regels van formaat wijzigen |
| `Ctrl + Shift + T` | Nieuw tabblad |
| `Ctrl + Shift + Arrows` | Tussen tabbladen bewegen |
| `Alt + Numbers` | Naar specifiek tabblad gaan |
| `Shift + Pg Up/Down` | Door de geschiedenis scrollen |
| `Ctrl + Left mouse` | Link in browser openen |

## Bestandsbeheerder

| Sneltoets | Functie |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Naar pad gaan |
| `Space` | Bestand voorvertonen (pijlen navigeren) |
| `Alt + Up` | Omhoog naar bovenliggende map gaan |

## Neovim (w/ lazyvim)

### Navigatie

| Sneltoets | Functie |
| ------------------------ | ------------------------------- |
| `Space` | Opdrachtopties tonen |
| `Space Space` | Bestand openen via fuzzy search |
| `Space E` | Zijbalk in-/uitschakelen |
| `Space G G` | git-bediening tonen |
| `Space S G` | Bestandsinhoud doorzoeken |
| `Ctrl + W W` | Tussen zijbalk en editor springen |
| `Ctrl + Left/right arrow` | Grootte van zijbalk wijzigen |
| `Shift + H` | Naar linker bestandstabblad gaan |
| `Shift + L` | Naar rechter bestandstabblad gaan |
| `Space B D` | Bestandstabblad sluiten |

### In de zijbalk

| Sneltoets | Functie |
| ------------------------ | ------------------------------- |
| `A` | Nieuw bestand toevoegen in bovenliggende map |
| `Shift + A` | Nieuwe submap toevoegen in bovenliggende map |
| `D` | Gemarkeerd bestand/map verwijderen |
| `M` | Gemarkeerd bestand/map verplaatsen |
| `R` | Gemarkeerd bestand/map hernoemen |
| `?` | Help voor alle opdrachten tonen |

[Bekijk alle Neovim-sneltoetsen die door LazyVim zijn geconfigureerd](https://www.lazyvim.org/keymaps).

## Snelle emoji's

Je kunt `Super + Ctrl + E` gebruiken om een complete emoji-kiezer te tonen die de selectie op het klembord plaatst, of je kunt deze snelle toegangsopties gebruiken.

| Sneltoets | EM | Aanwijzing |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | lach |
| `Shift + CapsLock M C` | 😂 | huil |
| `Shift + CapsLock M L` | 😍 | liefde |
| `Shift + CapsLock M V` | ✌️ | overwinning |
| `Shift + CapsLock M H` | ❤️ | hart |
| `Shift + CapsLock M Y` | 👍 | ja |
| `Shift + CapsLock M N` | 👎 | nee |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | wens |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | kus |
| `Shift + CapsLock M E` | 🙄 | oogrol |
| `Shift + CapsLock M I` | 😉 | knipoog |
| `Shift + CapsLock M P` | 🙏 | bidden |
| `Shift + CapsLock M D` | 🤤 | kwijl |
| `Shift + CapsLock M M` | 💰 | geld |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | toast |
| `Shift + CapsLock M O` | 👌 | ok |
| `Shift + CapsLock M G` | 👋 | groet |
| `Shift + CapsLock M A` | 💪 | arm |
| `Shift + CapsLock M B` | 🤯 | blazen |

## Snelle aanvullingen

| Sneltoets | Aanvulling |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Je naam (zoals ingevoerd tijdens het instellen) |
| `Shift + CapsLock Space E` | Je e-mail (zoals ingevoerd tijdens het instellen) |

Je kunt er meer van jezelf toevoegen door `~/.XCompose` te bewerken en vervolgens `omarchy restart xcompose` in de terminal uit te voeren, zodat de wijzigingen worden opgepikt.
