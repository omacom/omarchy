# GUI:er

## Files

Files (Nautilus) är den grafiska filhanteraren. `Super + Shift + F` öppnar den, och `Super + Shift + Alt + F` öppnar den i den katalog din terminal befinner sig i, vilket sparar mycket klickande. `Ctrl + L` låter dig skriva en sökväg, och att trycka `Space` på valfri fil ger dig en snabb förhandsvisning utan att öppna något.

Anslut ett USB-minne eller ett SD-kort så monteras det automatiskt, så att det bara dyker upp i sidofältet. För något mer involverat — formatera en enhet, kontrollera SMART-hälsa, skapa partitioner — starta _Disks_ från app-launchern (`Super + Space`).

Dubbelklick följer förnuftiga standarder: bilder öppnas i imv, video i mpv, PDF:er i Document Viewer och ren text i Neovim.

## Disktree

När disken fylls på och du inte har en aning om vad som äter upp den kan du starta [Disktree](https://github.com/tobi/disktree) från app-launchern (`Super + Space`). Den visar en grafisk treemap av din hemkatalog. Större block tar mer plats; gå in i kataloger med tangentbordet eller musen, markera vad som ska bort och granska dina val innan du tar bort något. Kör `disktree --disk` för att skanna hela disken.

## Obsidian

[Obsidian](https://obsidian.md/) är en gratis och mycket utbyggbar anteckningsapplikation som använder enkla Markdown-filer för lagring.

Obsidian är gratis för alla ändamål, inklusive personlig, kommersiell och ideell användning.

Obsidian erbjuder också ett [kommersiellt tillägg för synkronisering](https://obsidian.md/sync) med mobilappar på iOS och Android. (https://obsidian.md/pricing).

Du startar Obsidian med `Super + Shift + O`. För att använda temasynk måste du välja temat `Omarchy` under inställningar.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) är Omarchys egen dödsenkla Markdown-skrivapp. Inga vaults, inga plugins, bara du och orden.

Du startar Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) är ett grundläggande bildredigeringsverktyg som är utmärkt för beskärning, storleksändring och andra grundläggande manipuleringar. Förvänta dig bara inte ett Photoshop-alternativ. Men det har fortfarande en Magic Wand och lager!

Du startar Pinta via app-launchern (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) är en temaapplikation som kan extrahera färger från en bakgrundsbild och förvandla dem till ett komplett, sammanhängande tema. Det är det enklaste sättet att [göra ditt eget tema](43-making-your-own-theme.md).

Du startar Aether via app-launchern (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) låter dig skicka filer till andra enheter på samma nätverk som kör appen, som Apples AirDrop. Den är dock plattformsoberoende, så du kan skicka filer till och från Windows, macOS, Android, iOS och förstås Linux.

Du kan öppna menyn Dela på `Super + Ctrl + S` eller under _Utlös > Dela_ i Omarchy-menyn. Den ger dig fyra alternativ:

- **Urklipp** skickar det du har kopierat som en textfil. Utmärkt för att få en länk eller ett utdrag till din telefon utan att mejla dig själv.
- **Fil** öppnar en filväljare där du kan välja flera samtidigt.
- **Mapp** skickar en hel katalog.
- **Ta emot** öppnar själva LocalSend så att en annan enhet kan skicka något till dig.

Samma sak fungerar från terminalen med `omarchy share clipboard`, `omarchy share file [path]` och `omarchy share folder [path]`. Utelämna sökvägen så får du väljaren.

Du kan också skicka direkt från filhanteraren: högerklicka på en markering i Nautilus och välj _Send via LocalSend_.

Omarchys brandvägg är stängd som standard förutom LocalSends port, så det här fungerar direkt på en färsk installation. Se [säkerhet](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) är ett komplett kontorspaket med ordbehandlare, kalkylblad, presentationer, ritprogram och mer. Det är kompatibelt med filer från Microsoft Office, så det här är ett utmärkt sätt att kunna öppna de där Word-dokumenten.

Du startar LibreOffice via app-launchern (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) är Omarchys egen dödsenkla presentationsapp. Din presentation är en enda Markdown-fil med sina bilder och videor bredvid den: skriv varje bild nedanför en liveförhandsvisning, dra bilderna i ordning, presentera sedan i helskärm eller exportera till PDF och PowerPoint. Den plockar till och med upp ditt Omarchy-tema.

Du startar Hype via app-launchern (`Super + Space`). Tryck `?` inne i den för att se varje genväg.

## Signed

[Signed](https://github.com/omacom/signed) är Omarchys eget dödsenkla sätt att signera PDF:er och fylla i dem. Placera din sparade signatur, text och dagens datum var som helst på en sida, spara sedan en signerad kopia bredvid originalet. Se [Fylla i PDF:er](27-filling-out-pdfs.md) för hur.

Du startar Signed via app-launchern (`Super + Space`), eller öppna en PDF med det från filhanteraren.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) är Omarchys egen dödsenkla miniräknare, som öppnas i ett flytande fönster.

Du startar Omacalc med `Super + Ctrl + Q` (eller kalkylatortangenten, om ditt tangentbord har en sådan).

## Signal

[Signal](https://signal.org/) är pionjären inom E2E-krypterade meddelanden, och ett utmärkt kommunikationsalternativ för alla som hellre inte går via en av de stora techjättarna.

Du startar Signal med `Super + Shift + G`. Det är inte en del av basinstallationen, så första gången du trycker på det kommer Omarchy att erbjuda sig att installera det åt dig (det finns också under _Installera > Service_ i Omarchy-menyn).

## mpv

[mpv](https://mpv.io/) är en enkel, snabb mediespelare som spelar upp nästan vad som helst från vilken källa som helst. Utmärkt för att titta på videor.

Du startar mpv via app-launchern (`Super + Space`) eller dubbelklickar bara på en video i filhanteraren.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) är Omarchys egen dödsenkla videotrimmare. När allt du behöver är att klippa bort början och slutet av ett klipp slår den att starta en full videoredigerare.

Du startar Omacut via app-launchern (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) är Omarchys egen dödsenkla webbkamerainspelare. Välj din kamera och mikrofon en gång, tryck sedan `Space` för att spela in, och igen för att pausa och återuppta samma tagning. Den spelar alltid in med din kameras högsta upplösning, med en live-mikrofonmätare så att du kan kontrollera dina nivåer innan du börjar.

Stoppa tagningen så öppnas den direkt i en inbyggd editor. Dubbelklicka på ett klipp för att dela det, dra handtagen för att trimma varje bit, och ta bort de delar du inte vill ha. Spara den sedan som en MP4. Din originalinspelning bevaras tills du kasserar den, så du kan alltid komma tillbaka och klippa den annorlunda.

Du startar Monologue via app-launchern (`Super + Space`).
