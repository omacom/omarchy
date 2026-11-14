# Varsler

Varsler vises øverst til høyre på skjermen som har fokus. Du kan også raskt få tilgang til dato og klokkeslett, batteristatus og aktuelt vær med hurtigtastvarslene.

## Varsler

Varsler fra samme app eller nettsted stables i en bunke, så en pratsom Slack-kanal ikke skyver byggfeilen din ut av skjermen. Hold pekeren over en bunke for å spre den ut; ingenting nytt glir inn under pekeren mens du leser. Klikk på et kort for å hoppe til der det kom fra, høyreklikk, midtklikk eller trykk på ✕ for å avvise det.

Kortene tilbyr det de bærer: _Kopier kode_ for verifiseringskoder (holdes ute av [utklippstavlehistorikken](08-unified-clipboard-history.md) og slettes etter ett minutt), pluss eventuelle knapper appen tilbyr. Lenker i teksten i et varsel åpnes når du klikker på dem.

For å bruke dem uten musen trykker du på `Super + Ctrl + ,`. Det nyeste varselet er valgt og knappene til det er nummerert: trykk på et tall for å bruke en, `Enter` for å klikke på varselet, `↑` og `↓` for å flytte mellom varsler, `Delete` for å avvise ett, og `Esc` for å gi tastaturet tilbake. Det slipper også taket på egen hånd etter noen sekunders inaktivitet.

Å dempe varsler holder dem tilbake, unntatt Omarchys egne bekreftelser, nødvarsler og verifiseringskoder, som du ba om for et øyeblikk siden. Sett de siste få tilbake på skjermen, holdt tilbake eller ikke, med `Super + Shift + Alt + ,`. Historikken oppbevares i én dag.

## Hurtigtastvarsler

### Dato og klokkeslett

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Vær

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Stedet oppdages fra IP-adressen din, som vanligvis er nær nok, men ikke alltid. Du kan presisere det med `omarchy weather location --set Malibu`, eller være nøyaktig ved å legge til koordinater: `omarchy weather location --set Malibu 34.0259,-118.7798`. Kjør `omarchy weather location` på egen hånd for å se hvor den tror du er, og `--clear` for å gå tilbake til automatisk oppdagelse.

### Batteri

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
