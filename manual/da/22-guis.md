# GUI'er

## Filer

Filer (Nautilus) er den grafiske filhåndtering. `Super + Shift + F` åbner den, og `Super + Shift + Alt + F` åbner den i den mappe, din terminal befinder sig i, hvilket sparer en masse klik. Med `Ctrl + L` kan du indtaste en sti, og hvis du trykker på `Space` på en fil, får du en hurtig forhåndsvisning uden at åbne noget.

Sæt et USB-stik eller et SD-kort i, og det monteres automatisk, så det bare dukker op i sidebjælken. Til alt, der er mere indviklet — formatering af et drev, kontrol af SMART-tilstand, oprettelse af partitioner — skal du starte _Disks_ fra appstarteren (`Super + Space`).

Dobbeltklik følger fornuftige standarder: billeder, videoer og musik åbnes i Omaview, PDF'er i Document Viewer, Markdown i Omawrite og almindelig tekst i den editor, der er valgt under _Setup > Default > Editor_.

## Disktree

Når drevet fyldes op, og du ikke aner, hvad der æder pladsen, så start [Disktree](https://github.com/tobi/disktree) fra appstarteren (`Super + Space`). Den viser et grafisk treemap over din hjemmemappe. Større blokke fylder mere; gå ind i mapper med tastaturet eller musen, markér det, der skal væk, og gennemse dine valg, før du fjerner noget. Kør `disktree --disk` for at scanne hele disken.

## Obsidian

[Obsidian](https://obsidian.md/) er et gratis noteprogram, der kan udvides i høj grad, og som bruger enkle Markdown-filer til lagring.

Obsidian er gratis til alle formål, herunder personlig, kommerciel og almennyttig brug.

Obsidian tilbyder også et [kommercielt tillæg til synkronisering](https://obsidian.md/sync) med mobilapps på iOS og Android. (https://obsidian.md/pricing).

Du starter Obsidian med `Super + Shift + O`. For at bruge temasyncronisering skal du vælge temaet `Omarchy` under indstillinger.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er Omarchys egen dødsimple Markdown-skriveapp. Ingen vaults, ingen plugins, bare dig og ordene.

Du starter Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er et grundlæggende billedredigeringsværktøj, der er godt til beskæring, ændring af størrelse og andre grundlæggende ændringer. Forvent bare ikke et Photoshop-alternativ. Men det har stadig en Magic Wand og lag!

Du starter Pinta via appstarteren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er en temaapp, der kan udtrække farver fra et baggrundsbillede og forvandle dem til et komplet, sammenhængende tema. Det er den nemmeste måde at [lave dit eget tema](43-making-your-own-theme.md) på.

Du starter Aether via appstarteren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lader dig sende filer til andre enheder på samme netværk, der kører appen, ligesom Apples AirDrop. Det er dog på tværs af platforme, så du kan sende filer til og fra Windows, macOS, Android, iOS og selvfølgelig Linux.

Du kan åbne menuen Share med `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menuen. Den giver dig fire muligheder:

- **Clipboard** sender det, du har kopieret, som en tekstfil. Perfekt til at få et link eller et uddrag over på din telefon uden at sende en e-mail til dig selv.
- **File** åbner en filvælger, hvor du kan vælge flere på én gang.
- **Folder** sender en hel mappe.
- **Receive** åbner selve LocalSend, så en anden enhed kan sende noget til dig.

Det samme virker fra terminalen med `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Undlad at angive stien, og du får vælgeren.

Du kan også sende direkte fra filhåndteringen: højreklik på en markering i Nautilus og vælg _Send via LocalSend_.

Omarchys firewall er som standard lukket undtagen for LocalSends port, så det virker ud af boksen på en frisk installation. Se [sikkerhed](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er en komplet kontorpakke med tekstbehandling, regneark, præsentationer, tegneprogram og mere. Den er kompatibel med filer fra Microsoft Office, så det er en god måde at kunne åbne de Word-dokumenter på.

Du starter LibreOffice via appstarteren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er Omarchys egen dødsimple præsentationsapp. Dit deck er en enkelt Markdown-fil med sine billeder og videoer ved siden af: skriv hvert slide under en live-forhåndsvisning, træk slides på plads i rækkefølge, og præsentér derefter i fuldskærm eller eksportér til PDF og PowerPoint. Den bruger endda dit Omarchy-tema.

Du starter Hype via appstarteren (`Super + Space`). Tryk på `?` inde i den for at se alle genveje.

## Signed

[Signed](https://github.com/omacom/signed) er Omarchys egen dødsimple måde at underskrive PDF'er og udfylde dem på. Placér din gemte underskrift, tekst og dags dato hvor som helst på en side, og gem derefter en underskrevet kopi ved siden af originalen. Se [Udfyldning af PDF'er](27-filling-out-pdfs.md) for at se hvordan.

Du starter Signed via appstarteren (`Super + Space`), eller åbn en PDF med den fra filhåndteringen.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) er Omarchys eget 3D-skakspil. Spil mod en ven på samme computer eller den indbyggede modstander på tre niveauer, på fire udformede sæt, der hver bevæger sig på deres egen måde: fartøjer i kredsløb, udskåret træ og elfenben, skovens dyr og slik. Partier har ingen tidtagning og gemmes efter hvert træk.

Du starter Checkmate via appstarteren (`Super + Space`), hvor den er angivet som Chess. Tryk på `?` inde i den for at se alle genveje.

## Cards

[Cards](https://github.com/omacom/cards) er Omarchys egen Klondike-kabale. Træk tre, uden begrænsning på gennemgange, i fire kortserier: én tegnet i dit temas farver og tre med deres eget udtryk. Klik på et kort og derefter på det sted, hvor det skal hen, træk det, eller dobbeltklik for at sende det til det bedste sted. Spil gemmes efter hvert træk.

Du starter Cards via appstarteren (`Super + Space`). Klik på dens navn, eller tryk på `?`, for at se alle genveje.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er Omarchys egen dødsimple lommeregner, som åbnes i et svævende vindue.

Du starter Omacalc med `Super + Shift + Q` (eller lommeregnertasten, hvis dit tastatur har en).

## Signal

[Signal](https://signal.org/) er pioneren inden for E2E-krypterede beskeder og en god kommunikationsmulighed for alle, der foretrækker ikke at gå gennem en af de store techgiganter.

Du starter Signal med `Super + Shift + G`. Den er ikke en del af basisinstallationen, så første gang du trykker på det, tilbyder Omarchy at installere den for dig (den findes også under _Install > Service_ i Omarchy-menuen).

## Omaview

[Omaview](https://github.com/omacom/omaview) er Omarchys egen dødsimple billedfremviser og medieafspiller: ét vindue til dine fotos, videoer og din musik. Åbn et foto, og piletasterne går gennem resten af dets mappe, `N` og `P` gør det for alt, og `Ctrl + M` viser hele mappen som et gitter. Den viser også HEIC-, AVIF- og JPEG XL-fotos og fortsætter, hvor du slap, i alt, der er langt.

Tryk på `F` for fuldskærm, `E` for at redigere et billede i Omasnap eller trimme en video i Omacut, `Ctrl + P` for at udskrive et billede og `Delete` for at flytte en fil til papirkurven (`Ctrl + Z` henter den tilbage). Tryk på `?` inde i den for at se alle genveje.

Du starter Omaview som _Media Viewer_ via appstarteren (`Super + Space`), eller dobbeltklik bare på et billede, en video eller en sang i filhåndteringen.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er Omarchys egen dødsimple videotrimmer. Når alt, du har brug for, er at klippe starten og slutningen af et klip, er det bedre end at fyre op under et komplet videoredigeringsprogram.

Du starter Omacut via appstarteren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er Omarchys egen dødsimple webkameraoptager. Vælg dit kamera og din mikrofon én gang, og tryk derefter på `Space` for at optage og igen for at sætte på pause og genoptage samme optagelse. Den optager altid i dit kameras højeste opløsning med en live-mikrofonmåler, så du kan tjekke dine niveauer, før du starter.

Stop optagelsen, og den åbnes med det samme i en indbygget editor. Dobbeltklik på et klip for at dele det, træk i håndtagene for at trimme hvert stykke, og fjern de dele, du ikke vil have. Gem det derefter som en MP4. Din oprindelige optagelse bevares, indtil du kasserer den, så du altid kan komme tilbage og klippe den på en anden måde.

Du starter Monologue via appstarteren (`Super + Space`).
