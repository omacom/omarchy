# Entwicklungstools

## Alternative Editoren

Omarchy liefert Plain als Standardeditor bei Neuinstallationen und [Neovim](https://neovim.io/) vorinstalliert, aber wenn du etwas Mainstreamigeres und Vertrauteres willst, kannst du das Omarchy-Menü (`Super + Space`) aufrufen und dir die Optionen unter _Install > Editor_ ansehen. Dort findest du VSCode, Cursor, Zed, Sublime Text, Helix, Vim und Emacs. Wenn du nicht findest, wonach du suchst, schau unter _Install > Package_ nach, ob es nicht in einem Arch-Paket steckt (und wenn nicht, versuch _Install > AUR_, um im AUR nachzusehen).

Der originale `vi`-Editor ist ebenfalls sofort einsatzbereit. Führe `vi filename` aus, um eine Datei im Terminal zu bearbeiten.

Theme-Abgleich wird für `VSCode`, `Cursor`, `VSCodium` und `Helix` angeboten.

Du kannst den systemweiten Standardeditor unter `Setup > Defaults > Editor` festlegen.

## Umgebung

Omarchy unterstützt das Einrichten einer ganzen Reihe von Entwicklungsumgebungen über den Abschnitt _Install > Development_ im Omarchy-Menü (`Super + Space`). Dort findest du natürlich _Ruby on Rails_, aber auch alle drei großen Laufzeitumgebungen für JavaScript (Node.js, Bun, Deno) sowie beliebte PHP-Frameworks wie Laravel und Symfony. Ach, und Go, Rust, Python, Java, Elixir (mit Phoenix), .NET, OCaml, Zig, Clojure und Scala gibt es auch. Es ist eine sehr breite Auswahl!

Die Mehrheit dieser Umgebungen wird von [Mise](https://mise.jdx.dev/) verwaltet. Es ist ein Tool, mit dem du mehrere Versionen einer Programmiersprache auf derselben Maschine installieren und ausführen kannst. Es ist wie rbenv oder rvm für Ruby oder virtualenv für Python, aber es funktioniert für eine ganze Reihe verschiedener Umgebungen.

Um zum Beispiel Ruby zu installieren, würdest du `mise use -g ruby` ausführen, wodurch Ruby sowohl installiert als auch als globaler Standard festgelegt wird. Oder, wenn dein Projekt eine .ruby-version-Datei hat, kannst du einfach `mise i` im Stammverzeichnis dieses Projekts ausführen.

## Vorinstallierte CLI-Tools

`uv`, Node.js und `playwright-cli` (damit Agenten einen Browser steuern, unter Verwendung des installierten Chrome) sind als Pakete installiert, und `omarchy update` hält sie mit dem Rest des Systems aktuell. `ghui`, [Hunk](https://github.com/modem-dev/hunk) sowie die CLIs von Basecamp, Cloudflare und HEY sind unter _Install > CLI_ nur einen Klick entfernt, und [Coding-Agenten](17-ai.md) unter _Install > AI > CLI_.

mise verwaltet nur die Laufzeitumgebungen, die du über _Install > Development_ einrichtest; Omarchy installiert von sich aus nichts darüber. Führe `omarchy update` aus, um sie mit dem Rest von Omarchy zu aktualisieren; der `mup`-Alias aktualisiert nur mise-verwaltete Tools. Um deiner eigenen Konfiguration ein weiteres Tool hinzuzufügen, verwende `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) bedarf kaum einer Einführung. Es ermöglicht dir, isolierte Container auszuführen, und Omarchy installiert alles, was nötig ist, um es gut zu betreiben, einschließlich Docker selbst und [Docker Compose](https://docs.docker.com/compose/).

Standardmäßig ist dein Benutzer *nicht* in der `docker`-Gruppe. Diese Gruppe ist faktisch passwortloses Root — alles in ihr kann `docker run -v /:/host` ausführen und die Maschine übernehmen — also wäre ein einzelnes bösartiges Skript oder eine Abhängigkeit, die als du läuft, sonst nur einen Befehl von Root entfernt. Deshalb führst du Docker auf der Kommandozeile mit `sudo` aus (`sudo docker ps`, `sudo docker compose up`), und die grafischen Tools, die mit dem Daemon kommunizieren — die Windows VM —, fragen um Autorisierung, wenn sie sie benötigen. Wenn du den Komfort eines gruppenlosen Setups zurückhaben willst und den Kompromiss verstehst, aktiviere es unter **Setup > Security > Sudoless Docker** (oder führe `omarchy-setup-security-sudoless-docker` aus), was dich nach einer Warnung zur `docker`-Gruppe hinzufügt; dann funktionieren einfaches `docker` und der `d`-Alias wieder ohne `sudo`.

Du kannst die gängigen Datenbanken für lokale Entwicklung in Docker über _Install > Development > Docker DB_ im Omarchy-Menü einrichten.

## GitHub CLI

Die [GitHub CLI](https://cli.github.com/) ist `gh`, um mit Repositories, Issues und Pull Requests aus dem Terminal zu arbeiten. _Setup > Git_ installiert sie, wenn du dich dort dafür entscheidest, dich bei GitHub anzumelden, dann klont `gh repo clone org/repo` ein Repository. Führe `gh --help` aus, um ihre Befehle zu erkunden.

_Install > CLI > GitHub_ installiert die GitHub CLI, `gh`, zusammen mit `ghui`, einer Terminal-Oberfläche für Pull Requests. [Lazygit](https://github.com/jesseduffield/lazygit) ist für die Arbeit mit Git selbst vorinstalliert.
