# Shellfunktioner

Omarchy leveres med et sæt shellfunktioner til at forenkle almindelige opgaver og indkapsle indviklede parameterkald.

## Komprimering

- `compress [file/dir]`: Opret et tar.gz-arkiv fra filen/mappen.
- `decompress [file.tar.gz]`: Udpak en tar.gz-fil.

## Drev

- `iso2sd [image.iso]`: Opret et bootbart drev på et SD-kort ved hjælp af den refererede iso-fil og vælg drevet interaktivt.
- `format-drive [device] [name]`: Formatér en hel disk med en enkelt exFAT-partition (som også virker på Windows og macOS). Kør den uden argumenter for at se de tilgængelige drev. Vær forsigtig!

## Dev-layouts

Øjeblikkelige udviklingslayouts med flere ruder til tmux:

- `tdl [ai]`: Opret et Tmux Dev Layout med din editor, en AI-agent og en terminal. Brug agentaliaserne, som `tdl c` til opencode eller `tdl cx` til Claude Code, eller videregiv en anden agent for at køre begge, som `tdl c cx`.
- `tds`: Opret et Tmux Dev Square med editor, diff-overvågning (via `hunk diff --watch`), terminal og opencode.
- `tdlm [ai]`: Opret et `tdl`-vindue for hver undermappe i den aktuelle mappe.
- `tsl [count] [command]`: Opret en sværm af ruder fliselagt i et gitter, der alle kører den samme kommando (fantastisk til AI-agenter).

De samme layouts er tilgængelige til Herdr som `hdl`, `hds`, `hdlm` og `hsl`.

## Git worktrees

- `ga [branch]`: Opret et nyt worktree og en branch ved siden af det aktuelle repository og hop ind i det.
- `gd`: Fjern det aktuelle worktree og dets branch (beder om bekræftelse først).

## Rsync-overvågere

- `rsw [source] [destination]`: Start en baggrundsovervåger, der rsync'er kilde til destination, når noget ændrer sig. Destinationen kan være en fjernvært, som `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Vis alle aktive overvågere.
- `dsw`: Stop alle aktive overvågere.

## SSH-portvideresendelse

Ideelt til at lave webudvikling med localhost secure-context-privilegier mod en fjernboks.

- `fip`: Videresend en eller flere porte fra en fjernvært til localhost via SSH.
- `dip`: Afbryd en eller flere videresendte porte.
- `lip`: Vis alle aktive SSH-portvideresendelser.

Lad os sige, at du starter en dev-server på port `3000` på en maskine, der er tilgængelig som `nyc-dev`, så kan du køre `fip nyc-dev 3000` for at videresende den port, så `localhost:3000` faktisk når `nyc-dev:3000`, men uden behov for SSL-certifikater til at etablere den sikre kontekst, der er nødvendig for at teste websockets og lignende.

## SSH-genforbindelse

Selve `ssh` er pakket ind i en funktion, der rydder op i terminalen, hvis en forbindelse dør, mens en fjern-tmux, Herdr eller editor har gjort krav på den, og derefter automatisk genforbinder, når en interaktiv session falder ud (Ctrl-C stopper genforsøgsløkken).
