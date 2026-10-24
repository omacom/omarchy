# Kommer du fra Mac eller Windows

Hvis du har tilbrakt år på macOS eller Windows, kan fingrene dine hundre ting hjernen din har glemt at den noen gang lærte. Dette kapittelet er oversettelseslaget: hvor disse instinktene hører hjemme i Omarchy. Selve funksjonene dekkes i dybden andre steder — dette er bare kartet.

### Super er sentrum for alt

All muskelminnet du har bygget opp rundt Cmd eller Windows-tasten overføres til én tast: Super. Det er Windows-tasten på et PC-tastatur, og den er ankeret for nesten alle snarveier i Omarchy.

Refleksen din for Spotlight eller Raycast eller Start-menyen blir `Super + Space`. Det åpner Omarchy-menyen, som starter apper, endrer innstillinger, installerer programvare, fanger skjermen — omtrent alt. Begynn å skrive for å filtrere. `Super + Alt + Space` viser alle apper på ett rutenett, slik Launchpad gjør. Se [navigasjon](04-navigation.md).

### Det finnes ingen dock og ingen skrivebordsikoner

Ingenting å klikke på for å starte ting, ingen ikoner å ordne på skrivebordet. Apper starter fra en snarvei (`Super + Return` for terminalen, `Super + Shift + Return` for nettleseren, og `Super + K` for en liste over alt som er tilordnet) eller fra menyen. Den ene vedvarende delen av brukergrensesnittet er [menylinjen øverst](05-the-top-bar.md), som dekker det menylinjen, systemstatusfeltet og varslingssenteret gjorde for deg før — og nesten hver widget på den gjør noe ved venstre-, høyre- og midtklikk.

### Vinduer plasserer seg selv

Det største tankeskiftet: du drar ikke vinduer rundt eller fester dem til skjermhalvdeler. Åpne et vindu, og det tar hele skjermen. Åpne et annet, og de deler den. Du fisker aldri et vindu frem fra under et annet, fordi vinduer ikke overlapper.

Når du virkelig trenger et flytende vindu, veksler `Super + T` det aktive vinduet ut av flisleggingen (og tilbake). Men gi flisleggingen en reell sjanse først — den er hjertet i det hele. [Navigasjon](04-navigation.md) leder deg gjennom det.

Arbeidsområder vil føles kjente: de er macOS' Spaces eller Windows' virtuelle skrivebord, bortsett fra at du faktisk vil bruke dem, fordi `Super + 1/2/3/4` hopper rett til ett og `Super + Shift + 1/2/3/4` sender det aktive vinduet dit. Ingen animasjonsforsinkelse, bare umiddelbare hopp. Det betyr at du kanskje ikke engang trenger flere skjermer, hvis du var vant til det før.

### Kopiering og innliming fungerer bare

På Mac hadde du Cmd + C overalt. På Windows hadde du Ctrl + C overalt — unntatt terminalen, der den dreper programmet ditt. Omarchy gir deg `Super + C`, `Super + X` og `Super + V`, og de fungerer overalt, inkludert terminalen. Ingen egen refleks å lære for skallet.

Windows-folk: utklippstavlehistorikken din fra Win + V bor på `Super + Ctrl + V`, og den holder både bilder og tekst. Se [samlet utklippstavle og historikk](08-unified-clipboard-history.md).

### Oversettelsestabellen

| Du strekker deg etter | I Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-meny | `Super + Space` — Omarchy-menyen |
| AirDrop | LocalSend, via `Super + Ctrl + S` — se [GUI-er](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — se [skjermbilder og opptak](12-screenshots-recording.md) |
| Varslingssenter | Varslingshistorikk på `Super + Shift + Alt + ,` |
| Time Machine (for systemet) | Automatiske [systemøyeblikksbilder](47-system-snapshots.md) ved hver oppdatering |
| App Store / nedlasting av et installasjonsprogram | _Installer_ i menyen, eller `omarchy pkg add` — se [andre pakker](29-other-packages.md) |
| Systeminnstillinger / Kontrollpanel | _Oppsett_ i menyen, som redigerer vanlige konfigurasjonsfiler — se [dotfiler](31-dotfiles.md) |

### Noen ting er virkelig annerledes

Mange innstillinger bor i tekstfiler du redigerer, ikke paneler du klikker deg gjennom. Det høres primitivt ut helt til du innser at det betyr at hver justering kan sees, kopieres til neste maskin og legges under versjonskontroll. _Oppsett_-menyen slipper deg rett inn i riktig fil og starter det som trenger omstart på nytt når du er ferdig.

Oppdateringer kommer gjennom én kommando — _Oppdater > Omarchy_ — som oppdaterer Omarchy selv og hver pakke på systemet, og tar et øyeblikksbilde først. Ingen oppdateringsprogrammer per app som maser på deg tilfeldig. Se [oppdateringer](30-updates.md).

Programvare kommer fra en pakkebehandler, ikke fra nedlastede installasjonsprogrammer.

Og når du lukker et vindu, avsluttes appen faktisk. Det finnes ingen macOS-limbo der programmet fortsetter å kjøre uten vinduer. `Super + W` — eller `Super + Q`, hvis det er fingerminnet du kom med — betyr borte.

### På Mac-maskinvare

Omarchy kjører godt på Intel-Mac-er — se [Mac-støtte](44-mac-support.md). Og tastaturet er vennlig mot deg: Omarchy tilordner ingenting på nytt, og Linux behandler Command-tasten som Super, så Super sitter akkurat der Cmd alltid var. Tommelen din vil ikke merke flyttingen.

### Gi det to uker

Instinktene overføres raskere enn du skulle tro. Skumles kapittelet om [tastatursnarveier](07-hotkeys.md) én gang, og når du står fast på en binding, trykker du `Super + K` — den viser deg alle. Det er den eneste snarveien du faktisk må huske.
