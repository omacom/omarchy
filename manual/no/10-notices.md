# Varsler

Varslinger lander i øverste høyre hjørne av den fokuserte skjermen. Du kan også raskt få tilgang til dato og klokkeslett, batteristatus og aktuelt vær ved hjelp av hurtigtastvarslene.

## Varslinger

Varslinger fra samme app eller nettsted stables i en bunke, slik at en pratsom Slack-kanal ikke dytter byggfeilen din av skjermen. Hold pekeren over en bunke for å vifte den ut; ingenting nytt glir inn under pekeren mens du leser. Klikk på et kort for å hoppe til der det kom fra, høyreklikk, midtklikk eller trykk på ✕ for å avvise det.

Kort tilbyr det de bærer: _Kopier kode_ for verifiseringskoder (holdt utenfor [utklippstavlehistorikken](08-unified-clipboard-history.md) og tømt etter et minutt), pluss eventuelle knapper appen tilbyr. Lenker i teksten i en varsling åpnes når du klikker på dem.

`Super + ,` avviser den nyeste varslingen, eller åpner det den peker til når den tilbyr det, `Super + Alt + ,` avviser bare den siste, `Super + Shift + ,` avviser alle, og `Super + Shift + Alt + ,` åpner historikken. For å bruke dem uten musen, trykk `Super + Ctrl + ,`. Den nyeste varslingen velges og knappene nummereres: trykk et tall for å bruke en, `Enter` for å klikke på varslingen, `↑` og `↓` for å flytte mellom varsler, `Delete` for å avvise en, og `Esc` for å gi tastaturet tilbake. Den slipper også taket av seg selv etter noen sekunders inaktivitet.

Å dempe varsler holder dem tilbake, unntatt Omarchys egne bekreftelser, nødvarsler og verifiseringskoder, som du ba om for et øyeblikk siden. Sett de siste få tilbake på skjermen, holdt tilbake eller ikke, med `Super + Shift + Alt + ,`. Historikken oppbevares i én dag.

## Hurtigtastvarsler

### Dato og klokkeslett

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Vær

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Stedet oppdages fra IP-adressen din, noe som vanligvis er nær nok, men ikke alltid. Du kan presisere det med `omarchy weather location --set Malibu`, eller være nøyaktig ved å legge til koordinater: `omarchy weather location --set Malibu 34.0259,-118.7798`. Kjør `omarchy weather location` på egen hånd for å se hvor den tror du er, og `--clear` for å gå tilbake til automatisk oppdagelse.

### Batteri

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
