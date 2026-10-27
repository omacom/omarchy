# Vekslebrytere, inaktivitet og skjermspareren

Mye av det du endrer fra dag til dag, er egentlig ikke en innstilling. Det er en modus du slår på i en time og av igjen: nattlys mens du jobber sent, ikke forstyrr mens du presenterer, hold deg våken mens du ser på noe. Omarchy kaller dem vekslebrytere, og alle fungerer på samme måte — en hurtigtast, et menyelement og en kommando treffer alle den samme bryteren.

### Vekslemenyen

`Super + Ctrl + O` åpner _Trigger > Toggle_ direkte, eller du kan gå dit fra Omarchy-menyen (`Super + Space`). Alt i den listen er en bryter du kan vippe på uten å tenke over hvor tilstanden bor. Brytere for hvordan skrivebordet ser ut, ligger ved siden av, under _Appearance_.

Fra terminalen er de samme bryterne `omarchy toggle <thing>`. Kjør `omarchy toggle` alene for å se hele gruppen.

| Vekslebryter | Hurtigtast | Kommando |
| ------ | ------ | ------- |
| Nattlys | — | `omarchy toggle nightlight` |
| Demp varsler | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Hold deg våken (ingen inaktiv lås) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Krasjfangst | — | `omarchy toggle crash-capture` |
| Skjermsparer | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev)-temasynkronisering | — | `omarchy toggle theme sync` |
| Menylinje | `Super + Shift + Space` | `omarchy toggle bar` |
| Styreplate | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Berøringsskjerm | — | `omarchy toggle touchscreen` |
| Hvilemodus | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Bryterne for styreplate, berøringsskjerm og hybrid GPU bor under _Trigger > Hardware_ (`Super + Ctrl + H`) i stedet for under Toggle, siden de bare vises når du faktisk har den maskinvaren. Bryterne for styreplate og berøringsskjerm overlever en omlasting av Hyprland — navnet på den deaktiverte enheten lagres i en liten tilstandsfil som Hyprland leser ved oppstart for å deaktivere den igjen.

_Appearance_ rommer menylinjen og animasjoner, i tillegg til noen få ting som ikke er `omarchy toggle`-kommandoer, men oppfører seg på samme måte: batteriprosent i linjen, standardoppsettet for arbeidsområder, og under _Windows_, avstand mellom vinduer (`Super + Shift + Backspace`) og det kvadratiske sideforholdet for 1 vindu (`Super + Ctrl + Backspace`).

De fleste av disse er bare en flaggfil under `~/.local/state/omarchy/toggles/`. Hvis du vil forgrene på en av dem i et skript, gir `omarchy-toggle-enabled` deg en avslutningskode i stedet for å få deg til å gå og lete:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flaggene er oppkalt etter av-tilstanden — `screensaver-off`, `suspend-off`, `bar-off` — så tilstedeværelsen deres betyr at funksjonen er deaktivert.

### Indikatorer i linjen

Når en modus er på, får du et lite tegn midt i den øverste linjen ved siden av klokken. Det er indikator-widgeten, og den bærer diktering, skjermopptak, ventende påminnelser, nattlys, ikke forstyrr og hold deg våken.

Inaktive indikatorer er skjult. Hold musepekeren hvor som helst over linjen, og de toner inn dimmet, så du kan klikke på en for å slå den på uten å kjenne hurtigtasten dens. Klikker du på en aktiv en, slås den av igjen. Hvis du heller vil se alle sammen hele tiden, setter du `alwaysShow` til `true` på `omarchy.indicators`-oppføringen i `~/.config/omarchy/shell.json` — se [den øverste linjen](05-the-top-bar.md) for hvordan widgeter i linjen konfigureres.

### Nattlys

Nattlys varmer skjermen til 4000K, og å veksle den igjen setter den tilbake til 6500K. Vipp den fra vekslemenyen (`Super + Ctrl + O`) eller med `omarchy toggle nightlight`. Den drives av hyprsunset, som vekslebryteren starter for deg hvis den ikke allerede kjører.

Som standard gjør hyprsunset ingenting i det hele tatt med skjermen din. `~/.config/hypr/hyprsunset.conf` leveres med en identitetsprofil nettopp for at skjermen skal forbli urørt til du ber om varme. Hvis du heller vil ha den til å bytte etter klokken, erstatter du den med en tidsprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Start deretter hyprsunset ved innlogging ved å legge `o.launch_on_start("hyprsunset")` til i `~/.config/hypr/autostart.lua`. 4000K/6500K-paret som vekslebryteren bruker, er fast, så konfigurasjonsfilen er stedet du går til hvis du vil ha en annen temperatur.

### Ikke forstyrr

`Super + Ctrl + Alt + ,` demper varsler. Ingen varsler spretter opp mens den er på, og indikatoren med den utstrøkne bjellen sitter i linjen for å minne deg på hvorfor skrivebordet har blitt stille.

Ingenting går tapt, likevel. Dempede varsler holdes tilbake: Sett de siste par tilbake på skjermen med `Super + Shift + Alt + ,`. Se [varsler](10-notices.md) for resten.

To typer meldinger slipper fortsatt gjennom: Omarchys egne bekreftelsesvarsler for noe du akkurat gjorde ("Theme changed", "Screenshot saved"), og kritiske varsler sendt fra kommandolinjen. Chatteapper som merker alt som kritisk for å tvinge seg foran deg, kvalifiserer ikke.

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

Hvis du avviser skjermspareren før låsefristen, regnes det som aktivitet, og den ventende låsen avbrytes. Du blir ikke låst ute for å kaste et blikk på maskinen.

For å slutte å låse ved inaktivitet helt, slår `Super + Ctrl + I` — eller `omarchy toggle idle` — hold deg våken på, og kaffekopp-indikatoren vises i linjen. Det er den du skal trykke på før en lang presentasjon eller en byggjobb du vil følge med på. Trykk den igjen for å gå tilbake til normalt. `omarchy toggle idle status` skriver ut gjeldende tilstand som JSON hvis du trenger den fra et skript.

Dette handler om låsing og skjermspareren, ikke strøm. Hvilemodus og dvalemodus har sitt eget oppsett i [systemdvale](36-system-sleep.md).

### Skjermspareren

Omarchys skjermsparer er ASCII-kunst som kjører gjennom tilfeldige teksteffekter, én instans per skjerm. Enhver tast eller musebevegelse går ut av den.

Du kan starte den på forespørsel fra _System > Screensaver_ (`Super + Esc`), som tvinger den opp selv om du har slått den inaktive skjermspareren av. Det er ingen hurtigtast bundet til den som standard.

`omarchy toggle screensaver` er det som slår den inaktive av, hvis du heller vil gå rett fra arbeid til låst. Den trenger en terminal den vet hvordan den skal konfigurere — Alacritty, Foot, Ghostty eller Kitty — og vil fortelle deg det hvis standardterminalen din er noe annet.

Logoen den tegner, kan du endre, under _Appearance > Branding > Screensaver_. Last opp en png eller svg, og Omarchy konverterer den til ASCII. Se [profilering](41-branding.md).

### Låseskjermen

`Super + Ctrl + L` låser maskinen. Det kjører låseskjermen fra Omarchy-skallet, blanker skjermen, tilbakestiller tastaturoppsettet ditt til det første, så du ikke skriver passordet ditt med feil alfabet, og — hvis du har den kjørende — låser 1Password på vei ut.

Låseskjermen tar et passord, og den tar også et fingeravtrykk når du har satt opp ett. Det, og de andre måtene å autentisere på, dekkes i [maskinvareautentisering](37-hardware-authentication.md).
