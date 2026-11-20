# Hvis du kommer fra Mac eller Windows

Hvis du har tilbragt årevis på macOS eller Windows, kender dine fingre hundrede ting, som din hjerne har glemt, at den nogensinde lærte. Dette kapitel er oversættelseslaget: hvor de instinkter hører hjemme i Omarchy. Selve funktionerne er dækket i dybden andetsteds — det her er bare kortet.

### Super er centrum for det hele

Al den muskelhukommelse, du har opbygget omkring Cmd eller Windows-tasten, overføres til én tast: Super. Det er Windows-tasten på et PC-tastatur, og den er ankeret for næsten enhver genvejstast i Omarchy.

Din refleks med Spotlight eller Raycast eller Start-menuen bliver til `Super + Space`. Det åbner Omarchy-menuen, som starter apps, ændrer indstillinger, installerer software, tager skærmbilleder — stort set alt. Begynd at taste for at filtrere. `Super + Alt + Space` viser hver app på ét gitter, ligesom Launchpad gør. Se [navigation](04-navigation.md).

### Ingen skrivebordsikoner, og docken dukker kun op, når du flyder

Ingen ikoner at arrangere på skrivebordet og ingen dock på et fliselagt arbejdsområde — docken vises kun på et flydende arbejdsområde (se [navigation](04-navigation.md)). Apps starter fra en genvejstast (`Super + Return` til terminalen, `Super + Shift + Return` til browseren og `Super + K` til en liste over alt, hvad der er tilknyttet) eller fra menuen. Det eneste vedvarende stykke UI er [den øverste bjælke](05-the-top-bar.md), som dækker det, menulinjen, systembakken og Notification Center gjorde for dig før — og næsten hver widget på den gør noget ved venstre-, højre- og midterklik.

### Vinduer placerer sig selv

Det største mentalitetsskift: du trækker ikke vinduer rundt eller snapper dem til halve skærme. Åbn et vindue, og det fylder hele skærmen. Åbn et mere, og de deler den. Du fisker aldrig et vindue frem under et andet, fordi vinduer ikke overlapper.

Når du virkelig har brug for et flydende vindue, skifter `Super + T` det aktive vindue ud af fliselægningen (og tilbage igen). Men giv fliselægningen en reel chance først — det er hjertet i det hele. [Navigation](04-navigation.md) fører dig igennem det.

Arbejdsområder vil føles velkendte: de er macOS Spaces eller virtuelle skriveborde i Windows, bortset fra at du rent faktisk vil bruge dem, fordi `Super + 1/2/3/4` springer direkte til ét, og `Super + Shift + 1/2/3/4` sender det aktive vindue derhen. Ingen animationsforsinkelse, bare øjeblikkelige spring. Det betyder, at du måske ikke engang har brug for flere skærme, hvis du var vant til det før.

### Kopiér og indsæt virker bare

På Mac havde du Cmd + C overalt. På Windows havde du Ctrl + C overalt — undtagen i terminalen, hvor den dræber dit program. Omarchy giver dig `Super + C`, `Super + X` og `Super + V`, og de virker overalt, også i terminalen. Ingen separat refleks at lære til shellen.

Windows-folk: jeres Win + V-udklipsholderhistorik bor på `Super + Ctrl + V`, og den gemmer billeder såvel som tekst. Se [samlet udklipsholder og historik](08-unified-clipboard-history.md).

### Oversættelsestabellen

| Du rækker ud efter | I Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-menu | `Super + Space` — Omarchy-menuen |
| AirDrop | LocalSend, via `Super + Ctrl + S` — se [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eller `Print Screen` — se [skærmbilleder og optagelse](12-screenshots-recording.md) |
| Notification Center | Notifikationshistorik på `Super + Shift + Alt + ,` |
| Time Machine (til systemet) | Automatiske [systemsnapshots](47-system-snapshots.md) ved hver opdatering |
| App Store / download af et installationsprogram | _Install_ i menuen, eller `omarchy pkg add` — se [andre pakker](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ i menuen, som redigerer almindelige konfigurationsfiler — se [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, på `Super + Shift + F` — se [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome på `Super + Shift + Return`; vælg en anden under _Setup > Defaults > Browser_ — se [browsere](23-browsers.md) |
| Preview / Photos | Omaview til billeder, video og musik, Document Viewer til PDF'er — se [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, på `Super + Shift + N`; vælg en anden under _Setup > Defaults > Editor_ |

### Nogle ting er virkelig anderledes

Mange indstillinger bor i tekstfiler, du redigerer, ikke i paneler, du klikker dig igennem. Det lyder primitivt, indtil du indser, at det betyder, at enhver justering kan ses, kopieres til din næste maskine og sættes under versionsstyring. _Setup_-menuen sender dig direkte ind i den rigtige fil og genstarter det, der skal genstartes, når du er færdig.

Opdateringer kommer gennem én kommando — _Update > Omarchy_ — som opdaterer selve Omarchy og hver pakke på systemet og tager et snapshot først. Ingen opdateringsprogrammer pr. app, der plager dig på tilfældige tidspunkter. Se [opdateringer](30-updates.md).

Software kommer fra en pakkehåndtering, ikke fra downloadede installationsprogrammer.

Og når du lukker et vindue, lukker appen faktisk. Der er ingen macOS-limbo, hvor programmet bliver ved med at køre uden vinduer. `Super + W` — eller `Super + Q`, hvis det er den fingrehukommelse, du ankom med — betyder væk.

### På Mac-hardware

Omarchy kører godt på Intel Macs — se [Mac-support](44-mac-support.md). Og tastaturet er venligt mod dig: Omarchy ommapper ikke noget, og Linux behandler Command-tasten som Super, så Super sidder lige der, hvor Cmd altid var. Din tommelfinger vil ikke bemærke flytningen.

### Giv det to uger

Instinkterne overføres hurtigere, end du tror. Skim kapitlet om [genvejstaster](07-hotkeys.md) én gang, og hver gang du går blank på en binding, så tryk på `Super + K` — den viser dig dem alle. Det er den eneste genvejstast, du faktisk skal huske udenad.
