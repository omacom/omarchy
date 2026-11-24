# GUI-er

## Filer

Files (Folio) er den grafiske filbehandleren. `Super + Shift + F` åpner den, og `Super + Shift + Alt + F` åpner den i mappen terminalen din befinner seg i, noe som sparer deg for mye klikking. `Ctrl + L` lar deg skrive inn en sti, og å trykke `Space` på en fil forhåndsviser den i full størrelse uten å åpne den.

Koble til en USB-pinne eller et SD-kort, så monteres det automatisk og dukker bare opp i sidepanelet. For alt mer avansert — å formatere en stasjon, sjekke SMART-helsen, opprette partisjoner — starter du _Disks_ fra appstarteren (`Super + Space`).

Dobbelklikking følger fornuftige standarder: bilder, videoer og musikk åpnes i Omaview, PDF-er i Document Viewer, Markdown i Omawrite og ren tekst i teksteditoren din, Plain med mindre du velger en annen under _Setup > Defaults > Editor_.

## Disktree

Når stasjonen fylles opp og du ikke aner hva som spiser den opp, starter du [Disktree](https://github.com/tobi/disktree) fra appstarteren (`Super + Space`). Den viser et grafisk tre-kart over hjemmemappen din. Større blokker tar mer plass; gå inn i mapper med tastaturet eller musa, merk det som skal bort, og se gjennom valgene dine før du fjerner noe. Kjør `disktree --disk` for å skanne hele disken.

## Obsidian

[Obsidian](https://obsidian.md/) er en gratis og svært utvidbar notatapp som bruker enkle Markdown-filer til lagring.

Obsidian er gratis til alle formål, inkludert personlig, kommersiell og ideell bruk.

Obsidian tilbyr også et [kommersielt tillegg for synkronisering](https://obsidian.md/sync) med mobilapper på iOS og Android. (https://obsidian.md/pricing).

Du starter Obsidian med `Super + Shift + O`. For å bruke temasyncing må du velge `Omarchy`-temaet under innstillinger.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er Omarchys egen dødsenkle skriveapp for Markdown. Ingen hvelv, ingen utvidelser, bare deg og ordene.

Du starter Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er et enkelt bilderedigeringsverktøy som er ypperlig til beskjæring, endring av størrelse og andre grunnleggende manipuleringer. Bare ikke forvent et Photoshop-alternativ. Men den har fortsatt Magic Wand og lag!

Du starter Pinta via appstarteren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er en temaapp som kan hente ut farger fra et bakgrunnsbilde og gjøre dem til et komplett, sammenhengende tema. Det er den enkleste måten å [lage ditt eget tema](43-making-your-own-theme.md) på.

Du starter Aether via appstarteren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lar deg sende filer til andre enheter på samme nettverk som kjører appen, som Apples AirDrop. Den fungerer på tvers av plattformer, så du kan sende filer til og fra Windows, macOS, Android, iOS og selvfølgelig Linux.

Du kan åpne Del-menyen på `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menyen. Den gir deg fire alternativer:

- **Clipboard** sender det du har kopiert som en tekstfil. Flott for å få en lenke eller et utdrag over på telefonen din uten å sende e-post til deg selv.
- **File** åpner en filvelger der du kan velge flere samtidig.
- **Folder** sender en hel mappe.
- **Receive** åpner LocalSend på ordentlig, slik at en annen enhet kan sende noe til deg.

Det samme fungerer fra terminalen med `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Utelater du stien, får du filvelgeren.

Du kan også sende direkte fra filbehandleren: høyreklikk på et utvalg i Files og del det med LocalSend.

Omarchys brannmur er lukket som standard, bortsett fra porten til LocalSend, så dette fungerer rett ut av boksen på en fersk installasjon. Se [sikkerhet](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er en komplett kontorpakke med tekstbehandler, regneark, presentasjoner, tegneprogram og mer. Den er kompatibel med filer fra Microsoft Office, så dette er en flott måte å kunne åpne de Word-dokumentene på.

Du starter LibreOffice via appstarteren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er Omarchys egen dødsenkle presentasjonsapp. Lysbildestokken din er én enkelt Markdown-fil med bildene og videoene ved siden av: skriv hvert lysbilde under en sanntidsforhåndsvisning, dra lysbildene i rekkefølge, og presenter deretter i fullskjerm eller eksporter til PDF og PowerPoint. Den plukker til og med opp Omarchy-temaet ditt.

Du starter Hype via appstarteren (`Super + Space`). Trykk `?` inni den for å se alle snarveiene.

## Signed

[Signed](https://github.com/omacom/signed) er Omarchys egen dødsenkle måte å signere PDF-er og fylle dem ut på. Plasser den lagrede signaturen din, tekst og dagens dato hvor som helst på en side, og lagre deretter en signert kopi ved siden av originalen. Se [Fylle ut PDF-er](27-filling-out-pdfs.md) for hvordan.

Du starter Signed via appstarteren (`Super + Space`), eller åpner en PDF med den fra filbehandleren.

## Game Vibes

Game Vibes, i appstarteren (`Super + Space`), er der Omarchys små spill bor: Checkmate, et 3D-sjakkspill mot en venn eller den innebygde motstanderen; Cards, Klondike-kabal; Death Wish, et pikselpresist plattformspill med ti rom fulle av pigger og sager; og Neon Swarm, et arkade-skytespill. Hvert spill er en enkelt nettside som følger temaet ditt. Velg ett med pilene og `Enter`, og kom tilbake til listen med `Esc` fra tittelskjermen til et spill eller `Q` mens det er satt på pause. Det åpnes i fullskjerm: `Super + F` gjør det til et vindu, og `Super + W` lukker det.

Spillene du lager med en agent, dukker også opp her: velg _Make something cool → Game_ i agentpanelet og beskriv et, eller nevn et spill som allerede finnes i Game Vibes for å fortsette å jobbe med det. Agenten kopierer det til `~/Games/vibes`, der det er ditt å endre, og åpner det når det er ferdig. Du kan lage den kopien selv med `omarchy games vibes copy <game>`. Et spill noen andre deler, installeres som et tema: velg _Install > Gaming > Game Vibes_ og lim inn git-adressen, eller kjør `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ fjerner et igjen, og _Update > Game Vibes Games_ henter nye versjoner. Spill laster three.js fra nettet, så de trenger en tilkobling for å starte.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er Omarchys egen dødsenkle kalkulator, som åpnes i et flytende vindu.

Du starter Omacalc med `Super + Shift + Q` (eller kalkulatortasten, hvis tastaturet ditt har en).

## Signal

[Signal](https://signal.org/) er pioneren innen E2E-kryptert meldingsutveksling, og et flott kommunikasjonsalternativ for alle som helst ikke vil gå gjennom et av de store teknologikonglomeratene.

Du starter Signal med `Super + Shift + G`. Den er ikke en del av grunninstallasjonen, så første gang du trykker på den, tilbyr Omarchy å installere den for deg (den finnes også under _Install > Service_ i Omarchy-menyen).

## Omaview

[Omaview](https://github.com/omacom/omaview) er Omarchys egen dødsenkle bildeviser og mediespiller: ett vindu for bildene, videoene og musikken din. Åpne et bilde, så blar piltastene gjennom resten av mappen, `N` og `P` gjør det for hva som helst, og `Ctrl + M` viser hele mappen som et rutenett. Den viser også HEIC-, AVIF- og JPEG XL-bilder, og fortsetter der du slapp i alt som er langt.

Trykk `F` for fullskjerm, `E` for å redigere et bilde i Omasnap eller trimme en video i Omacut, `Ctrl + P` for å skrive ut et bilde, og `Delete` for å flytte en fil til papirkurven (`Ctrl + Z` bringer den tilbake). Trykk `?` inni den for å se alle snarveiene.

Du starter Omaview som _Media Viewer_ via appstarteren (`Super + Space`), eller bare dobbeltklikker på et bilde, en video eller en sang i filbehandleren.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er Omarchys egen dødsenkle videotrimmer. Når alt du trenger er å klippe av starten og slutten på et klipp, slår den å fyre opp en fullverdig videoredigerer.

Du starter Omacut via appstarteren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er Omarchys egen dødsenkle webkameraopptaker. Velg kamera og mikrofon én gang, trykk deretter `Space` for å ta opp, og igjen for å sette på pause og fortsette samme opptak. Den tar alltid opp i kameraets høyeste oppløsning, med en sanntids mikrofonmåler slik at du kan sjekke nivåene før du starter.

Stopp opptaket, og det åpnes med en gang i en innebygd redigerer. Dobbelklikk på et klipp for å dele det, dra i håndtakene for å trimme hver del, og fjern delene du ikke vil ha. Lagre det deretter som en MP4. Originalopptaket ditt beholdes til du forkaster det, slik at du alltid kan komme tilbake og klippe det annerledes.

Du starter Monologue via appstarteren (`Super + Space`).
