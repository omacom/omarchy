# Dotfiles

Omarchy konfigureres primært gennem de såkaldte dotfiles, der ligger i `~/.config`. De betragtes som dine filer til dine ændringer. Filerne, der ligger i `/usr/share/omarchy`, tilhører Omarchy selv, og du bør ikke rode med dem. Hvis du skal ændre noget i `/usr/share/omarchy`, bør du i stedet overskrive værdien i `~/.config`.

De vigtigste konfigurationsfiler kan redigeres direkte fra Omarchy-menuen (`Super + Space`), f.eks. _Setup > Keybindings_, _Setup > Input_ og _Setup > Config > [file]_. Når du gør det på den måde, genstartes enhver proces, der skal genstartes efter konfigurationsændringer, automatisk, når du afslutter editoren (Neovim som standard — `:wq`, husk det! — men du kan ændre det via _Setup > Defaults > Editor_).

Her er en liste over de vigtigste filer i `~/.config`, og hvad de styrer:

| Fil | Formål |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Den primære Hyprland-konfiguration. Indlæser Omarchys standardindstillinger plus dine tilsidesættelsesfiler nedenfor. [Læs mere om Hyprland-konfigurationer](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | Dine egne tastaturgenveje og tilsidesættelser af standarderne. |
| `~/.config/hypr/monitors.lua` | Skærmindstillinger, som skærmpanelet ikke dækker, f.eks. rotation, ekstra tilstande eller at holde en skærm slukket. |
| `~/.config/hypr/input.lua` | Styrer dit tastaturlayout, din mus og dine trackpad-indstillinger. |
| `~/.config/hypr/looknfeel.lua` | Styrer mellemrum, kanter, animationer og resten af udseendet. |
| `~/.config/hypr/autostart.lua` | Styrer ekstra processer, der startes med sessionen. |
| `~/.config/omarchy/shell.json` | Styrer Omarchy-shellen: barens placering, layout og widgets samt timinger for pauseskærm, lås og inaktivitet. |
| `~/.config/foot/foot.ini` | Styrer din terminal (foot er standard). |
| `~/.XCompose` | Definerer dine emoji med hurtig adgang og autofuldførelse af navn/e-mail. Sørg for at køre `omarchy-restart-xcompose`, efter du har foretaget ændringer. |

Hvis du ender med at lave mange ændringer for at tilpasse din egen opsætning, er det en god idé at tage backup af alle disse dotfiles. [Stow er en fantastisk måde at gøre det på](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Start dine egne apps med sessionen

Hvis du vil have noget til at køre, hver gang du logger ind — en sync daemon, en chatapp, dit eget script — så læg det i `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Det starter kommandoen som en del af sessionen, så den ryddes ordentligt op, når du logger ud igen.

### Kør scripts ved systemhændelser

Omarchy udløser hooks på en håndfuld tidspunkter, og du kan hænge dine egne scripts på dem. De ligger i `~/.config/omarchy/hooks/<event>.d/`, én mappe pr. hændelse, og hver eksekverbar fil deri køres, når hændelsen sker:

| Hændelse | Hvornår den kører |
| ----- | ------------ |
| `post-boot` | Lige efter skrivebordet er startet |
| `post-update` | Nær slutningen af `omarchy update`, efter pakker, migrationer og genstarter af tjenester, før mise-værktøjer opdateres |
| `pre-refresh-pacman` | Efter `omarchy refresh pacman` har gensynkroniseret pakkekonfigurationen, før den opdaterer pakker; et kanalskift kører den under samme opdateringstrin |
| `theme-set` | Efter et temaskift (temanavn i `$1`) |
| `font-set` | Efter et skrifttypeskift (skrifttypenavn i `$1`) |
| `battery-low` | Når batteriet er lavt (procent i `$1`) |

`pre-refresh-pacman`-hooken er stedet, hvor brugerdefinerede repositories eller `IgnorePkg`-linjer hører hjemme, da den kører før pakketransaktionen. Begge opdateringsrelaterede hooks kører som din bruger, efter Omarchy har ryddet sin cachede sudo-godkendelse, så en hook, der bruger `sudo`, skal bruge sin egen godkendelse og kan bede om din adgangskode.

Hver af disse mapper indeholder allerede en `.sample`-fil, der viser formen på en hook — fjern `.sample` fra navnet for at tage den i brug. For at installere et script, du har skrevet et andet sted, skal du bruge `omarchy hook install post-boot ~/my-hook`, som kopierer det ind og gør det eksekverbart.

### Tilføj dine egne menupunkter

Omarchy-menuen (`Super + Space`) kan udvides med dine egne rækker ved at redigere `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Punkter nøgles efter et id med punktummer, og det er id'et, der placerer dem i træet, så `personal` vises på rodmenuen, og `personal.notes` vises indeni den:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Genbruger du et eksisterende id, tilsidesætter du den række i stedet for at tilføje en ny. Filen leveres med alle tilgængelige felter dokumenteret som kommentarer.

### Tilføj dine egne shell-eksporter, funktioner og aliaser

Omarchy leveres med en masse ergonomiske aliaser og nyttige funktioner, men det er meget almindeligt at ville tilføje sine egne. Du bør tilføje både aliaser, funktioner og eksporter i `~/.bashrc`. Denne fil overskrives ikke ved opdateringer. Hvis du vil ændre nogen af Omarchys standarder, kan du også roligt tilføje dem her.

### Indstil miljøvariabler for skrivebordet

Skrivebordssessionens eksporter hører hjemme i `~/.config/uwsm/env.d/`. Disse filer køres, før dit skrivebord starter, så en shell-fejl kan sende dig tilbage til loginskærmen. Hold en fungerende terminal åben, mens du redigerer dem. For at deaktivere en tilsidesættelse skal du flytte den ud af `env.d`. Se [gendannelse af login](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), hvis en ændring forhindrer login.

### Ændring af interne Omarchy-filer

Hør her, det er din computer. Du kan gøre, hvad du vil med den, men jeg vil fraråde at ændre filerne i `/usr/share/omarchy` direkte. De tilhører Omarchy-pacman-pakken, så dine ændringer vil simpelthen blive overskrevet ved næste opdatering. Du er bedre stillet ved i stedet bare at overskrive alle standardværdier, du ikke kan lide, i mappen `~/.config/*`.

Du kan ændre stort set alt på den måde, f.eks. standardtastaturgenvejene. Rediger bare `~/.config/hypr/bindings.lua` for f.eks. at erstatte [Obsidian](https://obsidian.md/) med [Joplin](https://joplinapp.org/) (installer med `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` fjerner den eksisterende binding, før den tilføjer sin erstatning. Den tager samme argumenter som `o.bind`, herunder launch-hjælpere og bindingsindstillinger. Brug `o.bind` til at tilføje en binding eller `hl.unbind` til at fjerne en uden at erstatte den.

Hvis du insisterer på at hacke på de interne Omarchy-filer, så skift til dev-kanalen via _Update > Channel > Dev_. Det linker Omarchy til en git-checkout af kildekoden i `~/omarchy`, som du frit kan ændre, lige så meget du lyster. Der er ingen her, der skal fortælle dig, hvad du skal gøre!

### Nulstil alle ændringer

Hvis du ender med at rode konfigurationerne til, kan du altid gendanne dem til standarderne via _Update > Config_ i Omarchy-menuen. Eller ved at køre `omarchy reinstall configs` for at nulstille alt.
