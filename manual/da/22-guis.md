# GUI'er

## Filer

Filer (Folio) er den grafiske filhåndtering. `Super + Shift + F` åbner den, og `Super + Shift + Alt + F` åbner den i den mappe, din terminal befinder sig i, hvilket sparer en masse klik. `Ctrl + L` lader dig indtaste en sti, og hvis du trykker på `Space` på en fil, får du en forhåndsvisning af den i fuld størrelse uden at åbne den.

Sæt en USB-nøgle eller et SD-kort i, og det monteres automatisk, så det bare vises i sidepanelet. Til alt, der er mere indviklet — formatering af et drev, kontrol af SMART-tilstand, oprettelse af partitioner — skal du starte _Disks_ fra appstarteren (`Super + Space`).

Et krypteret drev beder om sin adgangskode, når det tilsluttes. Hvis et drev skal låse sig selv op, skal du tilføje en nøglefil til det med `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` og lægge den nøglefil i `~/.config/omarchy/drive-keys/<UUID>`, navngivet efter den UUID, som `lsblk -dno UUID /dev/sdX1` udskriver for den krypterede partition, og kun læsbar for dig (`chmod 600`). Hvis den nøglefil mangler eller afvises, bliver du bedt om adgangskoden som sædvanlig.

Dobbeltklik følger fornuftige standardindstillinger: billeder, videoer og musik åbnes i Omaview, PDF'er i Document Viewer, Markdown i Omawrite og almindelig tekst i din editor, Plain, medmindre du vælger en anden under _Setup > Defaults > Editor_.

## Disktree

Når drevet fyldes op, og du ikke aner, hvad der æder pladsen, skal du starte [Disktree](https://github.com/tobi/disktree) fra appstarteren (`Super + Space`). Den viser et grafisk treemap over din hjemmemappe. Større blokke fylder mere; gå ind i mapper med tastaturet eller musen, markér det, der skal væk, og gennemse dine valg, før du fjerner noget. Kør `disktree --disk` for at scanne hele disken.

## Obsidian

[Obsidian](https://obsidian.md/) er en gratis og meget udvidbar noteapp, der bruger enkle Markdown-filer til lagring.

Obsidian er gratis til alle formål, herunder personlig, kommerciel og nonprofit brug.

Obsidian tilbyder også et [kommercielt tilføjelsesprogram til synkronisering](https://obsidian.md/sync) med mobilapps på iOS og Android. (https://obsidian.md/pricing).

Du starter Obsidian med `Super + Shift + O`. For at bruge temasynkronisering skal du vælge temaet `Omarchy` under indstillinger.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er Omarchys egen dødssimple Markdown-skriveapp. Ingen vaults, ingen plugins, kun dig og ordene.

Du starter Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er et grundlæggende billedredigeringsværktøj, der er fantastisk til beskæring, ændring af størrelse og andre grundlæggende manipulationer. Forvent bare ikke et Photoshop-alternativ. Men den har stadig Magic Wand og lag!

Du starter Pinta via appstarteren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er en temaapp, der kan udtrække farver fra et baggrundsbillede og gøre dem til et komplet, sammenhængende tema. Det er den nemmeste måde at [lave dit eget tema](43-making-your-own-theme.md) på.

Du starter Aether via appstarteren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lader dig sende filer til andre enheder på samme netværk, der kører appen, ligesom Apples AirDrop. Den er dog på tværs af platforme, så du kan sende filer til og fra Windows, macOS, Android, iOS og selvfølgelig Linux.

Du kan åbne menuen Share på `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menuen. Den giver dig fire muligheder:

- **Clipboard** sender det, du har kopieret, som en tekstfil. Fantastisk til at få et link eller et uddrag over på din telefon uden at sende en e-mail til dig selv.
- **File** åbner en filvælger, hvor du kan vælge flere på én gang.
- **Folder** sender en hel mappe.
- **Receive** åbner LocalSend for alvor, så en anden enhed kan sende noget til dig.

Det samme fungerer fra terminalen med `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Udelad stien, så får du vælgeren.

Du kan også sende direkte fra filhåndteringen: højreklik på et valg i Filer, og del det med LocalSend.

Omarchys firewall er lukket som standard undtagen for LocalSends port, så dette fungerer ud af boksen på en frisk installation. Se [sikkerhed](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er en komplet kontorpakke med tekstbehandling, regneark, præsentationer, tegneprogram og meget mere. Den er kompatibel med filer fra Microsoft Office, så dette er en fantastisk måde at kunne åbne de Word-dokumenter på.

Du starter LibreOffice via appstarteren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er Omarchys egen dødssimple præsentationsapp. Din præsentation er en enkelt Markdown-fil med billeder og videoer ved siden af: skriv hvert dias under en live-forhåndsvisning, træk diasene i rækkefølge, præsentér derefter i fuldskærm eller eksportér til PDF og PowerPoint. Den bruger endda dit Omarchy-tema.

Du starter Hype via appstarteren (`Super + Space`). Tryk på `?` inde i den for at se alle genveje.

## Signed

[Signed](https://github.com/omacom/signed) er Omarchys egen dødssimple måde at underskrive PDF'er og udfylde dem på. Placer din gemte underskrift, tekst og dagens dato hvor som helst på en side, og gem derefter en underskrevet kopi ved siden af originalen. Se [Udfyldning af PDF'er](27-filling-out-pdfs.md) for at se hvordan.

Du starter Signed via appstarteren (`Super + Space`), eller åbner en PDF med den fra filhåndteringen.

## Game Vibes

Game Vibes i appstarteren (`Super + Space`) er der, hvor Omarchys små spil bor: Checkmate, et 3D-skakspil mod en ven eller den indbyggede modstander; Cards, Klondike-kabale; Death Wish, en pixelpræcis platformer med ti rum fulde af pigge og save; og Neon Swarm, et arkade-shooter. Hvert er en enkelt webside, der følger dit tema. Vælg et med pilene og `Enter`, og kom tilbage til listen med `Esc` fra et spils titelskærm eller `Q`, mens det er sat på pause. Det åbner i fuldskærm: `Super + F` gør det til et vindue, og `Super + W` lukker det.

De spil, du laver med en agent, vises også her: vælg _Make something cool → Game_ i agentpanelet og beskriv et, eller navngiv et spil, der allerede er i Game Vibes, for at blive ved med at arbejde på det. Agenten kopierer det til `~/Games/vibes`, hvor det er dit at ændre, og åbner det, når det er færdigt. Du kan selv lave den kopi med `omarchy games vibes copy <game>`. Et spil, som en anden deler, installeres som et tema: vælg _Install > Gaming > Game Vibes_ og indsæt dets git-adresse, eller kør `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ fjerner et igen, og _Update > Game Vibes Games_ henter nye versioner. Spil indlæser three.js fra nettet, så de kræver en forbindelse for at starte.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er Omarchys egen dødssimple lommeregner, som åbner i et flydende vindue.

Du starter Omacalc med `Super + Shift + Q` (eller lommeregnertasten, hvis dit tastatur har en).

## Signal

[Signal](https://signal.org/) er pioneren inden for E2E-krypteret beskedudveksling og en fantastisk kommunikationsmulighed for alle, der foretrækker ikke at gå gennem et af de store tech-konglomerater.

Du starter Signal med `Super + Shift + G`. Den er ikke en del af basisinstallationen, så første gang du trykker på det, vil Omarchy tilbyde at installere den for dig (den findes også under _Install > Service_ i Omarchy-menuen).

## Omaview

[Omaview](https://github.com/omacom/omaview) er Omarchys egen dødssimple billedfremviser og medieafspiller: ét vindue til dine fotos, videoer og musik. Åbn et foto, og piletasterne går gennem resten af dets mappe, `N` og `P` gør det for alt, og `Ctrl + M` viser hele mappen som et gitter. Den viser også HEIC-, AVIF- og JPEG XL-fotos og fortsætter, hvor du slap i alt, der er langt.

Tryk på `F` for fuldskærm, `E` for at redigere et billede i Omasnap eller trimme en video i Omacut, `Ctrl + P` for at udskrive et billede og `Delete` for at flytte en fil til Trash (`Ctrl + Z` bringer den tilbage). Tryk på `?` inde i den for at se alle genveje.

Du starter Omaview som _Media Viewer_ via appstarteren (`Super + Space`), eller dobbeltklik blot på et billede, en video eller en sang i filhåndteringen.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er Omarchys egen dødssimple videotrimmer. Når alt, hvad du har brug for, er at skære starten og slutningen af et klip, er den bedre end at fyre et fuldt videoredigeringsprogram op.

Du starter Omacut via appstarteren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er Omarchys egen dødssimple webcam-optager. Vælg dit kamera og din mikrofon én gang, tryk derefter på `Space` for at optage, og igen for at sætte den samme optagelse på pause og genoptage den. Den optager altid i dit kameras højeste opløsning med en live-mikrofonmåler, så du kan kontrollere dine niveauer, før du starter.

Stop optagelsen, og den åbner med det samme i en indbygget editor. Dobbeltklik på et klip for at dele det, træk i håndtagene for at trimme hvert stykke, og fjern de dele, du ikke vil have. Gem det derefter som en MP4. Din originale optagelse gemmes, indtil du kasserer den, så du altid kan vende tilbage og klippe den anderledes.

Du starter Monologue via appstarteren (`Super + Space`).
