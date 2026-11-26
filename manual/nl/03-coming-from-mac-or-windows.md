# Kom je van Mac of Windows

Als je jaren op macOS of Windows hebt doorgebracht, weten je vingers honderd dingen waarvan je brein is vergeten dat het ze ooit heeft geleerd. Dit hoofdstuk is de vertaallaag: waar die instincten in Omarchy terechtkomen. De functies zelf worden elders uitgebreid behandeld — dit is alleen de kaart.

### Super is het middelpunt van alles

Al het spiergeheugen dat je rond Cmd of de Windows-toets hebt opgebouwd, gaat over op één toets: Super. Dat is de Windows-toets op een pc-toetsenbord, en het anker voor bijna elke sneltoets in Omarchy.

Je Spotlight-, Raycast- of startmenu-reflex wordt `Super + Space`. Daarmee open je het Omarchy-menu, dat apps start, instellingen wijzigt, software installeert, het scherm vastlegt — zo'n beetje alles. Begin te typen om te filteren. `Super + Alt + Space` toont elke app in één raster, zoals Launchpad dat doet. Zie [navigatie](04-navigation.md).

### Geen bureaubladpictogrammen, en het dock verschijnt alleen wanneer je zweeft

Geen pictogrammen om op het bureaublad te rangschikken, en geen dock op een tegelende werkruimte — het dock verschijnt alleen op een zwevende werkruimte (zie [navigatie](04-navigation.md)). Apps starten vanaf een sneltoets (`Super + Return` voor de terminal, `Super + Shift + Return` voor de browser en `Super + K` voor een lijst van alles wat is toegewezen) of vanuit het menu. Het enige blijvende stukje UI is [de bovenbalk](05-the-top-bar.md), die dekt wat de menubalk, het systeemvak en Notification Center vroeger voor je deden — en bijna elke widget erop doet iets bij een klik links, rechts of in het midden.

### Vensters plaatsen zichzelf

De grootste omschakeling in je denken: je sleept geen vensters rond en klikt ze niet vast aan schermhelften. Open je een venster, dan neemt het het hele scherm in beslag. Open je een tweede, dan splitsen ze het. Je vist nooit een venster onder een ander vandaan, omdat vensters niet overlappen.

Wanneer je echt een zwevend venster nodig hebt, haalt `Super + T` het actieve venster uit de tegelindeling (en weer terug). Maar geef het tegelen eerst een echte kans — het is het hart van het geheel. [Navigatie](04-navigation.md) leidt je erdoorheen.

Werkruimtes voelen vertrouwd aan: het zijn macOS Spaces of virtuele bureaubladen van Windows, behalve dat je ze ook echt zult gebruiken, omdat `Super + 1/2/3/4` rechtstreeks naar één ervan springt en `Super + Shift + 1/2/3/4` het actieve venster daarheen stuurt. Geen animatievertraging, gewoon onmiddellijke sprongen. Dit betekent dat je misschien niet eens meerdere monitoren nodig hebt, als je daar vroeger aan gewend was.

### Kopiëren en plakken werken gewoon

Op de Mac had je overal Cmd + C. Op Windows had je overal Ctrl + C — behalve in de terminal, waar het je programma beëindigt. Omarchy geeft je `Super + C`, `Super + X` en `Super + V`, en ze werken overal, ook in de terminal. Geen aparte reflex om voor de shell te leren.

Windows-gebruikers: je Win + V-klembordgeschiedenis zit op `Super + Ctrl + V`, en die bevat zowel afbeeldingen als tekst. Zie [uniform klembord & geschiedenis](08-unified-clipboard-history.md).

### De vertaaltabel

| Waar je naar grijpt | In Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / startmenu | `Super + Space` — het Omarchy-menu |
| AirDrop | LocalSend, via `Super + Ctrl + S` — zie [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` of `Print Screen` — zie [schermafbeeldingen & opname](12-screenshots-recording.md) |
| Notification Center | Meldingsgeschiedenis op `Super + Shift + Alt + ,` |
| Time Machine (voor het systeem) | Automatische [systeemsnapshots](47-system-snapshots.md) bij elke update |
| App Store / een installatieprogramma downloaden | _Install_ in het menu, of `omarchy pkg add` — zie [andere pakketten](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ in het menu, dat gewone configuratiebestanden bewerkt — zie [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, op `Super + Shift + F` — zie [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome op `Super + Shift + Return`; kies een andere onder _Setup > Defaults > Browser_ — zie [browsers](23-browsers.md) |
| Preview / Photos | Omaview voor afbeeldingen, video en muziek, Document Viewer voor PDFs — zie [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, op `Super + Shift + N`; kies een andere onder _Setup > Defaults > Editor_ |

### Sommige dingen zijn echt anders

Veel instellingen staan in tekstbestanden die je bewerkt, niet in panelen waar je doorheen klikt. Dat klinkt primitief totdat je beseft dat het betekent dat elke aanpassing kan worden gezien, naar je volgende machine kan worden gekopieerd en in versiebeheer kan worden gezet. Het menu _Setup_ zet je direct in het juiste bestand en herstart wat herstart moet worden wanneer je klaar bent.

Updates komen via één commando — _Update > Omarchy_ — dat Omarchy zelf en elk pakket op het systeem bijwerkt, en eerst een snapshot maakt. Geen afzonderlijke app-updaters die je op willekeurige momenten lastigvallen. Zie [updates](30-updates.md).

Software komt van een pakketbeheerder, niet van gedownloade installatieprogramma's.

En wanneer je een venster sluit, stopt de app ook echt. Er is geen macOS-limbo waarin het programma blijft draaien zonder vensters. `Super + W` — of `Super + Q`, als dat het vingergeheugen is waarmee je aankwam — betekent weg.

### Op Mac-hardware

Omarchy draait goed op Intel Macs, en op M1-, M2- en M3-Macs met Omarchy for Apple Silicon. Zie [Mac-ondersteuning](44-mac-support.md). En het toetsenbord is vriendelijk voor je: Omarchy wijst niets opnieuw toe, en Linux behandelt de Command-toets als Super, dus Super zit precies waar Cmd altijd zat. Je duim merkt de overstap niet.

### Geef het twee weken

De instincten gaan sneller over dan je denkt. Blader een keer door het hoofdstuk [sneltoetsen](07-hotkeys.md), en telkens wanneer je een binding even kwijt bent, druk je op `Super + K` — dat toont je ze allemaal. Dat is de enige sneltoets die je echt uit je hoofd moet leren.
