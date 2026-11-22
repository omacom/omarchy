# Dotfiles

Omarchy konfigureres primært gennem de såkaldte dotfiles, der ligger i `~/.config`. De betragtes som dine filer til dine ændringer. Filerne, der ligger i `/usr/share/omarchy`, tilhører selve Omarchy, og dem skal du ikke pille ved. Hvis du har brug for at ændre noget i `/usr/share/omarchy`, skal du i stedet overskrive værdien i `~/.config`.

De vigtigste konfigurationer kan redigeres direkte fra Omarchy-menuen (`Super + Space`), f.eks. _Setup > Keyboard > Keybindings_, _Setup > Input_ og _Setup > Config > [file]_. Når du gør det på denne måde, genstartes alle processer, der skal genstartes efter konfigurationsændringer, automatisk, når du afslutter editoren (Neovim som standard — `:wq`, husk det! — men du kan ændre det via _Setup > Defaults > Editor_).

Her er en liste over de vigtigste filer i `~/.config`, og hvad de styrer:

| Fil                  | Formål              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Den primære Hyprland-konfiguration. Indlæser Omarchy-standardindstillingerne plus dine tilsidesættelsesfiler nedenfor. [Læs mere om Hyprland-konfigurationer](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Dine egne tastaturgenveje og tilsidesættelser af standardindstillingerne. |
| `~/.config/hypr/monitors.lua` | Skærmindstillinger, som skærmpanelet ikke dækker, f.eks. rotation, ekstra tilstande eller at holde en skærm slukket. |
| `~/.config/hypr/input.lua` | Styrer indstillinger for tastaturlayout, mus og pegefelt. |
| `~/.config/hypr/looknfeel.lua` | Styrer mellemrum, kanter, animationer og resten af udseendet. |
| `~/.config/hypr/autostart.lua` | Styrer ekstra processer, der startes med sessionen. |
| `~/.config/omarchy/shell.json` | Styrer Omarchy-skallen: bjælkens placering, layout og widgets samt tidspunkter for pauseskærm, lås og inaktivitet. |
| `~/.config/foot/foot.ini` | Styrer din terminal (foot er standarden). |
| `~/.XCompose` | Definerer dine emojier med hurtig adgang og autofuldførelse af navn/e-mail. Sørg for at køre `omarchy-restart-xcompose`, efter du har foretaget ændringer. |

Hvis du ender med at lave mange ændringer for at tilpasse din egen opsætning, er det en god idé at tage backup af alle disse dotfiles. [Stow er en fremragende måde at gøre det på](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Start dine egne apps med sessionen

Hvis du vil have noget til at køre, hver gang du logger ind — en synkroniseringsdæmon, en chatapp, dit eget script — så læg det i `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Det starter kommandoen som en del af sessionen, så den ryddes ordentligt op, når du logger ud igen.

### Kørsel af scripts ved systemhændelser

Omarchy udløser hooks på en håndfuld tidspunkter, og du kan hænge dine egne scripts på dem. De ligger i `~/.config/omarchy/hooks/<event>.d/`, én mappe pr. hændelse, og hver fil deri, der ikke ender på `.sample`, køres med bash, når hændelsen indtræffer:

| Hændelse | Hvornår den kører |
| ----- | ------------ |
| `post-boot` | Lige efter skrivebordet er startet |
| `post-update` | Nær slutningen af `omarchy update`, efter pakker, migrationer og genstart af tjenester, før mise-værktøjer opdateres |
| `pre-refresh-pacman` | Efter `omarchy refresh pacman` har gensynkroniseret pakkekonfigurationen, før den opdaterer pakker; et kanalskift kører den under det samme opdateringstrin |
| `theme-set` | Efter et temaskift (temanavn i `$1`) |
| `font-set` | Efter et skrifttypeskift (skrifttypenavn i `$1`) |
| `battery-low` | Når batteriet er ved at være lavt (procent i `$1`) |

`pre-refresh-pacman`-hooken er stedet, hvor brugerdefinerede pakkearkiver eller `IgnorePkg`-linjer hører hjemme, da den kører før pakketransaktionen. Begge kører som din bruger. `post-update` kører, mens `omarchy update`s sudo-godkendelse stadig er frisk, så en hook, der bruger `sudo`, vil ikke bede om din adgangskode igen; `pre-refresh-pacman` kører lige efter, at `omarchy refresh pacman` selv har brugt sudo.

Hver af disse mapper indeholder allerede en `.sample`-fil, der viser, hvordan en hook skal se ud — fjern `.sample` fra navnet for at tage den i brug. For at installere et script, du har skrevet et andet sted, skal du bruge `omarchy hook install post-boot ~/my-hook`, som kopierer det ind og gør det eksekverbart.

### Tilføjelse af dine egne menupunkter

Omarchy-menuen (`Super + Space`) kan udvides med dine egne rækker ved at redigere `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Punkter nøgles efter et id med punktummer, og det er id'et, der placerer dem i træet, så `personal` vises i rodmenuen, og `personal.notes` vises inde i den:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Genbrug et eksisterende id, og du tilsidesætter den række i stedet for at tilføje en ny. Filen leveres med alle de tilgængelige felter dokumenteret som kommentarer.

### Tilføjelse af dine egne shell-eksporter, funktioner og aliasser

Omarchy leveres med en masse ergonomiske aliasser og nyttige funktioner, men det er meget almindeligt at ville tilføje sine egne. Du skal tilføje både aliasser, funktioner og eksporter i `~/.bashrc`. Denne fil bliver ikke overskrevet ved opdateringer. Hvis du vil ændre nogen af Omarchy-standardindstillingerne, kan du også trygt tilføje dem her.

### Indstilling af miljøvariabler til skrivebordet

Eksporter til skrivebordssessionen hører hjemme i `~/.config/uwsm/env.d/`. Disse filer kører, før dit skrivebord starter, så en shell-fejl kan sende dig tilbage til loginskærmen. Hold en fungerende terminal åben, mens du redigerer dem. For at deaktivere en tilsidesættelse skal du flytte den ud af `env.d`. Se [gendannelse af login](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), hvis en ændring forhindrer login.

### Ændring af interne Omarchy-filer

Hør her, det er din computer. Du kan gøre lige, hvad du vil med den, men jeg vil fraråde at ændre filerne i `/usr/share/omarchy` direkte. De tilhører Omarchy-pacman-pakken, så dine ændringer bliver simpelthen overskrevet ved næste opdatering. Du er bedre stillet ved bare at overskrive de standardværdier, du ikke kan lide, i mappen `~/.config/*` i stedet.

Du kan ændre næsten alt på den måde, f.eks. standardtastaturgenvejene. Rediger bare `~/.config/hypr/bindings.lua` for f.eks. at erstatte [Obsidian](https://obsidian.md/) med [Joplin](https://joplinapp.org/) (installer med `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` fjerner den eksisterende genvej, før den tilføjer sin erstatning. Den tager de samme argumenter som `o.bind`, herunder starthjælpere og indstillinger for genveje. Brug `o.bind` til at tilføje en genvej, eller `hl.unbind` til at fjerne en uden at erstatte den.

Hvis du insisterer på at hacke på de interne Omarchy-filer, så skift til dev-kanalen via _Update > Channel > Dev_. Det linker Omarchy til en git-udcheckning af kildekoden i `~/omarchy`, som du frit kan ændre, lige så meget du lyster. Der er ingen her, der skal fortælle dig, hvad du skal gøre!

### Nulstilling af eventuelle ændringer

Hvis du ender med at lave rod i konfigurationerne, kan du altid vende tilbage til standardindstillingerne via _Update > Config_ i Omarchy-menuen. Eller ved at køre `omarchy reinstall configs` for at nulstille alt.
