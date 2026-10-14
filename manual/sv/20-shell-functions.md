# Shellfunktioner

Omarchy levereras med en uppsättning shellfunktioner för att förenkla vanliga uppgifter och kapsla in invecklade parameteranrop.

## Komprimering

- `compress [file/dir]`: Skapa ett tar.gz-arkiv från filen/katalogen.
- `decompress [file.tar.gz]`: Expandera en tar.gz-fil.

## Enheter

- `iso2sd [image.iso]`: Skapa en startbar enhet på ett SD-kort med den angivna iso-filen och välj enheten interaktivt.
- `format-drive [device] [name]`: Formatera en hel disk med en enda exFAT-partition (vilket fungerar på Windows och macOS också). Kör det utan argument för att se tillgängliga enheter. Var försiktig!

## Dev-layouter

Omedelbara utvecklingslayouter med flera paneler för tmux:

- `tdl [ai]`: Skapa en Tmux Dev Layout med din editor, en AI-agent och en terminal. Använd agentaliasen, som `tdl c` för opencode eller `tdl cx` för Claude Code, eller ange en andra agent för att köra båda, som `tdl c cx`.
- `tds`: Skapa en Tmux Dev Square med editor, diff-bevakning (via `hunk diff --watch`), terminal och opencode.
- `tdlm [ai]`: Skapa ett `tdl`-fönster för varje underkatalog i den aktuella katalogen.
- `tsl [count] [command]`: Skapa en svärm av paneler kaklade i ett rutnät, som alla kör samma kommando (utmärkt för AI-agenter).

Samma layouter finns för Herdr som `hdl`, `hds`, `hdlm` och `hsl`.

## Git worktrees

- `ga [branch]`: Skapa en ny worktree och branch bredvid det aktuella repositoryt och hoppa in i den.
- `gd`: Ta bort den aktuella worktree:n och dess branch (ber om bekräftelse först).

## Rsync-bevakare

- `rsw [source] [destination]`: Starta en bakgrundsbevakare som rsyncar källan till destinationen när något ändras. Destinationen kan vara en fjärrvärd, som `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Lista alla aktiva bevakare.
- `dsw`: Stoppa alla aktiva bevakare.

## SSH-portvidarebefordran

Idealisk för webbutveckling med localhost secure-context-privilegier mot en fjärrdator.

- `fip`: Vidarebefordra en eller flera portar från en fjärrvärd till localhost via SSH.
- `dip`: Koppla bort en eller flera vidarebefordrade portar.
- `lip`: Lista alla aktiva SSH-portvidarebefordringar.

Säg att du startar en dev-server på port `3000` på en maskin som nås som `nyc-dev`, då kan du köra `fip nyc-dev 3000` för att vidarebefordra den porten, så att `localhost:3000` faktiskt når `nyc-dev:3000`, men utan behov av SSL-certifikat för att etablera den säkra kontext som behövs för att testa web sockets eller liknande.

## SSH-återanslutning

Själva `ssh` är omslutet i en funktion som städar upp terminalen om en anslutning dör medan en fjärr-tmux, Herdr eller editor har tagit över den, och sedan automatiskt återansluter när en interaktiv session kopplas bort (Ctrl-C stoppar retry-loopen).
