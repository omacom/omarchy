# Dotfiles

Omarchy konfigureres primært gennem de såkaldte dotfiles, der ligger i `~/.config`. De betragtes som dine filer til dine ændringer. Filerne, der ligger i `/usr/share/omarchy`, tilhører selve Omarchy, og dem skal du ikke pille ved. Hvis du har brug for at ændre noget i `/usr/share/omarchy`, skal du i stedet overskrive værdien i `~/.config`.

De vigtigste konfigurationer kan redigeres direkte fra Omarchy-menuen (`Super + Space`), såsom _Setup > Keybindings_, _Setup > Input_ og _Setup > Config > [file]_. Når du gør det på denne måde, genstartes enhver proces, der har brug for at blive genstartet efter konfigurationsændringer, automatisk, når du afslutter editoren (Neovim som standard — `:wq`, husk det! — men du kan ændre det via _Setup > Defaults > Editor_).

Her er en liste over de vigtigste filer i `~/.config`, og hvad de styrer:

| Fil | Formål |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Den primære Hyprland-konfiguration. Indlæser Omarchy-standardindstillingerne plus dine tilsidesættelsesfiler nedenfor. [Få mere at vide om Hyprland-konfigurationer](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Dine egne tastebindinger og tilsidesættelser af standardindstillingerne. |
| `~/.config/hypr/monitors.lua` | Skærmindstillinger, som skærmpanelet ikke dækker, såsom rotation, ekstra tilstande eller at holde en skærm slukket. |
| `~/.config/hypr/input.lua` | Styrer dit tastaturlayout, dine mus- og trackpad-indstillinger. |
| `~/.config/hypr/looknfeel.lua` | Styrer mellemrum, kanter, animationer og resten af udseendet. |
| `~/.config/hypr/autostart.lua` | Styrer ekstra processer, der startes med sessionen. |
| `~/.config/omarchy/shell.json` | Styrer Omarchy-shellen: bjælkens placering, layout og widgets samt tidspunkter for pauseskærm, lås og inaktivitet. |
| `~/.config/foot/foot.ini` | Styrer din terminal (foot er standarden). |
| `~/.XCompose` | Definerer din hurtigadgang til emoji og autoudfyldning af navn/e-mail. Sørg for at køre `omarchy-restart-xcompose`, efter du har foretaget ændringer. |

Hvis du ender med at foretage mange ændringer for at tilpasse din egen opsætning, er det en god idé at sikkerhedskopiere alle disse dotfiles. [Stow er en fantastisk måde at gøre det på](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Start af dine egne apps med sessionen

Hvis du vil have noget til at køre, hver gang du logger ind — en synkroniseringsdaemon, en chatapp, dit eget script — så læg det i `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Det starter kommandoen som en del af sessionen, så den ryddes ordentligt op, når du logger ud igen.

### Kørsel af scripts ved systemhændelser

Omarchy affyrer hooks på en håndfuld tidspunkter, og du kan hænge dine egne scripts på dem. De ligger i `~/.config/omarchy/hooks/<event>.d/`, én mappe pr. hændelse, og hver eksekverbar fil deri kører, når hændelsen indtræffer:

| Hændelse | Hvornår den kører |
| ----- | ------------ |
| `post-boot` | Lige efter skrivebordet er startet |
| `post-update` | Mod slutningen af `omarchy update`, efter pakker, migreringer og genstart af tjenester, før mise-værktøjer opdateres |
| `pre-refresh-pacman` | Efter `omarchy refresh pacman` har gensynkroniseret pakkekonfigurationen, før den opdaterer pakker; et kanalskift kører den under det samme opdateringstrin |
| `theme-set` | Efter et temaskift (temanavn i `$1`) |
| `font-set` | Efter et skrifttypeskift (skrifttypenavn i `$1`) |
| `battery-low` | Når batteriet er ved at være lavt (procent i `$1`) |

Hooket `pre-refresh-pacman` er der, hvor brugerdefinerede repositories eller `IgnorePkg`-linjer hører hjemme, da det kører før pakketransaktionen. Begge opdateringsrelaterede hooks kører som din bruger, efter Omarchy har ryddet sin cachede sudo-godkendelse, så et hook, der bruger `sudo`, har brug for sin egen godkendelse og kan bede om din adgangskode.

Hver af disse mapper indeholder allerede en `.sample`-fil, der viser formen på et hook — fjern `.sample` fra navnet for at tage det i brug. For at installere et script, du har skrevet et andet sted, skal du bruge `omarchy hook install post-boot ~/my-hook`, som kopierer det ind og gør det eksekverbart.

### Tilføjelse af dine egne menupunkter

Omarchy-menuen (`Super + Space`) kan udvides med dine egne rækker ved at redigere `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Punkter er nøglet efter et punktdelt id, og det er id'et, der placerer dem i træet, så `personal` vises i rodmenuen, og `personal.notes` vises indeni den:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Genbruger du et eksisterende id, tilsidesætter du den række i stedet for at tilføje en ny. Filen leveres med alle de tilgængelige felter dokumenteret som kommentarer.

### Tilføjelse af dine egne shell-eksporter, funktioner og aliaser

Omarchy leveres med en masse ergonomiske aliaser og nyttige funktioner, men det er meget almindeligt at ville tilføje sine egne. Du bør tilføje både aliaser, funktioner og eksporter i `~/.bashrc`. Denne fil bliver ikke overskrevet ved opdateringer. Hvis du vil ændre nogle af Omarchy-standardindstillingerne, kan du også trygt tilføje dem her.

### Ændring af interne Omarchy-filer

Hør her, det er din computer. Du kan gøre, hvad du vil med den, men jeg vil fraråde at foretage ændringer direkte i filerne i `/usr/share/omarchy`. De tilhører Omarchy-pacman-pakken, så dine ændringer bliver ganske enkelt overskrevet ved den næste opdatering. Du er bedre tjent med blot at overskrive alle standardværdier, du ikke kan lide, i mappen `~/.config/*` i stedet.

Du kan ændre stort set alt på den måde, såsom standardtastebindingerne. Rediger blot `~/.config/hypr/bindings.lua` for f.eks. at udskifte [Obsidian](https://obsidian.md/) med [Joplin](https://joplinapp.org/) (installer med `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` fjerner den eksisterende binding, før den tilføjer dens erstatning. Den tager de samme argumenter som `o.bind`, herunder launch-hjælpere og bindingsindstillinger. Brug `o.bind` til at tilføje en binding, eller `hl.unbind` til at fjerne en uden at erstatte den.

Hvis du insisterer på at hacke på de interne Omarchy-filer, så skift til dev-kanalen via _Update > Channel > Dev_. Det linker Omarchy til en git-checkout af kildekoden i `~/omarchy`, som du frit kan ændre, lige så meget du lyster. Der er ingen her, der skal fortælle dig, hvad du skal gøre!

### Nulstilling af alle ændringer

Hvis du ender med at rode konfigurationerne til, kan du altid vende dem tilbage til standardindstillingerne via _Update > Config_ i Omarchy-menuen. Eller ved at køre `omarchy reinstall configs` for at nulstille alt.
