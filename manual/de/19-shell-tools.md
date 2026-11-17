# Shell-Werkzeuge

Zusätzlich zu den standardmäßigen Linux-Werkzeugen liefert Omarchy auch eine Reihe verbesserter Shell-Werkzeuge mit. Hier sind die wichtigsten.

## fzf

[fzf](https://junegunn.github.io/fzf/) bietet dir eine Fuzzy-Dateisuche über den Alias `ff`. Gehe in ein beliebiges Verzeichnis, tippe `ff` ein, und du kannst dich unscharf zu jeder Datei in diesem Baum vortasten, während du rechts eine Vorschau der Dateien siehst, auf die du die Auswahl eingrenzt.

Mit `Ctrl + R` kannst du fzf nutzen, um deine Befehlshistorie unscharf zu durchsuchen.

Dieses Werkzeug wird auch von Neovim verwendet, wenn du `Space Space` tippst.

Das vollständige Handbuch findest du über `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) ist ein Ersatz für cd. Es merkt sich die Verzeichnisse, in denen du warst, sodass du beim nächsten Mal leichter dorthin springen kannst. Angenommen, du führst einmal `cd ~/.config/omarchy` aus. Beim nächsten Mal kannst du einfach `cd omarchy` (oder sogar nur `cd oma`) eingeben, und Zoxide bringt dich direkt dorthin.

Das vollständige Handbuch findest du über `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) durchsucht die Inhalte von Dateien mit `rg <pattern> <path>`, zum Beispiel `rg Controller app/`, um alle Erwähnungen von `Controller` im Verzeichnis app zu finden.

Dieses Werkzeug wird auch von Neovim verwendet, wenn du `Space S G` tippst.

Das vollständige Handbuch findest du über `man rg`.

## eza

[eza](https://eza.rocks/) ist ein Ersatz für ls. Es bietet dir Verzeichnisauflistungen mit mehr Informationen, Farbe und Symbolen. Standardmäßig ist eza als ls aliasiert. Mit `lt` erhältst du außerdem eine Auflistung mit zwei Ebenen Verschachtelungstiefe. `lsa` liefert eine Auflistung einschließlich versteckter Dateien. Und `lta` eine verschachtelte Auflistung mit versteckten Dateien.

Das vollständige Handbuch findest du über `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) ist ein einfacher zu bedienender Ersatz für `find`. Verwende `fd person.rb`, um eine Datei namens `person.rb` im aktuellen Baum zu finden. `fd person.rb /` durchsucht das gesamte Dateisystem. `fd person.rb / -H` durchsucht das gesamte Dateisystem einschließlich versteckter Verzeichnisse.

Das vollständige Handbuch findest du über `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) ist `cat` mit Syntaxhervorhebung, Zeilennummern und Paging. Führe `bat somefile.rb` aus, und du wirst sehen, warum es schwer ist, wieder zurückzugehen. Es arbeitet auch still an anderen Stellen für dich: Es färbt deine Man-Pages ein und rendert die Vorschauen in `ff`.

Das vollständige Handbuch findest du über `man bat`.

## tldr

[tldr](https://tldr.sh/) ist das Gegenmittel zu Man-Pages, die mit drei Bildschirmen Geschichte beginnen, bevor sie dir ein einziges Beispiel zeigen. `tldr tar` liefert dir die Handvoll Aufrufe, die du eigentlich wolltest.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) lädt Videos von YouTube und Hunderten anderer Websites herunter. `yt-dlp <url>` holt die beste verfügbare Qualität ins aktuelle Verzeichnis.

Das vollständige Handbuch findest du über `man yt-dlp`.

## try

[try](https://github.com/tobi/try) macht es einfach, Programmierexperimente mit datumsmarkierten Verzeichnissen zu verwalten. Alle Experimente leben in `~/Work/tries`, und du erreichst sie über `try`.

Omarchy fügt das Verzeichnis `bin/` eines Projekts nicht automatisch zu `PATH` hinzu. Führe vertrauenswürdige projektlokale Werkzeuge mit einem expliziten relativen Pfad aus, zum Beispiel `bin/rails` oder `./bin/dev`.
