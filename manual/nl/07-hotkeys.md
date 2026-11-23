# Sneltoetsen

Je kunt alle belangrijke toetsenbordbindingen zien met `Super + K` (Tmux-bindingen met `Super + Alt + K` en Herdr-bindingen met `Super + Ctrl + K`).

## Hoe sneltoetsen zijn ingedeeld

Elke sneltoets zit op een vlak, bepaald door zijn modificatietoetsen, en elk vlak heeft één taak. Daardoor vervagen de sneltoetsen niet in elkaar, en kun je meestal raden waar iets woont.

| Vlak | Wat daar thuishoort | Voorbeelden |
| --- | --- | --- |
| `Super + key` | Het systeem: vensters, werkruimtes, lay-outs en kernmenu's | `Super + Space` Omarchy-menu, `Super + W` venster sluiten, `Super + F` volledig scherm |
| `Super + Shift + key` | Apps | `Super + Shift + B` browser, `Super + Shift + E` e-mail, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Panelen en systeemmenu's | `Super + Ctrl + A` audio, `Super + Ctrl + N` netwerk, `Super + Ctrl + C` vastlegmenu |
| `Super + Ctrl + Alt + key` | Snelle acties en kennisgevingen | `Super + Ctrl + Alt + T` tijd tonen, `Super + Ctrl + Alt + B` batterij, `Super + Ctrl + Alt + C` screenshot |

`Alt` aan een sneltoets toevoegen geeft je een variant van hetzelfde, nooit iets totaal anders:

- `Super + Shift + B` opent de browser; `Super + Shift + Alt + B` opent een privévenster
- `Super + Shift + E` opent e-mail; `Super + Shift + Alt + E` begint een nieuwe
- `Super + F` gaat volledig scherm; `Super + Alt + F` gaat volledige breedte
- `Super + Ctrl + C` opent het vastlegmenu; `Super + Ctrl + Alt + C` slaat het menu over en maakt een screenshot

Bij het toevoegen van een sneltoets:

1. Kies het vlak op basis van wat hij doet, kies dan de toets.
2. Verplaats geen bestaande sneltoets om ruimte te maken. Zoek een vrije toets op het juiste vlak.
3. Gebruik `Alt` alleen voor een variant van de sneltoets zonder `Alt`.

Een paar sneltoetsen breken deze regels omdat ze handig zijn. `Shift` met een pijl of `Tab` verplaatst of keert om in plaats van een app te openen, en `Print`, de mediatoetsen, `Alt + Tab` en `Ctrl + Alt + Del` werken zoals ze overal elders werken. Het zijn uitzonderingen, geen patronen om te kopiëren.

Als een standaardinstelling je niet bevalt (stel dat je `Super + Shift + S` wilt voor screenshots zoals op Windows), herbind hem dan in `~/.config/hypr/bindings.lua`.

## Navigeren

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-menu (apps en al het andere) |
| `Super + Alt + Space` | App-raster |
| `Super + Escape` | Systeemmenu (slaapstand, herstarten, enz.) |
| `Super + Ctrl + L` | Computer vergrendelen |
| `Super + W` of `Super + Q` | Venster sluiten |
| `Ctrl + Alt + Del` | Alle vensters sluiten |
| `Super + K` | Alle sneltoetsen tonen |
| `Super + Alt + K` | Tmux-sneltoetsen tonen |
| `Super + Ctrl + K` | Herdr-sneltoetsen tonen |
| `Super + M` | Venster minimaliseren naar het dock |
| `Super + T` | Venster omschakelen tussen tiling/floating |
| `Super + J` | Vensterpositie omschakelen (horizontaal/verticaal) |
| `Super + O` | Venster omschakelen naar sticky'n'floating |
| `Super + L` | Door de lay-outs dwindle, scrolling en floating bladeren |
| `Super + Alt + L` | In omgekeerde volgorde door de lay-outs bladeren |
| `Super + P` | Pseudo-vensterstijl omschakelen (natuurlijk vs. uitrekken) |
| `Super + F` | Volledig scherm gaan |
| `Super + Alt + F` | Volledige breedte gaan |
| `Super + Ctrl + F` | Volledig scherm binnen venster gaan |
| `Super + 1…9/0` | Naar specifieke werkruimte springen (0 is 10) op de gefocuste monitor |
| `Super + Tab` | Naar volgende werkruimte springen op de gefocuste monitor |
| `Super + Shift + Tab` | Naar vorige werkruimte springen op de gefocuste monitor |
| `Super + Ctrl + Tab` | Naar voormalige werkruimte springen op de gefocuste monitor |
| `Super + Shift + 1…9/0` | Venster verplaatsen naar werkruimte op de gefocuste monitor |
| `Super + Shift + Alt + 1…9/0` | Venster verplaatsen naar werkruimte op de gefocuste monitor zonder te volgen |
| `Super + S` | Volledige scratchpad omschakelen |
| `Super + Alt + S` | Venster verplaatsen naar volledige scratchpad |
| `Super + the key above Tab` (grave op Amerikaanse lay-outs) | Quake-console omschakelen |
| `Super + Shift + the key above Tab` (grave op Amerikaanse lay-outs) | Venster verplaatsen naar Quake-console |
| `Super + Shift + Ctrl + Arrows` | Venster verplaatsen naar de monitor in die richting |
| `Super + Shift + Alt + Arrows` | Werkruimte verplaatsen naar de monitor in die richting |
| `Super + Arrow` | Focus verplaatsen naar venster in de richting van de pijl, aan de schermrand overstekend naar de monitor aan die kant |
| `Super + Shift + Arrow` | Venster verwisselen met een ander in de richting van de pijl, inclusief een op de monitor aan die kant |
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
| `Super + Scroll Wheel` | Door werkruimtes scrollen op de gefocuste monitor |
| `Super + G` | Venstergroepering omschakelen |
| `Super + Alt + G` | Venster uit groepering halen |
| `Super + Alt + Tab` | Tussen vensters in groepering bladeren |
| `Super + Alt + Shift + Tab` | Achteruit tussen vensters in groepering bladeren |
| `Super + Alt + Scroll Wheel` | Tussen vensters in groepering bladeren |
| `Super + Alt + 1/2/3/4/5` | Naar specifiek venster in groepering springen |
| `Super + Alt + Arrow` | Venster in groepering verplaatsen in de richting van de pijl, inclusief een op de monitor aan die kant |
| `Super + Ctrl + Left/Right` | Tussen vensters binnen een tiling-groep bewegen |
| `Super + Ctrl + Z` | Op scherm inzoomen (herhaal voor meer zoom) |
| `Super + Ctrl + Alt + Z` | Volledig uitzoomen van scherm |
| `Super + /` | Vooruit stappen door opties voor monitorschaling |
| `Super + Alt + /` | Achteruit stappen door opties voor monitorschaling |
| `Alt + Tab` | Vooruit bladeren door vensters op de actieve werkruimte |
| `Alt + Shift + Tab` | Achteruit bladeren door vensters op de actieve werkruimte |
| `Ctrl + Alt + Tab`| Focus vooruit bladeren door monitors |
| `Ctrl + Alt + Shift + Tab`| Focus achteruit bladeren door monitors |
| `Super + I` | Invoertaal wisselen (met meer dan één lay-out of invoermethode) |
| `Super + Shift + I` | Invoertaal terug wisselen |

Op een touchpad wisselen swipes met drie en vier vingers van werkruimte, verplaatsen ze vensters en openen ze het menu en de Quake-console; zie [toetsenbord, muis en trackpad](34-keyboard-mouse-trackpad.md) voor de gebaren.

Formaat wijzigen gebruikt de twee toetsen rechts van 0, wat je toetsenbord er ook op print: `-` en `=` op Amerikaanse toetsenborden, `+` en `´` op Deense en Zweedse, `+` en `\` op Noorse, `ß` en `´` op Duitse, `'` en `¡` op Spaanse, en `-` en `^` op Japanse (JIS). `Super + K` geeft ze weer zoals je toetsenbord ze print. Op JIS is `Super + ^` gelijk aan `Super + Equal`, terwijl `Super + Shift + -` (waarmee je `=` typt) gelijk is aan `Super + Shift + Minus`. Monitorschaling en de wachtwoordmanager gebruiken `/`; op lay-outs die `/` alleen met Shift typen, zoals de meeste Europese doen, gebruiken ze in plaats daarvan de toets links van de rechter Shift (`-` op Deens en Duits).

## Systeembediening

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Audiopaneel |
| `Super + Ctrl + B` | Bluetooth-paneel |
| `Super + Ctrl + N` | Wifi/netwerkpaneel |
| `Super + Ctrl + D` | Schermpaneel |
| `Super + Ctrl + P` | Stroompaneel |
| `Super + Ctrl + X` | Agents-paneel |
| `Super + Ctrl + Alt + D` | Kalenderpaneel |
| `Super + Ctrl + Alt + E` | Wereldklokpaneel |
| `Super + Ctrl + 1-9` | Balkpaneel op positie omschakelen |
| `Super + Ctrl + S` | Deelmenu (via LocalSend) |
| `Super + Ctrl + C` | Vastlegbediening (screenshot/-opname/kiezer) |
| `Super + Ctrl + O` | Menu omschakelen |
| `Super + Ctrl + H` | Hardwaremenu |
| `Super + Ctrl + E` | Emoji-kiezer |
| `Super + Ctrl + .` | Media transcoden |
| `Super + Shift + Ctrl + A` | Je standaardagent starten |
| `Power`-toets | Systeemmenu |
| `Super + Shift + Copilot`-toets | Omarchy-menu |

## Aanpassingen

| Sneltoets | Functie |
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
| `Display`-toets | Door de werkruimtelayout bladeren |
| `Alt + Play` | Volgende track |
| `Alt + Shift + Play` | Vorige track |

## Apps starten

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agentmanager) |
| `Super + Shift + Return` of `Super + Shift + B` | Browser |
| `Super + Shift + Alt + B` | Browser (privé/incognito) |
| `Super + Shift + F` | Bestandsbeheerder |
| `Super + Shift + Alt + F` | Bestandsbeheerder in cwd van terminal |
| `Super + Shift + M` | Muziek (Spotify) |
| `Super + Shift + Alt + M` | Muziek (cliamp) |
| `Super + Shift + /` | Wachtwoordmanager (1password) |
| `Super + Shift + Q` of `Calculator`-toets | Rekenmachine (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, zodra geïnstalleerd) |
| `Super + Shift + T` | Activiteit (btop) |
| `Super + Shift + N` | Editor (Plain, of je gekozen standaard) |
| `Super + Shift + C` | Kalender ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-mail ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Nieuwe e-mail ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Je standaardagent, of ChatGPT totdat je er een kiest |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Messenger (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Messenger (WhatsApp) |
| `Super + Shift + Ctrl + G` | Messenger (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Schrijven (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (nieuwe post) |
| `Super + Shift + Y` | YouTube |

Wijzig/voeg bindingen toe in `~/.config/hypr/bindings.lua`.

## Universeel klembord

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + A` | Alles selecteren in apps die `Ctrl + A` ondersteunen |
| `Super + C` | Kopiëren |
| `Super + X` | Knippen (niet in terminal) |
| `Super + V` | Plakken |
| `Super + Ctrl + V` | Klembordbeheerder |

Normaal heb je op Linux `Ctrl + Shift + C/V` nodig om te kopiëren en plakken in de terminal en `Ctrl + C/V` om dat overal elders te doen. Deze uniforme Omarchy-klembordsneltoetsen werken overal.

## Vastleggen

| Sneltoets | Functie |
| ------------------- | ------------------------------ |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot (dezelfde opname, voor toetsenborden zonder Print Screen-toets) |
| `Super + Ctrl + C` | Vastlegmenu |
| `Alt + Print Screen` | Schermopname |
| `Super + Shift + Ctrl + Alt + C` | Schermopname zonder audio, menu overslaan (opnieuw indrukken om te stoppen) |
| `Super + Print Screen` | Kleurenkiezer |
| `Super + Ctrl + Print Screen` | Tekstextractie naar klembord |
| `Super + Alt + [` | Webcam-overlay kleiner maken tijdens opname |
| `Super + Alt + ]` | Webcam-overlay groter maken tijdens opname |
| `Alt + Shift + L` | Huidige URL kopiëren uit webapp of browser |
| `Alt + Shift + D` | De video op de huidige pagina downloaden naar `~/Videos` |
| `Alt + Space` | Dictatie starten/stoppen (vereist _Setup > Defaults > Dictation_) |
| `Right Alt` | Ingedrukt houden om te dicteren (vereist _Setup > Defaults > Dictation_) |

Bij schermopnames vraagt de sneltoets eerst welke audio je wilt, en start dan de opname. Druk er opnieuw op om te stoppen. Zie [screenshots en opname](12-screenshots-recording.md) voor de details.

Alle vastlegopties zijn ook toegankelijk onder _Trigger > Capture_ in het Omarchy-menu (`Super + Space`).

## Meldingen

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + ,` | Op de nieuwste melding reageren: open hem of druk op zijn enige knop, kies uit zijn keuzes, of verwijder hem als hij er geen heeft |
| `Super + Shift + ,` | Alle meldingen verwijderen |
| `Super + Ctrl + ,` | Meldingen bedienen met het toetsenbord |
| `Super + Alt + ,` | Nieuwste melding verwijderen |
| `Super + Shift + Alt + ,` | Meldingsgeschiedenis openen |
| `Super + Ctrl + Alt + ,` | Het stilzetten van meldingen omschakelen |

## Stijl

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Een nieuw thema kiezen (ook `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Thema-achtergrond kiezen (ook `Super + Ctrl + Space`) |
| `Super + Backspace` | Transparantie op een venster omschakelen |
| `Super + Ctrl + Backspace` | Vierkante beeldverhouding voor één venster omschakelen |

Extra achtergrondafbeeldingen staan in `~/.config/omarchy/backgrounds/<theme name>`. Ook beschikbaar via _Install > Style > Background_ in het Omarchy-menu.

Alle stijlopties zijn ook toegankelijk onder _Appearance_ in het Omarchy-menu (`Super + Space`).

## Schakelaars

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Vergrendeling bij inactiviteit omschakelen |
| `Super + Ctrl + Delete` | Laptopscherm in-/uitschakelen |
| `Super + Ctrl + Alt + Delete` | Laptopscherm spiegelen omschakelen |
| `Super + Shift + Space` | De bovenste balk omschakelen |
| `Shift + Mute` | Naar volgende audio-uitvoer wisselen |
| `Shift + Play` | Naar volgende mediabron wisselen |
| `Super + Shift + Backspace` | Tussenruimtes tussen vensters omschakelen |
| `Super + Ctrl + Alt + F` | Volledig-schermdesktop omschakelen (bovenste balk + tussenruimtes tussen vensters) |

## Herinneringen

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Een herinnering instellen |
| `Super + Ctrl + Alt + R` | Alle herinneringen zien |
| `Super + Ctrl + Shift + R` | Alle herinneringen wissen |

## Kennisgevingen

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Tijd tonen als melding |
| `Super + Ctrl + Alt + B` | Batterij tonen als melding |
| `Super + Ctrl + Alt + W` | Weer als melding omschakelen |

## Tmux

De prefix-toets is `Ctrl + Space` (`Ctrl + B` werkt ook). Je kunt deze bindingen wijzigen in `~/.config/tmux/tmux.conf`.

### Panelen

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Prefix + v` | Paneel ernaast splitsen (verticaal) |
| `Prefix + h` | Paneel eronder splitsen (horizontaal) |
| `Prefix + x` | Paneel sluiten |
| `Prefix + z` | Paneelzoom omschakelen (volledig scherm) |
| `Alt + Enter` | Paneel eronder splitsen (geen prefix) |
| `Alt + Shift + Enter` | Paneel ernaast splitsen (geen prefix) |
| `Alt + Escape` | Paneel sluiten (geen prefix) |
| `Ctrl + Alt + Arrows` | Tussen panelen bewegen |
| `Ctrl + Alt + Shift + Arrows` | Formaat van panelen wijzigen |

### Vensters

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Prefix + c` | Nieuw venster |
| `Prefix + k` | Venster sluiten |
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
| `Prefix + q` | Configuratie herladen |
| `Prefix + ?` | Tmux-toetsbindingen tonen |
| `Prefix + :` | Opdrachtprompt |

### Tmux-lay-outfuncties

Deze functies moeten binnen een Tmux-sessie worden uitgevoerd.

| Opdracht | Functie |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Dev-lay-out maken met editor, AI en terminal |
| `tdlm <ai> [<second_ai>]` | Dev-lay-out maken per submap |
| `tsl <count> <command>` | Zwermlay-out met meerdere panelen maken |

## Ghostty Terminal

Ghostty-terminal wordt geïnstalleerd met _Install > Terminal_ via het Omarchy-menu.

| Sneltoets | Functie |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nieuwe splitsing eronder |
| `Ctrl + Shift + O` | Nieuwe splitsing ernaast |
| `Ctrl + Alt + Arrows` | Tussen splitsingen bewegen |
| `Super + Ctrl + Shift + Arrows` | Formaat van splitsing met 10 regels wijzigen |
| `Super + Ctrl + Shift + Alt + Arrows` | Formaat van splitsing met 100 regels wijzigen |
| `Ctrl + Shift + T` | Nieuw tabblad |
| `Ctrl + Shift + Arrows` | Tussen tabbladen bewegen |
| `Alt + Numbers` | Naar specifiek tabblad gaan |
| `Shift + Pg Up/Down` | Door de geschiedenis scrollen |
| `Ctrl + Left mouse` | Link openen in browser |

## Bestandsbeheerder

| Sneltoets | Functie |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Naar pad gaan |
| `Space` | Bestand previewen (pijlen navigeren) |
| `Alt + Up` | Omhoog naar bovenliggende map gaan |

## Neovim (w/ lazyvim)

### Navigatie

| Sneltoets | Functie |
| ------------------------ | ------------------------------- |
| `Space` | Opdrachtopties tonen |
| `Space Space` | Bestand openen via fuzzy search |
| `Space E` | Zijbalk omschakelen |
| `Space G G` | Git-bediening tonen |
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

Je kunt `Super + Ctrl + E` gebruiken om een complete emoji-kiezer te tonen die de selectie op het klembord zet, of je kunt deze snelle toegangsopties gebruiken.

| Sneltoets | EM | Hint |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | glimlach |
| `Shift + CapsLock M C` | 😂 | huilen |
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
| `Shift + CapsLock M D` | 🤤 | kwijlen |
| `Shift + CapsLock M M` | 💰 | geld |
| `Shift + CapsLock M X` | 🎉 | vieren |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | proost |
| `Shift + CapsLock M O` |👌 | oké |
| `Shift + CapsLock M G` |👋 | groet |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | ontploffen |

## Snelle aanvullingen

| Sneltoets | Aanvulling |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Je naam (zoals ingevoerd bij setup) |
| `Shift + CapsLock Space E` | Je e-mail (zoals ingevoerd bij setup) |

Je kunt er meer van jezelf toevoegen door `~/.XCompose` te bewerken en daarna `omarchy restart xcompose` in de terminal uit te voeren om de wijzigingen te laten oppikken.
