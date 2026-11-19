# Grafiska program

## Filer

Filer (Nautilus) är den grafiska filhanteraren. `Super + Shift + F` öppnar den, och `Super + Shift + Alt + F` öppnar den i den katalog som terminalen befinner sig i, vilket sparar en massa klickande. Med `Ctrl + L` kan du skriva en sökväg, och trycker du på `Space` på en fil får du en snabb förhandsgranskning utan att öppna något.

Anslut ett USB-minne eller ett SD-kort så monteras det automatiskt och dyker helt enkelt upp i sidofältet. För allt mer avancerat — formatera en enhet, kontrollera SMART-hälsa, skapa partitioner — startar du _Disks_ från appstartaren (`Super + Space`).

Dubbelklick följer vettiga standardval: bilder, videor och musik öppnas i Omaview, PDF:er i Document Viewer, Markdown i Omawrite och vanlig text i den redigerare som valts under _Setup > Default > Editor_.

## Disktree

När enheten fylls upp och du inte har en aning om vad som äter upp den startar du [Disktree](https://github.com/tobi/disktree) från appstartaren (`Super + Space`). Den visar en grafisk trädkarta över din hemkatalog. Större block tar upp mer plats; gå in i kataloger med tangentbordet eller musen, markera det som ska bort och granska dina val innan du tar bort något. Kör `disktree --disk` för att skanna hela disken.

## Obsidian

[Obsidian](https://obsidian.md/) är en gratis och mycket utbyggbar anteckningsapp som använder enkla Markdown-filer för lagring.

Obsidian är gratis för alla ändamål, inklusive personlig, kommersiell och ideell användning.

Obsidian erbjuder också ett [kommersiellt tillägg för synkronisering](https://obsidian.md/sync) med mobilappar på iOS och Android. (https://obsidian.md/pricing).

Du startar Obsidian med `Super + Shift + O`. För att använda temasynkronisering måste du välja temat `Omarchy` under inställningarna.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) är Omarchys egen busenkla Markdown-skrivapp. Inga valv, inga insticksprogram, bara du och orden.

Du startar Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) är ett grundläggande bildredigeringsverktyg som är utmärkt för beskärning, storleksändring och andra grundläggande ändringar. Förvänta dig bara inte ett alternativ till Photoshop. Men den har ändå en Magic Wand och lager!

Du startar Pinta via appstartaren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) är en temaapp som kan extrahera färger från en bakgrundsbild och förvandla dem till ett komplett, sammanhållet tema. Det är det enklaste sättet att [skapa ditt eget tema](43-making-your-own-theme.md).

Du startar Aether via appstartaren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) låter dig skicka filer till andra enheter på samma nätverk som kör appen, som Apples AirDrop. Den fungerar dessutom över flera plattformar, så du kan skicka filer till och från Windows, macOS, Android, iOS och såklart Linux.

Du kan öppna Share-menyn med `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menyn. Den ger dig fyra alternativ:

- **Clipboard** skickar det du har kopierat som en textfil. Perfekt för att få över en länk eller ett textstycke till telefonen utan att mejla dig själv.
- **File** öppnar en filväljare där du kan välja flera på en gång.
- **Folder** skickar en hel katalog.
- **Receive** öppnar LocalSend på riktigt så att en annan enhet kan skicka något till dig.

Samma sak fungerar från terminalen med `omarchy share clipboard`, `omarchy share file [path]` och `omarchy share folder [path]`. Uteslut sökvägen så får du filväljaren.

Du kan också skicka direkt från filhanteraren: högerklicka på ett urval i Nautilus och välj _Send via LocalSend_.

Omarchys brandvägg är stängd som standard förutom för LocalSends port, så detta fungerar direkt från start på en ny installation. Se [säkerhet](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) är ett komplett kontorspaket med ordbehandlare, kalkylblad, presentationer, ritprogram och mer. Det är kompatibelt med filer från Microsoft Office, så det är ett utmärkt sätt att kunna öppna de där Word-dokumenten.

Du startar LibreOffice via appstartaren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) är Omarchys egen busenkla presentationsapp. Din presentation är en enda Markdown-fil med sina bilder och videor bredvid den: skriv varje presentationsbild under en liveförhandsgranskning, dra presentationsbilderna i rätt ordning, presentera sedan i helskärm eller exportera till PDF och PowerPoint. Den plockar till och med upp ditt Omarchy-tema.

Du startar Hype via appstartaren (`Super + Space`). Tryck på `?` inuti den för att se alla kortkommandon.

## Signed

[Signed](https://github.com/omacom/signed) är Omarchys eget busenkla sätt att signera PDF:er och fylla i dem. Placera din sparade signatur, text och dagens datum var som helst på en sida och spara sedan en signerad kopia bredvid originalet. Se [Fylla i PDF:er](27-filling-out-pdfs.md) för hur du gör.

Du startar Signed via appstartaren (`Super + Space`), eller öppnar en PDF med den från filhanteraren.

## Game Vibes

Game Vibes, i appstartaren (`Super + Space`), är där Omarchys små spel bor: Checkmate, ett 3D-schackspel mot en vän eller den inbyggda motståndaren; Cards, Klondike-patiens; och Neon Swarm, ett arkadskjutspel. Varje spel är en enda webbsida som följer ditt tema. Välj ett med piltangenterna och `Enter`, och kom tillbaka till listan med `Esc` från ett spels titelskärm eller `Q` medan det är pausat. Det öppnas i helskärm: `Super + F` gör det till ett fönster, och `Super + W` stänger det.

De spel du skapar med en agent dyker också upp här: välj _Make something cool → Game_ i agentpanelen och beskriv ett, eller namnge ett spel som redan finns i Game Vibes för att fortsätta arbeta på det. Agenten kopierar det till `~/Games/vibes`, där det är ditt att ändra, och öppnar det när det är klart. Du kan göra den kopian själv med `omarchy games vibes copy <game>`. Ett spel som någon annan delar installeras som ett tema: välj _Install > Gaming > Game Vibes_ och klistra in dess git-adress, eller kör `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ tar bort ett igen, och _Update > Game Vibes Games_ hämtar nya versioner. Spel laddar three.js från webben, så de behöver en anslutning för att starta.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) är Omarchys egen busenkla miniräknare, som öppnas i ett flytande fönster.

Du startar Omacalc med `Super + Shift + Q` (eller miniräknarknappen, om ditt tangentbord har en sådan).

## Signal

[Signal](https://signal.org/) är pionjären för E2E-krypterade meddelanden, och ett utmärkt kommunikationsalternativ för alla som föredrar att inte gå via någon av de stora techjättarna.

Du startar Signal med `Super + Shift + G`. Den ingår inte i grundinstallationen, så första gången du trycker på det erbjuder Omarchy att installera den åt dig (den finns också under _Install > Service_ i Omarchy-menyn).

## Omaview

[Omaview](https://github.com/omacom/omaview) är Omarchys egen busenkla bildvisare och mediaspelare: ett fönster för dina foton, videor och din musik. Öppna ett foto så stegar piltangenterna genom resten av dess mapp, `N` och `P` gör det för allt, och `Ctrl + M` visar hela mappen som ett rutnät. Den visar också HEIC-, AVIF- och JPEG XL-foton, och fortsätter där du slutade i allt långt.

Tryck på `F` för helskärm, `E` för att redigera en bild i Omasnap eller trimma en video i Omacut, `Ctrl + P` för att skriva ut en bild, och `Delete` för att flytta en fil till Papperskorgen (`Ctrl + Z` tar tillbaka den). Tryck på `?` inuti den för att se alla kortkommandon.

Du startar Omaview som _Media Viewer_ via appstartaren (`Super + Space`), eller dubbelklickar bara på en bild, video eller låt i filhanteraren.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) är Omarchys egen busenkla videotrimmare. När allt du behöver är att klippa bort början och slutet på ett klipp slår den att dra igång en fullfjädrad videoredigerare.

Du startar Omacut via appstartaren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) är Omarchys egen busenkla webbkamerainspelare. Välj din kamera och mikrofon en gång, tryck sedan på `Space` för att spela in, och igen för att pausa och återuppta samma tagning. Den spelar alltid in med kamerans högsta upplösning, med en live-mikrofonmätare så att du kan kontrollera dina nivåer innan du börjar.

Stoppa tagningen så öppnas den direkt i en inbyggd redigerare. Dubbelklicka på ett klipp för att dela det, dra i handtagen för att trimma varje del och ta bort de delar du inte vill ha. Spara det sedan som en MP4. Din originalinspelning sparas tills du kasserar den, så du kan alltid komma tillbaka och klippa den annorlunda.

Du startar Monologue via appstartaren (`Super + Space`).
