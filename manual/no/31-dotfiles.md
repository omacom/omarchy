# Dotfiles

Omarchy konfigureres først og fremst gjennom de såkalte dotfilene som ligger i `~/.config`. De regnes som dine filer for dine endringer. Filene som ligger i `/usr/share/omarchy`, tilhører Omarchy selv, og du bør ikke tukle med dem. Hvis du trenger å endre noe i `/usr/share/omarchy`, bør du overstyre verdien i `~/.config` i stedet.

Nøkkelkonfigurasjonene kan redigeres rett fra Omarchy-menyen (`Super + Space`), som _Oppsett > Tastatur > Tastebindinger_, _Oppsett > Inndata_ og _Oppsett > Konfigurasjon > [fil]_. Når du gjør det på denne måten, vil enhver prosess som må startes på nytt etter konfigurasjonsendringer, automatisk bli det etter at du avslutter redigeringsprogrammet (Neovim som standard — `:wq`, husk det! — men du kan endre det via _Oppsett > Standardvalg > Redigeringsprogram_).

Her er en liste over nøkkelfilene i `~/.config` og hva de styrer:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hovedkonfigurasjonen for Hyprland. Laster standardinnstillingene fra Omarchy pluss overstyringsfilene dine nedenfor. [Lær mer om Hyprland-konfigurasjoner](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Dine egne tastebindinger og overstyringer av standardinnstillingene. |
| `~/.config/hypr/monitors.lua` | Skjerminnstillinger som skjermpanelet ikke dekker, som rotasjon, ekstra moduser eller å holde en skjerm avskrudd. |
| `~/.config/hypr/input.lua` | Styrer tastaturoppsettet ditt, mus og styreflateinnstillinger. |
| `~/.config/hypr/looknfeel.lua` | Styrer mellomrom, kanter, animasjoner og resten av utseendet. |
| `~/.config/hypr/autostart.lua` | Styrer ekstra prosesser som startes med økten. |
| `~/.config/omarchy/shell.json` | Styrer Omarchy-skallet: posisjon for statuslinjen, oppsett og widgeter, pluss skjermsparer, lås og tidsavbrudd for inaktivitet. |
| `~/.config/foot/foot.ini` | Styrer terminalen din (foot er standard). |
| `~/.XCompose` | Definerer hurtigtilgangs-emoji og autofullføring for navn/e-post. Sørg for å kjøre `omarchy-restart-xcompose` etter at du har gjort endringer. |

Hvis du ender opp med å gjøre mange endringer for å finjustere ditt eget oppsett, er det en god idé å sikkerhetskopiere alle disse dotfilene. [Stow er en fin måte å gjøre det på](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Starte dine egne apper med økten

Hvis du vil at noe skal kjøre hver gang du logger inn — en synkroniseringsdaemon, en chat-app, ditt eget skript — legger du det i `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Det starter kommandoen som en del av økten, så den ryddes ordentlig opp når du logger ut igjen.

### Kjøre skript ved systemhendelser

Omarchy utløser hooks på en håndfull tidspunkter, og du kan henge dine egne skript på dem. De ligger i `~/.config/omarchy/hooks/<event>.d/`, én mappe per hendelse, og hver fil der inne som ikke slutter med `.sample`, kjøres med bash når hendelsen inntreffer:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Rett etter at skrivebordet har startet |
| `post-update` | Nær slutten av `omarchy update`, etter pakker, migreringer og omstart av tjenester, før mise-verktøy oppdateres |
| `pre-refresh-pacman` | Etter at `omarchy refresh pacman` har synkronisert pakkekonfigurasjonen på nytt, før den oppdaterer pakker; et kanalbytte kjører den under samme oppdateringstrinn |
| `theme-set` | Etter et temabytte (temanavn i `$1`) |
| `font-set` | Etter et skriftbytte (skriftnavn i `$1`) |
| `battery-low` | Når batteriet blir lavt (prosent i `$1`) |

`pre-refresh-pacman`-hooken er stedet der egendefinerte pakkebrønner eller `IgnorePkg`-linjer hører hjemme, siden den kjører før pakketransaksjonen. Begge kjører som brukeren din. `post-update` kjører mens sudo-autorisasjonen fra `omarchy update` fortsatt er fersk, så en hook som bruker `sudo`, vil ikke be om passordet ditt igjen; `pre-refresh-pacman` kjører rett etter at `omarchy refresh pacman` selv har brukt sudo.

Hver av disse mappene inneholder allerede en `.sample`-fil som viser hvordan en hook ser ut — fjern `.sample` fra navnet for å ta den i bruk. For å installere et skript du har skrevet et annet sted, bruker du `omarchy hook install post-boot ~/my-hook`, som kopierer det inn og gjør det kjørbart.

### Legge til dine egne menyelementer

Omarchy-menyen (`Super + Space`) kan utvides med dine egne rader ved å redigere `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Oppføringer nøkles med en prikket id, og det er id-en som plasserer dem i treet, så `personal` vises på rotmenyen og `personal.notes` vises inne i den:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Gjenbruker du en eksisterende id, overstyrer du den raden i stedet for å legge til en ny. Filen leveres med alle tilgjengelige felt dokumentert som kommentarer.

### Legge til egne skall-eksporter, funksjoner og aliaser

Omarchy leveres med en haug med ergonomiske aliaser og nyttige funksjoner, men det er svært vanlig å ville legge til sine egne. Du bør legge til både aliaser, funksjoner og eksporter i `~/.bashrc`. Denne filen vil ikke bli overskrevet ved oppdateringer. Hvis du vil endre noen av Omarchy-standardene, kan du også trygt legge dem til her.

### Sette miljøvariabler for skrivebordet

Eksporter for skrivebordsøkten hører hjemme i `~/.config/uwsm/env.d/`. Disse filene kjøres før skrivebordet ditt starter, så en skallfeil kan sende deg tilbake til innloggingsskjermen. Hold en terminal som fungerer åpen mens du redigerer dem. For å deaktivere en overstyring flytter du den ut av `env.d`. Se [gjenoppretting av innlogging](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) hvis en endring hindrer innlogging.

### Endre interne Omarchy-filer

Hør her, dette er din datamaskin. Du kan gjøre hva du vil med den, men jeg vil fraråde å gjøre endringer direkte i filene i `/usr/share/omarchy`. De tilhører Omarchy-pacman-pakken, så endringene dine vil rett og slett bli overskrevet ved neste oppdatering. Du har det bedre med å bare overstyre standardverdier du ikke liker i `~/.config/*`-mappen i stedet.

Du kan endre nesten alt på den måten, som standard-tastebindingene. Bare rediger `~/.config/hypr/bindings.lua` for å for eksempel erstatte [Obsidian](https://obsidian.md/) med [Joplin](https://joplinapp.org/) (installer med `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` fjerner den eksisterende bindingen før den legger til erstatningen. Den tar de samme argumentene som `o.bind`, inkludert oppstartshjelpere og bindingalternativer. Bruk `o.bind` for å legge til en binding, eller `hl.unbind` for å fjerne en uten å erstatte den.

Hvis du insisterer på å hacke på de interne Omarchy-filene, bytter du til dev-kanalen via _Oppdater > Kanal > Dev_. Det knytter Omarchy til en git-utsjekk av kildekoden i `~/omarchy`, som du fritt kan endre så mye hjertet begjærer. Ingen her skal fortelle deg hva du skal gjøre!

### Tilbakestille eventuelle endringer

Hvis du ender opp med å rote til konfigurasjonene, kan du alltid tilbakestille dem til standardinnstillingene via _Oppdater > Konfigurasjon_ i Omarchy-menyen. Eller ved å kjøre `omarchy reinstall configs` for å tilbakestille alt.
