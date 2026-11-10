# Kommer du fra Mac eller Windows

Hvis du har brukt macOS eller Windows i årevis, kan fingrene dine hundre ting hjernen din har glemt at den noen gang lærte. Dette kapitlet er oversettelseslaget: hvor de instinktene hører hjemme i Omarchy. Selve funksjonene er dekket grundig andre steder — dette er bare kartet.

### Super er midtpunktet i alt

All muskelhukommelsen du har bygget rundt Cmd eller Windows-tasten, overføres til én tast: Super. Det er Windows-tasten på et PC-tastatur, og den er ankeret for nesten alle hurtigtaster i Omarchy.

Refleksen din etter Spotlight, Raycast eller Start-menyen blir `Super + Space`. Det åpner Omarchy-menyen, som starter apper, endrer innstillinger, installerer programvare, tar skjermbilder — omtrent alt. Begynn å skrive for å filtrere. `Super + Alt + Space` viser alle appene i ett rutenett, slik Launchpad gjør. Se [navigering](04-navigation.md).

### Det finnes ingen dock og ingen skrivebordsikoner

Ingenting å klikke på for å starte ting, ingen ikoner å ordne på skrivebordet. Apper starter fra en hurtigtast (`Super + Return` for terminalen, `Super + Shift + Return` for nettleseren og `Super + K` for en liste over alt som er tilordnet) eller fra menyen. Den eneste faste delen av brukergrensesnittet er [topplinjen](05-the-top-bar.md), som dekker det menylinjen, systemstatusfeltet og Notification Center gjorde for deg før — og nesten hver widget på den gjør noe ved venstre-, høyre- og midtklikk.

### Vinduer plasserer seg selv

Den største omstillingen: du drar ikke vinduer rundt eller fester dem til skjermhalvdeler. Åpne et vindu, og det tar hele skjermen. Åpne et til, og de deler den. Du fisker aldri et vindu frem fra under et annet, fordi vinduer ikke overlapper.

Når du virkelig trenger et flytende vindu, veksler `Super + T` det aktive vinduet ut av flisleggingen (og tilbake igjen). Men gi flisleggingen en reell sjanse først — den er hjertet i hele greia. [Navigering](04-navigation.md) går gjennom det med deg.

Arbeidsområder vil føles kjente: de er Spaces i macOS eller virtuelle skrivebord i Windows, bortsett fra at du faktisk kommer til å bruke dem, fordi `Super + 1/2/3/4` hopper rett til ett og `Super + Shift + 1/2/3/4` sender det aktive vinduet dit. Ingen animasjonsforsinkelse, bare umiddelbare hopp. Det betyr at du kanskje ikke engang trenger flere skjermer, hvis du var vant til det før.

### Kopiering og liming bare fungerer

På Mac hadde du Cmd + C overalt. På Windows hadde du Ctrl + C overalt — bortsett fra i terminalen, der den dreper programmet ditt. Omarchy gir deg `Super + C`, `Super + X` og `Super + V`, og de fungerer overalt, også i terminalen. Ingen egen refleks å lære for skallet.

Windows-folk: utklippstavlehistorikken din fra Win + V bor på `Super + Ctrl + V`, og den tar vare på bilder så vel som tekst. Se [samlet utklippstavle og historikk](08-unified-clipboard-history.md).

### Oversettelsestabellen

| Du strekker deg etter | I Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-meny | `Super + Space` — Omarchy-menyen |
| AirDrop | LocalSend, via `Super + Ctrl + S` — se [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eller `Print Screen` — se [skjermbilder og opptak](12-screenshots-recording.md) |
| Notification Center | Varselhistorikk på `Super + Shift + Alt + ,` |
| Time Machine (for systemet) | Automatiske [systemøyeblikksbilder](47-system-snapshots.md) ved hver oppdatering |
| App Store / å laste ned et installasjonsprogram | _Installer_ i menyen, eller `omarchy pkg add` — se [andre pakker](29-other-packages.md) |
| System Settings / Control Panel | _Oppsett_ i menyen, som redigerer enkle konfigurasjonsfiler — se [dotfiles](31-dotfiles.md) |

### Noen ting er faktisk annerledes

Mange innstillinger bor i tekstfiler du redigerer, ikke i paneler du klikker deg gjennom. Det høres primitivt ut til du innser at det betyr at hver justering kan ses, kopieres til din neste maskin og settes i versjonskontroll. _Oppsett_-menyen slipper deg rett inn i riktig fil og starter det som må startes på nytt, når du er ferdig.

Oppdateringer kommer gjennom én kommando — _Oppdater > Omarchy_ — som oppdaterer selve Omarchy og hver pakke på systemet, og tar et øyeblikksbilde først. Ingen oppdateringsprogrammer per app som maser på deg i tide og utide. Se [oppdateringer](30-updates.md).

Programvare kommer fra en pakkebehandler, ikke fra nedlastede installasjonsprogrammer.

Og når du lukker et vindu, avsluttes appen faktisk. Det finnes ingen macOS-limbo der programmet fortsetter å kjøre uten vinduer. `Super + W` — eller `Super + Q`, hvis det er den fingerhukommelsen du kom med — betyr borte.

### På Mac-maskinvare

Omarchy kjører bra på Intel-Macer — se [Mac-støtte](44-mac-support.md). Og tastaturet er snilt mot deg: Omarchy tilordner ingenting på nytt, og Linux behandler Command-tasten som Super, så Super sitter akkurat der Cmd alltid var. Tommelen din vil ikke merke flyttingen.

### Gi det to uker

Instinktene overføres raskere enn du skulle tro. Skumles [hurtigtaster](07-hotkeys.md)-kapitlet én gang, og hver gang du går blank på en tilordning, trykk `Super + K` — den viser deg alle sammen. Det er den eneste hurtigtasten du faktisk må memorere.
