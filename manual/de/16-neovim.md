# Neovim

[Neovim](https://neovim.io/) ist eine moderne Implementierung von [dem vi-Editor](<https://en.wikipedia.org/wiki/Vi_(text_editor)>), den Bill Joy schon 1976 erstellt hat. Es ist ein modaler Editor, bei dem Einfügemodus und Befehlsmodus getrennt sind, und er ist so etwas wie eine Superkraft, sobald du auch nur einen Teil der unglaublich umfangreichen Tastaturbefehle gelernt hast. Aber die Lernkurve hat es auch in sich!

Wenn du völlig neu bei der Bearbeitung im vim-Stil bist, empfehle ich dir, dir [ThePrimeagen's Vim As Your Editor series](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) auf YouTube anzusehen. Das bringt dir die Grundlagen bei. Sei dir nur bewusst, dass es im Gegensatz zu ähnlicheren Mainstream-Editoren länger dauern wird, bis du grundlegende Fertigkeiten mit vim erlangst. Aber wenn du es geschafft hast, ist der Lohn dafür auch größer.

Nun ist Neovim im Grunde unendlich konfigurierbar. Wenn du wirklich ausrasten willst, kannst du deine eigene Neovim-Konfiguration von Grund auf erstellen. Es gibt einen großartigen Kurs von [Typecraft zum Einrichten von Neovim von Grund auf](https://www.youtube.com/watch?v=zHTeCSVAFNY). Und [ThePrimeagen hat ebenfalls einen](https://www.youtube.com/watch?v=w7i4amO_zaE).

Aber Omarchy wird mit einem kompletten Neovim-Setup ausgeliefert — dem Paket `omarchy-nvim` — das liebevoll abgestimmt wurde, um direkt nach der Installation das Beste zu zeigen, was möglich ist. Ohne dass du eine einzige Zeile Konfiguration schreiben musst! Es basiert auf [LazyVim](https://www.lazyvim.org/), einer Distribution von Neovim-Plugins und -Konfigurationen. Es ist fantastisch.

## LazyVim-Grundlagen

Wie erwähnt, werde ich dir in dieser kurzen Einführung nicht vim beibringen, aber ich kann dir ein paar Grundlagen von LazyVim zeigen und erklären, wie du dich zurechtfindest.

Zuerst gibt es bei Neovim die Idee der Leader-Taste. Das ist im Grunde das Tor zu allen Befehlen. LazyVim hat dafür `Space` festgelegt. Drücke sie also einfach, warte eine Sekunde, und du wirst sehen, wie eine Reihe von Optionen direkt daneben wie folgt erklärt wird:

Hier sind einige grundlegende Befehle, die ich ständig verwende:

- `Space Space` - Jede Datei im aktuellen Verzeichnis per Fuzzy-Suche finden.
- `Space S G` - Alle Dateien mit grep und einer Vorschau durchsuchen.
- `Space E` - Den Dateibaum ein-/ausschalten.
- `Ctrl + W W` - Zwischen dem Dateibaum und dem Editor hin- und herspringen.
- `Shift + H` - Zwischen den geöffneten Tabs nach links wechseln (vim nennt sie Buffer).
- `Shift + L` - Zwischen den geöffneten Tabs nach rechts wechseln.
- `Space B D` - Einen Tab schließen.
- `Space B O` - Alle anderen Tabs bis auf den aktuellen schließen.
- `Space G G` - LazyGit in einem schwebenden Bereich aus dem aktuellen Verzeichnis starten.
- `Space U W` - Weichen Zeilenumbruch umschalten.

Während du dich im Dateibaum befindest (`Space E`, um ihn einzublenden, `Ctrl + W W`, um dorthin zu springen), kannst du mit `a` eine neue Datei oder mit `A` ein neues Verzeichnis hinzufügen. Drücke im Baum `?`, um alle Befehle zu sehen.

Wenn du die grundlegende vim-Sprache lernen willst, habe ich über [die dreiteilige Syntax](https://world.hey.com/dhh/wonderful-vi-a1d034d3) geschrieben und darüber, wie du diese kranken Combo-Moves hinbekommst!

Alle möglichen Befehle kannst du auf [der LazyVim Keymaps-Seite](https://www.lazyvim.org/keymaps) sehen.

## Neovim starten

`Super + Shift + N` startet deinen Standardeditor, der bei neuen Installationen Plain ist; wähle Neovim unter _Setup > Defaults > Editor_, damit stattdessen Neovim gestartet wird. Aber normalerweise ist es einfacher, ihn vom Terminal aus zu steuern, indem du zu dem Verzeichnis navigierst, in dem du arbeiten willst, und `n` eingibst. `n` ist der Alias für `nvim`, der standardmäßig das aktuelle Verzeichnis zum Öffnen verwendet. Du kannst eine einzelne Datei mit `n myfile.txt` öffnen.

## Neovim für sudo-Bearbeitungen verwenden

Wenn du Dateien bearbeiten musst, die du nur als Superuser ändern kannst, führe `sudoedit /etc/sudoers.d/00-sudo-only-file` aus. Das öffnet deinen Standardeditor, lege also Neovim unter _Setup > Defaults > Editor_ fest, wenn du ihn dort mit all deinen Plugins haben willst.
