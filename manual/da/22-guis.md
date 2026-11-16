# GUI'er

## Filer

Files (Nautilus) er den grafiske filhåndtering. `Super + Shift + F` åbner den, og `Super + Shift + Alt + F` åbner den i den mappe, din terminal befinder sig i, hvilket sparer en masse klik. Med `Ctrl + L` kan du skrive en sti, og ved at trykke på `Space` på en fil får du en hurtig forhåndsvisning uden at åbne noget.

Slut en USB-nøgle eller et SD-kort til, og det monteres automatisk, så det bare vises i sidepanelet. Til noget mere avanceret — formatering af et drev, kontrol af SMART-tilstand, oprettelse af partitioner — skal du starte _Disks_ fra appstarteren (`Super + Space`).

Dobbeltklik følger fornuftige standarder: billeder, videoer og musik åbnes i Omaview, PDF'er i Document Viewer, Markdown i Omawrite og almindelig tekst i den editor, der er valgt under _Setup > Default > Editor_.

## Disktree

Når drevet fyldes op, og du ikke aner, hvad der æder pladsen, skal du starte [Disktree](https://github.com/tobi/disktree) fra appstarteren (`Super + Space`). Den viser et grafisk treemap over din hjemmemappe. Større blokke fylder mere; gå ind i mapper med tastaturet eller musen, markér det, der skal væk, og gennemgå dine valg, før du fjerner noget. Kør `disktree --disk` for at scanne hele disken.

## Obsidian

[Obsidian](https://obsidian.md/) er en gratis og yderst udvidbar noteapp, der bruger simple Markdown-filer til lagring.

Obsidian er gratis til alle formål, herunder personlig, kommerciel og nonprofitbrug.

Obsidian tilbyder også et [kommercielt tillæg til synkronisering](https://obsidian.md/sync) med mobilapps på iOS og Android. (https://obsidian.md/pricing).

Du starter Obsidian med `Super + Shift + O`. For at bruge temasyncronisering skal du vælge temaet `Omarchy` under indstillinger.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er Omarchys egen dødssimple Markdown-skriveapp. Ingen vaults, ingen plugins, bare dig og ordene.

Du starter Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er et simpelt billedredigeringsværktøj, der er godt til beskæring, ændring af størrelse og andre grundlæggende manipulationer. Forvent bare ikke et Photoshop-alternativ. Men den har stadig en Magic Wand og lag!

Du starter Pinta via appstarteren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er en temaapp, der kan udtrække farver fra et baggrundsbillede og gøre dem til et komplet, sammenhængende tema. Det er den nemmeste måde at [lave dit eget tema](43-making-your-own-theme.md) på.

Du starter Aether via appstarteren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lader dig sende filer til andre enheder på samme netværk, der kører appen, ligesom Apples AirDrop. Den er dog på tværs af platforme, så du kan sende filer til og fra Windows, macOS, Android, iOS og selvfølgelig Linux.

Du kan åbne menuen Share på `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menuen. Den giver dig fire muligheder:

- **Clipboard** sender det, du har kopieret, som en tekstfil. Perfekt til at få et link eller et uddrag over på din telefon uden at sende en e-mail til dig selv.
- **File** åbner en filvælger, hvor du kan vælge flere på én gang.
- **Folder** sender en hel mappe.
- **Receive** åbner selve LocalSend, så en anden enhed kan sende noget til dig.

Det samme virker fra terminalen med `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Udelad stien, og du får filvælgeren.

Du kan også sende direkte fra filhåndteringen: højreklik på et valg i Nautilus og vælg _Send via LocalSend_.

Omarchys firewall er lukket som standard undtagen for LocalSends port, så det virker ud af boksen på en frisk installation. Se [sikkerhed](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er en komplet kontorpakke med tekstbehandling, regneark, præsentationer, tegneprogram og mere. Den er kompatibel med filer fra Microsoft Office, så det er en god måde at kunne åbne de Word-dokumenter på.

Du starter LibreOffice via appstarteren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er Omarchys egen dødssimple præsentationsapp. Din præsentation er en enkelt Markdown-fil med dens billeder og videoer ved siden af: skriv hvert slide under en live forhåndsvisning, træk slides på plads i rækkefølge, og præsentér derefter i fuldskærm eller eksportér til PDF og PowerPoint. Den opfanger endda dit Omarchy-tema.

Du starter Hype via appstarteren (`Super + Space`). Tryk på `?` i den for at se alle genveje.

## Signed

[Signed](https://github.com/omacom/signed) er Omarchys egen dødssimple måde at underskrive PDF'er og udfylde dem på. Placer din gemte underskrift, tekst og dags dato hvor som helst på en side, og gem derefter en underskrevet kopi ved siden af originalen. Se [Udfyldning af PDF'er](27-filling-out-pdfs.md) for hvordan.

Du starter Signed via appstarteren (`Super + Space`) eller åbner en PDF med den fra filhåndteringen.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) er Omarchys eget 3D-skakspil. Spil mod en ven på samme computer eller den indbyggede modstander på tre niveauer, på fire skulpturerede sæt, der hver især bevæger sig på deres egen måde: rumfartøjer i kredsløb, udskåret træ og elfenben, skovvæsner og slik. Spil har intet ur og gemmes efter hvert træk.

Du starter Checkmate via appstarteren (`Super + Space`), hvor den er opført som Chess. Tryk på `?` i den for at se alle genveje.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er Omarchys egen dødssimple lommeregner, som åbner i et flydende vindue.

Du starter Omacalc med `Super + Shift + Q` (eller lommeregnertasten, hvis dit tastatur har en).

## Signal

[Signal](https://signal.org/) er pioneren inden for E2E-krypteret beskedtjeneste og en god kommunikationsmulighed for alle, der helst ikke vil gå gennem en af de store teknologikonglomerater.

Du starter Signal med `Super + Shift + G`. Den er ikke en del af basisinstallationen, så første gang du trykker på det, tilbyder Omarchy at installere den for dig (den findes også under _Install > Service_ i Omarchy-menuen).

## Omaview

[Omaview](https://github.com/omacom/omaview) er Omarchys egen dødssimple billedfremviser og medieafspiller: ét vindue til dine billeder, videoer og musik. Åbn et billede, og piletasterne bladrer gennem resten af dets mappe, `N` og `P` gør det for alt, og `Ctrl + M` viser hele mappen som et gitter. Den viser også HEIC-, AVIF- og JPEG XL-billeder og fortsætter, hvor du slap i alt, der er langt.

Tryk på `F` for fuldskærm, `E` for at redigere et billede i Omasnap eller trimme en video i Omacut, `Ctrl + P` for at udskrive et billede og `Delete` for at flytte en fil til papirkurven (`Ctrl + Z` henter den tilbage). Tryk på `?` i den for at se alle genveje.

Du starter Omaview som _Media Viewer_ via appstarteren (`Super + Space`) eller dobbeltklikker bare på et billede, en video eller en sang i filhåndteringen.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er Omarchys egen dødssimple videotrimmer. Når alt, hvad du har brug for, er at klippe starten og slutningen af et klip, slår den at fyre et fuldt videoredigeringsprogram op.

Du starter Omacut via appstarteren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er Omarchys egen dødssimple webkameraoptager. Vælg dit kamera og din mikrofon én gang, tryk derefter på `Space` for at optage og igen for at sætte den samme optagelse på pause og genoptage den. Den optager altid i dit kameras højeste opløsning med en live mikrofonmåler, så du kan kontrollere dine niveauer, før du starter.

Stop optagelsen, og den åbner med det samme i en indbygget editor. Dobbeltklik på et klip for at dele det, træk i håndtagene for at trimme hvert stykke, og fjern de dele, du ikke vil have. Gem det derefter som en MP4. Din originale optagelse bevares, indtil du kasserer den, så du altid kan vende tilbage og klippe den anderledes.

Du starter Monologue via appstarteren (`Super + Space`).
