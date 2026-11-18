# Neovim

[Neovim](https://neovim.io/) ist eine moderne Implementierung von [dem vi-Editor](<https://en.wikipedia.org/wiki/Vi_(text_editor)>), den Bill Joy schon 1976 geschaffen hat. Es ist ein modaler Editor, bei dem Einfügemodus und Befehlsmodus getrennt sind, und er ist so etwas wie eine Superkraft, sobald du auch nur eine Teilmenge des unglaublich tiefen Tastenbefehlssatzes lernst. Aber er hat auch eine ziemliche Lernkurve!

Wenn du völlig neu im vim-artigen Editieren bist, empfehle ich dir [ThePrimeagens Serie Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) auf YouTube. Das bringt dir die Grundlagen bei. Wisse nur, dass es im Gegensatz zu ähnlicheren Mainstream-Editoren länger dauern wird, bis du grundlegende Kompetenz mit vim erlangst. Aber sobald du es tust, ist der Ertrag auch größer.

Nun ist Neovim im Grunde unendlich konfigurierbar. Wenn du wirklich durchdrehen willst, kannst du deine eigene Neovim-Konfiguration von Grund auf erstellen. Es gibt einen großartigen Kurs von [Typecraft zum Einrichten von Neovim von Grund auf](https://www.youtube.com/watch?v=zHTeCSVAFNY). Und [ThePrimeagen hat auch einen](https://www.youtube.com/watch?v=w7i4amO_zaE).

Aber Omarchy liefert ein komplettes Neovim-Setup mit — das Paket `omarchy-nvim` — das liebevoll abgestimmt wurde, um das Beste dessen zu zeigen, was sofort einsatzbereit möglich ist. Ohne dass du eine einzige Konfigurationszeile schreiben musst! Es basiert auf [LazyVim](https://www.lazyvim.org/), einer Distribution von Neovim-Plugins und -Konfigurationen. Es ist großartig.

## LazyVim-Grundlagen

Wie erwähnt, werde ich dir in dieser kurzen Einführung nicht vim beibringen, aber ich kann dir ein paar Grundlagen von LazyVim zeigen und wie du dich zurechtfindest.

Zuerst hat Neovim die Idee der Leader-Taste. Das ist im Grunde das Tor zu allen Befehlen. LazyVim hat diese auf `Space` gesetzt. Drücke sie also einfach, warte eine Sekunde, und du siehst eine Reihe von Optionen, die inline so erklärt werden:

Hier sind einige grundlegende Befehle, die ich ständig verwende:

- `Space Space` - Finde per Fuzzy-Suche jede Datei im aktuellen Verzeichnis.
- `Space S G` - Durchsuche alle Dateien mit grep und einer Vorschau.
- `Space E` - Schalte den Dateibaum ein/aus.
- `Ctrl + W W` - Springe vom Dateibaum zum Editor und zurück.
- `Shift + H` - Bewege dich nach links zwischen den geöffneten Tabs (vim nennt sie Buffer).
- `Shift + L` - Bewege dich nach rechts zwischen den geöffneten Tabs.
- `Space B D` - Schließe einen Tab.
- `Space B O` - Schließe alle anderen Tabs außer dem aktuellen.
- `Space G G` - Starte LazyGit in einem schwebenden Pane aus dem aktuellen Verzeichnis.
- `Space U W` - Schalte Soft Wrap um.

Während du im Dateibaum bist (`Space E` zum Einblenden, `Ctrl + W W` zum Hinüberspringen), kannst du eine neue Datei mit `a` oder ein neues Verzeichnis mit `A` hinzufügen. Drücke `?`, während du im Baum bist, um alle Befehle zu sehen.

Wenn du die grundlegende vim-Sprache lernen willst, habe ich über [die dreiteilige Syntax](https://world.hey.com/dhh/wonderful-vi-a1d034d3) geschrieben und darüber, wie man diese krassen Kombos hinbekommt!

Alle möglichen Befehle siehst du auf [der LazyVim-Keymaps-Seite](https://www.lazyvim.org/keymaps).

## Neovim starten

Du kannst Neovim mit `Super + Shift + N` starten (die Zuordnung startet deinen Standardeditor, der sofort einsatzbereit Neovim ist), aber es ist normalerweise einfacher, ihn vom Terminal aus zu steuern, indem du in das Verzeichnis navigierst, in dem du arbeiten willst, und `n` tippst. Das `n` ist der Alias für `nvim`, der standardmäßig das aktuelle Verzeichnis zum Öffnen verwendet. Du kannst eine einzelne Datei mit `n myfile.txt` öffnen.

## Neovim für sudo-Bearbeitungen verwenden

Wenn du Dateien bearbeiten musst, die du nur als Superuser ändern kannst, kannst du Neovim mit allen deinen eingerichteten Plugins verwenden, indem du `sudoedit /etc/sudoers.d/00-sudo-only-file` ausführst.
