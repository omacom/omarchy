# Brytere, inaktivitet og skjermspareren

Mye av det du endrer til daglig er egentlig ikke en innstilling. Det er en modus du slår på i en time og av igjen: nattlys mens du jobber sent, ikke forstyrr mens du presenterer, hold deg våken mens du ser på noe. Omarchy kaller dem brytere, og de fungerer alle på samme måte — en hurtigtast, et menyelement og en kommando, som alle treffer den samme bryteren.

### Brytermenyen

`Super + Ctrl + O` åpner _Trigger > Toggle_ direkte, eller du kan gå dit fra Omarchy-menyen (`Super + Space`). Alt i den listen er en bryter du kan veksle uten å tenke på hvor tilstanden lever. Brytere for hvordan skrivebordet ser ut sitter ved siden av, under _Appearance_.

Fra terminalen er de samme bryterne `omarchy toggle <thing>`. Kjør `omarchy toggle` alene for å se hele gruppen.

| Bryter | Hurtigtast | Kommando |
| ------ | ------ | ------- |
| Nattlys | — | `omarchy toggle nightlight` |
| Demp varsler | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Hold våken (ingen lås ved inaktivitet) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Krasjfangst | — | `omarchy toggle crash-capture` |
| Skjermsparer | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev)-temasynkronisering | — | `omarchy toggle theme sync` |
| Menylinje | `Super + Shift + Space` | `omarchy toggle bar` |
| Fullskjermskrivebord (ingen linje, ingen mellomrom) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animasjoner, uskarphet og skygger | — | `omarchy toggle animations` |
| Styreplate | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Berøringsskjerm | — | `omarchy device touchscreen` |
| Hvile | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy device gpu hybrid` |

Bryterne for styreplate, berøringsskjerm og hybrid GPU lever under _Trigger > Hardware_ (`Super + Ctrl + H`) i stedet for under Toggle, siden de bare vises når du faktisk har den maskinvaren. Bryterne for styreplate og berøringsskjerm overlever en omlasting av Hyprland — navnet på den deaktiverte enheten lagres i en liten tilstandsfil som Hyprland leser ved oppstart for å deaktivere den igjen.

_Appearance_ inneholder menylinjen og animasjoner, i tillegg til noen ting som ikke er `omarchy toggle`-kommandoer, men oppfører seg på samme måte: batteriprosent i linjen, standardoppsettet for arbeidsområder, og under _Windows_, vindusmellomrom (`Super + Shift + Backspace`) og den firkantede 1-vindusproporsjonen (`Super + Ctrl + Backspace`).

Når Hyprland ikke har noen GPU å tegne med og i stedet rendrer på CPU-en (llvmpipe), som på Mac-er der GPU-en ikke støttes ennå, i de fleste virtuelle maskiner, eller når en grafikkdriver ikke laster, slår Omarchy av animasjoner, uskarphet og skygger for den økten og forteller deg det én gang med et varsel. _Appearance > Animations On_ bringer dem tilbake, og Omarchy husker det også til senere økter.

De fleste av disse er bare en flaggfil under `~/.local/state/omarchy/toggles/`. Hvis du vil forgrene på en av dem i et skript, gir `omarchy-toggle-enabled` deg en avslutningskode i stedet for å få deg til å lete:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flaggene er oppkalt etter av-tilstanden — `screensaver-off`, `suspend-off`, `bar-off` — så betyr det at funksjonen er deaktivert når de finnes.

### Indikatorer i linjen

Når en modus er på, får du et lite tegn midt i den øverste linjen ved siden av klokken. Det er indikator-widgeten, og den bærer skjermopptak, ventende påminnelser, nattlys, ikke forstyrr og hold våken, i tillegg til advarsler mens passordløs sudo er på eller noen er koblet til en ekstern økt.

Inaktive indikatorer er skjult. Hold musepekeren hvor som helst over linjen, og de toner inn nedtonet, så du kan klikke på en for å slå den på uten å kjenne hurtigtasten. Å klikke på en aktiv en slår den av igjen. Hvis du heller vil se alle sammen hele tiden, setter du `alwaysShow` til `true` på `omarchy.indicators`-oppføringen i `~/.config/omarchy/shell.json` — se [den øverste linjen](05-the-top-bar.md) for hvordan widgeter i linjen konfigureres.

### Nattlys

Nattlys varmer skjermen til 4000K, og å veksle det igjen setter det tilbake til 6500K. Slå det på fra brytermenyen (`Super + Ctrl + O`) eller med `omarchy toggle nightlight`. Det drives av hyprsunset, som bryteren starter for deg hvis den ikke allerede kjører.

Som standard gjør hyprsunset ingenting med skjermen din i det hele tatt. `~/.config/hypr/hyprsunset.conf` leveres med en identitetsprofil nettopp for at skjermen skal forbli urørt til du ber om varme. Hvis du heller vil at den skal bytte etter klokken, erstatter du den med en tidsprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Start deretter hyprsunset ved innlogging ved å legge til `o.launch_on_start("hyprsunset")` i `~/.config/hypr/autostart.lua`. 4000K/6500K-paret som bryteren bruker, er fast, så konfigurasjonsfilen er stedet du går til hvis du vil ha en annen temperatur.

### Ikke forstyrr

`Super + Ctrl + Alt + ,` demper varsler. Ingen meldinger spretter opp mens den er på, og indikatoren med den overstrøkede bjellen sitter i linjen for å minne deg på hvorfor skrivebordet har blitt stille.

Ingenting går tapt likevel. Dempede varsler holdes tilbake: legg de siste få tilbake på skjermen med `Super + Shift + Alt + ,`. Se [varsler](10-notices.md) for resten.

Tre typer meldinger slipper fortsatt gjennom: Omarchys egne bekreftelsesmeldinger for noe du nettopp gjorde ("Theme changed", "Screenshot saved"), kritiske varsler sendt fra kommandolinjen og verifiseringskoder. Chat-apper som markerer alt som kritisk for å tvinge seg foran deg, kvalifiserer ikke.

### Inaktivitet

Omarchy-skallet eier inaktivitetsoppførselen, og tidene er en `idle`-blokk på øverste nivå i `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Begge tallene er sekunder regnet fra øyeblikket du ble inaktiv — ikke fra hverandre. Så med standardinnstillingene kommer skjermspareren opp etter to og et halvt minutt, og låseskjermen tar over etter fem minutter, enten skjermspareren kjørte eller ikke. Lagre filen, og skallet plukker opp de nye tidene med en gang.

Hvis du avviser skjermspareren før låsefristen, regnes det som aktivitet, og den ventende låsen avbrytes. Du blir ikke låst ute fordi du kastet et blikk på maskinen din.

For å stoppe låsing ved inaktivitet helt, slår `Super + Ctrl + I` — eller `omarchy toggle idle` — hold våken på, og kaffekoppindikatoren vises i linjen. Det er den du skal trykke på før en lang presentasjon eller en bygging du vil følge med på. Trykk på den igjen for å gå tilbake til normalt. `omarchy toggle idle status` skriver ut nåværende tilstand som JSON hvis du trenger den fra et skript.

Dette handler om låsing og skjermspareren, ikke strøm. Hvile og dvalemodus har sitt eget oppsett i [systemhvile](36-system-sleep.md).

### Skjermspareren

Omarchys skjermsparer er ASCII-kunst som kjører gjennom tilfeldige teksteffekter, én instans per skjerm. Enhver tast eller musebevegelse avslutter den.

Du kan starte den på forespørsel fra _System > Screensaver_ (`Super + Esc`), noe som tvinger den opp selv om du har slått av skjermspareren ved inaktivitet. Det er ingen hurtigtast bundet til den som standard.

`omarchy toggle screensaver` er det som slår av den ved inaktivitet, hvis du heller vil gå rett fra arbeid til låst. Enhver tast, klikk, rulling eller musebevegelse lukker den.

Logoen den tegner, er din å endre, under _Appearance > Branding > Screensaver_. Last opp en png eller svg, og Omarchy konverterer den til ASCII. Se [merkevarebygging](41-branding.md).

### Låseskjermen

`Super + Ctrl + L` låser maskinen. Det kjører låseskjermen fra Omarchy-skallet, blanker skjermen, tilbakestiller tastaturoppsettet ditt til det første, så du ikke skriver passordet ditt i feil alfabet, og — hvis du har det kjørende — låser 1Password på vei ut.

Låseskjermen tar et passord, og den tar også et fingeravtrykk når du har satt opp ett. Det, og de andre måtene å autentisere på, dekkes i [maskinvareautentisering](37-hardware-authentication.md).
