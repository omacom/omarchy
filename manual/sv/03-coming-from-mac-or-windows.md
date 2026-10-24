# Kommer från Mac eller Windows

Om du har tillbringat år på macOS eller Windows känner dina fingrar till hundra saker som din hjärna har glömt att den någonsin lärt sig. Det här kapitlet är översättningslagret: vart de instinkterna tar vägen i Omarchy. Funktionerna i sig behandlas på djupet på andra ställen — det här är bara kartan.

### Super är centrum för allt

All muskelminne du har byggt upp kring Cmd eller Windows-tangenten överförs till en tangent: Super. Det är Windows-tangenten på ett PC-tangentbord, och den är ankaret för nästan varje snabbtangent i Omarchy.

Din Spotlight- eller Raycast- eller Start-menyreflex blir `Super + Space`. Det öppnar Omarchy-menyn, som startar appar, ändrar inställningar, installerar programvara, fångar skärmen — i stort sett allt. Börja skriva för att filtrera. `Super + Alt + Space` visar varje app på ett rutnät, så som Launchpad gör. Se [navigering](04-navigation.md).

### Det finns ingen docka och inga skrivbordsikoner

Inget att klicka på för att starta saker, inga ikoner att arrangera på skrivbordet. Appar startar från en snabbtangent (`Super + Return` för terminalen, `Super + Shift + Return` för webbläsaren och `Super + K` för en lista över allt som är mappat) eller från menyn. Den enda bestående delen av användargränssnittet är [menyfältet](05-the-top-bar.md), som täcker det som menyraden, systemfältet och Notiscenter gjorde för dig förut — och nästan varje widget på det gör något vid vänster-, höger- och mittenklick.

### Fönster placerar sig själva

Det största tankeskiftet: du drar inte runt fönster eller fäster dem vid skärmhalvor. Öppna ett fönster och det tar hela skärmen. Öppna ett andra och de delar den. Du fiskar aldrig fram ett fönster under ett annat, eftersom fönster inte överlappar.

När du verkligen behöver ett flytande fönster växlar `Super + T` det aktiva fönstret ur kaklingen (och tillbaka). Men ge kaklingen en riktig chans först — den är hjärtat i hela grejen. [Navigering](04-navigation.md) går igenom det.

Arbetsytor kommer att kännas bekanta: de är macOS Spaces eller Windows virtuella skrivbord, förutom att du faktiskt kommer att använda dem, eftersom `Super + 1/2/3/4` hoppar direkt till en och `Super + Shift + 1/2/3/4` skickar det aktiva fönstret dit. Ingen animationsfördröjning, bara omedelbara hopp. Det betyder att du kanske inte ens behöver flera skärmar, om du var van vid det förut.

### Kopiera och klistra in fungerar bara

På Macen hade du Cmd + C överallt. På Windows hade du Ctrl + C överallt — förutom i terminalen, där det dödar ditt program. Omarchy ger dig `Super + C`, `Super + X` och `Super + V`, och de fungerar överallt, inklusive i terminalen. Ingen separat reflex att lära sig för skalet.

Windows-användare: din Win + V-urklippshistorik bor på `Super + Ctrl + V`, och den innehåller bilder såväl som text. Se [enhetligt urklipp & historik](08-unified-clipboard-history.md).

### Översättningstabellen

| Du sträcker dig efter | I Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-menyn | `Super + Space` — Omarchy-menyn |
| AirDrop | LocalSend, via `Super + Ctrl + S` — se [GUI:er](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — se [skärmbilder & inspelning](12-screenshots-recording.md) |
| Notiscenter | Aviseringshistorik på `Super + Shift + Alt + ,` |
| Time Machine (för systemet) | Automatiska [systemsnapshot](47-system-snapshots.md) vid varje uppdatering |
| App Store / ladda ner en installatör | _Install_ i menyn, eller `omarchy pkg add` — se [andra paket](29-other-packages.md) |
| Systeminställningar / Kontrollpanelen | _Setup_ i menyn, som redigerar enkla konfigurationsfiler — se [dotfiles](31-dotfiles.md) |

### Vissa saker är verkligen annorlunda

Många inställningar bor i textfiler du redigerar, inte paneler du klickar dig igenom. Det låter primitivt tills du inser att det betyder att varje justering kan ses, kopieras till din nästa maskin och läggas i versionskontroll. Menyn _Setup_ släpper dig rakt in i rätt fil och startar om vad som än behöver startas om när du är klar.

Uppdateringar kommer genom ett kommando — _Update > Omarchy_ — som uppdaterar Omarchy själv och varje paket på systemet, och tar ett snapshot först. Inga uppdaterare per app som tjatar på dig slumpmässigt. Se [uppdateringar](30-updates.md).

Programvara kommer från en pakethanterare, inte från nedladdade installatörer.

Och när du stänger ett fönster avslutas appen faktiskt. Det finns inget macOS-limbo där programmet fortsätter att köras utan några fönster. `Super + W` — eller `Super + Q`, om det är fingerminnet du kom med — betyder borta.

### På Mac-hårdvara

Omarchy körs bra på Intel-Macar — se [Mac-stöd](44-mac-support.md). Och tangentbordet är snällt mot dig: Omarchy mappar inte om någonting, och Linux behandlar Command-tangenten som Super, så Super sitter precis där Cmd alltid var. Din tumme kommer inte att märka flytten.

### Ge det två veckor

Instinkterna överförs snabbare än du tror. Skumma kapitlet om [snabbtangenter](07-hotkeys.md) en gång, och när du än står blank inför en bindning, tryck på `Super + K` — den visar dig alla. Det är den enda snabbtangenten du faktiskt måste memorera.
