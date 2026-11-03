# Entwicklungs-Tools

## Alternative Editoren

Omarchy liefert standardmäßig [Neovim](https://neovim.io/) aus, aber wenn du etwas gängigeres und vertrauteres möchtest, kannst du das Omarchy Menu (`Super + Space`) öffnen und dir die Optionen unter _Install > Editor_ ansehen. Dort sind VSCode, Cursor, Zed, Sublime Text, Helix, Vim und Emacs aufgeführt. Wenn du nicht findest, wonach du suchst, schau unter _Install > Package_ nach, ob es nicht als Arch-Paket verfügbar ist (und falls nicht, versuche _Install > AUR_, um in AUR nachzusehen).

Der ursprüngliche `vi`-Editor ist ebenfalls von Haus aus verfügbar. Führe `vi filename` aus, um eine Datei im Terminal zu bearbeiten.

Eine Theme-Anpassung wird für `VSCode`, `Cursor`, `VSCodium` und `Helix` angeboten.

Den systemweiten Standard-Editor kannst du unter `Setup > Defaults > Editor` festlegen.

## Umgebung

Omarchy unterstützt die Einrichtung einer ganzen Reihe von Entwicklungsumgebungen über den Bereich _Install > Development_ des Omarchy Menu (`Super + Space`). Dort findest du natürlich _Ruby on Rails_, aber auch alle drei großen Laufzeitumgebungen für JavaScript (Node.js, Bun, Deno) sowie beliebte PHP-Frameworks wie Laravel und Symfony. Oh, und Go, Rust, Python, Java, Elixir (mit Phoenix), .NET, OCaml, Zig, Clojure und Scala gibt es auch. Es ist eine sehr breite Auswahl!

Die meisten dieser Umgebungen werden von [Mise](https://mise.jdx.dev/) verwaltet. Es ist ein Tool, mit dem du mehrere Versionen einer Programmiersprache auf derselben Maschine installieren und ausführen kannst. Es ist wie rbenv oder rvm für Ruby oder virtualenv für Python, funktioniert aber für eine ganze Reihe verschiedener Umgebungen.

Um beispielsweise Ruby zu installieren, würdest du `mise use -g ruby` ausführen. Dadurch wird Ruby sowohl installiert als auch als globaler Standard festgelegt. Oder wenn dein Projekt eine .ruby-version-Datei hat, kannst du einfach `mise i` im Stammverzeichnis dieses Projekts ausführen.

## Vorinstallierte CLI-Tools

Omarchy stellt Tools wie `gh`, `uv` und die meisten [Coding-Agenten](17-ai.md) über [mises Lazy-Installation](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) bereit. Beim ersten Ausführen eines solchen Tools installiert mise es. Spätere Ausführungen verwenden die installierte Version wieder; sie suchen nicht bei jedem Start nach einem Update.

Du kannst dir die Standardeinstellungen auch ansehen oder sie im Voraus installieren:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Führe `omarchy update` aus, um installierte Tools zusammen mit dem restlichen Omarchy zu aktualisieren. Der Alias `mup` aktualisiert nur die von mise verwalteten Tools. Um ein weiteres Tool zu deiner eigenen Konfiguration hinzuzufügen, verwende `mise use -g <tool>`.

Die Python-Einrichtung installiert über mise auch `uv`. Wenn du die Python-Entwicklungsumgebung entfernst, bleibt `uv` als eigenständiges Tool verfügbar.

### Eigene Installation verwenden

Die Befehle von mise stehen auf `PATH` vor `~/.local/bin`. Ein Tool, das du selbst installiert hast, beispielsweise mit dem eigenen Installer von Claude Code oder Cursor, führt daher trotzdem mises Kopie aus. Vom Desktop gestartete Apps finden mises Befehle ebenfalls vor Systempaketen. Eine App, die `gh` ausführt, erhält also mises Kopie, selbst wenn du `github-cli` mit pacman installiert hast, und mise installiert diese Kopie beim ersten Mal. Um stattdessen deine eigene Installation zu verwenden, deaktiviere mises Kopie in `~/.config/mise/config.toml`. Wenn du beispielsweise die Cursor CLI selbst installiert hast:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Wenn du bereits eine `[settings]`-Tabelle hast, füge den Eintrag dort hinzu; erweitere eine vorhandene `disable_tools`-Liste, anstatt sie zu ersetzen. Stelle sicher, dass sich deine Installation auf `PATH` befindet. Verwende den mise-Toolnamen, der von seinem Befehl abweichen kann: `oh-my-pi` stellt beispielsweise `omp` bereit. Der Launcher für den Standard-Agenten bevorzugt ebenfalls einen von dir installierten Cursor oder Muse in `~/.local/bin`.

### Standardeinstellungen entfernen und wiederherstellen

Bei _Remove Preinstalls_ überspringt mise Omarchys Tool-Deklarationen für deinen Benutzer, indem sie zu `ignored_config_paths` in `~/.config/mise/miserc.toml` hinzugefügt werden. _Restore Preinstalls_ entfernt diese Zeile wieder. Tools, die du selbst deklarierst, in deiner eigenen Konfiguration oder in der `mise.toml` eines Projekts, funktionieren in beiden Fällen weiterhin. Wenn du nach dem Entfernen der Vorinstallationen einen Standard-Agenten auswählst oder Python einrichtest, wird dieses Tool zu deiner eigenen Konfiguration hinzugefügt. Beides gilt nur für deinen Benutzer; andere Benutzer auf der Maschine behalten ihre eigene Auswahl.

## Docker

[Docker](https://www.docker.com/) braucht wohl kaum eine Einführung. Es ermöglicht dir, isolierte Container auszuführen, und Omarchy installiert alles, was für einen guten Betrieb nötig ist, einschließlich Docker selbst und [Docker Compose](https://docs.docker.com/compose/).

Standardmäßig ist dein Benutzer *nicht* in der Gruppe `docker`. Diese Gruppe ist faktisch root ohne Passwort – alles darin kann `docker run -v /:/host` ausführen und die Maschine übernehmen –, sodass ein einziges bösartiges Skript oder eine Abhängigkeit, die als du ausgeführt wird, sonst nur einen Befehl von root entfernt wäre. Auf der Kommandozeile führst du Docker daher mit `sudo` aus (`sudo docker ps`, `sudo docker compose up`), und die grafischen Tools, die mit dem Daemon kommunizieren – die Windows VM –, fragen bei Bedarf nach einer Autorisierung. Wenn du den Komfort einer gruppenlosen Einrichtung zurückhaben möchtest und den Kompromiss verstehst, aktiviere ihn über **Setup > Security > Sudoless Docker** (oder führe `omarchy-setup-security-sudoless-docker` aus). Dadurch wirst du nach einer Warnung zur Gruppe `docker` hinzugefügt; dann funktionieren einfaches `docker` und der Alias `d` wieder ohne `sudo`.

Die gängigen Datenbanken für die lokale Entwicklung in Docker kannst du über _Install > Development > Docker DB_ im Omarchy-Menü einrichten.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ist als `gh` verfügbar, um vom Terminal aus mit Repositories, Issues und Pull Requests zu arbeiten. Führe `gh auth login` aus, um es bei der ersten Verwendung zu installieren und dich zu authentifizieren, und anschließend `gh repo clone org/repo`, um ein Repository zu klonen. Führe `gh --help` aus, um seine Befehle zu erkunden.

Für eine Terminaloberfläche für Pull Requests führe `ghui` aus; mise installiert es ebenfalls bei der ersten Verwendung. [Lazygit](https://github.com/jesseduffield/lazygit) ist für die Arbeit mit Git selbst vorinstalliert.
