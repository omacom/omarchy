# Dotfiles

Omarchy konfigureres primært gjennom de såkalte dotfiles som ligger i `~/.config`. De regnes som dine filer for dine endringer. Filene som ligger i `/usr/share/omarchy`, tilhører selve Omarchy, og du bør ikke tukle med dem. Hvis du trenger å endre noe i `/usr/share/omarchy`, bør du i stedet overstyre verdien i `~/.config`.

De viktigste konfigurasjonene kan redigeres rett fra Omarchy-menyen (`Super + Space`), som _Setup > Keybindings_, _Setup > Input_ og _Setup > Config > [file]_. Når du gjør det på denne måten, vil enhver prosess som trenger omstart etter konfigurasjonsendringer, automatisk bli startet på nytt etter at du avslutter redigeringsprogrammet (Neovim som standard — `:wq`, husk det! — men du kan endre det via _Setup > Defaults > Editor_).

Her er en liste over de viktigste filene i `~/.config` og hva de styrer:

| Fil | Formål |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hovedkonfigurasjonen for Hyprland. Laster standardinnstillingene fra Omarchy pluss overstyringsfilene dine nedenfor. [Les mer om Hyprland-konfigurasjoner](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | Dine egne tastebindinger og overstyringer av standardene. |
| `~/.config/hypr/monitors.lua` | Skjerminnstillinger som skjermpanelet ikke dekker, som rotasjon, ekstra moduser eller å holde en skjerm avskrudd. |
| `~/.config/hypr/input.lua` | Styrer tastaturoppsettet, musen og styreflateinnstillingene dine. |
| `~/.config/hypr/looknfeel.lua` | Styrer mellomrom, kanter, animasjoner og resten av utseendet. |
| `~/.config/hypr/autostart.lua` | Styrer ekstra prosesser som startes med økten. |
| `~/.config/omarchy/shell.json` | Styrer Omarchy-skallet: plassering av linjen, oppsett og widgets, pluss tidspunkter for skjermsparer, lås og inaktivitet. |
| `~/.config/foot/foot.ini` | Styrer terminalen din (foot er standard). |
| `~/.XCompose` | Definerer emoji for hurtigtilgang og autofullføring av navn/e-post. Sørg for å kjøre `omarchy-restart-xcompose` etter at du har gjort endringer. |

Hvis du ender opp med å gjøre mange endringer for å tilpasse ditt eget oppsett, er det lurt å sikkerhetskopiere alle disse dotfiles. [Stow er en flott måte å gjøre det på](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Starte dine egne apper med økten

Hvis du vil at noe skal kjøre hver gang du logger inn — en synkroniseringsdaemon, en chat-app, ditt eget skript — legger du det i `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Det starter kommandoen som en del av økten, så den ryddes ordentlig opp når du logger ut igjen.

### Kjøre skript ved systemhendelser

Omarchy utløser hooks ved en håndfull tidspunkter, og du kan henge dine egne skript på dem. De ligger i `~/.config/omarchy/hooks/<event>.d/`, én mappe per hendelse, og hver kjørbar fil der inne kjøres når hendelsen inntreffer:

| Hendelse | Når den kjøres |
| ----- | ------------ |
| `post-boot` | Rett etter at skrivebordet har startet |
| `post-update` | Nær slutten av `omarchy update`, etter pakker, migreringer og omstart av tjenester, før mise-verktøy oppdateres |
| `pre-refresh-pacman` | Etter at `omarchy refresh pacman` har synkronisert pakkekonfigurasjonen på nytt, før den oppdaterer pakker; et kanalbytte kjører den under det samme oppdateringstrinnet |
| `theme-set` | Etter et temabytte (temanavn i `$1`) |
| `font-set` | Etter et skriftbytte (skriftnavn i `$1`) |
| `battery-low` | Når batteriet blir lavt (prosent i `$1`) |

`pre-refresh-pacman`-hooken er stedet der egendefinerte pakkebrønner eller `IgnorePkg`-linjer hører hjemme, siden den kjøres før pakketransaksjonen. Begge de oppdateringsrelaterte hookene kjøres som brukeren din etter at Omarchy har fjernet sin bufrede sudo-autorisasjon, så en hook som bruker `sudo`, trenger sin egen autorisasjon og kan be om passordet ditt.

Hver av disse mappene inneholder allerede en `.sample`-fil som viser hvordan en hook ser ut — fjern `.sample` fra navnet for å ta den i bruk. For å installere et skript du har skrevet et annet sted, bruker du `omarchy hook install post-boot ~/my-hook`, som kopierer det inn og gjør det kjørbart.

### Legge til dine egne menyoppføringer

Omarchy-menyen (`Super + Space`) kan utvides med dine egne rader ved å redigere `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Oppføringer er nøklet med en punktdelt id, og det er id-en som plasserer dem i treet, så `personal` vises på rotmenyen og `personal.notes` vises inni den:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Bruker du en eksisterende id på nytt, overstyrer du den raden i stedet for å legge til en ny. Filen leveres med alle tilgjengelige felt dokumentert som kommentarer.

### Legge til dine egne shell-eksporter, funksjoner og aliaser

Omarchy leveres med en haug ergonomiske aliaser og nyttige funksjoner, men det er svært vanlig å ville legge til sine egne. Du bør legge både aliaser, funksjoner og eksporter i `~/.bashrc`. Denne filen blir ikke overskrevet ved oppdateringer. Hvis du vil endre noen av standardinnstillingene i Omarchy, kan du også trygt legge dem til her.

### Angi miljøvariabler for skrivebordet

Eksporter for skrivebordsøkten hører hjemme i `~/.config/uwsm/env.d/`. Disse filene kjøres før skrivebordet ditt starter, så en shell-feil kan sende deg tilbake til innloggingsskjermen. Hold en fungerende terminal åpen mens du redigerer dem. For å deaktivere en overstyring flytter du den ut av `env.d`. Se [gjenoppretting av innlogging](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) hvis en endring hindrer innlogging.

### Endre interne Omarchy-filer

Se, dette er datamaskinen din. Du kan gjøre hva du vil med den, men jeg fraråder å gjøre endringer direkte i filene i `/usr/share/omarchy`. De tilhører Omarchy pacman-pakken, så endringene dine vil ganske enkelt bli overskrevet ved neste oppdatering. Du har det bedre med bare å overstyre standardverdier du ikke liker, i `~/.config/*`-mappen i stedet.

Du kan endre nesten alt på den måten, som standardtastebindingene. Bare rediger `~/.config/hypr/bindings.lua` for å for eksempel erstatte [Obsidian](https://obsidian.md/) med [Joplin](https://joplinapp.org/) (installer med `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` fjerner den eksisterende bindingen før den legger til erstatningen. Den tar de samme argumentene som `o.bind`, inkludert oppstartshjelpere og bindingsalternativer. Bruk `o.bind` for å legge til en binding, eller `hl.unbind` for å fjerne en uten å erstatte den.

Hvis du insisterer på å hacke på de interne Omarchy-filene, bytter du til dev-kanalen via _Update > Channel > Dev_. Det lenker Omarchy til en git-utsjekking av kildekoden i `~/omarchy`, som du fritt kan endre så mye du vil. Ingen her skal fortelle deg hva du skal gjøre!

### Tilbakestille eventuelle endringer

Hvis du ender opp med å rote til konfigurasjonene, kan du alltid tilbakestille dem til standardene via _Update > Config_ i Omarchy-menyen. Eller ved å kjøre `omarchy reinstall configs` for å tilbakestille alt.
