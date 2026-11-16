# GUI'er

## Filer

Filer (Nautilus) er den grafiske filhåndtering. `Super + Shift + F` åbner den, og `Super + Shift + Alt + F` åbner den i den mappe, dit terminalvindue står i, hvilket sparer en masse klik. `Ctrl + L` lader dig indtaste en sti, og et tryk på `Space` på en hvilken som helst fil giver dig et hurtigt kig uden at åbne noget.

Sæt en USB-nøgle eller et SD-kort i, så monteres det automatisk og dukker bare op i sidebjælken. Til noget mere avanceret — formatering af et drev, kontrol af SMART-tilstand, oprettelse af partitioner — start _Disks_ fra appstarteren (`Super + Space`).

Dobbeltklik følger fornuftige standarder: billeder, videoer og musik åbnes i Omaview, PDF'er i Document Viewer, Markdown i Omawrite og almindelig tekst i den editor, der er valgt under _Setup > Default > Editor_.

## Disktree

Når drevet fyldes op, og du ikke aner, hvad der sluger pladsen, så start [Disktree](https://github.com/tobi/disktree) fra appstarteren (`Super + Space`). Den viser et grafisk trækort over din hjemmemappe. Større blokke fylder mere; gå ind i mapper med tastaturet eller musen, markér det, der skal væk, og gennemse dine valg, før du fjerner noget. Kør `disktree --disk` for at scanne hele disken.

## Obsidian

[Obsidian](https://obsidian.md/) er en gratis og meget udvidbar noteapp, der bruger simple Markdown-filer til opbevaring.

Obsidian er gratis til alle formål, herunder privat, kommerciel og nonprofitbrug.

Obsidian tilbyder også en [kommerciel tilføjelse til synkronisering](https://obsidian.md/sync) med mobilapps på iOS og Android. (https://obsidian.md/pricing).

Du starter Obsidian med `Super + Shift + O`. For at bruge temasyncronisering skal du vælge temaet `Omarchy` under indstillinger.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er Omarchys egen dødssimple app til at skrive Markdown. Ingen bokse, ingen plugins, bare dig og ordene.

Du starter Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er et grundlæggende billedredigeringsværktøj, der er perfekt til beskæring, ændring af størrelse og andre grundlæggende manipulationer. Forvent bare ikke et Photoshop-alternativ. Men den har stadig en Magic Wand og lag!

Du starter Pinta via appstarteren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er en temaapp, der kan udtrække farver fra et baggrundsbillede og gøre dem til et komplet, sammenhængende tema. Det er den nemmeste måde at [lave dit eget tema](43-making-your-own-theme.md) på.

Du starter Aether via appstarteren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lader dig sende filer til andre enheder på samme netværk, der kører appen, ligesom Apples AirDrop. Den er dog på tværs af platforme, så du kan sende filer til og fra Windows, macOS, Android, iOS og selvfølgelig Linux.

Du kan åbne menuen Share på `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menuen. Den giver dig fire muligheder:

- **Clipboard** sender det, du har kopieret, som en tekstfil. Perfekt til at få et link eller et kodestykke over på din telefon uden at sende en e-mail til dig selv.
- **File** åbner en filvælger, hvor du kan vælge flere på én gang.
- **Folder** sender en hel mappe.
- **Receive** åbner LocalSend rigtigt, så en anden enhed kan sende noget til dig.

Det samme virker fra terminalen med `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Udelad stien, så får du vælgeren.

Du kan også sende direkte fra filhåndteringen: højreklik på et valg i Nautilus og vælg _Send via LocalSend_.

Omarchys firewall er lukket som standard undtagen for LocalSends port, så det virker lige ud af boksen på en frisk installation. Se [sikkerhed](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er en komplet kontorpakke med tekstbehandling, regneark, præsentationer, tegneprogram og meget mere. Den er kompatibel med filer fra Microsoft Office, så det er en fantastisk måde at kunne åbne de Word-dokumenter på.

Du starter LibreOffice via appstarteren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er Omarchys egen dødssimple præsentationsapp. Dit oplæg er en enkelt Markdown-fil med dens billeder og videoer ved siden af den: skriv hvert dias under en live forhåndsvisning, træk dias ind i rækkefølge, og præsentér derefter i fuldskærm eller eksportér til PDF og PowerPoint. Den bruger endda dit Omarchy-tema.

Du starter Hype via appstarteren (`Super + Space`). Tryk på `?` inde i den for at se alle genveje.

## Signed

[Signed](https://github.com/omacom/signed) er Omarchys egen dødssimple måde at underskrive PDF'er og udfylde dem på. Sæt din gemte underskrift, tekst og dagens dato hvor som helst på en side, og gem derefter en underskrevet kopi ved siden af originalen. Se [Udfyldning af PDF'er](27-filling-out-pdfs.md) for hvordan.

Du starter Signed via appstarteren (`Super + Space`), eller åbner en PDF med den fra filhåndteringen.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er Omarchys egen dødssimple lommeregner, som åbnes i et flydende vindue.

Du starter Omacalc med `Super + Shift + Q` (eller lommeregnertasten, hvis dit tastatur har en).

## Signal

[Signal](https://signal.org/) er pioneren inden for E2E-krypteret beskedudveksling og en fantastisk kommunikationsmulighed for alle, der helst ikke vil gå gennem en af de store techgiganter.

Du starter Signal med `Super + Shift + G`. Den er ikke en del af basisinstallationen, så første gang du bruger genvejen, tilbyder Omarchy at installere den for dig (den findes også under _Install > Service_ i Omarchy-menuen).

## Omaview

[Omaview](https://github.com/omacom/omaview) er Omarchys egen dødssimple billedfremviser og medieafspiller: ét vindue til dine fotos, videoer og musik. Åbn et foto, og piletasterne går gennem resten af dets mappe, `N` og `P` gør det samme for alt, og `Ctrl + M` viser hele mappen som et gitter. Den viser også HEIC-, AVIF- og JPEG XL-fotos og fortsætter, hvor du slap, i alt, der er langt.

Tryk på `F` for fuldskærm, `E` for at redigere et billede i Omasnap eller trimme en video i Omacut, `Ctrl + P` for at udskrive et billede og `Delete` for at flytte en fil til papirkurven (`Ctrl + Z` henter den tilbage). Tryk på `?` inde i den for at se alle genveje.

Du starter Omaview som _Media Viewer_ via appstarteren (`Super + Space`), eller dobbeltklikker bare på et billede, en video eller en sang i filhåndteringen.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er Omarchys egen dødssimple videotrimmer. Når alt, du har brug for, er at klippe starten og slutningen af et klip, slår den at fyre et fuldt videoredigeringsprogram op.

Du starter Omacut via appstarteren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er Omarchys egen dødssimple webcameoptager. Vælg dit kamera og din mikrofon én gang, og tryk derefter på `Space` for at optage og igen for at sætte den samme optagelse på pause og genoptage den. Den optager altid i dit kameras højeste opløsning med en live mikrofonmåler, så du kan tjekke dine niveauer, før du starter.

Stop optagelsen, så åbner den med det samme i en indbygget editor. Dobbeltklik på et klip for at dele det, træk i håndtagene for at trimme hvert stykke, og fjern de dele, du ikke vil have. Gem det derefter som en MP4. Din oprindelige optagelse gemmes, indtil du kasserer den, så du altid kan vende tilbage og klippe den anderledes.

Du starter Monologue via appstarteren (`Super + Space`).
