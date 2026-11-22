# Shell-functies

Omarchy wordt geleverd met een set shell-functies om veelvoorkomende taken te vereenvoudigen en omslachtige parameteraanroepen in te kapselen.

## Compressie

- `compress [file/dir]`: Maak een tar.gz-archief van het bestand/de map.
- `decompress [file.tar.gz]`: Pak een tar.gz-bestand uit.

## Schijven

- `iso2sd [image.iso]`: Maak een opstartbare schijf op een SD-kaart met het gerefereerde iso-bestand en kies de schijf interactief.
- `format-drive [device] [name]`: Formatteer een hele schijf met een enkele exFAT-partitie (die ook op Windows en macOS werkt). Voer het uit zonder argumenten om de beschikbare schijven te zien. Wees voorzichtig!

## Dev-lay-outs

Directe ontwikkel-lay-outs met meerdere panelen voor tmux:

- `tdl [ai]`: Maak een Tmux Dev Layout met je editor, een AI-agent en een terminal. Gebruik de agent-aliassen, zoals `tdl c` voor opencode of `tdl cx` voor Claude Code, of geef een tweede agent mee om beide uit te voeren, zoals `tdl c cx`.
- `tds`: Maak een Tmux Dev Square met editor, diff-bewaking (via `hunk diff --watch`), terminal en opencode.
- `tdlm [ai]`: Maak een `tdl`-venster voor elke submap in de huidige map.
- `tsl [count] [command]`: Maak een zwerm panelen betegeld in een raster, die allemaal hetzelfde commando uitvoeren (geweldig voor AI-agents).

Dezelfde lay-outs zijn beschikbaar voor Herdr als `hdl`, `hds`, `hdlm` en `hsl`.

## Git-worktrees

- `ga [branch]`: Maak een nieuwe worktree en branch naast de huidige repository en spring erin.
- `gd`: Verwijder de huidige worktree en de bijbehorende branch (vraagt eerst om bevestiging).

## Rsync-watchers

- `rsw [source] [destination]`: Start een achtergrond-watcher die bron naar bestemming rsync't telkens wanneer er iets verandert. De bestemming kan een externe host zijn, zoals `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Toon alle actieve watchers.
- `dsw`: Stop alle actieve watchers.

## SSH-poortdoorschakeling

Ideaal voor webontwikkeling met localhost secure-context-privileges tegen een externe machine.

- `fip`: Schakel een of meer poorten van een externe host door naar localhost via SSH.
- `dip`: Verbreek de verbinding van een of meer doorgeschakelde poorten.
- `lip`: Toon alle actieve SSH-poortdoorschakelingen.

Stel dat je een dev-server start op poort `3000` op een machine die bereikbaar is als `nyc-dev`, dan kun je `fip nyc-dev 3000` uitvoeren om die poort door te schakelen, zodat `localhost:3000` daadwerkelijk `nyc-dev:3000` bereikt, maar zonder dat SSL-certificaten nodig zijn om de beveiligde context tot stand te brengen die nodig is voor het testen van websockets of iets dergelijks.

## SSH-herverbinding

`ssh` zelf is verpakt in een functie die de terminal opruimt als een verbinding doodgaat terwijl een externe tmux, Herdr of editor deze heeft geclaimd, en vervolgens automatisch opnieuw verbinding maakt wanneer een interactieve sessie wegvalt (Ctrl-C stopt de herprobeerlus).
