# Brytere, inaktivitet og skjermbespareren

Mye av det du endrer til daglig er egentlig ikke en innstilling. Det er en modus du slår på i en time og av igjen: nattlys mens du jobber sent, ikke forstyrr mens du presenterer, hold deg våken mens du ser på noe. Omarchy kaller dem brytere, og de fungerer alle på samme måte — en hurtigtast, et menyelement og en kommando, alle mot samme bryter.

### Brytermenyen

`Super + Ctrl + O` åpner _Utløser > Bryter_ direkte, eller du kan gå dit fra Omarchy-menyen (`Super + Space`). Alt på den listen er en bryter du kan slå av og på uten å tenke på hvor tilstanden bor. Brytere for hvordan skrivebordet ser ut ligger ved siden av, under _Utseende_.

Fra terminalen er de samme bryterne `omarchy toggle <thing>`. Kjør `omarchy toggle` alene for å se hele gruppen.

| Bryter | Hurtigtast | Kommando |
| ------ | ------ | ------- |
| Nattlys | — | `omarchy toggle nightlight` |
| Demp varsler | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Hold deg våken (ingen lås ved inaktivitet) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Krasjfangst | — | `omarchy toggle crash-capture` |
| Skjermbesparer | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) temasynk | — | `omarchy toggle theme sync` |
| Menylinje | `Super + Shift + Space` | `omarchy toggle bar` |
| Styreplate | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Berøringsskjerm | — | `omarchy device touchscreen` |
| Hvilemodus | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Bryterne for styreplate, berøringsskjerm og hybrid GPU finnes under _Utløser > Maskinvare_ (`Super + Ctrl + H`) i stedet for under Bryter, siden de bare vises når du faktisk har den maskinvaren. Bryterne for styreplate og berøringsskjerm overlever en gjeninnlasting av Hyprland — navnet på den deaktiverte enheten lagres i en liten tilstandsfil som Hyprland leser ved oppstart for å deaktivere den igjen.

_Utseende_ rommer menylinjen og animasjoner, i tillegg til noen få ting som ikke er `omarchy toggle`-kommandoer, men oppfører seg på samme måte: batteriprosent i linjen, standardoppsettet for arbeidsområder, og under _Vinduer_, vindusavstand (`Super + Shift + Backspace`) og det kvadratiske sideforholdet for 1 vindu (`Super + Ctrl + Backspace`).

Når Hyprland ikke har noen GPU å tegne med og i stedet rendrer på CPU-en (llvmpipe), som på Mac-er der GPU-en ennå ikke støttes, i de fleste virtuelle maskiner, eller når en grafikkdriver ikke lastes, slår Omarchy av animasjoner, uskarphet og skygger for den økten og forteller deg det én gang med et varsel. _Utseende > Animasjoner på_ slår dem på igjen, og Omarchy husker det også for senere økter.

De fleste av disse er bare en flaggfil under `~/.local/state/omarchy/toggles/`. Hvis du vil forgrene på en av dem i et skript, gir `omarchy-toggle-enabled` deg en avslutningskode i stedet for å tvinge deg til å lete:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flaggene er oppkalt etter av-tilstanden — `screensaver-off`, `suspend-off`, `bar-off` — så at de finnes betyr at funksjonen er deaktivert.

### Indikatorer i linjen

Når en modus er på, får du et lite tegn midt på den øverste linjen ved siden av klokken. Det er indikatorwidgeten, og den rommer diktering, skjermopptak, ventende påminnelser, nattlys, ikke forstyrr og hold deg våken.

Inaktive indikatorer er skjult. Hold pekeren hvor som helst over linjen, og de tones inn nedtonet, så du kan klikke på en for å slå den på uten å kjenne hurtigtasten. Å klikke på en aktiv en slår den av igjen. Hvis du heller vil se alle sammen hele tiden, setter du `alwaysShow` til `true` på `omarchy.indicators`-oppføringen i `~/.config/omarchy/shell.json` — se [den øverste linjen](05-the-top-bar.md) for hvordan widgeter i linjen konfigureres.

### Nattlys

Nattlys varmer skjermen til 4000K, og å slå det av og på igjen setter den tilbake til 6500K. Slå det av og på fra brytermenyen (`Super + Ctrl + O`) eller med `omarchy toggle nightlight`. Det drives av hyprsunset, som bryteren starter for deg hvis den ikke allerede kjører.

Som standard gjør ikke hyprsunset noe som helst med skjermen din. `~/.config/hypr/hyprsunset.conf` leveres med en identitetsprofil nettopp for at skjermen skal forbli urørt til du ber om varme. Hvis du heller vil at det skal bytte etter klokken, erstatter du den med en tidsprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Start deretter hyprsunset ved innlogging ved å legge til `o.launch_on_start("hyprsunset")` i `~/.config/hypr/autostart.lua`. Paret 4000K/6500K som bryteren bruker er fast, så konfigurasjonsfilen er stedet du går til hvis du vil ha en annen temperatur.

### Ikke forstyrr

`Super + Ctrl + Alt + ,` demper varsler. Ingen meldinger spretter opp mens det er på, og den overstrøkne bjelleindikatoren sitter i linjen for å minne deg på hvorfor skrivebordet har blitt stille.

Ingenting går tapt, likevel. Dempede varsler holdes tilbake: legg de siste få tilbake på skjermen med `Super + Shift + Alt + ,`. Se [varsler](10-notices.md) for resten.

To typer meldinger slipper fortsatt gjennom: Omarchys egne bekreftelsesmeldinger for noe du nettopp gjorde ("Theme changed", "Screenshot saved"), og kritiske varsler sendt fra kommandolinjen. Chat-apper som markerer alt som kritisk for å tvinge seg foran deg, kvalifiserer ikke.

### Inaktivitet

Omarchy-skallet eier atferden ved inaktivitet, og tidspunktene er en `idle`-blokk på toppnivå i `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Begge tallene er sekunder regnet fra øyeblikket du ble inaktiv — ikke fra hverandre. Så med standardinnstillingene kommer skjermbespareren opp etter to og et halvt minutt, og låseskjermen tar over etter fem minutter, enten skjermbespareren kjørte eller ikke. Lagre filen, og skallet plukker opp de nye tidspunktene med en gang.

Hvis du avviser skjermbespareren før låsefristen, regnes det som aktivitet, og den ventende låsen avbrytes. Du blir ikke låst ute for å kaste et blikk på maskinen din.

For å stoppe låsing ved inaktivitet helt slår `Super + Ctrl + I` — eller `omarchy toggle idle` — på hold deg våken, og kaffekoppindikatoren vises i linjen. Det er den du trykker på før en lang presentasjon eller et bygg du vil følge med på. Trykk på den igjen for å gå tilbake til normalt. `omarchy toggle idle status` skriver ut nåværende tilstand som JSON hvis du trenger den fra et skript.

Dette handler om låsing og skjermbespareren, ikke om strøm. Hvilemodus og dvalemodus har sitt eget oppsett i [systemhvile](36-system-sleep.md).

### Skjermbespareren

Omarchys skjermbesparer er ASCII-kunst som kjører gjennom tilfeldige teksteffekter, én forekomst per skjerm. Enhver tast eller musebevegelse avslutter den.

Du kan starte den på forespørsel fra _System > Skjermbesparer_ (`Super + Esc`), som tvinger den opp selv om du har slått skjermbespareren ved inaktivitet av. Det er ingen hurtigtast bundet til den som standard.

`omarchy toggle screensaver` er det som slår den ved inaktivitet av, hvis du heller vil gå rett fra arbeid til låst. Enhver tast, klikk, rulling eller musebevegelse lukker den.

Logoen den tegner kan du endre, under _Utseende > Merkevare > Skjermbesparer_. Last opp en png eller svg, og Omarchy konverterer den til ASCII. Se [merkevare](41-branding.md).

### Låseskjermen

`Super + Ctrl + L` låser maskinen. Det kjører låseskjermen fra Omarchy-skallet, gjør skjermen tom, tilbakestiller tastaturoppsettet ditt til det første, så du ikke skriver passordet ditt med feil alfabet, og — hvis du har den kjørende — låser 1Password på vei ut.

Låseskjermen tar et passord, og den tar også et fingeravtrykk når du har satt opp ett. Det, og de andre måtene å autentisere på, dekkes i [maskinvareautentisering](37-hardware-authentication.md).
