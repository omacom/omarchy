# Grafiske brukergrensesnitt

## Files

Files (Folio) er den grafiske filbehandleren. `Super + Shift + F` åpner den, og `Super + Shift + Alt + F` åpner den i mappen terminalen din står i, noe som sparer deg for mye klikking. Med `Ctrl + L` kan du skrive inn en sti, og med `Space` på en fil forhåndsviser du den i full størrelse uten å åpne den.

Koble til en USB-pinne eller et SD-kort, så monteres det automatisk og dukker bare opp i sidefeltet. For alt mer avansert — formatering av en disk, sjekk av SMART-helse, oppretting av partisjoner — starter du _Disks_ fra appstarteren (`Super + Space`).

En kryptert disk ber om passordet sitt når den kobles til. For å få en til å låse seg opp av seg selv, legger du til en nøkkelfil på den med `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` og plasserer den nøkkelfilen i `~/.config/omarchy/drive-keys/<UUID>`, navngitt med UUID-en som `lsblk -dno UUID /dev/sdX1` skriver ut for den krypterte partisjonen, og kun lesbar for deg (`chmod 600`). Hvis den nøkkelfilen mangler eller avvises, blir du bedt om passordet som vanlig.

Dobbeltklikk følger fornuftige standardvalg: bilder, videoer og musikk åpnes i Omaview, PDF-er i Document Viewer, Markdown i Omawrite og ren tekst i tekstredigereren din, Plain med mindre du velger en annen under _Setup > Defaults > Editor_.

## Disktree

Når disken fyller seg opp og du ikke aner hva som spiser den opp, starter du [Disktree](https://github.com/tobi/disktree) fra appstarteren (`Super + Space`). Den viser et grafisk tre-kart over hjemmemappen din. Større blokker tar mer plass; gå inn i mapper med tastaturet eller musen, marker hva som skal bort, og se gjennom valgene dine før du fjerner noe. Kjør `disktree --disk` for å skanne hele disken.

## Obsidian

[Obsidian](https://obsidian.md/) er en gratis notatapp med rike utvidelsesmuligheter som bruker enkle Markdown-filer til lagring.

Obsidian er gratis til alle formål, inkludert personlig, kommersiell og ideell bruk.

Obsidian tilbyr også et [kommersielt tillegg for synkronisering](https://obsidian.md/sync) med mobilapper på iOS og Android. (https://obsidian.md/pricing).

Du starter Obsidian med `Super + Shift + O`. For å bruke temasynkronisering må du velge temaet `Omarchy` under innstillingene.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er Omarchys egen dødssimple Markdown-skriveapp. Ingen hvelv, ingen utvidelser, bare deg og ordene.

Du starter Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er et enkelt bilderedigeringsverktøy som er flott til beskjæring, endring av størrelse og annen grunnleggende behandling. Bare ikke forvent et Photoshop-alternativ. Men den har fortsatt Magic Wand og lag!

Du starter Pinta via appstarteren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er en temaapp som kan hente ut farger fra et bakgrunnsbilde og gjøre dem om til et komplett, sammenhengende tema. Det er den enkleste måten å [lage ditt eget tema](43-making-your-own-theme.md) på.

Du starter Aether via appstarteren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lar deg sende filer til andre enheter på samme nettverk som kjører appen, som Apples AirDrop. Den fungerer på tvers av plattformer, så du kan sende filer til og fra Windows, macOS, Android, iOS og selvfølgelig Linux.

Du kan åpne Share-menyen med `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menyen. Den gir deg fire valg:

- **Clipboard** sender det du har kopiert, som en tekstfil. Flott for å få en lenke eller et utklipp over på telefonen uten å sende e-post til deg selv.
- **File** åpner en filvelger der du kan velge flere samtidig.
- **Folder** sender en hel mappe.
- **Receive** åpner LocalSend på ordentlig, så en annen enhet kan sende noe til deg.

Det samme fungerer fra terminalen med `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Utelat stien, så får du filvelgeren.

Du kan også sende rett fra filbehandleren: høyreklikk på et utvalg i Files og del det med LocalSend.

Omarchys brannmur er som standard lukket unntatt for LocalSends port, så dette fungerer rett ut av boksen på en fersk installasjon. Se [sikkerhet](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er en komplett kontorpakke med tekstbehandler, regneark, presentasjoner, tegneprogram og mer. Den er kompatibel med filer fra Microsoft Office, så dette er en flott måte å kunne åpne de Word-dokumentene på.

Du starter LibreOffice via appstarteren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er Omarchys egen dødssimple presentasjonsapp. Presentasjonen din er én enkelt Markdown-fil med bildene og videoene ved siden av: skriv hvert lysbilde under en sanntidsforhåndsvisning, dra lysbildene i rekkefølge, og presenter deretter i fullskjerm eller eksporter til PDF og PowerPoint. Den tar til og med i bruk Omarchy-temaet ditt.

Du starter Hype via appstarteren (`Super + Space`). Trykk `?` inne i den for å se alle snarveiene.

## Signed

[Signed](https://github.com/omacom/signed) er Omarchys egen dødssimple måte å signere PDF-er og fylle dem ut på. Plasser den lagrede signaturen din, tekst og dagens dato hvor som helst på en side, og lagre deretter en signert kopi ved siden av originalen. Se [Fylle ut PDF-er](27-filling-out-pdfs.md) for hvordan.

Du starter Signed via appstarteren (`Super + Space`), eller åpner en PDF med den fra filbehandleren.

## Game Vibes

Game Vibes, i appstarteren (`Super + Space`), er der Omarchys små spill bor: Checkmate, et 3D-sjakkspill mot en venn eller den innebygde motstanderen; Cards, Klondike-kabal; Death Wish, et pikselpresist plattformspill med ti rom fulle av pigger og sager; og Neon Swarm, et arkade-skytespill. Hvert spill er en enkelt nettside som følger temaet ditt. Velg ett med piltastene og `Enter`, og kom tilbake til listen med `Esc` fra et spills tittelskjerm eller `Q` mens det er satt på pause. Det åpner i fullskjerm: `Super + F` gjør det til et vindu, og `Super + W` lukker det.

Spillene du lager med en agent, dukker også opp her: velg _Make something cool → Game_ i agentpanelet og beskriv ett, eller nevn et spill som allerede finnes i Game Vibes, for å fortsette å jobbe på det. Agenten kopierer det inn i `~/Games/vibes`, der det er ditt å endre, og åpner det når det er ferdig. Du kan lage den kopien selv med `omarchy games vibes copy <game>`. Et spill noen andre deler, installeres som et tema: velg _Install > Gaming > Game Vibes_ og lim inn git-adressen, eller kjør `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ fjerner ett igjen, og _Update > Game Vibes Games_ henter nye versjoner. Spill laster three.js fra nettet, så de trenger en tilkobling for å starte.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er Omarchys egen dødssimple kalkulator, som åpner i et flytende vindu.

Du starter Omacalc med `Super + Shift + Q` (eller kalkulatortasten, hvis tastaturet ditt har en).

## Signal

[Signal](https://signal.org/) er pioneren innen E2E-krypterte meldinger, og et flott kommunikasjonsvalg for alle som helst ikke vil gå gjennom et av de store teknologikonglomeratene.

Du starter Signal med `Super + Shift + G`. Den er ikke en del av grunninstallasjonen, så første gang du trykker på det, vil Omarchy tilby å installere den for deg (den ligger også under _Install > Service_ i Omarchy-menyen).

## Omaview

[Omaview](https://github.com/omacom/omaview) er Omarchys egen dødssimple bildeviser og mediespiller: ett vindu for fotoene, videoene og musikken din. Åpne et foto, så går piltastene gjennom resten av mappen, `N` og `P` gjør det for alt, og `Ctrl + M` viser hele mappen som et rutenett. Den viser også HEIC-, AVIF- og JPEG XL-fotoer, og fortsetter der du slapp i alt som er langt.

Trykk `F` for fullskjerm, `E` for å redigere et bilde i Omasnap eller trimme en video i Omacut, `Ctrl + P` for å skrive ut et bilde, og `Delete` for å flytte en fil til papirkurven (`Ctrl + Z` henter den tilbake). Trykk `?` inne i den for å se alle snarveiene.

Du starter Omaview som _Media Viewer_ via appstarteren (`Super + Space`), eller dobbeltklikker bare på et bilde, en video eller en sang i filbehandleren.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er Omarchys egen dødssimple videotrimmer. Når alt du trenger, er å klippe bort starten og slutten av et klipp, slår det å fyre opp et fullt videoredigeringsprogram.

Du starter Omacut via appstarteren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er Omarchys egen dødssimple webkamera-opptaker. Velg kamera og mikrofon én gang, trykk deretter `Space` for å ta opp, og igjen for å sette samme opptak på pause og fortsette det. Den tar alltid opp i kameraets høyeste oppløsning, med en sanntids mikrofonmåler så du kan sjekke nivåene dine før du starter.

Stopp opptaket, så åpner det seg med en gang i en innebygd redigerer. Dobbeltklikk på et klipp for å dele det, dra i håndtakene for å trimme hvert stykke, og fjern delene du ikke vil ha. Lagre det deretter som en MP4. Det opprinnelige opptaket ditt beholdes til du forkaster det, så du kan alltid komme tilbake og klippe det annerledes.

Du starter Monologue via appstarteren (`Super + Space`).
