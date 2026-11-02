# Vekslebrytere, inaktivitet og skjermspareren

Mye av det du endrer til daglig er egentlig ikke en innstilling. Det er en modus du slår på i en time og av igjen: nattlys mens du jobber sent, ikke forstyrr mens du presenterer, hold våken mens du ser på noe. Omarchy kaller dem vekslebrytere, og de fungerer alle på samme måte — en hurtigtast, et menyelement og en kommando, alle rettet mot samme bryter.

### Vekslemenyen

`Super + Ctrl + O` åpner _Trigger > Toggle_ direkte, eller du kan gå dit fra Omarchy-menyen (`Super + Space`). Alt på den listen er en bryter du kan vippe over uten å tenke på hvor tilstanden bor. Brytere for hvordan skrivebordet ser ut, finner du ved siden av, under _Appearance_.

Fra terminalen er de samme bryterne `omarchy toggle <thing>`. Kjør `omarchy toggle` alene for å se hele gruppen.

| Vekslebryter | Hurtigtast | Kommando |
| ------ | ------ | ------- |
| Nattlys | — | `omarchy toggle nightlight` |
| Demp varsler | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Hold våken (ingen lås ved inaktivitet) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Krasjfangst | — | `omarchy toggle crash-capture` |
| Skjermsparer | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) temasynkronisering | — | `omarchy toggle theme sync` |
| Menylinje | `Super + Shift + Space` | `omarchy toggle bar` |
| Pekeplate | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Berøringsskjerm | — | `omarchy toggle touchscreen` |
| Hvilemodus | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Bryterne for pekeplate, berøringsskjerm og hybrid GPU bor under _Trigger > Hardware_ (`Super + Ctrl + H`) i stedet for under Toggle, siden de bare dukker opp når du faktisk har den maskinvaren. Bryterne for pekeplate og berøringsskjerm overlever en om lasting av Hyprland — navnet på den deaktiverte enheten lagres i en liten tilstandsfil som Hyprland leser ved oppstart for å deaktivere den igjen.

_Appearance_ inneholder menylinjen og animasjoner, pluss noen få ting som ikke er `omarchy toggle`-kommandoer, men oppfører seg likt: batteriprosent i linjen, standardoppsett for arbeidsområder, og under _Windows_, vindusavstand (`Super + Shift + Backspace`) og kvadratisk sideforhold for 1 vindu (`Super + Ctrl + Backspace`).

De fleste av disse er bare en flaggfil under `~/.local/state/omarchy/toggles/`. Hvis du vil forgrene på en av dem i et skript, gir `omarchy-toggle-enabled` deg en avslutningskode i stedet for å tvinge deg til å lete:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flaggene er oppkalt etter av-tilstanden — `screensaver-off`, `suspend-off`, `bar-off` — så tilstedeværelsen deres betyr at funksjonen er deaktivert.

### Indikatorer i linjen

Når en modus er på, får du et lite symbol midt på topplinjen ved siden av klokken. Det er indikator-widgeten, og den inneholder diktering, skjermopptak, ventende påminnelser, nattlys, ikke forstyrr og hold våken.

Inaktive indikatorer er skjult. Hold musepekeren hvor som helst over linjen, så toner de frem nedtonet, slik at du kan klikke på en for å slå den på uten å kunne hurtigtasten. Klikker du på en aktiv en, slår du den av igjen. Hvis du heller vil se alle sammen hele tiden, setter du `alwaysShow` til `true` på `omarchy.indicators`-oppføringen i `~/.config/omarchy/shell.json` — se [topplinjen](05-the-top-bar.md) for hvordan widgeter i linjen konfigureres.

### Nattlys

Nattlys varmer skjermen til 4000K, og vipper du den igjen, settes den tilbake til 6500K. Vipp den fra vekslemenyen (`Super + Ctrl + O`) eller med `omarchy toggle nightlight`. Den drives av hyprsunset, som vekslebryteren starter for deg hvis den ikke allerede kjører.

Som standard gjør hyprsunset overhodet ingenting med skjermen din. `~/.config/hypr/hyprsunset.conf` leveres med en identitetsprofil nettopp for at skjermen skal forbli urørt til du ber om varme. Hvis du heller vil at den skal bytte etter klokken, erstatter du den med en tidsprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Start deretter hyprsunset ved innlogging ved å legge til `o.launch_on_start("hyprsunset")` i `~/.config/hypr/autostart.lua`. Paret 4000K/6500K som vekslebryteren bruker, er fast, så konfigurasjonsfilen er stedet du går til hvis du vil ha en annen temperatur.

### Ikke forstyrr

`Super + Ctrl + Alt + ,` demper varsler. Ingen varsler dukker opp mens den er på, og indikatoren med den overstrøkne bjellen sitter i linjen for å minne deg på hvorfor skrivebordet har blitt stille.

Ingenting går tapt av den grunn. Dempede varsler holdes tilbake: legg de siste parene tilbake på skjermen med `Super + Shift + Alt + ,`. Se [varsler](10-notices.md) for resten.

To typer meldinger slipper fortsatt gjennom: Omarchys egne bekreftelsesvarsler for noe du akkurat gjorde ("Theme changed", "Screenshot saved"), og kritiske varsler sendt fra kommandolinjen. Chat-apper som merker alt som kritisk for å tvinge seg foran deg, kvalifiserer ikke.

### Inaktivitet

Omarchy-skallet eier inaktivitetsoppførselen, og tidene er en `idle`-blokk på toppnivå i `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Begge tallene er sekunder regnet fra øyeblikket du ble inaktiv — ikke fra hverandre. Så med standardverdiene kommer skjermspareren opp etter to og et halvt minutt, og låseskjermen tar over etter fem minutter, enten skjermspareren kjørte eller ikke. Lagre filen, så plukker skallet opp de nye tidene med en gang.

Hvis du avviser skjermspareren før låsefristen, regnes det som aktivitet, og den ventende låsen avbrytes. Du blir ikke låst ute for å kaste et blikk på maskinen.

For å stoppe låsing ved inaktivitet helt, vipper `Super + Ctrl + I` — eller `omarchy toggle idle` — hold våken på, og kaffekoppindikatoren vises i linjen. Det er den du trykker før en lang presentasjon eller en byggejobb du vil følge med på. Trykk den igjen for å gå tilbake til normalen. `omarchy toggle idle status` skriver ut gjeldende tilstand som JSON hvis du trenger den fra et skript.

Dette handler om låsing og skjermspareren, ikke om strøm. Hvilemodus og dvalemodus har sitt eget oppsett i [systemdvale](36-system-sleep.md).

### Skjermspareren

Omarchys skjermsparer er ASCII-kunst som kjøres gjennom tilfeldige teksteffekter, én forekomst per skjerm. Enhver tast eller musebevegelse avslutter den.

Du kan starte den på forespørsel fra _System > Screensaver_ (`Super + Esc`), som tvinger den opp selv om du har slått av skjermspareren ved inaktivitet. Det er ingen hurtigtast bundet til den som standard.

`omarchy toggle screensaver` er det som slår av den ved inaktivitet, hvis du heller vil gå rett fra arbeid til låst. Enhver tast, klikk, rulling eller musebevegelse lukker den.

Logoen den tegner, kan du endre selv, under _Appearance > Branding > Screensaver_. Last opp en png eller svg, så konverterer Omarchy den til ASCII. Se [profilering](41-branding.md).

### Låseskjermen

`Super + Ctrl + L` låser maskinen. Det kjører låseskjermen fra Omarchy-skallet, blanker skjermen, tilbakestiller tastaturoppsettet til det første, slik at du ikke skriver passordet ditt med feil alfabet, og — hvis du har den kjørende — låser 1Password på vei ut.

Låseskjermen tar et passord, og den tar også et fingeravtrykk når du har satt opp ett. Det, og de andre måtene å autentisere på, dekkes i [maskinvareautentisering](37-hardware-authentication.md).
