# Til/fra, ledig & pauseskærmen

Meget af det, du ændrer fra dag til dag, er egentlig ikke en indstilling. Det er en tilstand, du slår til i en time og fra igen: natlys, mens du arbejder sent, forstyr ikke, mens du præsenterer, hold vågen, mens du ser noget. Omarchy kalder dem til/fra-omskiftere, og de virker alle på samme måde — en genvejstast, en menupost og en kommando, der alle rammer den samme kontakt.

### Til/fra-menuen

`Super + Ctrl + O` åbner _Udløs > Til/fra_ direkte, eller du kan gå derhen fra Omarchy-menuen (`Super + Space`). Alt på den liste er en kontakt, du kan slå til eller fra uden at tænke over, hvor tilstanden bor. Kontakter til, hvordan skrivebordet ser ud, sidder ved siden af under _Udløs > Udseende_.

Fra terminalen er de samme kontakter `omarchy toggle <thing>`. Kør `omarchy toggle` for sig selv for at se hele gruppen.

| Til/fra | Genvejstast | Kommando |
| ------ | ------ | ------- |
| Natlys | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Slå notifikationer fra | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Hold vågen (ingen lås ved ledig) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Nedbrudsregistrering | — | `omarchy toggle crash-capture` |
| Pauseskærm | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) temasynk | — | `omarchy toggle theme sync` |
| Menulinje | `Super + Shift + Space` | `omarchy toggle bar` |
| Pegefelt | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Berøringsskærm | — | `omarchy toggle touchscreen` |
| Hvile | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Kontakterne til pegefelt, berøringsskærm og hybrid GPU bor under _Udløs > Hardware_ (`Super + Ctrl + H`) snarere end under Til/fra, da de kun vises, når du rent faktisk har den hardware. Pegefelt- og berøringsskærmskontakterne overlever en genindlæsning af Hyprland — den deaktiverede enheds navn gemmes i en lille tilstandsfil, som Hyprland læser ved opstart for at deaktivere den igen.

_Udløs > Udseende_ rummer menulinjen og animationerne plus et par ting, der ikke er `omarchy toggle`-kommandoer, men opfører sig på samme måde: batteriprocent på linjen, standardlayoutet for arbejdsområder, vinduesmellemrum (`Super + Shift + Backspace`) og 1-vindues kvadratisk format (`Super + Ctrl + Backspace`).

De fleste af disse er bare en flagfil under `~/.local/state/omarchy/toggles/`. Hvis du vil forgrene dig på én i et script, giver `omarchy-toggle-enabled` dig en afslutningskode i stedet for at få dig til at lede:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flaggene er navngivet efter fra-tilstanden — `screensaver-off`, `suspend-off`, `bar-off` — så deres tilstedeværelse betyder, at funktionen er deaktiveret.

### Indikatorer på linjen

Når en tilstand er slået til, får du et lille tegn i midten af menulinjen ved siden af uret. Det er indikatorwidget'en, og den bærer diktering, skærmoptagelse, ventende påmindelser, natlys, forstyr ikke og hold vågen.

Inaktive indikatorer er skjulte. Hold musen over området omkring dem, og de toner frem nedtonet, så du kan klikke på én for at slå den til uden at kende dens genvejstast. Et klik på en aktiv slår den fra igen. Hvis du hellere vil se dem alle hele tiden, skal du sætte `alwaysShow` til `true` på posten `omarchy.indicators` i `~/.config/omarchy/shell.json` — se [menulinjen](05-the-top-bar.md) for, hvordan linjewidgets konfigureres.

### Natlys

`Super + Ctrl + N` varmer skærmen til 4000 K, og et nyt tryk sætter den tilbage til 6500 K. Den drives af hyprsunset, som omskifteren starter for dig, hvis den ikke allerede kører.

Som standard gør hyprsunset slet ingenting ved din skærm. `~/.config/hypr/hyprsunset.conf` leveres med en identitetsprofil netop for at skærmen forbliver uberørt, indtil du beder om varme. Hvis du hellere vil have den til at skifte efter uret, skal du erstatte det med en tidsprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Start derefter hyprsunset ved login ved at tilføje `o.launch_on_start("hyprsunset")` til `~/.config/hypr/autostart.lua`. Parret 4000 K/6500 K, som omskifteren bruger, er fast, så konfigurationsfilen er der, du går hen, hvis du vil have en anden temperatur.

### Forstyr ikke

`Super + Ctrl + ,` slår notifikationer fra. Ingen toasts popper op, mens den er slået til, og indikatoren med den overkrydsede klokke sidder på linjen for at minde dig om, hvorfor skrivebordet er blevet stille.

Intet går dog tabt. En dæmpet notifikation skrives direkte ind i din notifikationshistorik, hvilket er præcis den optegnelse, du ønsker, når du kommer tilbage og undrer dig over, hvad du gik glip af. Åbn den med `Super + Shift + Alt + ,`. Se [meddelelser](10-notices.md) for resten af notifikationshistorien.

To slags beskeder kommer stadig igennem: Omarchys egne bekræftelsestoasts for noget, du lige har gjort ("Theme changed", "Screenshot saved"), og kritiske alarmer sendt fra kommandolinjen. Chatapps, der markerer alt som kritisk for at tvinge sig vej ind foran dig, kvalificerer sig ikke.

### Ledig

Omarchy-shell'en ejer ledig-adfærden, og tiderne er en `idle`-blok på øverste niveau i `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Begge tal er sekunder regnet fra det øjeblik, du gik i ledig — ikke fra hinanden. Så med standarderne kommer pauseskærmen frem efter to og et halvt minut, og låseskærmen overtager ved fem minutter, uanset om pauseskærmen kørte eller ej. Gem filen, og shell'en fanger de nye tider med det samme.

Hvis du afviser pauseskærmen før låsefristen, tæller det som aktivitet, og den ventende lås annulleres. Du bliver ikke låst ude for at kaste et blik på din maskine.

For helt at stoppe låsning ved ledig slår `Super + Ctrl + I` — eller `omarchy toggle idle` — hold vågen til, og kaffekopindikatoren vises på linjen. Det er den, du skal trykke på før en lang præsentation eller en build, du vil holde øje med. Tryk på den igen for at gå tilbage til normal. `omarchy toggle idle status` udskriver den aktuelle tilstand som JSON, hvis du har brug for den fra et script.

Det handler om låsning og pauseskærmen, ikke strøm. Hvile og dvale har deres egen opsætning i [systemsøvn](36-system-sleep.md).

### Pauseskærmen

Omarchys pauseskærm er ASCII-kunst, der kører gennem tilfældige teksteffekter, én instans pr. skærm. Enhver tast eller musebevægelse afslutter den.

Du kan starte den efter behov fra _System > Pauseskærm_ (`Super + Esc`), som tvinger den frem, selvom du har slået ledig-pauseskærmen fra. Der er ingen genvejstast bundet til den som standard.

`omarchy toggle screensaver` er det, der slår den ledige fra, hvis du hellere vil gå direkte fra arbejde til låst. Den har brug for en terminal, den ved, hvordan den skal konfigurere — Alacritty, Foot, Ghostty eller Kitty — og vil fortælle dig det, hvis din standardterminal er noget andet.

Logoet, den tegner, er dit at ændre under _Stil > Pauseskærm_. Upload en png eller svg, og Omarchy konverterer den til ASCII. Se [branding](41-branding.md).

### Låseskærmen

`Super + Ctrl + L` låser maskinen. Det kører låseskærmen fra Omarchy-shell'en, slukker skærmen, nulstiller dit tastaturlayout til det første, så du ikke skriver din adgangskode i det forkerte alfabet, og låser — hvis du har det kørende — 1Password på vej ud.

Låseskærmen tager en adgangskode, og den tager også et fingeraftryk, når du har sat ét op. Det og de andre måder at godkende på er beskrevet i [hardwaregodkendelse](37-hardware-authentication.md).
