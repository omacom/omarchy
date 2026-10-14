# Brytere, inaktivitet og skjermspareren

Mye av det du endrer til daglig er ikke egentlig en innstilling. Det er en modus du slår på i en time og av igjen: nattlys mens du jobber sent, ikke forstyrr mens du presenterer, hold våken mens du ser på noe. Omarchy kaller dem brytere, og de fungerer alle på samme måte — en snarvei, en menyoppføring og en kommando, som alle treffer samme bryter.

### Brytermenyen

`Super + Ctrl + O` åpner _Utløs > Av/på_ direkte, eller du kan gå dit fra Omarchy-menyen (`Super + Space`). Alt i den listen er en bryter du kan vippe uten å tenke på hvor tilstanden bor. Brytere for hvordan skrivebordet ser ut sitter ved siden av den, under _Utløs > Utseende_.

Fra terminalen er de samme bryterne `omarchy toggle <thing>`. Kjør `omarchy toggle` alene for å se hele gruppen.

| Bryter | Snarvei | Kommando |
| ------ | ------ | ------- |
| Nattlys | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Demp varsler | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Hold våken (ingen inaktivitetslås) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Krasjregistrering | — | `omarchy toggle crash-capture` |
| Skjermsparer | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev)-temasynk | — | `omarchy toggle theme sync` |
| Menylinje | `Super + Shift + Space` | `omarchy toggle bar` |
| Styreflate | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Berøringsskjerm | — | `omarchy toggle touchscreen` |
| Hvile | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Bryterne for styreflate, berøringsskjerm og hybrid GPU bor under _Utløs > Maskinvare_ (`Super + Ctrl + H`) snarere enn under Av/på, siden de bare vises når du faktisk har den maskinvaren. Bryterne for styreflate og berøringsskjerm overlever en Hyprland-reload — den deaktiverte enhetens navn lagres i en liten tilstandsfil som Hyprland leser ved oppstart for å deaktivere den igjen.

_Utløs > Utseende_ holder menylinjen og animasjoner, pluss noen få ting som ikke er `omarchy toggle`-kommandoer, men oppfører seg likt: batteriprosent i linjen, standard arbeidsområdelayout, vindusmellomrom (`Super + Shift + Backspace`) og 1-vindus-firkantforholdet (`Super + Ctrl + Backspace`).

De fleste av disse er bare en flaggfil under `~/.local/state/omarchy/toggles/`. Hvis du vil forgrene deg på én i et skript, gir `omarchy-toggle-enabled` deg en exit-kode i stedet for å få deg til å lete:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flaggene er navngitt etter av-tilstanden — `screensaver-off`, `suspend-off`, `bar-off` — så tilstedeværelsen deres betyr at funksjonen er deaktivert.

### Indikatorer i linjen

Når en modus er på, får du et lite tegn midt i menylinjen ved siden av klokken. Det er indikatorwidgeten, og den bærer diktering, skjermopptak, ventende påminnelser, nattlys, ikke forstyrr og hold våken.

Inaktive indikatorer er skjult. Hold over området rundt dem, og de toner seg inn dempet, slik at du kan klikke én for å slå den på uten å kjenne snarveien dens. Å klikke en aktiv én slår den av igjen. Hvis du heller vil se alle hele tiden, setter du `alwaysShow` til `true` på oppføringen `omarchy.indicators` i `~/.config/omarchy/shell.json` — se [menylinjen](05-the-top-bar.md) for hvordan linjewidgeter konfigureres.

### Nattlys

`Super + Ctrl + N` varmer skjermen til 4000K, og å trykke den igjen setter den tilbake til 6500K. Den drives av hyprsunset, som bryteren starter for deg hvis den ikke allerede kjører.

Som standard gjør hyprsunset ingenting med skjermen din i det hele tatt. `~/.config/hypr/hyprsunset.conf` leveres med en identitetsprofil nettopp slik at skjermen forblir urørt til du ber om varme. Hvis du heller vil at den skal bytte etter klokken, erstatter du det med en tidsprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Start deretter hyprsunset ved innlogging ved å legge til `o.launch_on_start("hyprsunset")` i `~/.config/hypr/autostart.lua`. Paret 4000K/6500K som bryteren bruker er fast, så konfigurasjonsfilen er dit du går hvis du vil ha en annen temperatur.

### Ikke forstyrr

`Super + Ctrl + ,` demper varsler. Ingen toast-er dukker opp mens den er på, og indikatoren med den utkryssede klokken sitter i linjen for å minne deg på hvorfor skrivebordet har blitt stille.

Ingenting går likevel tapt. Et dempet varsel skrives rett inn i varslingshistorikken din, som er nøyaktig den loggen du vil ha når du kommer tilbake og lurer på hva du gikk glipp av. Åpne den med `Super + Shift + Alt + ,`. Se [varslingsblikker](10-notices.md) for resten av varslingshistorien.

To typer meldinger slipper fortsatt gjennom: Omarchys egne bekreftels-toast-er for noe du nettopp gjorde («Theme changed», «Screenshot saved»), og kritiske varsler sendt fra kommandolinjen. Chat-apper som markerer alt som kritisk for å tvinge seg frem foran deg, kvalifiserer ikke.

### Inaktivitet

Omarchy-skallet eier inaktivitetsatferden, og timingene er en `idle`-blokk på øverste nivå i `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Begge tallene er sekunder telt fra øyeblikket du ble inaktiv — ikke fra hverandre. Så med standardinnstillingene kommer skjermspareren opp etter to og et halvt minutt, og låseskjermen tar over ved fem minutter, enten skjermspareren kjørte eller ikke. Lagre filen, og skallet plukker opp de nye timingene med en gang.

Hvis du avbryter skjermspareren før låsfristen, regnes det som aktivitet, og den ventende låsen avlyses. Du låses ikke ute for å kikke på maskinen din.

For å stoppe låsing ved inaktivitet helt, vipper `Super + Ctrl + I` — eller `omarchy toggle idle` — hold våken på, og kaffekoppindikatoren dukker opp i linjen. Det er den du skal trykke før en lang presentasjon eller en bygging du vil se på. Trykk den igjen for å gå tilbake til normalen. `omarchy toggle idle status` skriver ut gjeldende tilstand som JSON hvis du trenger den fra et skript.

Dette handler om låsing og skjermspareren, ikke strøm. Hvile og dvale har sitt eget oppsett i [systemsøvn](36-system-sleep.md).

### Skjermspareren

Omarchys skjermsparer er ASCII-kunst som kjører gjennom tilfeldige teksteffekter, én instans per skjerm. Enhver tast eller musebevegelse avslutter den.

Du kan starte den på forespørsel fra _System > Skjermsparer_ (`Super + Esc`), som tvinger den opp selv om du har slått av den inaktive skjermspareren. Det er ingen snarvei bundet til den som standard.

`omarchy toggle screensaver` er det som slår av den inaktive, hvis du heller vil gå rett fra arbeid til låst. Den trenger en terminal den vet hvordan den konfigureres — Alacritty, Foot, Ghostty eller Kitty — og sier fra hvis standardterminalen din er noe annet.

Logoen den tegner er din å endre, under _Stil > Skjermsparer_. Last opp en png eller svg, og Omarchy konverterer den til ASCII. Se [merkevarebygging](41-branding.md).

### Låseskjermen

`Super + Ctrl + L` låser maskinen. Det kjører låseskjermen fra Omarchy-skallet, blanker skjermen, tilbakestiller tastaturoppsettet ditt til det første slik at du ikke skriver passordet ditt i feil alfabet, og — hvis du har den kjørende — låser 1Password på vei ut.

Låseskjermen tar et passord, og den tar et fingeravtrykk også når du har satt opp ett. Det, og de andre måtene å autentisere seg på, dekkes i [maskinvareautentisering](37-hardware-authentication.md).
