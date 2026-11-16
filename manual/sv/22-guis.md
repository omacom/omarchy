# GUIs

## Files

Files (Nautilus) är den grafiska filhanteraren. `Super + Shift + F` öppnar den, och `Super + Shift + Alt + F` öppnar den i den katalog där din terminal befinner sig, vilket sparar en hel del klickande. `Ctrl + L` låter dig skriva en sökväg, och om du trycker på `Space` på en fil får du en snabb förhandsvisning utan att öppna något.

Koppla in ett USB-minne eller ett SD-kort så monteras det automatiskt, så det dyker bara upp i sidofältet. För allt mer avancerat — formatera en disk, kontrollera SMART-hälsa, skapa partitioner — starta _Disks_ från appstartaren (`Super + Space`).

Dubbelklick följer vettiga standardval: bilder, videor och musik öppnas i Omaview, PDF:er i Document Viewer, Markdown i Omawrite och vanlig text i den redigerare som valts under _Setup > Default > Editor_.

## Disktree

När disken fylls på och du inte har en aning om vad som äter upp den, starta [Disktree](https://github.com/tobi/disktree) från appstartaren (`Super + Space`). Den visar en grafisk trädkarta över din hemkatalog. Större block tar upp mer utrymme; navigera in i kataloger med tangentbordet eller musen, markera det som ska bort och granska dina val innan du tar bort något. Kör `disktree --disk` för att skanna hela disken.

## Obsidian

[Obsidian](https://obsidian.md/) är en gratis och mycket utbyggbar anteckningsapp som använder enkla Markdown-filer för lagring.

Obsidian är gratis för alla ändamål, inklusive personligt, kommersiellt och ideellt bruk.

Obsidian erbjuder också ett [kommersiellt tillägg för synkronisering](https://obsidian.md/sync) med mobilappar på iOS och Android. (https://obsidian.md/pricing).

Du startar Obsidian med `Super + Shift + O`. För att använda temasynkronisering måste du välja temat `Omarchy` under inställningar.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) är Omarchys egen dödssimpla skrivapp för Markdown. Inga valv, inga insticksprogram, bara du och orden.

Du startar Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) är ett enkelt bildredigeringsverktyg som är utmärkt för att beskära, ändra storlek och andra grundläggande ändringar. Förvänta dig bara inte ett alternativ till Photoshop. Men den har ändå Magic Wand och lager!

Du startar Pinta via appstartaren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) är en temaapp som kan extrahera färger från en bakgrundsbild och förvandla dem till ett komplett, sammanhängande tema. Det är det enklaste sättet att [göra ditt eget tema](43-making-your-own-theme.md).

Du startar Aether via appstartaren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) låter dig skicka filer till andra enheter på samma nätverk som kör appen, som Apples AirDrop. Den är dock plattformsoberoende, så du kan skicka filer till och från Windows, macOS, Android, iOS och naturligtvis Linux.

Du kan öppna Share-menyn med `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menyn. Den ger dig fyra alternativ:

- **Clipboard** skickar det du har kopierat som en textfil. Utmärkt för att få över en länk eller ett stycke kod till telefonen utan att mejla dig själv.
- **File** öppnar en filväljare där du kan välja flera samtidigt.
- **Folder** skickar en hel katalog.
- **Receive** öppnar LocalSend på riktigt så att en annan enhet kan skicka något till dig.

Samma sak fungerar från terminalen med `omarchy share clipboard`, `omarchy share file [path]` och `omarchy share folder [path]`. Uteslut sökvägen så får du väljaren.

Du kan också skicka direkt från filhanteraren: högerklicka på valfritt urval i Nautilus och välj _Send via LocalSend_.

Omarchys brandvägg är stängd som standard förutom för LocalSends port, så det här fungerar direkt på en färsk installation. Se [säkerhet](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) är ett komplett kontorspaket med ordbehandlare, kalkylblad, presentationer, ritprogram och mer. Det är kompatibelt med filer från Microsoft Office, så det här är ett utmärkt sätt att kunna öppna de där Word-dokumenten.

Du startar LibreOffice via appstartaren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) är Omarchys egen dödssimpla presentationsapp. Din presentation är en enda Markdown-fil med sina bilder och videor bredvid sig: skriv varje presentationsbild under en liveförhandsvisning, dra presentationsbilderna i ordning och presentera sedan i helskärm eller exportera till PDF och PowerPoint. Den plockar till och med upp ditt Omarchy-tema.

Du startar Hype via appstartaren (`Super + Space`). Tryck på `?` inuti den för att se varje genväg.

## Signed

[Signed](https://github.com/omacom/signed) är Omarchys eget dödssimpla sätt att signera PDF:er och fylla i dem. Placera din sparade signatur, text och dagens datum var som helst på en sida och spara sedan en signerad kopia bredvid originalet. Se [Fylla i PDF:er](27-filling-out-pdfs.md) för hur du gör.

Du startar Signed via appstartaren (`Super + Space`), eller öppna en PDF med den från filhanteraren.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) är Omarchys eget schackspel i 3D. Spela mot en vän på samma dator eller mot den inbyggda motståndaren på tre nivåer, på fyra skulpterade uppsättningar som var och en rör sig på sitt eget sätt: rymdfarkoster i omloppsbana, snidat trä och elfenben, skogsvarelser och godis. Partierna har ingen klocka och sparas efter varje drag.

Du startar Checkmate via appstartaren (`Super + Space`), där den listas som Chess. Tryck på `?` inuti den för att se varje genväg.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) är Omarchys egen dödssimpla miniräknare, som öppnas i ett flytande fönster.

Du startar Omacalc med `Super + Shift + Q` (eller miniräknarknappen, om ditt tangentbord har en sådan).

## Signal

[Signal](https://signal.org/) är pionjären för E2E-krypterad meddelandehantering och ett utmärkt kommunikationsalternativ för alla som helst slipper gå via något av de stora techkonglomeraten.

Du startar Signal med `Super + Shift + G`. Den ingår inte i basinstallationen, så första gången du trycker på det kommer Omarchy att erbjuda sig att installera den åt dig (den finns också under _Install > Service_ i Omarchy-menyn).

## Omaview

[Omaview](https://github.com/omacom/omaview) är Omarchys egen dödssimpla bildvisare och mediaspelare: ett fönster för dina foton, videor och din musik. Öppna ett foto så stegar piltangenterna genom resten av dess mapp, `N` och `P` gör det för vad som helst, och `Ctrl + M` visar hela mappen som ett rutnät. Den visar också HEIC-, AVIF- och JPEG XL-foton och fortsätter där du slutade i allt som är långt.

Tryck på `F` för helskärm, `E` för att redigera en bild i Omasnap eller trimma en video i Omacut, `Ctrl + P` för att skriva ut en bild och `Delete` för att flytta en fil till Trash (`Ctrl + Z` tar tillbaka den). Tryck på `?` inuti den för att se varje genväg.

Du startar Omaview som _Media Viewer_ via appstartaren (`Super + Space`), eller dubbelklicka bara på en bild, en video eller en låt i filhanteraren.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) är Omarchys egen dödssimpla videotrimmare. När allt du behöver är att klippa bort början och slutet på ett klipp slår den att dra igång en fullfjädrad videoredigerare.

Du startar Omacut via appstartaren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) är Omarchys egen dödssimpla webbkamerainspelare. Välj din kamera och mikrofon en gång, tryck sedan på `Space` för att spela in och igen för att pausa och återuppta samma tagning. Den spelar alltid in i kamerans högsta upplösning, med en livemätare för mikrofonen så att du kan kontrollera dina nivåer innan du börjar.

Stoppa tagningen så öppnas den direkt i en inbyggd redigerare. Dubbelklicka på ett klipp för att dela det, dra i handtagen för att trimma varje del och ta bort de delar du inte vill ha. Spara den sedan som en MP4. Din originalinspelning behålls tills du kastar den, så du kan alltid komma tillbaka och klippa den annorlunda.

Du startar Monologue via appstartaren (`Super + Space`).
