# Grafiska program

## Filer

Filer (Nautilus) är den grafiska filhanteraren. `Super + Shift + F` öppnar den, och `Super + Shift + Alt + F` öppnar den i den katalog som din terminal står i, vilket sparar en hel del klickande. Med `Ctrl + L` kan du skriva in en sökväg, och om du trycker på `Space` på en fil får du en snabb förhandsvisning utan att öppna något.

Sätt i ett USB-minne eller ett SD-kort så monteras det automatiskt, så det dyker helt enkelt upp i sidofältet. För allt mer avancerat — formatera en enhet, kontrollera SMART-hälsan, skapa partitioner — startar du _Disks_ från programstartaren (`Super + Space`).

Dubbelklick följer vettiga standardval: bilder öppnas i imv, video i mpv, PDF:er i Document Viewer och ren text i Neovim.

## Disktree

När enheten fylls upp och du inte har en aning om vad som äter upp den startar du [Disktree](https://github.com/tobi/disktree) från programstartaren (`Super + Space`). Den visar en grafisk treemap över din hemkatalog. Större block tar upp mer utrymme; gå in i kataloger med tangentbordet eller musen, markera det som ska bort och granska dina val innan du tar bort något. Kör `disktree --disk` för att skanna hela disken.

## Obsidian

[Obsidian](https://obsidian.md/) är ett gratis och mycket utbyggbart anteckningsprogram som använder enkla Markdown-filer för lagring.

Obsidian är gratis för alla ändamål, inklusive personlig, kommersiell och ideell användning.

Obsidian erbjuder också ett [kommersiellt tillägg för synkronisering](https://obsidian.md/sync) med mobilappar på iOS och Android. (https://obsidian.md/pricing).

Du startar Obsidian med `Super + Shift + O`. För att använda tem synkronisering måste du välja temat `Omarchy` under inställningarna.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) är Omarchys eget busenkla skrivprogram för Markdown. Inga valv, inga plugins, bara du och orden.

Du startar Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) är ett enkelt bildredigeringsverktyg som är utmärkt för att beskära, ändra storlek och andra grundläggande ändringar. Förvänta dig bara inget alternativ till Photoshop. Men det har fortfarande en Magic Wand och lager!

Du startar Pinta via programstartaren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) är ett temaprogram som kan extrahera färger från en bakgrundsbild och förvandla dem till ett komplett, sammanhängande tema. Det är det enklaste sättet att [skapa ditt eget tema](43-making-your-own-theme.md).

Du startar Aether via programstartaren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) låter dig skicka filer till andra enheter på samma nätverk som kör appen, ungefär som Apples AirDrop. Det är dock plattformsoberoende, så du kan skicka filer till och från Windows, macOS, Android, iOS och naturligtvis Linux.

Du kan öppna Share-menyn med `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menyn. Den ger dig fyra alternativ:

- **Clipboard** skickar det du har kopierat som en textfil. Utmärkt för att få över en länk eller ett kodstycke till telefonen utan att mejla dig själv.
- **File** öppnar en filväljare där du kan välja flera filer samtidigt.
- **Folder** skickar en hel katalog.
- **Receive** öppnar LocalSend på riktigt så att en annan enhet kan skicka något till dig.

Samma sak fungerar från terminalen med `omarchy share clipboard`, `omarchy share file [path]` och `omarchy share folder [path]`. Utelämna sökvägen så får du väljaren.

Du kan också skicka direkt från filhanteraren: högerklicka på ett urval i Nautilus och välj _Send via LocalSend_.

Omarchys brandvägg är stängd som standard förutom för LocalSends port, så det här fungerar direkt på en ny installation. Se [säkerhet](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) är ett komplett kontorspaket med ordbehandlare, kalkylprogram, presentationer, ritprogram och mer. Det är kompatibelt med filer från Microsoft Office, så det här är ett utmärkt sätt att kunna öppna de där Word-dokumenten.

Du startar LibreOffice via programstartaren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) är Omarchys eget busenkla presentationsprogram. Ditt bildspel är en enda Markdown-fil med sina bilder och videor bredvid den: skriv varje bild under en liveförhandsvisning, dra bilderna i ordning och presentera sedan i helskärm eller exportera till PDF och PowerPoint. Det plockar till och med upp ditt Omarchy-tema.

Du startar Hype via programstartaren (`Super + Space`). Tryck på `?` i programmet för att se varje genväg.

## Signed

[Signed](https://github.com/omacom/signed) är Omarchys eget busenkla sätt att signera PDF:er och fylla i dem. Placera din sparade signatur, text och dagens datum var som helst på en sida och spara sedan en signerad kopia bredvid originalet. Se [Fylla i PDF:er](27-filling-out-pdfs.md) för att se hur.

Du startar Signed via programstartaren (`Super + Space`), eller öppnar en PDF med det från filhanteraren.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) är Omarchys egen busenkla miniräknare, som öppnas i ett flytande fönster.

Du startar Omacalc med `Super + Shift + Q` (eller miniräknarknappen, om ditt tangentbord har en sådan).

## Signal

[Signal](https://signal.org/) är pionjären inom E2E-krypterade meddelanden och ett utmärkt kommunikationsalternativ för alla som helst slipper gå via någon av de stora teknikkoncernerna.

Du startar Signal med `Super + Shift + G`. Det ingår inte i grundinstallationen, så första gången du trycker på den kombinationen erbjuder Omarchy att installera det åt dig (det finns också under _Install > Service_ i Omarchy-menyn).

## mpv

[mpv](https://mpv.io/) är en enkel, snabb mediaspelare som spelar nästan vad som helst från vilken källa som helst. Utmärkt för att titta på videor.

Du startar mpv via programstartaren (`Super + Space`) eller dubbelklickar bara på en video i filhanteraren.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) är Omarchys egen busenkla videotrimmare. När allt du behöver är att klippa bort början och slutet av ett klipp slår det att starta en fullfjädrad videoredigerare.

Du startar Omacut via programstartaren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) är Omarchys egen busenkla webbkamerainspelare. Välj din kamera och mikrofon en gång, tryck sedan på `Space` för att spela in och igen för att pausa och återuppta samma tagning. Den spelar alltid in med kamerans högsta upplösning, med en livemikrofonmätare så att du kan kontrollera nivåerna innan du börjar.

Stoppa tagningen så öppnas den direkt i en inbyggd redigerare. Dubbelklicka på ett klipp för att dela det, dra i handtagen för att trimma varje del och ta bort de delar du inte vill ha. Spara det sedan som en MP4. Din originalinspelning behålls tills du kastar den, så du kan alltid komma tillbaka och klippa den annorlunda.

Du startar Monologue via programstartaren (`Super + Space`).
