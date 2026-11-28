# Når du kommer fra Mac eller Windows

Hvis du har brukt macOS eller Windows i årevis, kan fingrene dine hundre ting hjernen din har glemt at den noen gang lærte. Dette kapittelet er oversettelseslaget: hvor de instinktene hører hjemme i Omarchy. Funksjonene i seg selv er beskrevet i dybden andre steder — dette er bare kartet.

### Super er sentrum for alt

All muskelhukommelsen du har bygget opp rundt Cmd eller Windows-tasten overføres til én tast: Super. Det er Windows-tasten på et PC-tastatur, og den er ankeret for nesten alle hurtigtaster i Omarchy.

Spotlight-, Raycast- eller Start-menyrefleksen din blir til `Super + Space`. Det åpner Omarchy-menyen, som starter apper, endrer innstillinger, installerer programvare, tar skjermbilder — omtrent alt. Begynn å skrive for å filtrere. `Super + Alt + Space` viser alle apper i ett rutenett, slik Launchpad gjør. Se [navigasjon](04-navigation.md).

### Ingen ikoner på skrivebordet, og dokken holder seg unna

Ingen ikoner å ordne på skrivebordet, og dokken skjuler seg så snart et arbeidsområde har et vindu, helt til du skyver pekeren mot kanten av skjermen der den er, den nederste med mindre du flytter den (se [navigasjon](04-navigation.md)). Apper starter fra en hurtigtast (`Super + Return` for terminalen, `Super + Shift + Return` for nettleseren og `Super + K` for en liste over alt som er tilordnet) eller fra menyen. Det ene vedvarende UI-elementet er [topplinjen](05-the-top-bar.md), som dekker det menylinjen, systemstatusfeltet og Notification Center gjorde for deg før — og nesten alle widgeter på den gjør noe ved venstre-, høyre- og midtklikk.

### Vinduer plasserer seg selv

Den største endringen i tankesett: du drar ikke vinduer rundt eller fester dem til skjermhalvdeler. Åpne et vindu, og det tar hele skjermen. Åpne et til, og de deler den. Du fisker aldri et vindu fram fra under et annet, fordi vinduer ikke overlapper.

Når du virkelig trenger et flytende vindu, veksler `Super + T` det aktive ut av flisleggingen (og tilbake). Men gi flisleggingen en reell sjanse først — det er hjertet i hele greia. [Navigasjon](04-navigation.md) leder deg gjennom det.

Arbeidsområder vil føles kjente: de er macOS Spaces eller virtuelle skrivebord i Windows, bortsett fra at du faktisk kommer til å bruke dem, fordi `Super + 1/2/3/4` hopper rett til ett og `Super + Shift + 1/2/3/4` sender det aktive vinduet dit. Ingen animasjonsforsinkelse, bare umiddelbare hopp. Det betyr at du kanskje ikke engang trenger flere skjermer, hvis du var vant til det før.

### Kopier og lim inn bare fungerer

På Mac hadde du Cmd + C overalt. På Windows hadde du Ctrl + C overalt — bortsett fra i terminalen, der det dreper programmet ditt. Omarchy gir deg `Super + C`, `Super + X` og `Super + V`, og de fungerer overalt, også i terminalen. Ingen egen refleks å lære for skallet.

Windows-folk: Win + V-historikken for utklippstavlen din bor på `Super + Ctrl + V`, og den inneholder både bilder og tekst. Se [samlet utklippstavle og historikk](08-unified-clipboard-history.md).

### Oversettelsestabellen

| Du strekker deg etter | I Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-meny | `Super + Space` — Omarchy-menyen |
| AirDrop | LocalSend, via `Super + Ctrl + S` — se [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eller `Print Screen` — se [skjermbilder og opptak](12-screenshots-recording.md) |
| Notification Center | Varslingshistorikk på `Super + Shift + Alt + ,` |
| Time Machine (for systemet) | Automatiske [systemøyeblikksbilder](47-system-snapshots.md) ved hver oppdatering |
| App Store / å laste ned et installasjonsprogram | _Installer_ i menyen, eller `omarchy pkg add` — se [andre pakker](29-other-packages.md) |
| System Settings / Control Panel | _Oppsett_ i menyen, som redigerer enkle konfigurasjonsfiler — se [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, på `Super + Shift + F` — se [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome på `Super + Shift + Return`; velg en annen under _Oppsett > Standard > Nettleser_ — se [nettlesere](23-browsers.md) |
| Preview / Photos | Omaview for bilder, video og musikk, Document Viewer for PDF-er — se [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, på `Super + Shift + N`; velg en annen under _Oppsett > Standard > Redigeringsprogram_ |

### Noen ting er faktisk annerledes

Mange innstillinger bor i tekstfiler du redigerer, ikke i paneler du klikker deg gjennom. Det høres primitivt ut helt til du innser at det betyr at alle justeringer kan ses, kopieres til din neste maskin og legges i versjonskontroll. _Oppsett_-menyen slipper deg rett inn i riktig fil og starter det som må startes på nytt, når du er ferdig.

Oppdateringer kommer gjennom én kommando — _Oppdater > Omarchy_ — som oppdaterer selve Omarchy og alle pakker på systemet, og tar et øyeblikksbilde først. Ingen oppdateringsprogrammer per app som maser på deg i tide og utide. Se [oppdateringer](30-updates.md).

Programvare kommer fra en pakkebehandler, ikke fra nedlastede installasjonsprogrammer.

Og når du lukker et vindu, avsluttes appen faktisk. Det finnes ingen macOS-limbo der programmet fortsetter å kjøre uten vinduer. `Super + W` — eller `Super + Q`, hvis det er fingerhukommelsen du kom med — betyr borte.

### På Mac-maskinvare

Omarchy kjører godt på Intel-Macer, og på M1-, M2- og M3-Macer med Omarchy for Apple Silicon. Se [Mac-støtte](44-mac-support.md). Og tastaturet er snilt mot deg: Omarchy tilordner ingenting på nytt, og Linux behandler Command-tasten som Super, så Super sitter rett der Cmd alltid var. Tommelen din vil ikke merke flyttingen.

### Gi det to uker

Instinktene overføres raskere enn du skulle tro. Skumles kapittelet om [hurtigtaster](07-hotkeys.md) én gang, og hver gang du går blank på en tilordning, trykk `Super + K` — den viser deg alle sammen. Det er den eneste hurtigtasten du faktisk må huske utenat.
