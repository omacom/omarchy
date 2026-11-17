# Shell-Funktionen

Omarchy bringt eine Reihe von Shell-Funktionen mit, um häufige Aufgaben zu vereinfachen und umständliche Parameteraufrufe zu kapseln.

## Kompression

- `compress [file/dir]`: Erstelle ein tar.gz-Archiv aus einer Datei/einem Verzeichnis.
- `decompress [file.tar.gz]`: Entpacke eine tar.gz-Datei.

## Laufwerke

- `iso2sd [image.iso]`: Erstelle ein bootfähiges Laufwerk auf einer SD-Karte aus der angegebenen ISO-Datei und wähle das Laufwerk interaktiv aus.
- `format-drive [device] [name]`: Formatiere eine ganze Platte mit einer einzigen exFAT-Partition (die auch unter Windows und macOS funktioniert). Führe den Befehl ohne Argumente aus, um die verfügbaren Laufwerke zu sehen. Vorsicht!

## Dev-Layouts

Sofortige Entwicklungs-Layouts mit mehreren Panes für tmux:

- `tdl [ai]`: Erstelle ein Tmux Dev Layout mit deinem Editor, einem KI-Agenten und einem Terminal. Verwende die Agenten-Aliase, zum Beispiel `tdl c` für opencode oder `tdl cx` für Claude Code, oder übergib einen zweiten Agenten, um beide auszuführen, zum Beispiel `tdl c cx`.
- `tds`: Erstelle ein Tmux Dev Square mit Editor, Diff-Beobachtung (über `hunk diff --watch`), Terminal und opencode.
- `tdlm [ai]`: Erstelle ein `tdl`-Fenster für jedes Unterverzeichnis im aktuellen Verzeichnis.
- `tsl [count] [command]`: Erstelle einen Schwarm von Panes, die in einem Raster gekachelt sind und alle denselben Befehl ausführen (ideal für KI-Agenten).

Dieselben Layouts gibt es für Herdr als `hdl`, `hds`, `hdlm` und `hsl`.

## Git-Worktrees

- `ga [branch]`: Erstelle einen neuen Worktree und Branch neben dem aktuellen Repository und springe hinein.
- `gd`: Entferne den aktuellen Worktree und seinen Branch (fragt vorher um Bestätigung).

## Rsync-Watcher

- `rsw [source] [destination]`: Starte einen Hintergrund-Watcher, der die Quelle bei jeder Änderung per rsync zum Ziel synchronisiert. Das Ziel kann ein Remote-Host sein, zum Beispiel `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Liste alle aktiven Watcher auf.
- `dsw`: Stoppe alle aktiven Watcher.

## SSH-Portweiterleitung

Ideal für Webentwicklung mit localhost-Secure-Context-Rechten gegenüber einem Remote-Rechner.

- `fip`: Leite einen oder mehrere Ports von einem Remote-Host per SSH an localhost weiter.
- `dip`: Trenne einen oder mehrere weitergeleitete Ports.
- `lip`: Liste alle aktiven SSH-Portweiterleitungen auf.

Angenommen, du startest einen Dev-Server auf Port `3000` auf einem Rechner, der als `nyc-dev` erreichbar ist, dann kannst du `fip nyc-dev 3000` ausführen, um diesen Port weiterzuleiten, sodass `localhost:3000` tatsächlich `nyc-dev:3000` erreicht, aber ohne SSL-Zertifikate, um den sicheren Kontext herzustellen, der zum Testen von WebSockets oder Ähnlichem nötig ist.

## SSH-Wiederverbindung

`ssh` selbst ist in eine Funktion verpackt, die das Terminal aufräumt, wenn eine Verbindung stirbt, während ein entferntes tmux, Herdr oder ein Editor es beansprucht hat, und die danach automatisch wieder verbindet, wenn eine interaktive Sitzung abbricht (Ctrl-C stoppt die Wiederholungsschleife).
