# Kommer du från Mac eller Windows

Om du har tillbringat åratal på macOS eller Windows vet dina fingrar hundra saker som din hjärna har glömt att den någonsin har lärt sig. Det här kapitlet är översättningsskiktet: var de instinkterna hör hemma i Omarchy. Funktionerna i sig beskrivs på djupet på andra ställen — det här är bara kartan.

### Super är centrum för allt

Allt muskelminne som du har byggt upp kring Cmd eller Windows-tangenten överförs till en enda tangent: Super. Det är Windows-tangenten på ett PC-tangentbord, och den är ankaret för nästan varje snabbtangent i Omarchy.

Din reflex för Spotlight, Raycast eller Start-menyn blir `Super + Space`. Det öppnar Omarchy-menyn, som startar appar, ändrar inställningar, installerar programvara och tar skärmbilder — i stort sett allt. Börja skriva för att filtrera. `Super + Alt + Space` visar varje app i ett enda rutnät, på samma sätt som Launchpad gör. Se [navigering](04-navigation.md).

### Det finns ingen docka och inga skrivbordsikoner

Inget att klicka på för att starta saker, inga ikoner att arrangera på skrivbordet. Appar startar från en snabbtangent (`Super + Return` för terminalen, `Super + Shift + Return` för webbläsaren och `Super + K` för en lista över allt som är mappat) eller från menyn. Den enda bestående delen av gränssnittet är [den övre listen](05-the-top-bar.md), som täcker det som menyraden, systemfältet och Notiscenter gjorde för dig tidigare — och nästan varje widget på den gör något vid vänster-, höger- och mittenklick.

### Fönster placerar sig själva

Det största tankeskiftet: du drar inte runt fönster eller fäster dem vid ena halvan av skärmen. Öppna ett fönster och det tar hela skärmen. Öppna ett andra och de delar på den. Du behöver aldrig fiska fram ett fönster under ett annat, eftersom fönster inte överlappar varandra.

När du verkligen behöver ett flytande fönster växlar `Super + T` det aktiva fönstret ut ur rutläggningen (och tillbaka igen). Men ge rutläggningen en riktig chans först — det är hjärtat i hela grejen. [Navigering](04-navigation.md) leder dig igenom det.

Arbetsytor kommer att kännas bekanta: de är macOS Spaces eller virtuella skrivbord i Windows, förutom att du faktiskt kommer att använda dem, eftersom `Super + 1/2/3/4` hoppar direkt till en av dem och `Super + Shift + 1/2/3/4` skickar det aktiva fönstret dit. Ingen animationsfördröjning, bara omedelbara hopp. Det betyder att du kanske inte ens behöver flera bildskärmar, om du var van vid det tidigare.

### Kopiera och klistra in bara fungerar

På Mac hade du Cmd + C överallt. På Windows hade du Ctrl + C överallt — utom i terminalen, där det dödar ditt program. Omarchy ger dig `Super + C`, `Super + X` och `Super + V`, och de fungerar överallt, inklusive i terminalen. Ingen separat reflex att lära sig för skalet.

Ni som kommer från Windows: er urklippshistorik med Win + V bor på `Super + Ctrl + V`, och den rymmer bilder såväl som text. Se [enhetligt urklipp och historik](08-unified-clipboard-history.md).

### Översättningstabellen

| Du sträcker dig efter | I Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start-menyn | `Super + Space` — Omarchy-menyn |
| AirDrop | LocalSend, via `Super + Ctrl + S` — se [GUI:er](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` eller `Print Screen` — se [skärmbilder och inspelning](12-screenshots-recording.md) |
| Notiscenter | Notishistorik på `Super + Shift + Alt + ,` |
| Time Machine (för systemet) | Automatiska [systemögonblicksbilder](47-system-snapshots.md) vid varje uppdatering |
| App Store / att ladda ner ett installationsprogram | _Installera_ i menyn, eller `omarchy pkg add` — se [andra paket](29-other-packages.md) |
| Systeminställningar / Kontrollpanelen | _Konfigurera_ i menyn, som redigerar vanliga konfigurationsfiler — se [dotfiles](31-dotfiles.md) |

### Vissa saker är verkligen annorlunda

Många inställningar bor i textfiler som du redigerar, inte i paneler som du klickar dig igenom. Det låter primitivt tills du inser att det betyder att varje justering kan ses, kopieras till din nästa maskin och läggas under versionshantering. Menyn _Konfigurera_ släpper dig rakt in i rätt fil och startar om det som behöver startas om när du är klar.

Uppdateringar kommer via ett enda kommando — _Uppdatera > Omarchy_ — som uppdaterar själva Omarchy och varje paket på systemet, och tar en ögonblicksbild först. Inga uppdaterare för enskilda appar som tjatar på dig vid slumpmässiga tillfällen. Se [uppdateringar](30-updates.md).

Programvara kommer från en pakethanterare, inte från nedladdade installationsprogram.

Och när du stänger ett fönster avslutas appen faktiskt. Det finns inget macOS-limbo där programmet fortsätter att köra utan några fönster. `Super + W` — eller `Super + Q`, om det är det fingerminnet du kom hit med — betyder borta.

### På Mac-hårdvara

Omarchy körs bra på Intel-Macar — se [Mac-stöd](44-mac-support.md). Och tangentbordet är snällt mot dig: Omarchy mappar inte om någonting, och Linux behandlar Command-tangenten som Super, så Super sitter precis där Cmd alltid satt. Din tumme kommer inte att märka flytten.

### Ge det två veckor

Instinkterna överförs snabbare än du tror. Skumma igenom kapitlet [snabbtangenter](07-hotkeys.md) en gång, och när du står helt stilla inför en bindning trycker du på `Super + K` — den visar dig allihop. Det är den enda snabbtangenten du faktiskt måste memorera.
