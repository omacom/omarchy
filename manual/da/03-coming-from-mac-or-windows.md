# Kommer du fra Mac eller Windows

Hvis du har tilbragt årevis på macOS eller Windows, kender dine fingre hundrede ting, som din hjerne har glemt, at den nogensinde lærte. Dette kapitel er oversættelseslaget: hvor de instinkter hører hjemme i Omarchy. Selve funktionerne er dækket i dybden andre steder — dette er blot kortet.

### Super er centrum for alting

Al den muskelhukommelse, du har opbygget omkring Cmd eller Windows-tasten, flytter over på én tast: Super. Det er Windows-tasten på et PC-tastatur, og den er ankeret for næsten alle genvejstaster i Omarchy.

Din refleks til Spotlight eller Raycast eller Start-menuen bliver til `Super + Space`. Det åbner Omarchy-menuen, som starter apps, ændrer indstillinger, installerer software, tager skærmbilleder — stort set alt. Begynd at skrive for at filtrere. `Super + Alt + Space` viser alle apps i ét gitter, ligesom Launchpad gør. Se [navigation](04-navigation.md).

### Ingen ikoner på skrivebordet, og docken holder sig væk

Ingen ikoner at arrangere på skrivebordet, og docken skjuler sig, så snart et arbejdsområde har et vindue, indtil du skubber markøren til dens kant af skærmen, den nederste, medmindre du flytter den (se [navigation](04-navigation.md)). Apps starter fra en genvejstast (`Super + Return` for terminalen, `Super + Shift + Return` for browseren og `Super + K` for en liste over alt, hvad der er tilknyttet) eller fra menuen. Det eneste vedvarende stykke UI er [den øverste bjælke](05-the-top-bar.md), som dækker det, menulinjen, systembakken og Notification Center gjorde for dig før — og næsten alle widgets på den gør noget ved venstre-, højre- og midterklik.

### Vinduer placerer sig selv

Den største ændring i tankegang: du trækker ikke vinduer rundt eller snapper dem til halvdele af skærmen. Åbn et vindue, og det fylder hele skærmen. Åbn et andet, og de deler den. Du fisker aldrig et vindue frem under et andet, fordi vinduer ikke overlapper.

Når du virkelig har brug for et flydende vindue, skifter `Super + T` det aktive vindue ud af fliselægningen (og tilbage igen). Men giv fliselægningen en reel chance først — det er hjertet i det hele. [Navigation](04-navigation.md) guider dig igennem det.

Arbejdsområder vil føles bekendte: de er macOS Spaces eller virtuelle skriveborde i Windows, bortset fra at du rent faktisk vil bruge dem, fordi `Super + 1/2/3/4` springer direkte til et, og `Super + Shift + 1/2/3/4` sender det aktive vindue derhen. Ingen animationsforsinkelse, bare øjeblikkelige spring. Det betyder, at du måske ikke engang har brug for flere skærme, hvis du var vant til det før.

### Kopiér og indsæt virker bare

På Mac havde du Cmd + C overalt. På Windows havde du Ctrl + C overalt — undtagen i terminalen, hvor det dræber dit program. Omarchy giver dig `Super + C`, `Super + X` og `Super + V`, og de virker overalt, også i terminalen. Ingen separat refleks at lære til shell'en.

Folk fra Windows: din Win + V-udklipsholderhistorik bor på `Super + Ctrl + V`, og den gemmer billeder såvel som tekst. Se [samlet udklipsholder & historik](08-unified-clipboard-history.md).

### Oversættelsestabellen

| Du rækker efter | I Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-menu | `Super + Space` — Omarchy-menuen |
| AirDrop | LocalSend, via `Super + Ctrl + S` — se [GUI'er](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eller `Print Screen` — se [skærmbilleder & optagelse](12-screenshots-recording.md) |
| Notification Center | Notifikationshistorik på `Super + Shift + Alt + ,` |
| Time Machine (til systemet) | Automatiske [systemsnapshots](47-system-snapshots.md) ved hver opdatering |
| App Store / at downloade et installationsprogram | _Install_ i menuen, eller `omarchy pkg add` — se [andre pakker](29-other-packages.md) |
| Systemindstillinger / Kontrolpanel | _Setup_ i menuen, som redigerer almindelige konfigurationsfiler — se [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, på `Super + Shift + F` — se [GUI'er](22-guis.md) |
| Safari / Edge | Google Chrome på `Super + Shift + Return`; vælg en anden under _Setup > Defaults > Browser_ — se [browsere](23-browsers.md) |
| Preview / Photos | Omaview til billeder, video og musik, Document Viewer til PDF'er — se [GUI'er](22-guis.md) |
| TextEdit / Notepad | Plain, på `Super + Shift + N`; vælg en anden under _Setup > Defaults > Editor_ |

### Nogle ting er virkelig anderledes

Mange indstillinger bor i tekstfiler, du redigerer, ikke i paneler, du klikker dig igennem. Det lyder primitivt, indtil du indser, at det betyder, at enhver justering kan ses, kopieres til din næste maskine og sættes under versionskontrol. _Setup_-menuen smider dig direkte ind i den rigtige fil og genstarter det, der skal genstartes, når du er færdig.

Opdateringer kommer via én kommando — _Update > Omarchy_ — som opdaterer Omarchy selv og alle pakker på systemet og tager et snapshot først. Ingen opdateringsprogrammer pr. app, der maser sig på på tilfældige tidspunkter. Se [opdateringer](30-updates.md).

Software kommer fra en pakkehåndtering, ikke fra downloadede installationsprogrammer.

Og når du lukker et vindue, lukker appen rent faktisk. Der er intet macOS-limbo, hvor programmet bliver ved med at køre uden vinduer. `Super + W` — eller `Super + Q`, hvis det er den fingerhukommelse, du ankom med — betyder væk.

### På Mac-hardware

Omarchy kører godt på Intel-Macs og på M1-, M2- og M3-Macs med Omarchy til Apple Silicon. Se [Mac-understøttelse](44-mac-support.md). Og tastaturet er venligt mod dig: Omarchy ombinder ingenting, og Linux behandler Command-tasten som Super, så Super sidder lige der, hvor Cmd altid var. Din tommelfinger vil ikke bemærke flytningen.

### Giv det to uger

Instinkterne overføres hurtigere, end du tror. Skim [genvejstaster](07-hotkeys.md)-kapitlet én gang, og hver gang du går blank på en binding, så tryk på `Super + K` — den viser dig dem alle. Det er den eneste genvejstast, du rent faktisk skal huske udenad.
