# GUI'er

## Filer

Filer (Nautilus) er den grafiske filhåndtering. `Super + Shift + F` åbner den, og `Super + Shift + Alt + F` åbner den i den mappe, din terminal står i, hvilket sparer en masse klik. `Ctrl + L` lader dig skrive en sti, og hvis du trykker på `Space` på en fil, får du en hurtig forhåndsvisning uden at åbne noget.

Tilslut en USB-nøgle eller et SD-kort, og det monteres automatisk, så det bare vises i sidepanelet. Til alt, der er mere indviklet — formatering af et drev, kontrol af SMART-tilstand, oprettelse af partitioner — skal du starte _Disks_ fra applikationsstarteren (`Super + Space`).

Dobbeltklik følger fornuftige standarder: billeder åbnes i imv, video i mpv, PDF'er i Document Viewer og ren tekst i Neovim.

## Disktree

Når drevet fyldes op, og du ikke aner, hvad der æder pladsen, skal du starte [Disktree](https://github.com/tobi/disktree) fra applikationsstarteren (`Super + Space`). Det viser et grafisk treemap over din hjemmemappe. Større blokke fylder mere; gå ind i mapper med tastaturet eller musen, markér, hvad der skal væk, og gennemgå dine valg, før du fjerner noget. Kør `disktree --disk` for at scanne hele disken.

## Obsidian

[Obsidian](https://obsidian.md/) er en gratis og meget udvidelig noteapp, der bruger enkle Markdown-filer til lagring.

Obsidian er gratis til alle formål, herunder privat, kommerciel og nonprofit brug.

Obsidian tilbyder også en [kommerciel tilføjelse til synkronisering](https://obsidian.md/sync) med mobilapps på iOS og Android. (https://obsidian.md/pricing).

Du starter Obsidian med `Super + Shift + O`. For at bruge temasyncronisering skal du vælge temaet `Omarchy` under indstillinger.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er Omarchys egen dødssimple Markdown-skriveapp. Ingen vaults, ingen plugins, bare dig og ordene.

Du starter Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er et grundlæggende billedredigeringsværktøj, der er godt til beskæring, ændring af størrelse og andre grundlæggende manipulationer. Forvent bare ikke et Photoshop-alternativ. Men den har stadig Magic Wand og lag!

Du starter Pinta via applikationsstarteren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er en temaapp, der kan udtrække farver fra et baggrundsbillede og forvandle dem til et komplet, sammenhængende tema. Det er den nemmeste måde at [lave dit eget tema](43-making-your-own-theme.md) på.

Du starter Aether via applikationsstarteren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lader dig sende filer til andre enheder på det samme netværk, der kører appen, ligesom Apple's AirDrop. Den er dog på tværs af platforme, så du kan sende filer til og fra Windows, macOS, Android, iOS og selvfølgelig Linux.

Du kan åbne menuen Share på `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menuen. Den giver dig fire muligheder:

- **Clipboard** sender det, du har kopieret, som en tekstfil. Perfekt til at få et link eller et uddrag over på din telefon uden at maile det til dig selv.
- **File** åbner en filvælger, hvor du kan vælge flere på én gang.
- **Folder** sender en hel mappe.
- **Receive** åbner selve LocalSend, så en anden enhed kan sende noget til dig.

Det samme fungerer fra terminalen med `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Udelad stien, og du får vælgeren.

Du kan også sende direkte fra filhåndteringen: højreklik på et valg i Nautilus og vælg _Send via LocalSend_.

Omarchys firewall er lukket som standard undtagen for LocalSends port, så dette fungerer ud af boksen på en frisk installation. Se [sikkerhed](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er en komplet kontorpakke med tekstbehandling, regneark, præsentationer, tegneprogram og mere. Den er kompatibel med filer fra Microsoft Office, så dette er en god måde at kunne åbne de Word-dokumenter på.

Du starter LibreOffice via applikationsstarteren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er Omarchys egen dødssimple præsentationsapp. Dit deck er en enkelt Markdown-fil med dens billeder og videoer ved siden af: skriv hvert slide under en live forhåndsvisning, træk slides i rækkefølge, og præsentér derefter i fuldskærm eller eksportér til PDF og PowerPoint. Den opfanger endda dit Omarchy-tema.

Du starter Hype via applikationsstarteren (`Super + Space`). Tryk på `?` inde i den for at se alle genveje.

## Signed

[Signed](https://github.com/omacom/signed) er Omarchys egen dødssimple måde at signere PDF'er og udfylde dem på. Placér din gemte underskrift, tekst og dags dato hvor som helst på en side, og gem derefter en signeret kopi ved siden af originalen. Se [Udfyldning af PDF'er](27-filling-out-pdfs.md) for, hvordan du gør.

Du starter Signed via applikationsstarteren (`Super + Space`), eller åbner en PDF med den fra filhåndteringen.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er Omarchys egen dødssimple lommeregner, som åbner i et svævende vindue.

Du starter Omacalc med `Super + Shift + Q` (eller lommeregnertasten, hvis dit tastatur har en).

## Signal

[Signal](https://signal.org/) er pioneren inden for E2E-krypteret beskedudveksling og en god kommunikationsmulighed for alle, der helst vil undgå at gå gennem et af de store tech-konglomerater.

Du starter Signal med `Super + Shift + G`. Den er ikke en del af basisinstallationen, så første gang du trykker på det, tilbyder Omarchy at installere den for dig (den findes også under _Install > Service_ i Omarchy-menuen).

## mpv

[mpv](https://mpv.io/) er en enkel, hurtig medieafspiller, der afspiller næsten hvad som helst fra enhver kilde. Perfekt til at se videoer.

Du starter mpv via applikationsstarteren (`Super + Space`) eller dobbeltklikker bare på en video i filhåndteringen.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er Omarchys egen dødssimple videotrimmer. Når alt, hvad du har brug for, er at klippe starten og slutningen af et klip, slår den at fyre op i en fuld videoredigerer.

Du starter Omacut via applikationsstarteren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er Omarchys egen dødssimple webcam-optager. Vælg dit kamera og din mikrofon én gang, tryk derefter på `Space` for at optage, og igen for at sætte den samme optagelse på pause og genoptage den. Den optager altid i dit kameras højeste opløsning, med en live mikrofonmåler, så du kan tjekke dine niveauer, før du starter.

Stop optagelsen, og den åbner med det samme i en indbygget editor. Dobbeltklik på et klip for at dele det, træk i håndtagene for at trimme hvert stykke, og fjern de dele, du ikke vil have. Gem den derefter som en MP4. Din originale optagelse bevares, indtil du kasserer den, så du altid kan vende tilbage og klippe den anderledes.

Du starter Monologue via applikationsstarteren (`Super + Space`).
