# Dotfiles

Omarchy er primært konfigureret gennem de såkaldte dotfiles, der bor i `~/.config`. De betragtes som dine filer til dine ændringer. Filerne, der bor i `/usr/share/omarchy`, tilhører Omarchy selv, og dem skal du ikke rode med. Hvis du har brug for at ændre noget i `/usr/share/omarchy`, skal du i stedet overskrive værdien i `~/.config`.

De vigtigste konfigurationer kan redigeres direkte fra Omarchy-menuen (`Super + Space`), som _Setup > Keyboard > Keybindings_, _Setup > Input_ og _Setup > Config > [file]_. Når du gør det på denne måde, vil enhver proces, der skal genstartes efter konfigurationsændringer, automatisk blive det, når du afslutter editoren (Neovim som standard — `:wq`, husk det! — men du kan ændre det via _Setup > Defaults > Editor_).

Her er en liste over de vigtigste filer i `~/.config`, og hvad de styrer:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Den primære Hyprland-konfiguration. Indlæser Omarchy-standarderne plus dine tilsidesættende filer nedenfor. [Få mere at vide om Hyprland-konfigurationer](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Dine egne tastebindinger og tilsidesættelser af standarderne. |
| `~/.config/hypr/monitors.lua` | Skærmindstillinger, som skærmpanelet ikke dækker, som rotation, ekstra tilstande eller at holde en skærm slukket. |
| `~/.config/hypr/input.lua` | Styrer dit tastaturlayout, din mus og dine trackpad-indstillinger. |
| `~/.config/hypr/looknfeel.lua` | Styrer mellemrum, kanter, animationer og resten af udseendet. |
| `~/.config/hypr/autostart.lua` | Styrer ekstra processer, der startes med sessionen. |
| `~/.config/omarchy/shell.json` | Styrer Omarchy-shellen: barens placering, layout og widgets, plus pauserskærm, lås og tider for inaktivitet. |
| `~/.config/foot/foot.ini` | Styrer din terminal (foot er standarden). |
| `~/.XCompose` | Definerer dine emoji med hurtig adgang og autofuldførelse af navn/e-mail. Sørg for at køre `omarchy-restart-xcompose`, efter du har lavet ændringer. |

Hvis du ender med at lave en masse ændringer for at finjustere din egen opsætning, er det en god idé at sikkerhedskopiere alle disse dotfiles. [Stow er en fantastisk måde at gøre det på](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Start dine egne apps med sessionen

Hvis du vil have noget til at køre, hver gang du logger ind — en synkroniseringsdæmon, en chatapp, dit eget script — så put det i `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Det starter kommandoen som en del af sessionen, så den bliver ryddet ordentligt op, når du logger ud igen.

### Kør scripts ved systemhændelser

Omarchy affyrer hooks på en håndfuld tidspunkter, og du kan hænge dine egne scripts på dem. De bor i `~/.config/omarchy/hooks/<event>.d/`, én mappe pr. hændelse, og hver eksekverbar fil derinde kører, når hændelsen sker:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Lige efter skrivebordet er startet |
| `post-update` | Tæt på slutningen af `omarchy update`, efter pakker, migrationer og genstart af tjenester, før mise-værktøjer opdateres |
| `pre-refresh-pacman` | Efter `omarchy refresh pacman` gensynkroniserer pakkekonfigurationen, før den opdaterer pakker; et kanalskift kører den under det samme genopfriskningstrin |
| `theme-set` | Efter et temaskift (temanavn i `$1`) |
| `font-set` | Efter et skrifttypeskift (skrifttypenavn i `$1`) |
| `battery-low` | Når batteriet bliver lavt (procent i `$1`) |

`pre-refresh-pacman`-hooket er der, hvor brugerdefinerede repositories eller `IgnorePkg`-linjer hører hjemme, eftersom den kører før pakketransaktionen. Begge opdateringsrelaterede hooks kører som din bruger, efter Omarchy rydder sin cachede sudo-autorisation, så et hook, der bruger `sudo`, har brug for sin egen autorisation og kan bede om din adgangskode.

Hver af disse mapper indeholder allerede en `.sample`-fil, der viser formen på et hook — fjern `.sample` fra navnet for at tage det i brug. For at installere et script, du har skrevet et andet sted, skal du bruge `omarchy hook install post-boot ~/my-hook`, som kopierer det ind og gør det eksekverbart.

### Tilføj dine egne menupunkter

Omarchy-menuen (`Super + Space`) kan udvides med dine egne rækker ved at redigere `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Punkter er nøglet med et punktdelt id, og det er id'et, der placerer dem i træet, så `personal` dukker op i rodmenuen, og `personal.notes` dukker op inde i den:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Genbruger du et eksisterende id, tilsidesætter du den række i stedet for at tilføje en ny. Filen leveres med alle de tilgængelige felter dokumenteret som kommentarer.

### Tilføj dine egne shell exports, funktioner og aliaser

Omarchy leveres med en masse ergonomiske aliaser og nyttige funktioner, men det er meget almindeligt at ville tilføje sine egne. Du skal tilføje både aliaser, funktioner og exports i `~/.bashrc`. Denne fil vil ikke blive overskrevet ved opdateringer. Hvis du vil ændre nogen af Omarchy-standarderne, kan du også trygt tilføje dem her.

### Indstil miljøvariabler til skrivebordet

Eksporter til skrivebordssessioner hører hjemme i `~/.config/uwsm/env.d/`. Disse filer kører, før dit skrivebord starter, så en shell-fejl kan sende dig tilbage til loginskærmen. Hold en fungerende terminal åben, mens du redigerer dem. For at deaktivere en tilsidesættelse skal du flytte den ud af `env.d`. Se [gendannelse ved login](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), hvis en ændring forhindrer login.

### Ændr interne Omarchy-filer

Hør her, det er din computer. Du kan gøre lige, hvad du vil med den, men jeg vil råde dig til ikke at lave ændringer direkte i filerne i `/usr/share/omarchy`. De tilhører Omarchy pacman-pakken, så dine ændringer vil simpelthen blive overskrevet ved næste opdatering. Du har det bedre med bare at overskrive de standardværdier, du ikke kan lide, i mappen `~/.config/*` i stedet.

Du kan ændre stort set alt på den måde, som standardtastebindingerne. Bare rediger `~/.config/hypr/bindings.lua` for f.eks. at erstatte [Obsidian](https://obsidian.md/) med [Joplin](https://joplinapp.org/) (installer med `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` fjerner den eksisterende binding, før den tilføjer sin erstatning. Den tager de samme argumenter som `o.bind`, inklusive launch-hjælpere og bindingsindstillinger. Brug `o.bind` til at tilføje en binding, eller `hl.unbind` til at fjerne en uden at erstatte den.

Hvis du insisterer på at hacke på de interne Omarchy-filer, så skift til dev-kanalen via _Update > Channel > Dev_. Det linker Omarchy til et git-checkout af kildekoden i `~/omarchy`, som du frit kan ændre, alt det hjertet begærer. Der er ingen her, der skal fortælle dig, hvad du skal gøre!

### Nulstil eventuelle ændringer

Hvis du ender med at lave rod i konfigurationerne, kan du altid vende dem tilbage til standarderne via _Update > Config_ i Omarchy-menuen. Eller ved at køre `omarchy reinstall configs` for at nulstille alt.
