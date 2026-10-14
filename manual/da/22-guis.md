# GUI'er

## Filer

Filer (Nautilus) er den grafiske filhåndtering. `Super + Shift + F` åbner den, og `Super + Shift + Alt + F` åbner den i den mappe, din terminal befinder sig i, hvilket sparer en masse klik. `Ctrl + L` lader dig skrive en sti, og at trykke på `Space` på en vilkårlig fil giver dig en hurtig forhåndsvisning uden at åbne noget.

Sæt en USB-nøgle eller et SD-kort i, og det monteres automatisk, så det bare dukker op i sidebjælken. Til noget mere involveret — formatering af et drev, tjek af SMART-tilstand, oprettelse af partitioner — start _Diske_ fra app-starteren (`Super + Space`).

Dobbeltklik følger fornuftige standarder: billeder åbner i imv, video i mpv, PDF'er i Document Viewer og almindelig tekst i Neovim.

## Disktree

Når drevet fyldes op, og du ikke aner, hvad der æder det, så start [Disktree](https://github.com/tobi/disktree) fra app-starteren (`Super + Space`). Det viser et grafisk treemap over din hjemmemappe. Større blokke optager mere plads; gå ind i mapper med tastaturet eller musen, markér hvad der skal væk, og gennemgå dine valg, før du fjerner noget. Kør `disktree --disk` for at scanne hele disken.

## Obsidian

[Obsidian](https://obsidian.md/) er en gratis og meget udvidbar noteapplikation, der bruger enkle Markdown-filer til lagring.

Obsidian er gratis til alle formål, inklusive personlig, kommerciel og nonprofitbrug.

Obsidian tilbyder også en [kommerciel tilføjelse til synkronisering](https://obsidian.md/sync) med mobilapps på iOS og Android. (https://obsidian.md/pricing).

Du starter Obsidian med `Super + Shift + O`. For at bruge temasykronisering skal du vælge temaet `Omarchy` under indstillinger.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er Omarchys egen dødenkle Markdown-skriveapp. Ingen vaults, ingen plugins, bare dig og ordene.

Du starter Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er et grundlæggende billedredigeringsværktøj, der er fantastisk til beskæring, størrelsesændring og andre grundlæggende manipulationer. Bare forvent ikke et Photoshop-alternativ. Men det har stadig en tryllestav og lag!

Du starter Pinta via applikationsstarteren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er en temaapplikation, der kan udtrække farver fra et baggrundsbillede og forvandle dem til et komplet, sammenhængende tema. Det er den nemmeste måde at [lave dit eget tema](43-making-your-own-theme.md) på.

Du starter Aether via applikationsstarteren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lader dig sende filer til andre enheder på det samme netværk, der kører appen, ligesom Apples AirDrop. Det er dog på tværs af platforme, så du kan sende filer til og fra Windows, macOS, Android, iOS og selvfølgelig Linux.

Du kan åbne Del-menuen på `Super + Ctrl + S` eller under _Udløs > Del_ i Omarchy-menuen. Den giver dig fire muligheder:

- **Udklipsholder** sender, hvad du har kopieret, som en tekstfil. Fantastisk til at få et link eller et uddrag over på din telefon uden at maile til dig selv.
- **Fil** åbner en filvælger, hvor du kan vælge flere på én gang.
- **Mappe** sender en hel mappe.
- **Modtag** åbner selve LocalSend, så en anden enhed kan sende noget til dig.

Det samme virker fra terminalen med `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Udelad stien, og du får vælgeren.

Du kan også sende direkte fra filhåndteringen: højreklik på et vilkårligt valg i Nautilus og vælg _Send via LocalSend_.

Omarchys firewall er som standard lukket undtagen for LocalSends port, så dette virker ud af boksen på en frisk installation. Se [sikkerhed](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er en komplet kontorpakke med tekstbehandling, regneark, præsentationer, tegneapplikation og mere. Den er kompatibel med filer fra Microsoft Office, så dette er en fantastisk måde at kunne åbne de Word-dokumenter på.

Du starter LibreOffice via applikationsstarteren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er Omarchys egen dødenkle præsentationsapp. Dit deck er en enkelt Markdown-fil med dens billeder og videoer ved siden af: skriv hvert slide under en live forhåndsvisning, træk slides på plads, og præsentér derefter i fuld skærm eller eksportér til PDF og PowerPoint. Den opfanger endda dit Omarchy-tema.

Du starter Hype via applikationsstarteren (`Super + Space`). Tryk på `?` inde i den for at se hver genvej.

## Signed

[Signed](https://github.com/omacom/signed) er Omarchys egen dødenkle måde at underskrive PDF'er og udfylde dem på. Sæt din gemte underskrift, tekst og dags dato hvor som helst på en side, og gem derefter en underskrevet kopi ved siden af originalen. Se [Udfyldning af PDF'er](27-filling-out-pdfs.md) for hvordan.

Du starter Signed via applikationsstarteren (`Super + Space`) eller åbner en PDF med den fra filhåndteringen.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er Omarchys egen dødenkle lommeregner, som åbner i et flydende vindue.

Du starter Omacalc med `Super + Ctrl + Q` (eller lommeregnertasten, hvis dit tastatur har en).

## Signal

[Signal](https://signal.org/) er pioneren inden for E2E-krypteret beskedudveksling og en fantastisk kommunikationsmulighed for enhver, der foretrækker ikke at gå gennem et af de store tech-konglomerater.

Du starter Signal med `Super + Shift + G`. Det er ikke en del af basisinstallationen, så første gang du trykker på det, vil Omarchy tilbyde at installere det for dig (det er også under _Installer > Service_ i Omarchy-menuen).

## mpv

[mpv](https://mpv.io/) er en enkel, hurtig medieafspiller, der kan afspille næsten alt fra enhver kilde. Fantastisk til at se videoer.

Du starter mpv via applikationsstarteren (`Super + Space`) eller dobbeltklikker bare på en video i filhåndteringen.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er Omarchys egen dødenkle videotrimmer. Når alt, hvad du har brug for, er at klippe starten og slutningen af et klip, slår det at fyre op under et fuldt videoredigeringsprogram.

Du starter Omacut via applikationsstarteren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er Omarchys egen dødenkle webcam-optager. Vælg dit kamera og din mikrofon én gang, tryk derefter på `Space` for at optage og igen for at pause og genoptage den samme optagelse. Den optager altid i dit kameras højeste opløsning med en live mikrofonmåler, så du kan tjekke dine niveauer, før du starter.

Stop optagelsen, og den åbner med det samme i en indbygget editor. Dobbeltklik på et klip for at opdele det, træk i håndtagene for at trimme hvert stykke, og fjern de dele, du ikke vil have. Gem det derefter som en MP4. Din originale optagelse bevares, indtil du kasserer den, så du altid kan komme tilbage og klippe den anderledes.

Du starter Monologue via applikationsstarteren (`Super + Space`).
