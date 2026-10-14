# Når du kommer fra Mac eller Windows

Hvis du har brugt år på macOS eller Windows, kender dine fingre hundrede ting, som din hjerne har glemt, at den nogensinde lærte. Dette kapitel er oversættelseslaget: hvor de instinkter hører hjemme i Omarchy. Selve funktionerne er beskrevet i dybden andre steder — det her er bare kortet.

### Super er centrum for det hele

Al den muskelhukommelse, du har opbygget omkring Cmd eller Windows-tasten, overføres til én tast: Super. Det er Windows-tasten på et PC-tastatur, og det er ankeret for næsten alle genvejstaster i Omarchy.

Din Spotlight- eller Raycast- eller Start-menu-refleks bliver til `Super + Space`. Det åbner Omarchy-menuen, som starter apps, ændrer indstillinger, installerer software, optager skærmen — stort set det hele. Begynd at skrive for at filtrere. `Super + Alt + Space` viser alle apps i ét gitter, ligesom Launchpad gjorde det. Se [navigation](04-navigation.md).

### Der er ingen dock og ingen skrivebordsikoner

Ingenting at klikke på for at starte ting, ingen ikoner at arrangere på skrivebordet. Apps starter fra en genvejstast (`Super + Return` til terminalen, `Super + Shift + Return` til browseren og `Super + K` til en liste over alt, hvad der er bundet) eller fra menuen. Det ene vedvarende stykke UI er [menulinjen](05-the-top-bar.md), som dækker det, menulinjen, systembakken og Notifikationscenter gjorde for dig før — og næsten alle widgets på den gør noget ved venstre-, højre- og midterklik.

### Vinduer placerer sig selv

Det største tankesæt-skifte: du trækker ikke vinduer rundt eller snapper dem til skærmhalvdele. Åbn et vindue, og det fylder hele skærmen. Åbn et mere, og de deler den. Du fisker aldrig et vindue frem under et andet, fordi vinduer ikke overlapper.

Når du virkelig har brug for et flydende vindue, skifter `Super + T` det aktive vindue ud af fliselægningen (og tilbage igen). Men giv fliselægningen en reel chance først — det er hjertet i det hele. [Navigation](04-navigation.md) fører dig igennem det.

Arbejdsområder vil føles velkendte: de er macOS Spaces eller virtuelle skriveborde i Windows, bortset fra at du rent faktisk vil bruge dem, fordi `Super + 1/2/3/4` hopper direkte til ét, og `Super + Shift + 1/2/3/4` sender det aktive vindue derhen. Ingen animationsforsinkelse, bare øjeblikkelige hop. Det betyder, at du måske ikke engang har brug for flere skærme, hvis du var vant til det før.

### Kopiér og indsæt virker bare

På Mac'en havde du Cmd + C overalt. På Windows havde du Ctrl + C overalt — undtagen i terminalen, hvor den dræber dit program. Omarchy giver dig `Super + C`, `Super + X` og `Super + V`, og de virker overalt, inklusive i terminalen. Ingen særskilt refleks at lære til shell'en.

Windows-folk: jeres Win + V-udklipshistorik bor på `Super + Ctrl + V`, og den rummer billeder såvel som tekst. Se [samlet udklipsholder & historik](08-unified-clipboard-history.md).

### Oversættelsestabellen

| Du rækker ud efter | I Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-menu | `Super + Space` — Omarchy-menuen |
| AirDrop | LocalSend via `Super + Ctrl + S` — se [GUI'er](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — se [skærmbilleder & optagelse](12-screenshots-recording.md) |
| Notifikationscenter | Notifikationshistorik på `Super + Shift + Alt + ,` |
| Time Machine (til systemet) | Automatiske [systemøjebliksbilleder](47-system-snapshots.md) ved hver opdatering |
| App Store / at hente en installatør | _Installer_ i menuen eller `omarchy pkg add` — se [andre pakker](29-other-packages.md) |
| Systemindstillinger / Kontrolpanel | _Opsætning_ i menuen, som redigerer almindelige konfigurationsfiler — se [dotfiles](31-dotfiles.md) |

### Nogle ting er virkelig anderledes

Mange indstillinger bor i tekstfiler, du redigerer, ikke i paneler, du klikker dig igennem. Det lyder primitivt, indtil du indser, at det betyder, at hver eneste finjustering kan ses, kopieres til din næste maskine og lægges i versionsstyring. Menuen _Opsætning_ sender dig direkte ind i den rigtige fil og genstarter det, der skal genstartes, når du er færdig.

Opdateringer kommer gennem én kommando — _Opdater > Omarchy_ — som opdaterer selve Omarchy og alle pakker på systemet og tager et øjebliksbillede først. Ingen opdateringsprogrammer pr. app, der plager dig på må og få. Se [opdateringer](30-updates.md).

Software kommer fra en pakkehåndtering, ikke fra hentede installatører.

Og når du lukker et vindue, afsluttes programmet rent faktisk. Der er ingen macOS-limbo, hvor programmet bliver ved med at køre uden vinduer. `Super + W` — eller `Super + Q`, hvis det er den fingerhukommelse, du ankom med — betyder væk.

### På Mac-hardware

Omarchy kører godt på Intel-Mac'er — se [Mac-understøttelse](44-mac-support.md). Og tastaturet er venligt mod dig: Omarchy ombinder ingenting, og Linux behandler Command-tasten som Super, så Super sidder lige der, hvor Cmd altid var. Din tommelfinger vil ikke bemærke flytningen.

### Giv det to uger

Instinkterne overføres hurtigere, end du skulle tro. Skum kapitlet om [genvejstaster](07-hotkeys.md) én gang, og når du ikke kan huske en binding, så tryk på `Super + K` — den viser dig dem alle. Det er den eneste genvejstast, du rent faktisk skal huske udenad.
