# GUI'er

## Files

Files (Nautilus) er den grafiske filhåndtering. `Super + Shift + F` åbner den, og `Super + Shift + Alt + F` åbner den i den mappe, din terminal befinder sig i, hvilket sparer en masse klik. `Ctrl + L` lader dig indtaste en sti, og et tryk på `Space` på en hvilken som helst fil giver dig en hurtig forhåndsvisning uden at åbne noget.

Sæt et USB-stik eller et SD-kort i, og det monteres automatisk, så det bare dukker op i sidebjælken. Til alt det mere indviklede — formatering af et drev, kontrol af SMART-tilstand, oprettelse af partitioner — skal du starte _Disks_ fra programstarteren (`Super + Space`).

Dobbeltklik følger fornuftige standarder: billeder, videoer og musik åbnes i Omaview, PDF'er i Document Viewer og almindelig tekst i Neovim.

## Disktree

Når drevet fyldes op, og du ikke aner, hvad der æder pladsen, skal du starte [Disktree](https://github.com/tobi/disktree) fra programstarteren (`Super + Space`). Den viser et grafisk treemap over din hjemmemappe. Større blokke fylder mere; gå ind i mapper med tastaturet eller musen, markér det, der skal væk, og gennemse dine valg, før du fjerner noget som helst. Kør `disktree --disk` for at scanne hele disken.

## Obsidian

[Obsidian](https://obsidian.md/) er en gratis og meget udvidbar noteapp, der bruger enkle Markdown-filer til lagring.

Obsidian er gratis til alle formål, herunder personlig, kommerciel og nonprofit-brug.

Obsidian tilbyder også en [kommerciel tilføjelse til synkronisering](https://obsidian.md/sync) med mobilapps på iOS og Android. (https://obsidian.md/pricing).

Du starter Obsidian med `Super + Shift + O`. For at bruge temasykronisering skal du vælge temaet `Omarchy` under indstillinger.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er Omarchys egen dødsimple Markdown-skriveapp. Ingen vaults, ingen plugins, kun dig og ordene.

Du starter Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er et grundlæggende billedredigeringsværktøj, der er godt til beskæring, ændring af størrelse og andre grundlæggende manipulationer. Forvent bare ikke et Photoshop-alternativ. Men den har stadig Magic Wand og lag!

Du starter Pinta via programstarteren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er en temaapp, der kan udtrække farver fra et baggrundsbillede og forvandle dem til et komplet, sammenhængende tema. Det er den nemmeste måde at [lave dit eget tema](43-making-your-own-theme.md) på.

Du starter Aether via programstarteren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lader dig sende filer til andre enheder på det samme netværk, der kører appen, ligesom Apples AirDrop. Den er dog på tværs af platforme, så du kan sende filer til og fra Windows, macOS, Android, iOS og selvfølgelig Linux.

Du kan åbne menuen Share på `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menuen. Den giver dig fire muligheder:

- **Clipboard** sender det, du har kopieret, som en tekstfil. Perfekt til at få et link eller et uddrag over på din telefon uden at sende en e-mail til dig selv.
- **File** åbner en filvælger, hvor du kan vælge flere på én gang.
- **Folder** sender en hel mappe.
- **Receive** åbner selve LocalSend, så en anden enhed kan sende noget til dig.

Det samme virker fra terminalen med `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Udelad stien, og du får vælgeren.

Du kan også sende direkte fra filhåndteringen: højreklik på et hvilket som helst valg i Nautilus, og vælg _Send via LocalSend_.

Omarchys firewall er som standard lukket, undtagen for LocalSends port, så dette virker ud af boksen på en frisk installation. Se [sikkerhed](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er en komplet kontorpakke med tekstbehandling, regneark, præsentationer, tegneprogram og meget mere. Den er kompatibel med filer fra Microsoft Office, så det er en fantastisk måde at kunne åbne de Word-dokumenter på.

Du starter LibreOffice via programstarteren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er Omarchys egen dødsimple præsentationsapp. Din præsentation er en enkelt Markdown-fil med dens billeder og videoer ved siden af: skriv hvert slide under en direkte forhåndsvisning, træk slides i rækkefølge, og præsentér derefter i fuldskærm eller eksportér til PDF og PowerPoint. Den opfanger endda dit Omarchy-tema.

Du starter Hype via programstarteren (`Super + Space`). Tryk på `?` inde i den for at se alle genveje.

## Signed

[Signed](https://github.com/omacom/signed) er Omarchys egen dødsimple måde at underskrive PDF'er og udfylde dem på. Placér din gemte signatur, tekst og dags dato hvor som helst på en side, og gem derefter en underskrevet kopi ved siden af originalen. Se [Udfyldning af PDF'er](27-filling-out-pdfs.md) for at se hvordan.

Du starter Signed via programstarteren (`Super + Space`) eller åbner en PDF med den fra filhåndteringen.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er Omarchys egen dødsimple lommeregner, som åbner i et flydende vindue.

Du starter Omacalc med `Super + Shift + Q` (eller lommeregnertasten, hvis dit tastatur har en).

## Signal

[Signal](https://signal.org/) er pioneren inden for E2E-krypteret beskeder og en fantastisk kommunikationsmulighed for alle, der helst vil undgå en af de store techgiganter.

Du starter Signal med `Super + Shift + G`. Den er ikke en del af basisinstallationen, så første gang du trykker på den, tilbyder Omarchy at installere den for dig (den findes også under _Install > Service_ i Omarchy-menuen).

## Omaview

[Omaview](https://github.com/omacom/omaview) er Omarchys egen dødsimple billedfremviser og medieafspiller: ét vindue til dine fotos, videoer og musik. Åbn et foto, og piletasterne går gennem resten af dets mappe, `N` og `P` gør det for alting, og `Ctrl + M` viser hele mappen som et gitter. Den viser også HEIC-, AVIF- og JPEG XL-fotos og fortsætter, hvor du slap, i alt hvad der er langt.

Tryk på `F` for fuldskærm, `E` for at redigere et billede i Omasnap eller trimme en video i Omacut, `Ctrl + P` for at udskrive et billede og `Delete` for at flytte en fil til papirkurven (`Ctrl + Z` henter den tilbage). Tryk på `?` inde i den for at se alle genveje.

Du starter Omaview som _Media Viewer_ via programstarteren (`Super + Space`) eller dobbeltklikker bare på et billede, en video eller en sang i filhåndteringen.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er Omarchys egen dødsimple videotrimmer. Når alt, du har brug for, er at klippe starten og slutningen af et klip, slår den at fyre op under et komplet videoredigeringsprogram.

Du starter Omacut via programstarteren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er Omarchys egen dødsimple webkameraoptager. Vælg dit kamera og din mikrofon én gang, tryk derefter på `Space` for at optage og igen for at sætte den samme optagelse på pause og genoptage den. Den optager altid i dit kameras højeste opløsning med en direkte mikrofonmåler, så du kan kontrollere dine niveauer, før du går i gang.

Stop optagelsen, og den åbner med det samme i en indbygget editor. Dobbeltklik på et klip for at dele det, træk i håndtagene for at trimme hvert stykke, og fjern de dele, du ikke vil have. Gem det derefter som en MP4. Din originale optagelse bevares, indtil du kasserer den, så du altid kan vende tilbage og klippe den anderledes.

Du starter Monologue via programstarteren (`Super + Space`).
