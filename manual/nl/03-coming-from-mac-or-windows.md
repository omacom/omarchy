# Kom je van Mac of Windows

Als je jaren op macOS of Windows hebt doorgebracht, kennen je vingers honderd dingen waarvan je brein is vergeten dat het ze ooit heeft geleerd. Dit hoofdstuk is de vertaallaag: waar die instincten in Omarchy terechtkomen. De functies zelf worden elders uitgebreid behandeld — dit is alleen de kaart.

### Super is het middelpunt van alles

Al het spiergeheugen dat je rond Cmd of de Windows-toets hebt opgebouwd, gaat over naar één toets: Super. Dat is de Windows-toets op een pc-toetsenbord, en het anker voor bijna elke sneltoets in Omarchy.

Je Spotlight-, Raycast- of Startmenu-reflex wordt `Super + Space`. Daarmee open je het Omarchy-menu, waarmee je apps start, instellingen wijzigt, software installeert, het scherm vastlegt — zo'n beetje alles. Begin met typen om te filteren. `Super + Alt + Space` toont elke app op één raster, zoals Launchpad dat doet. Zie [navigatie](04-navigation.md).

### Er is geen dock en geen bureaubladpictogrammen

Niets om op te klikken om dingen te starten, geen pictogrammen om op het bureaublad te rangschikken. Apps starten met een sneltoets (`Super + Return` voor de terminal, `Super + Shift + Return` voor de browser en `Super + K` voor een lijst van alles wat is toegewezen) of vanuit het menu. Het enige blijvende stukje UI is [de bovenbalk](05-the-top-bar.md), die dekt wat de menubalk, het systeemvak en Notification Center vroeger voor je deden — en bijna elke widget erop doet iets bij links klikken, rechts klikken en met de middelste knop klikken.

### Vensters plaatsen zichzelf

De grootste omslag in denken: je sleept geen vensters rond en klikt ze niet vast op schermhelften. Open een venster en het neemt het hele scherm. Open een tweede en ze splitsen het. Je vist nooit een venster van onder een ander vandaan, omdat vensters niet overlappen.

Als je echt een zwevend venster nodig hebt, haalt `Super + T` het actieve venster uit de tegelindeling (en weer terug). Maar geef die tegelindeling eerst echt een kans — het is het hart van het geheel. [Navigatie](04-navigation.md) leidt je erdoorheen.

Werkruimtes zullen vertrouwd aanvoelen: het zijn macOS Spaces of virtuele bureaubladen van Windows, behalve dat je ze ook echt zult gebruiken, omdat `Super + 1/2/3/4` meteen naar er een springt en `Super + Shift + 1/2/3/4` het actieve venster daarheen stuurt. Geen animatievertraging, gewoon directe sprongen. Dit betekent dat je misschien niet eens meerdere monitoren nodig hebt, als je daaraan gewend was.

### Kopiëren en plakken werkt gewoon

Op de Mac had je overal Cmd + C. Op Windows had je overal Ctrl + C — behalve in de terminal, waar het je programma beëindigt. Omarchy geeft je `Super + C`, `Super + X` en `Super + V`, en ze werken overal, ook in de terminal. Geen aparte reflex om voor de shell te leren.

Windows-mensen: je Win + V-klembordgeschiedenis zit op `Super + Ctrl + V`, en die bewaart zowel afbeeldingen als tekst. Zie [uniform klembord en geschiedenis](08-unified-clipboard-history.md).

### De vertaaltabel

| Je grijpt naar | In Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — het Omarchy-menu |
| AirDrop | LocalSend, via `Super + Ctrl + S` — zie [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` of `Print Screen` — zie [schermafbeeldingen en opnames](12-screenshots-recording.md) |
| Notification Center | Meldingsgeschiedenis op `Super + Shift + Alt + ,` |
| Time Machine (voor het systeem) | Automatische [systeemsnapshots](47-system-snapshots.md) bij elke update |
| App Store / een installatieprogramma downloaden | _Install_ in het menu, of `omarchy pkg add` — zie [andere pakketten](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ in het menu, dat gewone configuratiebestanden bewerkt — zie [dotfiles](31-dotfiles.md) |

### Sommige dingen zijn echt anders

Veel instellingen staan in tekstbestanden die je bewerkt, niet in panelen waar je doorheen klikt. Dat klinkt primitief, tot je beseft dat het betekent dat elke aanpassing kan worden bekeken, naar je volgende machine kan worden gekopieerd en in versiebeheer kan worden gezet. Het _Setup_-menu zet je meteen in het juiste bestand en herstart wat herstart moet worden als je klaar bent.

Updates komen via één opdracht — _Update > Omarchy_ — die Omarchy zelf en elk pakket op het systeem bijwerkt, en eerst een snapshot maakt. Geen updaters per app die je op willekeurige momenten lastigvallen. Zie [updates](30-updates.md).

Software komt van een pakketbeheerder, niet van gedownloade installatieprogramma's.

En als je een venster sluit, stopt de app ook echt. Er is geen macOS-limbo waarin het programma blijft draaien zonder vensters. `Super + W` — of `Super + Q`, als dat het vingergeheugen is waarmee je aankwam — betekent weg.

### Op Mac-hardware

Omarchy draait goed op Intel Macs — zie [Mac-ondersteuning](44-mac-support.md). En het toetsenbord is vriendelijk voor je: Omarchy wijst niets opnieuw toe, en Linux behandelt de Command-toets als Super, dus Super zit precies waar Cmd altijd zat. Je duim merkt de overstap niet.

### Geef het twee weken

De instincten gaan sneller over dan je denkt. Blader één keer door het hoofdstuk [sneltoetsen](07-hotkeys.md), en als je een toewijzing blanco vergeet, druk op `Super + K` — dat toont ze je allemaal. Dat is de enige sneltoets die je echt uit je hoofd moet leren.
