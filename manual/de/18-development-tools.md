# Entwicklungswerkzeuge

## Alternative Editoren

Omarchy wird standardmäßig mit [Neovim](https://neovim.io/) ausgeliefert, aber wenn du etwas Gebräuchlicheres und Vertrauteres möchtest, kannst du das Omarchy-Menü (`Super + Space`) öffnen und dir die Optionen unter _Installieren > Editor_ ansehen. Dort findest du VSCode, Cursor, Zed, Sublime Text, Helix, Vim und Emacs. Wenn du nicht findest, was du suchst, schau unter _Installieren > Package_ nach, ob es nicht in einem Arch-Paket steckt (und wenn nicht, versuch es über _Installieren > AUR_ im AUR).

Der originale Editor `vi` ist ebenfalls von Haus aus verfügbar. Führe `vi filename` aus, um eine Datei im Terminal zu bearbeiten.

Für `VSCode`, `Cursor`, `VSCodium` und `Helix` wird eine Anpassung an das Design angeboten.

Den systemweiten Standard-Editor legst du unter `Einrichtung > Defaults > Editor` fest.

## Umgebung

Omarchy unterstützt die Einrichtung einer ganzen Reihe von Entwicklungsumgebungen über den Abschnitt _Installieren > Development_ im Omarchy-Menü (`Super + Space`). Du findest dort natürlich _Ruby on Rails_, aber auch alle drei großen Laufzeitumgebungen für JavaScript (Node.js, Bun, Deno) sowie beliebte PHP-Frameworks wie Laravel und Symfony. Ach ja, und Go, Rust, Python, Java, Elixir (mit Phoenix), .NET, OCaml, Zig, Clojure und Scala gibt es auch. Eine wirklich breite Auswahl!

Die Mehrheit dieser Umgebungen wird von [Mise](https://mise.jdx.dev/) verwaltet. Das ist ein Werkzeug, mit dem du mehrere Versionen einer Programmiersprache auf demselben Rechner installieren und ausführen kannst. Es ist wie rbenv oder rvm für Ruby oder virtualenv für Python, funktioniert aber für eine ganze Reihe verschiedener Umgebungen.

Um zum Beispiel Ruby zu installieren, führst du `mise use -g ruby` aus, was Ruby installiert und zugleich als globalen Standard festlegt. Oder, wenn dein Projekt eine Datei .ruby-version hat, kannst du einfach `mise i` im Stammverzeichnis dieses Projekts ausführen.

## Docker

[Docker](https://www.docker.com/) braucht kaum eine Einführung. Es erlaubt dir, isolierte Container auszuführen, und Omarchy installiert alles, was für einen guten Betrieb nötig ist, einschließlich Docker selbst und [Docker Compose](https://docs.docker.com/compose/).

Standardmäßig ist dein Benutzer *nicht* in der Gruppe `docker`. Diese Gruppe ist faktisch passwortloses root — alles darin kann `docker run -v /:/host` ausführen und den Rechner übernehmen — sodass sonst ein einziges bösartiges Skript oder eine Abhängigkeit, die unter deinem Benutzer läuft, nur einen Befehl von root entfernt wäre. Auf der Kommandozeile führst du Docker deshalb mit `sudo` aus (`sudo docker ps`, `sudo docker compose up`), und die grafischen Werkzeuge, die mit dem Daemon sprechen — die Windows-VM — bitten bei Bedarf um Autorisierung. Wenn du den Komfort einer gruppenlosen Einrichtung zurückhaben willst und den Kompromiss verstehst, aktiviere sie über **Einrichtung > Security > Sudoless Docker** (oder führe `omarchy-setup-security-sudoless-docker` aus), was dich nach einer Warnung zur Gruppe `docker` hinzufügt; dann funktionieren das einfache `docker` und der Alias `d` wieder ohne `sudo`.

Die gängigen Datenbanken für die lokale Entwicklung in Docker kannst du im Omarchy-Menü über _Installieren > Development > Docker DB_ einrichten.

## GitHub CLI

[Die GitHub CLI](https://cli.github.com/) lässt dich mit deinem GitHub-Konto authentifizieren und damit private Repositories klonen. Sie ist als einer der träge ladenden mise-Stubs eingebunden, sodass sie sich beim ersten Ausführen von `gh` selbst installiert. Zur Authentifizierung führst du `gh auth login` aus. Danach kannst du private Repositories mit `gh repo clone org/repo` auschecken.

Mit diesem Befehl kannst du auch eine ganze Reihe anderer GitHub-Operationen durchführen. Führe einfach `gh` aus, um zu sehen, was alles möglich ist.

Es gibt auch einen träge installierenden Stub für `ghui`, um deine Pull Requests in einer TUI zu verwalten. Und [lazygit](https://github.com/jesseduffield/lazygit) ist vorinstalliert, falls du Git selbst ebenfalls aus einer TUI heraus steuern möchtest.
