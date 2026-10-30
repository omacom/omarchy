# Punktfiler

Omarchy konfigureres primært via de såkalte punktfilene som bor i `~/.config`. De regnes som dine filer for dine endringer. Filene som bor i `/usr/share/omarchy` tilhører selve Omarchy, og du bør ikke rote med dem. Hvis du må endre noe i `/usr/share/omarchy`, bør du overskrive verdien i `~/.config` i stedet.

De viktigste konfigurasjonene kan redigeres rett fra Omarchy-menyen (`Super + Space`), som _Oppsett > Skjermer_, _Oppsett > Tastatursnarveier_, _Oppsett > Inndata_ og _Oppsett > Konfig > [file]_. Når du gjør det på denne måten, startes enhver prosess som må startes på nytt etter konfigurasjonsredigeringer automatisk etter at du avslutter editoren (Neovim som standard — `:wq`, husk! — men du kan endre det via _Oppsett > Standarder > Editor_).

Her er en liste over de viktigste filene i `~/.config` og hva de styrer:

| Fil                  | Formål              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hovedkonfigurasjonen for Hyprland. Laster Omarchy-standardene pluss overstyringsfilene dine nedenfor. [Lær mer om Hyprland-konfigurasjoner](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Dine egne tastatursnarveier og overstyringer av standardene. |
| `~/.config/hypr/monitors.lua` | Styrer skjermene, oppløsningen og posisjonen din. |
| `~/.config/hypr/input.lua` | Styrer tastaturoppsettet, mus- og styreflateinnstillingene dine. |
| `~/.config/hypr/looknfeel.lua` | Styrer mellomrom, rammer, animasjoner og resten av utseendet. |
| `~/.config/hypr/autostart.lua` | Styrer ekstra prosesser startet med økten. |
| `~/.config/omarchy/shell.json` | Styrer Omarchy-skallet: linjeplassering, oppsett og widgets, pluss tidsinnstillinger for skjermsparer, lås og inaktivitet. |
| `~/.config/foot/foot.ini` | Styrer terminalen din (foot er standard). |
| `~/.XCompose` | Definerer dine raske emoji- og navn-/e-post-autofullføringer. Sørg for å kjøre `omarchy-restart-xcompose` etter endringer. |

Hvis du ender opp med å gjøre mange endringer for å finjustere oppsettet ditt, er det en god idé å sikkerhetskopiere alle disse punktfilene. [Stow er en flott måte å gjøre det på](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Starte dine egne apper med økten

Hvis du vil at noe skal kjøre hver gang du logger inn — en synkdaemon, en chat-app, ditt eget skript — legg det i `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Det starter kommandoen som en del av økten, så den ryddes skikkelig opp når du logger ut igjen.

### Kjøre skript ved systemhendelser

Omarchy fyrer av kroker ved en håndfull øyeblikk, og du kan henge dine egne skript på dem. De bor i `~/.config/omarchy/hooks/<event>.d/`, én mappe per hendelse, og hver kjørbare fil der inne kjører når hendelsen inntreffer:

| Hendelse | Når den kjører |
| ----- | ------------ |
| `post-boot` | Rett etter at skrivebordet har startet |
| `post-update` | Mot slutten av `omarchy update`, etter pakker, migreringer og omstart av tjenester, før mise-verktøy oppdateres |
| `pre-refresh-pacman` | Etter at `omarchy refresh pacman` synkroniserer pakkekonfigurasjonen på nytt, før den oppdaterer pakker; et kanalbytte kjører den under det samme oppdateringstrinnet |
| `theme-set` | Etter et temabytte (temanavn i `$1`) |
| `font-set` | Etter et skriftbytte (skriftnavn i `$1`) |
| `battery-low` | Når batteriet blir lavt (prosent i `$1`) |

`pre-refresh-pacman`-kroken er der egendefinerte repoer eller `IgnorePkg`-linjer hører hjemme, siden den kjører før pakketransaksjonen. Begge oppdateringsrelaterte krokene kjører som brukeren din etter at Omarchy fjerner sin bufrede sudo-autorisasjon, så en krok som bruker `sudo` trenger sin egen autorisasjon og kan be om passordet ditt.

Hver av disse mappene inneholder allerede en `.sample`-fil som viser formen til en krok — dropp `.sample` fra navnet for å sette den i arbeid. For å installere et skript du har skrevet et annet sted, bruk `omarchy hook install post-boot ~/my-hook`, som kopierer det inn og gjør det kjørbart.

### Legge til dine egne menyoppføringer

Omarchy-menyen (`Super + Space`) kan utvides med dine egne rader ved å redigere `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Oppføringer nøkles med en prikket ID, og ID-en er det som plasserer dem i treet, så `personal` vises på rotmenyen, og `personal.notes` vises inni den:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Gjenbruk en eksisterende ID, så overstyrer du den raden i stedet for å legge til en ny. Filen leveres med alle tilgjengelige feltene dokumentert som kommentarer.

### Legge til dine egne skallexporter, funksjoner og aliaser

Omarchy leveres med en gjeng ergonomiske aliaser og nyttige funksjoner, men det er svært vanlig å ønske å legge til egne. Du bør legge til både aliaser, funksjoner og exporter i `~/.bashrc`. Denne filen overskrives ikke ved oppdateringer. Hvis du vil endre noen av Omarchy-standardene, kan du også trygt legge dem til her.

### Endre interne Omarchy-filer

Hør her, dette er datamaskinen din. Du kan gjøre hva du vil med den, men jeg fraråder å gjøre endringer direkte i filene i `/usr/share/omarchy`. De tilhører Omarchy pacman-pakken, så endringene dine blir bare overskrevet ved neste oppdatering. Du har det bedre med å bare overskrive eventuelle standardverdier du ikke liker i `~/.config/*`-mappen i stedet.

Du kan endre omtrent alt på den måten, som standard tastatursnarveier. Bare rediger `~/.config/hypr/bindings.lua` for å si erstatte [Obsidian](https://obsidian.md/) med [Joplin](https://joplinapp.org/) (installer med `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` fjerner den eksisterende bindingen før den legger til erstatningen. Den tar de samme argumentene som `o.bind`, inkludert starthjelpere og bindingsvalg. Bruk `o.bind` for å legge til en binding, eller `hl.unbind` for å fjerne en uten å erstatte den.

Hvis du insisterer på å hakke på de interne Omarchy-filene, bytt til dev-kanalen via _Oppdater > Kanal > Dev_. Det lenker Omarchy til en git-utsjekking av kildekoden i `~/omarchy`, som du står fritt til å endre så mye hjertet ditt begjærer. Det er ingen her til å fortelle deg hva du skal gjøre!

### Tilbakestille endringer

Hvis du ender opp med å rote til konfigurasjonene, kan du alltid tilbakestille dem til standardene via _Oppdater > Konfig_ i Omarchy-menyen. Eller ved å kjøre `omarchy reinstall configs` for å tilbakestille alt.
