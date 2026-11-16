# Grafiska program

## Files

Files (Nautilus) är den grafiska filhanteraren. `Super + Shift + F` öppnar den, och `Super + Shift + Alt + F` öppnar den i den katalog som din terminal befinner sig i, vilket sparar en massa klickande. `Ctrl + L` låter dig skriva en sökväg, och att trycka på `Space` på en fil ger dig en snabb förhandsgranskning utan att öppna något.

Anslut ett USB-minne eller ett SD-kort så monteras det automatiskt, så det bara dyker upp i sidofältet. För något mer avancerat — att formatera en enhet, kontrollera SMART-hälsa, skapa partitioner — starta _Disks_ från programstartaren (`Super + Space`).

Dubbelklick följer vettiga standardval: bilder, videor och musik öppnas i Omaview, PDF:er i Document Viewer, Markdown i Omawrite och vanlig text i redigeraren som valts under _Setup > Default > Editor_.

## Disktree

När enheten fylls upp och du inte har en aning om vad som äter upp den, starta [Disktree](https://github.com/tobi/disktree) från programstartaren (`Super + Space`). Den visar en grafisk träkarta över din hemkatalog. Större block tar upp mer utrymme; gå in i kataloger med tangentbordet eller musen, markera vad som ska bort och granska dina val innan du tar bort något. Kör `disktree --disk` för att skanna hela disken.

## Obsidian

[Obsidian](https://obsidian.md/) är ett gratis och i hög grad utbyggbart anteckningsprogram som använder enkla Markdown-filer för lagring.

Obsidian är gratis för alla ändamål, inklusive personlig, kommersiell och ideell användning.

Obsidian erbjuder också ett [kommersiellt tillägg för synkronisering](https://obsidian.md/sync) med mobilappar på iOS och Android. (https://obsidian.md/pricing).

Du startar Obsidian med `Super + Shift + O`. För att använda temasynkronisering måste du välja temat `Omarchy` under inställningarna.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) är Omarchys egen busenkla app för Markdown-skrivande. Inga valv, inga insticksmoduler, bara du och orden.

Du startar Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) är ett enkelt bildredigeringsverktyg som är bra för att beskära, ändra storlek och andra grundläggande manipulationer. Förvänta dig bara inte ett alternativ till Photoshop. Men den har fortfarande Magic Wand och lager!

Du startar Pinta via programstartaren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) är ett temaprogram som kan extrahera färger från en bakgrundsbild och förvandla dem till ett komplett, sammanhängande tema. Det är det enklaste sättet att [göra ditt eget tema](43-making-your-own-theme.md).

Du startar Aether via programstartaren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) låter dig skicka filer till andra enheter i samma nätverk som kör appen, som Apples AirDrop. Den är dock plattformsoberoende, så du kan skicka filer till och från Windows, macOS, Android, iOS och såklart Linux.

Du kan öppna Share-menyn med `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menyn. Den ger dig fyra alternativ:

- **Clipboard** skickar vad du än har kopierat som en textfil. Perfekt för att få över en länk eller ett kodstycke till telefonen utan att mejla dig själv.
- **File** öppnar en filväljare där du kan välja flera samtidigt.
- **Folder** skickar en hel katalog.
- **Receive** öppnar LocalSend på riktigt så att en annan enhet kan skicka något till dig.

Samma sak fungerar från terminalen med `omarchy share clipboard`, `omarchy share file [path]` och `omarchy share folder [path]`. Utelämna sökvägen så får du väljaren.

Du kan också skicka direkt från filhanteraren: högerklicka på ett urval i Nautilus och välj _Send via LocalSend_.

Omarchys brandvägg är stängd som standard förutom för LocalSends port, så det här fungerar direkt på en ny installation. Se [säkerhet](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) är ett komplett kontorspaket med ordbehandlare, kalkylprogram, presentationer, ritprogram och mer. Det är kompatibelt med filer från Microsoft Office, så det här är ett utmärkt sätt att kunna öppna de där Word-dokumenten.

Du startar LibreOffice via programstartaren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) är Omarchys eget busenkla presentationsprogram. Din presentation är en enda Markdown-fil med dess bilder och videor bredvid den: skriv varje sida nedanför en direktförhandsgranskning, dra sidorna i ordning och presentera sedan i helskärm eller exportera till PDF och PowerPoint. Den tar till och med över ditt Omarchy-tema.

Du startar Hype via programstartaren (`Super + Space`). Tryck på `?` inuti den för att se alla kortkommandon.

## Signed

[Signed](https://github.com/omacom/signed) är Omarchys eget busenkla sätt att signera PDF:er och fylla i dem. Placera din sparade signatur, text och dagens datum var som helst på en sida och spara sedan en signerad kopia bredvid originalet. Se [Fylla i PDF:er](27-filling-out-pdfs.md) för hur du gör.

Du startar Signed via programstartaren (`Super + Space`), eller öppnar en PDF med den från filhanteraren.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) är Omarchys eget 3D-schackspel. Spela mot en vän på samma dator eller den inbyggda motståndaren på tre nivåer, på fyra skulpterade uppsättningar som var och en rör sig på sitt eget sätt: farkoster i omloppsbana, snidat trä och elfenben, skogsvarelser och godis. Partierna har ingen klocka och sparas efter varje drag.

Du startar Checkmate via programstartaren (`Super + Space`). Tryck på `?` inuti det för att se alla kortkommandon.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) är Omarchys egen busenkla miniräknare, som öppnas i ett flytande fönster.

Du startar Omacalc med `Super + Shift + Q` (eller miniräknartangenten, om ditt tangentbord har en).

## Signal

[Signal](https://signal.org/) är pionjären inom E2E-krypterade meddelanden och ett utmärkt kommunikationsalternativ för alla som föredrar att inte gå via något av de stora teknikkonglomeraten.

Du startar Signal med `Super + Shift + G`. Den ingår inte i grundinstallationen, så första gången du trycker på den kommer Omarchy att erbjuda sig att installera den åt dig (den finns också under _Install > Service_ i Omarchy-menyn).

## Omaview

[Omaview](https://github.com/omacom/omaview) är Omarchys egen busenkla bildvisare och mediaspelare: ett fönster för dina foton, videor och din musik. Öppna ett foto så stegar piltangenterna genom resten av dess mapp, `N` och `P` gör det för vad som helst, och `Ctrl + M` visar hela mappen som ett rutnät. Den visar också HEIC-, AVIF- och JPEG XL-foton, och fortsätter där du slutade med allt långt innehåll.

Tryck på `F` för helskärm, `E` för att redigera en bild i Omasnap eller trimma en video i Omacut, `Ctrl + P` för att skriva ut en bild och `Delete` för att flytta en fil till papperskorgen (`Ctrl + Z` tar tillbaka den). Tryck på `?` inuti den för att se alla kortkommandon.

Du startar Omaview som _Media Viewer_ via programstartaren (`Super + Space`), eller dubbelklickar bara på en bild, en video eller en låt i filhanteraren.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) är Omarchys eget busenkla videotrimmningsprogram. När allt du behöver är att klippa bort början och slutet av ett klipp slår det att starta en fullfjädrad videoredigerare.

Du startar Omacut via programstartaren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) är Omarchys egen busenkla webbkamerainspelare. Välj din kamera och mikrofon en gång, tryck sedan på `Space` för att spela in, och igen för att pausa och återuppta samma tagning. Den spelar alltid in med din kameras högsta upplösning, med en direkt mikrofonmätare så att du kan kontrollera dina nivåer innan du börjar.

Stoppa tagningen så öppnas den direkt i en inbyggd redigerare. Dubbelklicka på ett klipp för att dela det, dra i handtagen för att trimma varje del och ta bort de delar du inte vill ha. Spara det sedan som en MP4. Din ursprungliga inspelning behålls tills du kastar den, så du kan alltid komma tillbaka och klippa den annorlunda.

Du startar Monologue via programstartaren (`Super + Space`).
