# Funcions de l'intèrpret d'ordres

Omarchy ve amb un conjunt de funcions de l'intèrpret d'ordres per simplificar tasques habituals i encapsular crides de paràmetres complicades.

## Compressió

- `compress [file/dir]`: Crea un arxiu tar.gz a partir del fitxer o directori.
- `decompress [file.tar.gz]`: Expandeix un fitxer tar.gz.

## Unitats

- `iso2sd [image.iso]`: Crea una unitat d'arrencada en una targeta SD fent servir el fitxer iso referenciat i triant la unitat de manera interactiva.
- `format-drive [device] [name]`: Formata un disc sencer amb una sola partició exFAT (que també funciona a Windows i macOS). Executa-la sense arguments per veure les unitats disponibles. Ves-hi amb compte!

## Disposicions de desenvolupament

Disposicions de desenvolupament multipanell instantànies per a tmux:

- `tdl [ai]`: Crea una disposició de desenvolupament de Tmux amb l'editor, un agent d'IA i un terminal. Fes servir els àlies d'agent, com ara `tdl c` per a opencode o `tdl cx` per a Claude Code, o passa-hi un segon agent per executar-los tots dos, com ara `tdl c cx`.
- `tds`: Crea un quadrat de desenvolupament de Tmux amb editor, vigilància de diferències (mitjançant `hunk diff --watch`), terminal i opencode.
- `tdlm [ai]`: Crea una finestra `tdl` per a cada subdirectori del directori actual.
- `tsl [count] [command]`: Crea un eixam de panells en mosaic en una quadrícula, tots executant la mateixa ordre (ideal per a agents d'IA).

Les mateixes disposicions estan disponibles per a Herdr com a `hdl`, `hds`, `hdlm` i `hsl`.

## Worktrees de Git

- `ga [branch]`: Crea un nou worktree i una branca al costat del repositori actual i hi salta a dins.
- `gd`: Elimina el worktree actual i la seva branca (demana confirmació abans).

## Vigilants d'rsync

- `rsw [source] [destination]`: Inicia un vigilant en segon pla que sincronitza amb rsync l'origen cap a la destinació sempre que alguna cosa canvia. La destinació pot ser un host remot, com ara `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Llista tots els vigilants actius.
- `dsw`: Atura tots els vigilants actius.

## Reenviament de ports SSH

Ideal per fer desenvolupament web amb privilegis de context segur de localhost contra una màquina remota.

- `fip`: Reenvia un o més ports d'un host remot a localhost mitjançant SSH.
- `dip`: Desconnecta un o més ports reenviats.
- `lip`: Llista tots els reenviaments de ports SSH actius.

Suposa que engegues un servidor de desenvolupament al port `3000` en una màquina accessible com a `nyc-dev`; aleshores pots executar `fip nyc-dev 3000` per reenviar aquell port, de manera que `localhost:3000` arribi en realitat a `nyc-dev:3000`, però sense necessitar certificats SSL per establir el context segur necessari per provar websockets o coses semblants.

## Reconnexió SSH

El mateix `ssh` està embolcallat en una funció que neteja el terminal si una connexió es talla mentre un tmux, un Herdr o un editor remot se n'havia apoderat, i després es reconnecta automàticament quan una sessió interactiva cau (Ctrl-C atura el bucle de reintents).
