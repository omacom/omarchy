# Terminal

[Foot](https://codeberg.org/dnkl/foot) ist das Standardterminal für Omarchy. Es ist schnell, leichtgewichtig und sogar mit alten Computern kompatibel. Es unterstützt jedoch keine nativen Tabs oder Splits.

Wenn du Tmux verwendest, stört dich das vielleicht nicht, aber wenn nicht, unterstützen wir auch _Alacritty_, _Ghostty_ und _Kitty_ vollständig als Optionen. Wähle deine Präferenz unter _Installieren > Terminal_ im Omarchy-Menü.

Du startest ein neues Terminal mit `Super + Return`. (Diese Zuordnung zeigt automatisch auf das Terminal, das du über _Installieren > Terminal_ installiert hast, und du kannst unter _Einrichtung > Standards > Terminal_ zwischen installierten Terminals wechseln.)

## Tmux

Tmux bietet eine konsistente, programmierbare Oberfläche für Panes, Fenster (alias Tabs) und wiederaufnehmbare Sitzungen, unabhängig von deinem Terminal. Es funktioniert sogar auf Remote-Hosts, sodass du denselben Ansatz verwenden kannst, wenn du dich per SSH auf einem Server einloggst.

Du startest eine neue Tmux-Sitzung in einem frischen Terminal mit `Super + Alt + Return`, und weil Tmux ein persistenter Prozess ist, kannst du deine Sitzung wieder aufnehmen, selbst wenn du dieses Terminal schließt. Drücke einfach `Ctrl + Space` (die Präfix-Taste genannt) und dann `s`, um alle deine aktiven Sitzungen zu sehen.

Omarchy liefert eine ergonomisch optimierte Tmux-Konfiguration mit, die viele Tastenzuordnungen zum Lernen hat, also halte [den Spickzettel griffbereit](07-hotkeys.md#tmux).

## Tmux-Layoutfunktionen

Weil Tmux programmierbar ist, können wir Funktionen verwenden, um Layouts zu erstellen. Omarchy liefert vier verschiedene Funktionen für gängige Entwickler-Layouts mit.

`tdl [agent]` startet eine dreigeteilte IDE-ähnliche Oberfläche mit dem `$EDITOR` auf der linken Seite, deinem gewählten KI-Agenten auf der rechten Seite (wie `c` für opencode oder `cx` für Claude oder `codex` für OpenAI) und dann einem Terminal unten.

So würde `tdl c` dies starten (oder einfach `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Du kannst auch einen zweiten Agenten mit `tdl c cx` (opencode + claude) starten (oder einfach `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Es gibt auch `tds`, das ein viergeteiltes Quadrat startet mit dem Editor oben links, einem Live-Diff-Watcher oben rechts, einem Terminal unten links und opencode unten rechts.

Du kannst diese Layout-Konfiguration auch für jedes Unterverzeichnis im aktuellen Verzeichnis mit `tdlm [agent]` starten und dann mit `alt + 1/2/3/4/5/...` navigieren:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Schließlich kannst du einen Schwarm von Agenten mit `tsl [panes] [command]` starten. So gibt dir `tsl 4 c` ein viergeteiltes Raster von opencode-Agenten:

 ![tmux-tsl](images/tmux-tsl.webp)
