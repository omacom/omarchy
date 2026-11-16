# GUI-er

## Filer

Files (Nautilus) er den grafiske filbehandleren. `Super + Shift + F` åpner den, og `Super + Shift + Alt + F` åpner den i mappen terminalen din befinner seg i, noe som sparer deg for mye klikking. Med `Ctrl + L` kan du skrive inn en sti, og hvis du trykker `Space` på en fil, får du en rask forhåndsvisning uten å åpne noe.

Koble til en USB-minnepinne eller et SD-kort, så monteres det automatisk og dukker bare opp i sidefeltet. For noe mer avansert — formatering av en disk, sjekking av SMART-helse, oppretting av partisjoner — starter du _Disks_ fra appstarteren (`Super + Space`).

Dobbeltklikking følger fornuftige standardvalg: bilder, videoer og musikk åpnes i Omaview, PDF-er i Document Viewer, Markdown i Omawrite og ren tekst i redigeringsprogrammet valgt under _Setup > Default > Editor_.

## Disktree

Når disken fylles opp og du ikke aner hva som spiser plassen, starter du [Disktree](https://github.com/tobi/disktree) fra appstarteren (`Super + Space`). Det viser et grafisk treemap over hjemmemappen din. Større blokker tar mer plass; naviger inn i mapper med tastaturet eller musa, marker det som skal bort, og se gjennom valgene dine før du fjerner noe. Kjør `disktree --disk` for å skanne hele disken.

## Obsidian

[Obsidian](https://obsidian.md/) er et gratis og svært utvidbart notatprogram som bruker enkle Markdown-filer til lagring.

Obsidian er gratis til alle formål, inkludert personlig, kommersiell og ideell bruk.

Obsidian tilbyr også et [kommersielt tillegg for synkronisering](https://obsidian.md/sync) med mobilapper på iOS og Android. (https://obsidian.md/pricing).

Du starter Obsidian med `Super + Shift + O`. For å bruke temasynkronisering må du velge `Omarchy`-temaet under innstillinger.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er Omarchys egen dødsenkle skriveapp for Markdown. Ingen vaults, ingen plugins, bare deg og ordene.

Du starter Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er et enkelt bildebehandlingsverktøy som er flott til beskjæring, endring av størrelse og andre grunnleggende manipuleringer. Bare ikke forvent et alternativ til Photoshop. Men den har fortsatt Magic Wand og lag!

Du starter Pinta via appstarteren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er en temaapp som kan hente ut farger fra et bakgrunnsbilde og gjøre dem om til et komplett, sammenhengende tema. Det er den enkleste måten å [lage ditt eget tema](43-making-your-own-theme.md) på.

Du starter Aether via appstarteren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lar deg sende filer til andre enheter på samme nettverk som kjører appen, akkurat som Apples AirDrop. Den er på tvers av plattformer, derimot, så du kan sende filer til og fra Windows, macOS, Android, iOS og selvfølgelig Linux.

Du kan åpne Share-menyen med `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menyen. Den gir deg fire alternativer:

- **Clipboard** sender det du har kopiert, som en tekstfil. Flott for å få en lenke eller et utdrag over på telefonen uten å sende e-post til deg selv.
- **File** åpner en filvelger der du kan velge flere samtidig.
- **Folder** sender en hel mappe.
- **Receive** åpner LocalSend på ordentlig, slik at en annen enhet kan sende noe til deg.

Det samme fungerer fra terminalen med `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Utelater du stien, får du filvelgeren.

Du kan også sende rett fra filbehandleren: høyreklikk på et utvalg i Nautilus og velg _Send via LocalSend_.

Brannmuren i Omarchy er lukket som standard, bortsett fra porten til LocalSend, så dette fungerer rett ut av boksen på en fersk installasjon. Se [sikkerhet](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er en komplett kontorpakke med tekstbehandler, regneark, presentasjoner, tegneprogram og mer. Den er kompatibel med filer fra Microsoft Office, så dette er en flott måte å kunne åpne de Word-dokumentene på.

Du starter LibreOffice via appstarteren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er Omarchys egen dødsenkle presentasjonsapp. Presentasjonen din er én enkelt Markdown-fil med bildene og videoene ved siden av: skriv hvert lysbilde under en sanntids forhåndsvisning, dra lysbildene i riktig rekkefølge, og presenter deretter i fullskjerm eller eksporter til PDF og PowerPoint. Den plukker til og med opp Omarchy-temaet ditt.

Du starter Hype via appstarteren (`Super + Space`). Trykk `?` inne i den for å se alle snarveiene.

## Signed

[Signed](https://github.com/omacom/signed) er Omarchys egen dødsenkle måte å signere PDF-er og fylle dem ut på. Plasser den lagrede signaturen din, tekst og dagens dato hvor som helst på en side, og lagre deretter en signert kopi ved siden av originalen. Se [Fylle ut PDF-er](27-filling-out-pdfs.md) for hvordan.

Du starter Signed via appstarteren (`Super + Space`), eller åpner en PDF med den fra filbehandleren.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er Omarchys egen dødsenkle kalkulator, som åpnes i et flytende vindu.

Du starter Omacalc med `Super + Shift + Q` (eller kalkulatortasten, hvis tastaturet ditt har en).

## Signal

[Signal](https://signal.org/) er pioneren innen E2E-krypterte meldinger, og et flott kommunikasjonsalternativ for alle som heller vil slippe å gå gjennom en av de store teknologigigantene.

Du starter Signal med `Super + Shift + G`. Det er ikke en del av grunninstallasjonen, så første gang du trykker på den, tilbyr Omarchy å installere den for deg (den finnes også under _Install > Service_ i Omarchy-menyen).

## Omaview

[Omaview](https://github.com/omacom/omaview) er Omarchys egen dødsenkle bildeviser og mediespiller: ett vindu for bildene, videoene og musikken din. Åpne et bilde, så blar piltastene gjennom resten av mappen, `N` og `P` gjør det for hva som helst, og `Ctrl + M` viser hele mappen som et rutenett. Den viser også HEIC-, AVIF- og JPEG XL-bilder, og fortsetter der du slapp i alt som er langt.

Trykk `F` for fullskjerm, `E` for å redigere et bilde i Omasnap eller trimme en video i Omacut, `Ctrl + P` for å skrive ut et bilde, og `Delete` for å flytte en fil til papirkurven (`Ctrl + Z` henter den tilbake). Trykk `?` inne i den for å se alle snarveiene.

Du starter Omaview som _Media Viewer_ via appstarteren (`Super + Space`), eller dobbeltklikker bare på et bilde, en video eller en sang i filbehandleren.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er Omarchys egen dødsenkle videotrimmer. Når alt du trenger er å kutte starten og slutten av et klipp, slår den å fyre opp et fullverdig videoredigeringsprogram.

Du starter Omacut via appstarteren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er Omarchys egen dødsenkle webkameraopptaker. Velg kamera og mikrofon én gang, trykk deretter `Space` for å ta opp, og igjen for å sette det samme opptaket på pause og fortsette det. Den tar alltid opp i kameraets høyeste oppløsning, med en sanntids mikrofonmåler slik at du kan sjekke nivåene før du starter.

Stopp opptaket, så åpnes det med en gang i en innebygd editor. Dobbeltklikk på et klipp for å dele det, dra i håndtakene for å trimme hver del, og fjern delene du ikke vil ha. Lagre det deretter som en MP4. Det originale opptaket ditt beholdes til du forkaster det, så du alltid kan komme tilbake og klippe det annerledes.

Du starter Monologue via appstarteren (`Super + Space`).
