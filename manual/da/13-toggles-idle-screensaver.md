# Kontakter, inaktivitet og pauseskærmen

En stor del af det, du ændrer fra dag til dag, er egentlig ikke en indstilling. Det er en tilstand, du slår til i en time og fra igen: natlys, mens du arbejder sent, forstyr ikke, mens du præsenterer, hold vågen, mens du ser noget. Omarchy kalder dem kontakter, og de fungerer alle på samme måde — en genvejstast, et menupunkt og en kommando, der alle rammer den samme kontakt.

### Kontaktmenuen

`Super + Ctrl + O` åbner _Udløser > Kontakt_ direkte, eller du kan gå dertil fra Omarchy-menuen (`Super + Space`). Alt på den liste er en kontakt, du kan slå til og fra uden at tænke over, hvor tilstanden bor. Kontakter for, hvordan skrivebordet ser ud, sidder ved siden af den under _Udseende_.

Fra terminalen er de samme kontakter `omarchy toggle <thing>`. Kør `omarchy toggle` alene for at se hele gruppen.

| Kontakt | Genvejstast | Kommando |
| ------ | ------ | ------- |
| Natlys | — | `omarchy toggle nightlight` |
| Slå notifikationer fra | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Hold vågen (ingen lås ved inaktivitet) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Nedbrudsopsamling | — | `omarchy toggle crash-capture` |
| Pauseskærm | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev)-temasynkronisering | — | `omarchy toggle theme sync` |
| Menulinje | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Berøringsskærm | — | `omarchy toggle touchscreen` |
| Suspendér | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Kontakterne til touchpad, berøringsskærm og hybrid GPU bor under _Udløser > Hardware_ (`Super + Ctrl + H`) i stedet for under Kontakt, da de kun vises, når du faktisk har den hardware. Kontakterne til touchpad og berøringsskærm overlever en genindlæsning af Hyprland — navnet på den deaktiverede enhed gemmes i en lille tilstandsfil, som Hyprland læser ved opstart for at deaktivere den igen.

_Udseende_ rummer menulinjen og animationer plus et par ting, der ikke er `omarchy toggle`-kommandoer, men opfører sig på samme måde: batteriprocent i linjen, standardlayoutet for arbejdsområder og under _Vinduer_, vinduesmellemrum (`Super + Shift + Backspace`) og det kvadratiske format til 1 vindue (`Super + Ctrl + Backspace`).

De fleste af disse er bare en flagfil under `~/.local/state/omarchy/toggles/`. Hvis du vil forgrene på en af dem i et script, giver `omarchy-toggle-enabled` dig en exit-kode i stedet for at tvinge dig til selv at gå på jagt:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flagene er opkaldt efter fra-tilstanden — `screensaver-off`, `suspend-off`, `bar-off` — så deres tilstedeværelse betyder, at funktionen er deaktiveret.

### Indikatorer i linjen

Når en tilstand er slået til, får du et lille ikon midt på den øverste linje ved siden af uret. Det er indikator-widgetten, og den bærer diktering, skærmoptagelse, ventende påmindelser, natlys, forstyr ikke og hold vågen.

Inaktive indikatorer er skjulte. Hold musen et hvilket som helst sted på linjen, og de toner frem nedtonet, så du kan klikke på en for at slå den til uden at kende dens genvejstast. Klik på en aktiv indikator for at slå den fra igen. Hvis du hellere vil se dem alle hele tiden, så sæt `alwaysShow` til `true` på `omarchy.indicators`-posten i `~/.config/omarchy/shell.json` — se [den øverste linje](05-the-top-bar.md) for, hvordan widgets i linjen konfigureres.

### Natlys

Natlys varmer skærmen til 4000K, og slår du det fra igen, sættes den tilbage til 6500K. Slå det til og fra fra kontaktmenuen (`Super + Ctrl + O`) eller med `omarchy toggle nightlight`. Det drives af hyprsunset, som kontakten starter for dig, hvis det ikke allerede kører.

Som standard gør hyprsunset slet ikke noget ved din skærm. `~/.config/hypr/hyprsunset.conf` leveres med en identitetsprofil, netop så skærmen forbliver urørt, indtil du beder om varme. Hvis du hellere vil have, at det skifter efter uret, så erstat den med en tidsprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Start derefter hyprsunset ved login ved at tilføje `o.launch_on_start("hyprsunset")` til `~/.config/hypr/autostart.lua`. 4000K/6500K-parret, som kontakten bruger, er fast, så konfigurationsfilen er der, hvor du går hen, hvis du vil have en anden temperatur.

### Forstyr ikke

`Super + Ctrl + Alt + ,` slår notifikationer fra. Ingen toasts dukker op, mens det er slået til, og indikatoren med den overstregede klokke sidder i linjen for at minde dig om, hvorfor skrivebordet er blevet stille.

Intet går dog tabt. Notifikationer, der er slået fra, holdes tilbage: Sæt de seneste par tilbage på skærmen med `Super + Shift + Alt + ,`. Se [meddelelser](10-notices.md) for resten.

To slags beskeder slipper stadig igennem: Omarchys egne bekræftelsestoasts for noget, du lige har gjort ("Theme changed", "Screenshot saved"), og kritiske advarsler sendt fra kommandolinjen. Chatapps, der markerer alt som kritisk for at tvinge sig vej ind foran dig, kvalificerer ikke.

### Inaktivitet

Omarchy-skallen ejer inaktivitetsadfærden, og tiderne er en `idle`-blok på øverste niveau i `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Begge tal er sekunder talt fra det øjeblik, du blev inaktiv — ikke fra hinanden. Så med standardindstillingerne kommer pauseskærmen frem efter to et halvt minut, og låseskærmen tager over efter fem minutter, uanset om pauseskærmen kørte eller ej. Gem filen, og skallen opfanger de nye tider med det samme.

Hvis du afviser pauseskærmen før låsefristen, tæller det som aktivitet, og den ventende lås annulleres. Du bliver ikke låst ude for at kaste et blik på din maskine.

For helt at stoppe låsning ved inaktivitet slår `Super + Ctrl + I` — eller `omarchy toggle idle` — hold vågen til, og kaffekopindikatoren vises i linjen. Det er den, du skal ramme før en lang præsentation eller en build, du vil holde øje med. Slå den til igen for at vende tilbage til det normale. `omarchy toggle idle status` udskriver den aktuelle tilstand som JSON, hvis du har brug for den fra et script.

Dette handler om låsning og pauseskærmen, ikke om strøm. Suspendér og dvale har deres egen opsætning i [systemdvale](36-system-sleep.md).

### Pauseskærmen

Omarchys pauseskærm er ASCII-kunst, der kører gennem tilfældige teksteffekter, én instans pr. skærm. Enhver tast eller musebevægelse afslutter den.

Du kan starte den efter behov fra _System > Pauseskærm_ (`Super + Esc`), hvilket tvinger den frem, selv om du har slået pauseskærmen ved inaktivitet fra. Der er som standard ikke bundet nogen genvejstast til den.

`omarchy toggle screensaver` er det, der slår den ved inaktivitet fra, hvis du hellere vil gå direkte fra arbejde til låst. Enhver tast, ethvert klik, rul eller enhver musebevægelse lukker den.

Det logo, den tegner, kan du selv ændre under _Udseende > Branding > Pauseskærm_. Upload en png eller svg, og Omarchy konverterer den til ASCII. Se [branding](41-branding.md).

### Låseskærmen

`Super + Ctrl + L` låser maskinen. Det kører låseskærmen fra Omarchy-skallen, blanker skærmen, nulstiller dit tastaturlayout til det første, så du ikke skriver din adgangskode i det forkerte alfabet, og — hvis du har den kørende — låser 1Password på vej ud.

Låseskærmen tager en adgangskode, og den tager også et fingeraftryk, når du først har sat et op. Det og de andre måder at godkende på er dækket i [hardwaregodkendelse](37-hardware-authentication.md).
