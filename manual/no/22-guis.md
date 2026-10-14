# GUI-er

## Filer

Filer (Nautilus) er den grafiske filbehandleren. `Super + Shift + F` åpner den, og `Super + Shift + Alt + F` åpner den i mappen terminalen din befinner seg i, noe som sparer mye klikking. `Ctrl + L` lar deg skrive inn en sti, og trykker du `Space` på en hvilken som helst fil, får du en rask forhåndsvisning uten å åpne noe.

Koble til en USB-pinne eller et SD-kort, så monteres det automatisk, så det bare dukker opp i sidepanelet. For noe mer innviklet — formatere en disk, sjekke SMART-helse, opprette partisjoner — start _Disker_ fra appstarteren (`Super + Space`).

Dobbeltklikk følger fornuftige standarder: bilder åpnes i imv, video i mpv, PDF-er i Dokumentviser og ren tekst i Neovim.

## Disktree

Når disken fylles opp og du ikke aner hva som spiser plassen, start [Disktree](https://github.com/tobi/disktree) fra appstarteren (`Super + Space`). Den viser et grafisk trekart over hjemmemappen din. Større blokker tar mer plass; gå inn i mapper med tastaturet eller musa, merk hva som skal bort, og se gjennom valgene dine før du fjerner noe. Kjør `disktree --disk` for å skanne hele disken.

## Obsidian

[Obsidian](https://obsidian.md/) er en gratis og svært utvidbar notatapplikasjon som bruker enkle Markdown-filer til lagring.

Obsidian er gratis til alle formål, inkludert personlig, kommersiell og ideell bruk.

Obsidian tilbyr også et [kommersielt tillegg for synkronisering](https://obsidian.md/sync) med mobilapper på iOS og Android. (https://obsidian.md/pricing).

Du starter Obsidian med `Super + Shift + O`. For å bruke temasykronisering må du velge `Omarchy`-temaet under innstillinger.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er Omarchys egen kjempeenkle Markdown-skriveapp. Ingen hvelv, ingen utvidelser, bare du og ordene.

Du starter Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er et enkelt bildebehandlingsverktøy som er flott til beskjæring, endring av størrelse og annen grunnleggende manipulering. Bare ikke forvent et Photoshop-alternativ. Men det har likevel tryllestav og lag!

Du starter Pinta via appstarteren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er en temaapplikasjon som kan hente ut farger fra et bakgrunnsbilde og gjøre dem om til et komplett, sammenhengende tema. Det er den enkleste måten å [lage ditt eget tema](43-making-your-own-theme.md) på.

Du starter Aether via appstarteren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lar deg sende filer til andre enheter på samme nettverk som kjører appen, som Apples AirDrop. Den er imidlertid multiplattform, så du kan sende filer til og fra Windows, macOS, Android, iOS og selvsagt Linux.

Du kan åpne Del-menyen på `Super + Ctrl + S` eller under _Utløs > Del_ i Omarchy-menyen. Den gir deg fire valg:

- **Utklippstavle** sender det du har kopiert som en tekstfil. Flott for å få en lenke eller et utdrag over på telefonen uten å sende e-post til deg selv.
- **Fil** åpner en filvelger der du kan velge flere på en gang.
- **Mappe** sender en hel mappe.
- **Motta** åpner selve LocalSend, slik at en annen enhet kan sende noe til deg.

Det samme fungerer fra terminalen med `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Utelat stien, så får du velgeren.

Du kan også sende rett fra filbehandleren: høyreklikk på et hvilket som helst utvalg i Nautilus og velg _Send via LocalSend_.

Omarchys brannmur er lukket som standard bortsett fra LocalSends port, så dette fungerer rett ut av esken på en fersk installasjon. Se [sikkerhet](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er en komplett kontorpakke med tekstbehandler, regneark, presentasjoner, tegneprogram og mer. Den er kompatibel med filer fra Microsoft Office, så dette er en fin måte å kunne åpne de Word-dokumentene på.

Du starter LibreOffice via appstarteren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er Omarchys egen kjempeenkle presentasjonsapp. Presentasjonen din er én enkelt Markdown-fil med bildene og videoene ved siden av: skriv hvert lysbilde under en sanntids forhåndsvisning, dra lysbildene i rekkefølge, presenter deretter i fullskjerm eller eksporter til PDF og PowerPoint. Den plukker til og med opp Omarchy-temaet ditt.

Du starter Hype via appstarteren (`Super + Space`). Trykk `?` inni den for å se hver snarvei.

## Signed

[Signed](https://github.com/omacom/signed) er Omarchys egen kjempeenkle måte å signere PDF-er og fylle dem ut på. Sett din lagrede signatur, tekst og dagens dato hvor som helst på en side, og lagre deretter en signert kopi ved siden av originalen. Se [Fylle ut PDF-er](27-filling-out-pdfs.md) for hvordan.

Du starter Signed via appstarteren (`Super + Space`), eller åpner en PDF med den fra filbehandleren.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er Omarchys egen kjempeenkle kalkulator, som åpnes i et flytende vindu.

Du starter Omacalc med `Super + Ctrl + Q` (eller kalkulatortasten, hvis tastaturet ditt har en).

## Signal

[Signal](https://signal.org/) er pioneren innen ende-til-ende-kryptert meldingsutveksling, og et flott kommunikasjonsvalg for alle som heller ikke vil gå via ett av de store teknologikonglomeratene.

Du starter Signal med `Super + Shift + G`. Den er ikke en del av basisinstallasjonen, så første gang du trykker på den, tilbyr Omarchy å installere den for deg (den finnes også under _Installer > Tjeneste_ i Omarchy-menyen).

## mpv

[mpv](https://mpv.io/) er en enkel, rask mediespiller som spiller nesten hva som helst fra hvilken som helst kilde. Flott til å se videoer.

Du starter mpv via appstarteren (`Super + Space`) eller dobbeltklikker bare på en video i filbehandleren.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er Omarchys egen kjempeenkle videotrimmer. Når alt du trenger er å kutte starten og slutten av et klipp, slår den å fyre opp et fullverdig videoredigeringsprogram.

Du starter Omacut via appstarteren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er Omarchys egen kjempeenkle webkameraopptaker. Velg kamera og mikrofon én gang, trykk deretter `Space` for å ta opp, og igjen for å pause og fortsette samme opptak. Den tar alltid opp i kameraets høyeste oppløsning, med et sanntids mikrofonmåler så du kan sjekke nivåene før du starter.

Stopp opptaket, så åpnes det med en gang i en innebygd editor. Dobbeltklikk på et klipp for å dele det, dra i håndtakene for å trimme hvert stykke, og fjern delene du ikke vil ha. Lagre det deretter som MP4. Det opprinnelige opptaket beholdes til du kaster det, så du kan alltid komme tilbake og klippe det annerledes.

Du starter Monologue via appstarteren (`Super + Space`).
