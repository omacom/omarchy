# Kommer du fra Mac eller Windows

Hvis du har brukt årevis på macOS eller Windows, kan fingrene dine hundre ting hjernen din har glemt at den noen gang lærte. Dette kapittelet er oversettelseslaget: hvor de instinktene havner i Omarchy. Selve funksjonene er dekket i dybden andre steder — dette er bare kartet.

### Super er sentrum for alt

All muskelhukommelsen du har bygget rundt Cmd eller Windows-tasten overføres til én tast: Super. Det er Windows-tasten på et PC-tastatur, og den er ankeret for nesten alle hurtigtaster i Omarchy.

Spotlight-, Raycast- eller Start-menyrefleksen din blir til `Super + Space`. Det åpner Omarchy-menyen, som starter apper, endrer innstillinger, installerer programvare, fanger skjermen — omtrent alt. Begynn å skrive for å filtrere. `Super + Alt + Space` viser alle apper i ett rutenett, slik Launchpad gjør. Se [navigasjon](04-navigation.md).

### Ingen skrivebordsikoner, og dokken vises bare når du flyter

Ingen ikoner å ordne på skrivebordet, og ingen dokk på et arbeidsområde med flislegging — dokken vises bare på et flytende arbeidsområde (se [navigasjon](04-navigation.md)). Apper starter fra en hurtigtast (`Super + Return` for terminalen, `Super + Shift + Return` for nettleseren og `Super + K` for en liste over alt som er tilordnet) eller fra menyen. Den ene faste delen av brukergrensesnittet er [topplinjen](05-the-top-bar.md), som dekker det menylinjen, systemstatusfeltet og Notification Center gjorde for deg før — og nesten alle widgeter på den gjør noe ved venstre-, høyre- og midtklikk.

### Vinduer plasserer seg selv

Det største skiftet i tankemåte: Du drar ikke vinduer rundt eller fester dem til skjermhalvdeler. Åpne et vindu, og det tar hele skjermen. Åpne et til, og de deler den. Du fisker aldri et vindu fram fra under et annet, for vinduer overlapper ikke.

Når du virkelig trenger et flytende vindu, veksler `Super + T` det aktive vinduet ut av flisleggingen (og tilbake). Men gi flisleggingen en skikkelig sjanse først — den er hjertet i hele greia. [Navigasjon](04-navigation.md) leder deg gjennom det.

Arbeidsområder vil føles kjente: De er macOS Spaces eller virtuelle skrivebord i Windows, bortsett fra at du faktisk kommer til å bruke dem, for `Super + 1/2/3/4` hopper rett til ett og `Super + Shift + 1/2/3/4` sender det aktive vinduet dit. Ingen animasjonsforsinkelse, bare øyeblikkelige hopp. Det betyr at du kanskje ikke engang trenger flere skjermer, hvis du var vant til det før.

### Kopier og lim inn bare fungerer

På Mac hadde du Cmd + C overalt. På Windows hadde du Ctrl + C overalt — unntatt i terminalen, der den dreper programmet ditt. Omarchy gir deg `Super + C`, `Super + X` og `Super + V`, og de fungerer overalt, også i terminalen. Ingen egen refleks å lære for skallet.

Windows-folk: Win + V-utklippshistorikken din bor på `Super + Ctrl + V`, og den holder både bilder og tekst. Se [samlet utklippstavle og historikk](08-unified-clipboard-history.md).

### Oversettelsestabellen

| Det du strekker deg etter | I Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy-menyen |
| AirDrop | LocalSend, via `Super + Ctrl + S` — se [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eller `Print Screen` — se [skjermbilder og opptak](12-screenshots-recording.md) |
| Notification Center | Varslingshistorikk på `Super + Shift + Alt + ,` |
| Time Machine (for systemet) | Automatiske [systemøyeblikksbilder](47-system-snapshots.md) ved hver oppdatering |
| App Store / å laste ned et installasjonsprogram | _Install_ i menyen, eller `omarchy pkg add` — se [andre pakker](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ i menyen, som redigerer enkle konfigurasjonsfiler — se [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, på `Super + Shift + F` — se [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome på `Super + Shift + Return`; velg en annen under _Setup > Defaults > Browser_ — se [nettlesere](23-browsers.md) |
| Preview / Photos | Omaview for bilder, video og musikk, Document Viewer for PDF-er — se [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, på `Super + Shift + N`; velg en annen under _Setup > Defaults > Editor_ |

### Noen ting er faktisk annerledes

Mange innstillinger bor i tekstfiler du redigerer, ikke paneler du klikker deg gjennom. Det høres primitivt ut, helt til du innser at det betyr at hver justering kan ses, kopieres til din neste maskin og legges i versjonskontroll. _Setup_-menyen slipper deg rett inn i riktig fil og starter det som må startes på nytt når du er ferdig.

Oppdateringer kommer gjennom én kommando — _Update > Omarchy_ — som oppdaterer selve Omarchy og alle pakker på systemet, og tar et øyeblikksbilde først. Ingen oppdaterere per app som maser på deg i tide og utide. Se [oppdateringer](30-updates.md).

Programvare kommer fra en pakkebehandler, ikke fra nedlastede installasjonsprogrammer.

Og når du lukker et vindu, avsluttes appen faktisk. Det finnes ingen macOS-limbo der programmet fortsetter å kjøre uten vinduer. `Super + W` — eller `Super + Q`, hvis det er fingerhukommelsen du kom med — betyr borte.

### På Mac-maskinvare

Omarchy kjører bra på Intel-Macer — se [Mac-støtte](44-mac-support.md). Og tastaturet er snilt mot deg: Omarchy tilordner ingenting på nytt, og Linux behandler Command-tasten som Super, så Super sitter akkurat der Cmd alltid var. Tommelen din vil ikke merke flyttingen.

### Gi det to uker

Instinktene overføres raskere enn du skulle tro. Skumles [hurtigtaster](07-hotkeys.md)-kapittelet én gang, og hver gang du står fast på en tastebinding, trykk `Super + K` — den viser deg alle sammen. Det er den eneste hurtigtasten du faktisk må huske.
