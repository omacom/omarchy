# Overstappen vanaf Mac of Windows

Als je jaren op macOS of Windows hebt doorgebracht, kennen je vingers honderd dingen die je hersenen allang vergeten zijn ooit te hebben geleerd. Dit hoofdstuk is de vertaallaag: waar die instincten in Omarchy naartoe gaan. De functies zelf worden elders diepgaand behandeld — dit is alleen de kaart.

### Super is het middelpunt van alles

Al het spiergeheugen dat je hebt opgebouwd rond Cmd of de Windows-toets draag je over op één toets: Super. Dat is de Windows-toets op een pc-toetsenbord, en het is het anker voor bijna elke sneltoets in Omarchy.

Je Spotlight- of Raycast- of Startmenu-reflex wordt `Super + Space`. Dat opent het Omarchy-menu, dat apps start, instellingen verandert, software installeert, het scherm vastlegt — zo'n beetje alles. Begin te typen om te filteren. `Super + Alt + Space` toont elke app in één raster, zoals Launchpad dat doet. Zie [navigatie](04-navigation.md).

### Er is geen dock en geen bureaubladpictogrammen

Niets om op te klikken om dingen te starten, geen pictogrammen om op het bureaublad te rangschikken. Apps starten vanaf een sneltoets (`Super + Return` voor de terminal, `Super + Shift + Return` voor de browser, en `Super + K` voor een lijst van alles wat is toegewezen) of vanuit het menu. Het enige blijvende stukje UI is [de bovenbalk](05-the-top-bar.md), die dekt wat de menubalk, het systeemvak en het Berichtencentrum vroeger voor je deden — en bijna elke widget erop doet iets bij links, rechts en midden klikken.

### Vensters plaatsen zichzelf

De grootste mindset-shift: je sleept geen vensters rond en klikt ze niet vast aan schermhelften. Open een venster en het neemt het hele scherm in beslag. Open een tweede en ze splitsen het. Je vist nooit een venster onder een ander vandaan, omdat vensters niet overlappen.

Wanneer je echt een zwevend venster nodig hebt, schakelt `Super + T` het actieve venster uit de tegelindeling (en weer terug). Maar geef het tegelen eerst een echte kans — het is het hart van het hele ding. [Navigatie](04-navigation.md) leidt je erdoorheen.

Werkbladen zullen vertrouwd voelen: het zijn macOS Spaces of virtuele bureaubladen van Windows, behalve dat je ze daadwerkelijk zult gebruiken, omdat `Super + 1/2/3/4` er rechtstreeks naartoe springt en `Super + Shift + 1/2/3/4` het actieve venster erheen stuurt. Geen animatievertraging, alleen instant sprongen. Dit betekent dat je misschien niet eens meerdere monitoren nodig hebt, als je dat vroeger gewend was.

### Kopiëren en plakken werken gewoon

Op de Mac had je overal Cmd + C. Op Windows had je overal Ctrl + C — behalve in de terminal, waar het je programma doodt. Omarchy geeft je `Super + C`, `Super + X` en `Super + V`, en ze werken overal, inclusief de terminal. Geen aparte reflex om te lernen voor de shell.

Windows-mensen: je Win + V-klembordgeschiedenis leeft op `Super + Ctrl + V`, en het bevat afbeeldingen naast tekst. Zie [uniform klembord & geschiedenis](08-unified-clipboard-history.md).

### De vertaaltabel

| Je reikt naar | In Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Startmenu | `Super + Space` — het Omarchy-menu |
| AirDrop | LocalSend, via `Super + Ctrl + S` — zie [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — zie [schermafbeeldingen & opname](12-screenshots-recording.md) |
| Berichtencentrum | Meldingsgeschiedenis op `Super + Shift + Alt + ,` |
| Time Machine (voor het systeem) | Automatische [systeemsnapshots](47-system-snapshots.md) bij elke update |
| App Store / een installatieprogramma downloaden | _Installeren_ in het menu, of `omarchy pkg add` — zie [andere pakketten](29-other-packages.md) |
| Systeeminstellingen / Configuratiescherm | _Instellen_ in het menu, dat gewone configbestanden bewerkt — zie [dotfiles](31-dotfiles.md) |

### Sommige dingen zijn echt anders

Veel instellingen leven in tekstbestanden die je bewerkt, niet in panelen waar je doorheen klikt. Dat klinkt primitief totdat je beseft dat het betekent dat elke tweak gezien kan worden, gekopieerd kan worden naar je volgende machine, en in versiebeheer kan worden geplaatst. Het menu _Instellen_ zet je direct in het juiste bestand neer en herstart wat herstart moet worden als je klaar bent.

Updates komen via één commando — _Bijwerken > Omarchy_ — dat Omarchy zelf en elk pakket op het systeem bijwerkt, waarbij eerst een snapshot wordt genomen. Geen per-app updaters die je willekeurig lastigvallen. Zie [updates](30-updates.md).

Software komt van een pakketbeheerder, niet van gedownloade installatieprogramma's.

En wanneer je een venster sluit, stopt de app ook echt. Er is geen macOS-limbo waarin het programma blijft draaien zonder vensters. `Super + W` — of `Super + Q`, als dat het vingergeheugen is waarmee je bent aangekomen — betekent weg.

### Op Mac-hardware

Omarchy draait goed op Intel Macs — zie [Mac-ondersteuning](44-mac-support.md). En het toetsenbord is vriendelijk voor je: Omarchy remapt niets, en Linux behandelt de Command-toets als Super, dus Super zit precies waar Cmd altijd zat. Je duim zal de verhuizing niet merken.

### Geef het twee weken

De instincten dragen sneller over dan je denkt. Blader één keer door het hoofdstuk [sneltoetsen](07-hotkeys.md), en wanneer je een binding even kwijt bent, druk je op `Super + K` — het toont ze allemaal. Dat is de enige sneltoets die je echt uit je hoofd moet leren.
