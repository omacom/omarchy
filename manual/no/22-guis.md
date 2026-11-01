# GUI-er

## Files

Files (Nautilus) er den grafiske filbehandleren. `Super + Shift + F` åpner den, og `Super + Shift + Alt + F` åpner den i mappen terminalen din står i, noe som sparer deg for mye klikking. `Ctrl + L` lar deg skrive inn en sti, og å trykke `Space` på en fil gir deg en rask forhåndsvisning uten å åpne noe som helst.

Koble til en USB-minnepinne eller et SD-kort, så monteres det automatisk, så det bare dukker opp i sidepanelet. For alt som er mer involvert — å formatere en stasjon, sjekke SMART-helse, opprette partisjoner — start _Disks_ fra appstarteren (`Super + Space`).

Dobbeltklikk følger fornuftige standarder: bilder åpnes i imv, video i mpv, PDF-er i Document Viewer, og ren tekst i Neovim.

## Disktree

Når stasjonen fylles opp og du ikke aner hva som spiser den, start [Disktree](https://github.com/tobi/disktree) fra appstarteren (`Super + Space`). Den viser et grafisk trekart over hjemmemappen din. Større blokker tar opp mer plass; gå inn i mapper med tastaturet eller musen, marker det som skal bort, og se gjennom valgene dine før du fjerner noe som helst. Kjør `disktree --disk` for å skanne hele disken.

## Obsidian

[Obsidian](https://obsidian.md/) er en gratis og svært utvidbar notatapp som bruker enkle Markdown-filer til lagring.

Obsidian er gratis til alle formål, inkludert personlig, kommersiell og ideell bruk.

Obsidian tilbyr også et [kommersielt tillegg for synkronisering](https://obsidian.md/sync) med mobilapper på iOS og Android. (https://obsidian.md/pricing).

Du starter Obsidian med `Super + Shift + O`. For å bruke temasynkronisering må du velge `Omarchy`-temaet under innstillinger.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er Omarchys egen dødssimple Markdown-skriveapp. Ingen hvelv, ingen utvidelser, bare deg og ordene.

Du starter Omawrite med `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er et grunnleggende bilderedigeringsverktøy som er flott for beskjæring, endring av størrelse og andre grunnleggende manipulasjoner. Bare ikke forvent et alternativ til Photoshop. Men den har fortsatt Magic Wand og lag!

Du starter Pinta via appstarteren (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er en temaapp som kan hente ut farger fra et bakgrunnsbilde og gjøre dem om til et komplett, sammenhengende tema. Det er den enkleste måten å [lage ditt eget tema](43-making-your-own-theme.md) på.

Du starter Aether via appstarteren (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lar deg sende filer til andre enheter på samme nettverk som kjører appen, som Apples AirDrop. Den er imidlertid på tvers av plattformer, så du kan sende filer til og fra Windows, macOS, Android, iOS og selvfølgelig Linux.

Du kan åpne Del-menyen på `Super + Ctrl + S` eller under _Trigger > Share_ i Omarchy-menyen. Den gir deg fire alternativer:

- **Clipboard** sender det du har kopiert, som en tekstfil. Flott for å få en lenke eller et utdrag over på telefonen uten å sende e-post til deg selv.
- **File** åpner en filvelger der du kan velge flere samtidig.
- **Folder** sender en hel mappe.
- **Receive** åpner LocalSend på ordentlig, slik at en annen enhet kan sende noe til deg.

Det samme fungerer fra terminalen med `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Utelat stien, så får du velgeren.

Du kan også sende rett fra filbehandleren: høyreklikk på et utvalg i Nautilus og velg _Send via LocalSend_.

Brannmuren i Omarchy er lukket som standard, bortsett fra porten til LocalSend, så dette fungerer rett ut av boksen på en fersk installasjon. Se [sikkerhet](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er en komplett kontorpakke med tekstbehandler, regneark, presentasjoner, tegneprogram og mer. Den er kompatibel med filer fra Microsoft Office, så dette er en flott måte å kunne åpne de Word-dokumentene på.

Du starter LibreOffice via appstarteren (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er Omarchys egen dødssimple presentasjonsapp. Presentasjonen din er én enkelt Markdown-fil med bildene og videoene ved siden av: skriv hvert lysbilde under en sanntids forhåndsvisning, dra lysbildene i rekkefølge, og presenter deretter i fullskjerm eller eksporter til PDF og PowerPoint. Den plukker til og med opp Omarchy-temaet ditt.

Du starter Hype via appstarteren (`Super + Space`). Trykk `?` inne i den for å se alle snarveier.

## Signed

[Signed](https://github.com/omacom/signed) er Omarchys egen dødssimple måte å signere PDF-er og fylle dem ut på. Plasser den lagrede signaturen din, tekst og dagens dato hvor som helst på en side, og lagre deretter en signert kopi ved siden av originalen. Se [Fylle ut PDF-er](27-filling-out-pdfs.md) for hvordan.

Du starter Signed via appstarteren (`Super + Space`), eller åpner en PDF med den fra filbehandleren.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er Omarchys egen dødssimple kalkulator, som åpnes i et flytende vindu.

Du starter Omacalc med `Super + Shift + Q` (eller kalkulatortasten, hvis tastaturet ditt har en).

## Signal

[Signal](https://signal.org/) er pioneren innen E2E-kryptert meldingsutveksling, og et flott kommunikasjonsalternativ for alle som heller vil slippe å gå gjennom en av de store teknologikonglomeratene.

Du starter Signal med `Super + Shift + G`. Den er ikke en del av grunninstallasjonen, så første gang du trykker det, vil Omarchy tilby å installere den for deg (den ligger også under _Install > Service_ i Omarchy-menyen).

## mpv

[mpv](https://mpv.io/) er en enkel, rask mediespiller som spiller nesten hva som helst fra enhver kilde. Flott for å se på videoer.

Du starter mpv via appstarteren (`Super + Space`) eller bare dobbeltklikker på en video i filbehandleren.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er Omarchys egen dødssimple videotrimmer. Når alt du trenger er å klippe bort starten og slutten av et klipp, slår den å fyre opp en full videoredigerer.

Du starter Omacut via appstarteren (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er Omarchys egen dødssimple webkameraopptaker. Velg kamera og mikrofon én gang, trykk deretter `Space` for å ta opp, og igjen for å sette det samme opptaket på pause og fortsette det. Den tar alltid opp i kameraets høyeste oppløsning, med en sanntids mikrofonmåler slik at du kan sjekke nivåene dine før du starter.

Stopp opptaket, så åpnes det med en gang i en innebygd editor. Dobbeltklikk på et klipp for å dele det, dra i håndtakene for å trimme hvert stykke, og fjern delene du ikke vil ha. Lagre det deretter som en MP4. Originalopptaket ditt beholdes til du forkaster det, så du kan alltid komme tilbake og klippe det annerledes.

Du starter Monologue via appstarteren (`Super + Space`).
