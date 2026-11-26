# Kommer du från Mac eller Windows

Om du har tillbringat år på macOS eller Windows känner dina fingrar hundra saker som din hjärna har glömt att den någonsin lärt sig. Det här kapitlet är översättningslagret: var de instinkterna hör hemma i Omarchy. Funktionerna själva gås igenom på djupet på andra ställen — det här är bara kartan.

### Super är centrum för allt

Allt muskelminne du har byggt upp kring Cmd eller Windows-tangenten flyttar över till en enda tangent: Super. Det är Windows-tangenten på ett PC-tangentbord, och den är ankaret för nästan varje snabbtangent i Omarchy.

Din reflex för Spotlight, Raycast eller Start-menyn blir `Super + Space`. Det öppnar Omarchy-menyn, som startar appar, ändrar inställningar, installerar programvara, tar skärmdumpar — i stort sett allt. Börja skriva för att filtrera. `Super + Alt + Space` visar alla appar på ett enda rutnät, precis som Launchpad gör. Se [navigering](04-navigation.md).

### Inga skrivbordsikoner, och dockan dyker bara upp när du flyter

Inga ikoner att arrangera på skrivbordet, och ingen docka på en arbetsyta med tiling — dockan dyker bara upp på en flytande arbetsyta (se [navigering](04-navigation.md)). Appar startar från en snabbtangent (`Super + Return` för terminalen, `Super + Shift + Return` för webbläsaren och `Super + K` för en lista över allt som är mappat) eller från menyn. Den enda bestående delen av gränssnittet är [toppanelen](05-the-top-bar.md), som täcker det som menyraden, systemfältet och Notification Center gjorde för dig tidigare — och nästan varje widget på den gör något vid vänster-, höger- och mittenklick.

### Fönstren placerar sig själva

Den största mentala omställningen: du drar inte runt fönster och fäster dem inte vid skärmhalvor. Öppna ett fönster och det tar hela skärmen. Öppna ett till och de delar på den. Du fiskar aldrig fram ett fönster under ett annat, eftersom fönster inte överlappar varandra.

När du verkligen behöver ett flytande fönster växlar `Super + T` det aktiva fönstret ut ur tilingen (och tillbaka). Men ge tilingen en riktig chans först — den är hjärtat i alltihop. [Navigering](04-navigation.md) går igenom det.

Arbetsytor kommer att kännas bekanta: de är macOS Spaces eller Windows virtuella skrivbord, med den skillnaden att du faktiskt kommer att använda dem, eftersom `Super + 1/2/3/4` hoppar rakt till en och `Super + Shift + 1/2/3/4` skickar det aktiva fönstret dit. Ingen fördröjning från animationer, bara omedelbara hopp. Det här betyder att du kanske inte ens behöver flera skärmar, om du var van vid det tidigare.

### Kopiera och klistra in fungerar bara

På Mac hade du Cmd + C överallt. På Windows hade du Ctrl + C överallt — utom i terminalen, där det dödar ditt program. Omarchy ger dig `Super + C`, `Super + X` och `Super + V`, och de fungerar överallt, även i terminalen. Ingen separat reflex att lära sig för skalet.

Ni som kommer från Windows: er urklippshistorik från Win + V finns på `Super + Ctrl + V`, och den rymmer både bilder och text. Se [enat urklipp och historik](08-unified-clipboard-history.md).

### Översättningstabellen

| Du letar efter | I Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy-menyn |
| AirDrop | LocalSend, via `Super + Ctrl + S` — se [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eller `Print Screen` — se [skärmbilder och inspelning](12-screenshots-recording.md) |
| Notification Center | Meddelandehistorik på `Super + Shift + Alt + ,` |
| Time Machine (för systemet) | Automatiska [systemögonblicksbilder](47-system-snapshots.md) vid varje uppdatering |
| App Store / downloading an installer | _Install_ i menyn, eller `omarchy pkg add` — se [andra paket](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ i menyn, som redigerar vanliga konfigurationsfiler — se [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, på `Super + Shift + F` — se [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome på `Super + Shift + Return`; välj en annan under _Setup > Defaults > Browser_ — se [webbläsare](23-browsers.md) |
| Preview / Photos | Omaview för bilder, video och musik, Document Viewer för PDF:er — se [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, på `Super + Shift + N`; välj en annan under _Setup > Defaults > Editor_ |

### Vissa saker är faktiskt annorlunda

Många inställningar bor i textfiler du redigerar, inte i paneler du klickar dig igenom. Det låter primitivt tills du inser att det betyder att varje justering kan ses, kopieras till din nästa maskin och läggas i versionshantering. _Setup_-menyn släpper dig rakt ner i rätt fil och startar om det som behöver startas om när du är klar.

Uppdateringar kommer via ett enda kommando — _Update > Omarchy_ — som uppdaterar själva Omarchy och varje paket på systemet, och tar en ögonblicksbild först. Inga separata uppdaterare per app som tjatar på dig vid slumpmässiga tillfällen. Se [uppdateringar](30-updates.md).

Programvara kommer från en pakethanterare, inte från nedladdade installationsprogram.

Och när du stänger ett fönster avslutas appen faktiskt. Det finns inget macOS-limbo där programmet fortsätter att köra utan några fönster. `Super + W` — eller `Super + Q`, om det är den fingerreflexen du kom med — betyder borta.

### På Mac-hårdvara

Omarchy kör bra på Intel-Macar, och på M1-, M2- och M3-Macar med Omarchy för Apple Silicon. Se [Mac-stöd](44-mac-support.md). Och tangentbordet är snällt mot dig: Omarchy mappar inte om någonting, och Linux behandlar Command-tangenten som Super, så Super sitter precis där Cmd alltid satt. Din tumme kommer inte att märka flytten.

### Ge det två veckor

Instinkterna flyttar över snabbare än du tror. Skumma igenom kapitlet om [snabbtangenter](07-hotkeys.md) en gång, och när du får blackout på en bindning trycker du på `Super + K` — den visar dig allihop. Det är den enda snabbtangenten du faktiskt måste memorera.
