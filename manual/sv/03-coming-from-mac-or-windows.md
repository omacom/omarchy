# Kommer du från Mac eller Windows

Om du har tillbringat år på macOS eller Windows har dina fingrar lärt sig hundra saker som din hjärna har glömt att den någonsin lärde sig. Det här kapitlet är översättningsskiktet: vart de instinkterna tar vägen i Omarchy. Själva funktionerna beskrivs på djupet på andra ställen — det här är bara kartan.

### Super är centrum för allt

Allt muskelminne du har byggt upp kring Cmd eller Windows-tangenten överförs till en enda tangent: Super. Det är Windows-tangenten på ett PC-tangentbord, och det är ankaret för nästan varje snabbtangent i Omarchy.

Din Spotlight-, Raycast- eller Start-menyreflex blir `Super + Space`. Det öppnar Omarchy-menyn, som startar appar, ändrar inställningar, installerar programvara, tar skärmbilder — i stort sett allt. Börja skriva för att filtrera. `Super + Alt + Space` visar varje app i ett enda rutnät, på samma sätt som Launchpad gör. Se [navigering](04-navigation.md).

### Inga skrivbordsikoner, och dockan dyker bara upp när du flyter

Inga ikoner att arrangera på skrivbordet, och ingen docka på en arbetsyta med tiling — dockan dyker bara upp på en flytande arbetsyta (se [navigering](04-navigation.md)). Appar startar från en snabbtangent (`Super + Return` för terminalen, `Super + Shift + Return` för webbläsaren och `Super + K` för en lista över allt som är mappat) eller från menyn. Den enda bestående delen av gränssnittet är [toppanelen](05-the-top-bar.md), som täcker in det som menyraden, systemfältet och Notification Center gjorde för dig tidigare — och nästan varje widget på den gör något vid vänster-, höger- och mittenklick.

### Fönster placerar sig själva

Det största tankeskiftet: du drar inte runt fönster eller fäster dem vid skärmhalvor. Öppna ett fönster och det tar upp hela skärmen. Öppna ett andra och de delar på den. Du fiskar aldrig fram ett fönster under ett annat, eftersom fönster inte överlappar varandra.

När du verkligen behöver ett flytande fönster växlar `Super + T` ut det aktiva ur tilingen (och tillbaka). Men ge tilingen en riktig chans först — det är hjärtat i alltihop. [Navigering](04-navigation.md) går igenom det med dig.

Arbetsytor kommer att kännas bekanta: de är macOS Spaces eller virtuella skrivbord i Windows, förutom att du faktiskt kommer att använda dem, eftersom `Super + 1/2/3/4` hoppar rakt till en och `Super + Shift + 1/2/3/4` skickar det aktiva fönstret dit. Ingen animationsfördröjning, bara omedelbara hopp. Det betyder att du kanske inte ens behöver flera skärmar, om du var van vid det tidigare.

### Kopiera och klistra in bara fungerar

På Mac hade du Cmd + C överallt. På Windows hade du Ctrl + C överallt — utom i terminalen, där det dödar ditt program. Omarchy ger dig `Super + C`, `Super + X` och `Super + V`, och de fungerar överallt, även i terminalen. Ingen separat reflex att lära sig för skalet.

Ni från Windows: er Win + V-historik för urklipp finns på `Super + Ctrl + V`, och den rymmer bilder såväl som text. Se [enhetligt urklipp & historik](08-unified-clipboard-history.md).

### Översättningstabellen

| Det du letar efter | I Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy-menyn |
| AirDrop | LocalSend, via `Super + Ctrl + S` — se [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eller `Print Screen` — se [skärmbilder & inspelning](12-screenshots-recording.md) |
| Notification Center | Aviseringshistorik på `Super + Shift + Alt + ,` |
| Time Machine (för systemet) | Automatiska [systemögonblicksbilder](47-system-snapshots.md) vid varje uppdatering |
| App Store / att ladda ner ett installationsprogram | _Install_ i menyn, eller `omarchy pkg add` — se [andra paket](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ i menyn, som redigerar vanliga konfigurationsfiler — se [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, på `Super + Shift + F` — se [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome på `Super + Shift + Return`; välj en annan under _Setup > Defaults > Browser_ — se [webbläsare](23-browsers.md) |
| Preview / Photos | Omaview för bilder, video och musik, Document Viewer för PDF:er — se [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, på `Super + Shift + N`; välj en annan under _Setup > Defaults > Editor_ |

### Vissa saker är faktiskt annorlunda

Många inställningar bor i textfiler som du redigerar, inte i paneler du klickar dig igenom. Det låter primitivt tills du inser att det betyder att varje justering kan ses, kopieras till din nästa maskin och läggas i versionshantering. _Setup_-menyn släpper dig rakt in i rätt fil och startar om det som behöver startas om när du är klar.

Uppdateringar kommer genom ett enda kommando — _Update > Omarchy_ — som uppdaterar själva Omarchy och varje paket på systemet, och tar en ögonblicksbild först. Inga uppdaterare för enskilda appar som gnäller på dig vid slumpmässiga tillfällen. Se [uppdateringar](30-updates.md).

Programvara kommer från en pakethanterare, inte från nedladdade installationsprogram.

Och när du stänger ett fönster avslutas appen faktiskt. Det finns inget macOS-limbo där programmet fortsätter att köra utan några fönster. `Super + W` — eller `Super + Q`, om det är det fingerminnet du kom med — betyder borta.

### På Mac-hårdvara

Omarchy körs bra på Intel-Macar — se [Mac-stöd](44-mac-support.md). Och tangentbordet är snällt mot dig: Omarchy mappar inte om någonting, och Linux behandlar Command-tangenten som Super, så Super sitter precis där Cmd alltid satt. Din tumme kommer inte att märka flytten.

### Ge det två veckor

Instinkterna överförs snabbare än du tror. Skumma igenom kapitlet om [snabbtangenter](07-hotkeys.md) en gång, och närhelst du står tom på en bindning, tryck på `Super + K` — den visar dig alla. Det är den enda snabbtangenten du faktiskt måste memorera.
