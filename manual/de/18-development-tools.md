# Entwicklungstools

## Alternative Editoren

Omarchy liefert Plain als Standardeditor auf neuen Installationen und [Neovim](https://neovim.io/) vorinstalliert aus, aber wenn du etwas Mainstreamigeres und Vertrauteres möchtest, kannst du das Omarchy Menu (`Super + Space`) aufrufen und dir die Optionen unter _Installieren > Editor_ ansehen. Dort sind VSCode, Cursor, Zed, Sublime Text, Helix, Vim und Emacs aufgelistet. Wenn du nicht findest, wonach du suchst, schau unter _Installieren > Paket_ nach und sieh, ob es nicht in einem Arch-Paket enthalten ist (und wenn nicht, versuch es über _Installieren > AUR_, um im AUR nachzusehen).

Der ursprüngliche `vi`-Editor ist ebenfalls sofort einsatzbereit verfügbar. Führe `vi filename` aus, um eine Datei im Terminal zu bearbeiten.

Für `VSCode`, `Cursor`, `VSCodium` und `Helix` wird eine Theme-Anpassung angeboten.

Den systemweiten Standardeditor kannst du unter `Setup > Defaults > Editor` festlegen.

## Umgebung

Omarchy unterstützt die Einrichtung einer ganzen Reihe von Entwicklungsumgebungen über den Bereich _Installieren > Entwicklung_ des Omarchy Menu (`Super + Space`). Dort findest du natürlich _Ruby on Rails_, aber auch alle drei großen Laufzeitumgebungen für JavaScript (Node.js, Bun, Deno) sowie beliebte PHP-Frameworks wie Laravel und Symfony. Oh, und Go, Rust, Python, Java, Elixir (mit Phoenix), .NET, OCaml, Zig, Clojure und Scala gibt es auch. Das ist eine sehr breite Auswahl!

Die Mehrheit dieser Umgebungen wird von [Mise](https://mise.jdx.dev/) verwaltet. Es ist ein Tool, mit dem du mehrere Versionen einer Programmiersprache auf derselben Maschine installieren und ausführen kannst. Es ist wie rbenv oder rvm für Ruby oder virtualenv für Python, aber es funktioniert für eine ganze Reihe verschiedener Umgebungen.

Um zum Beispiel Ruby zu installieren, würdest du `mise use -g ruby` ausführen, wodurch Ruby sowohl installiert als auch als globaler Standard festgelegt wird. Oder, wenn dein Projekt eine .ruby-version-Datei hat, kannst du einfach `mise i` im Stammverzeichnis dieses Projekts ausführen.

## Vorinstallierte CLI-Tools

`uv`, Node.js und `playwright-cli` (damit Agenten einen Browser steuern können, unter Verwendung des installierten Chrome) sind als Pakete installiert, und `omarchy update` hält sie zusammen mit dem restlichen System aktuell. [Hunk](https://github.com/modem-dev/hunk) sowie die GitHub-, Basecamp-, Cloudflare- und HEY-CLIs sind unter _Installieren > CLI_ nur eine Auswahl entfernt, und [Coding-Agenten](17-ai.md) unter _Installieren > AI > CLI_.

mise verwaltet nur die Laufzeitumgebungen, die du über _Installieren > Entwicklung_ einrichtest; Omarchy installiert von sich aus nichts darüber. Führe `omarchy update` aus, um sie zusammen mit dem Rest von Omarchy zu aktualisieren; der `mup`-Alias aktualisiert nur mise-verwaltete Tools. Um ein weiteres Tool zu deiner eigenen Konfiguration hinzuzufügen, verwende `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) braucht kaum eine Vorstellung. Es ermöglicht dir, isolierte Container auszuführen, und Omarchy installiert alles, was du brauchst, um es gut zu betreiben, einschließlich Docker selbst und [Docker Compose](https://docs.docker.com/compose/).

Standardmäßig ist dein Benutzer *nicht* in der `docker`-Gruppe. Diese Gruppe ist effektiv passwortloses root — alles in ihr kann `docker run -v /:/host` ausführen und die Maschine übernehmen —, also wäre ein einzelnes bösartiges Skript oder eine Abhängigkeit, die als du läuft, andernfalls nur einen Befehl von root entfernt. Auf der Kommandozeile führst du Docker daher mit `sudo` aus (`sudo docker ps`, `sudo docker compose up`), und die grafischen Tools, die mit dem Daemon kommunizieren — die Windows VM —, fragen um Autorisierung, wenn sie sie benötigen. Wenn du die Bequemlichkeit eines Setups ohne Gruppe zurückhaben möchtest und den Kompromiss verstehst, aktiviere es über **Einrichtung > Sicherheit > Sudoless Docker** (oder führe `omarchy-setup-security-sudoless-docker` aus), wodurch du nach einer Warnung zur `docker`-Gruppe hinzugefügt wirst; dann funktionieren einfaches `docker` und der `d`-Alias wieder ohne `sudo`.

Die gängigen Datenbanken für die lokale Entwicklung in Docker kannst du über _Installieren > Entwicklung > Docker DB_ im Omarchy-Menü einrichten.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ist `gh`, um vom Terminal aus mit Repositories, Issues und Pull Requests zu arbeiten. _Einrichtung > Git_ installiert es, wenn du dich dort bei GitHub anmeldest, oder installiere es separat über _Installieren > CLI > GitHub_. Dann klont `gh repo clone org/repo` ein Repository; führe `gh --help` aus, um seine Befehle zu erkunden.

[Lazygit](https://github.com/jesseduffield/lazygit) ist für die Arbeit mit Git selbst vorinstalliert.
