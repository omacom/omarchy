# Kommer du fra Mac eller Windows

Hvis du har brugt årevis på macOS eller Windows, kender dine fingre hundrede ting, som din hjerne har glemt, at den nogensinde har lært. Dette kapitel er oversættelseslaget: hvor de instinkter hører hjemme i Omarchy. Selve funktionerne er dækket i dybden andre steder — dette er bare kortet.

### Super er centrum for alting

Al den muskelhukommelse, du har opbygget omkring Cmd eller Windows-tasten, overføres til én tast: Super. Det er Windows-tasten på et PC-tastatur, og den er ankeret for næsten alle genvejstaster i Omarchy.

Din Spotlight-, Raycast- eller Start-menu-refleks bliver til `Super + Space`. Det åbner Omarchy-menuen, som starter apps, ændrer indstillinger, installerer software, tager skærmbilleder — stort set alting. Begynd at skrive for at filtrere. `Super + Alt + Space` viser alle apps i ét gitter, ligesom Launchpad gør. Se [navigation](04-navigation.md).

### Der er ingen dock og ingen skrivebordsikoner

Intet at klikke på for at starte ting, ingen ikoner at arrangere på skrivebordet. Apps starter fra en genvejstast (`Super + Return` til terminalen, `Super + Shift + Return` til browseren og `Super + K` til en liste over alt, der er tilknyttet) eller fra menuen. Det eneste vedvarende stykke UI er [den øverste bjælke](05-the-top-bar.md), som dækker det, menubjælken, systembakken og Notification Center gjorde for dig før — og næsten alle widgets på den gør noget ved venstre-, højre- og midterklik.

### Vinduer placerer sig selv

Det største skift i tankegang: Du trækker ikke vinduer rundt eller snapper dem til halve skærme. Åbn et vindue, og det fylder hele skærmen. Åbn et mere, og de deler den. Du fisker aldrig et vindue frem fra under et andet, fordi vinduer ikke overlapper.

Når du virkelig har brug for et flydende vindue, slår `Super + T` det aktive ud af tiling (og tilbage igen). Men giv tiling en reel chance først — det er hjertet i det hele. [Navigation](04-navigation.md) fører dig igennem det.

Workspaces vil føles velkendte: De er macOS Spaces eller virtuelle skriveborde i Windows, bortset fra at du faktisk vil bruge dem, fordi `Super + 1/2/3/4` springer direkte til ét og `Super + Shift + 1/2/3/4` sender det aktive vindue derhen. Ingen animationsforsinkelse, bare øjeblikkelige spring. Det betyder, at du måske ikke engang har brug for flere skærme, hvis du var vant til det før.

### Kopiér og indsæt virker bare

På Mac havde du Cmd + C overalt. På Windows havde du Ctrl + C overalt — undtagen i terminalen, hvor det dræber dit program. Omarchy giver dig `Super + C`, `Super + X` og `Super + V`, og de virker overalt, også i terminalen. Ingen separat refleks at lære til shellen.

Windows-folk: Din Win + V-udklipsholderhistorik bor på `Super + Ctrl + V`, og den holder både billeder og tekst. Se [samlet udklipsholder & historik](08-unified-clipboard-history.md).

### Oversættelsestabellen

| Du rækker ud efter | I Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-menu | `Super + Space` — Omarchy-menuen |
| AirDrop | LocalSend, via `Super + Ctrl + S` — se [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eller `Print Screen` — se [skærmbilleder & optagelse](12-screenshots-recording.md) |
| Notification Center | Notifikationshistorik på `Super + Shift + Alt + ,` |
| Time Machine (til systemet) | Automatiske [systemsnapshots](47-system-snapshots.md) ved hver opdatering |
| App Store / at downloade et installationsprogram | _Install_ i menuen, eller `omarchy pkg add` — se [andre pakker](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ i menuen, som redigerer almindelige konfigurationsfiler — se [dotfiles](31-dotfiles.md) |

### Nogle ting er virkelig anderledes

Mange indstillinger bor i tekstfiler, du redigerer, ikke i paneler, du klikker dig igennem. Det lyder primitivt, indtil du indser, at det betyder, at hver eneste justering kan ses, kopieres til din næste maskine og sættes i version control. _Setup_-menuen smider dig direkte ind i den rigtige fil og genstarter det, der skal genstartes, når du er færdig.

Opdateringer kommer via én kommando — _Update > Omarchy_ — som opdaterer selve Omarchy og alle pakker på systemet og tager et snapshot først. Ingen opdateringsprogrammer pr. app, der plager dig på tilfældige tidspunkter. Se [opdateringer](30-updates.md).

Software kommer fra en package manager, ikke fra downloadede installationsprogrammer.

Og når du lukker et vindue, afslutter appen faktisk. Der er intet macOS-limbo, hvor programmet bliver ved med at køre uden vinduer. `Super + W` — eller `Super + Q`, hvis det er den fingerhukommelse, du ankom med — betyder væk.

### På Mac-hardware

Omarchy kører godt på Intel Macs — se [Mac-understøttelse](44-mac-support.md). Og tastaturet er venligt mod dig: Omarchy ommapper ikke noget, og Linux behandler Command-tasten som Super, så Super sidder lige der, hvor Cmd altid var. Din tommelfinger vil ikke bemærke flytningen.

### Giv det to uger

Instinkterne overføres hurtigere, end du tror. Skim kapitlet om [genvejstaster](07-hotkeys.md) én gang, og hver gang du går i sort over en binding, så tryk `Super + K` — den viser dig dem alle. Det er den eneste genvejstast, du faktisk skal huske udenad.
