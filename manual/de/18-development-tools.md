# Entwicklungstools

## Alternative Editoren

Omarchy wird bei neuen Installationen mit Plain als Standard-Editor ausgeliefert und hat [Neovim](https://neovim.io/) vorinstalliert, aber wenn du etwas Mainstreamigeres und Vertrauteres möchtest, kannst du das Omarchy Menu (`Super + Space`) öffnen und dir die Optionen unter _Install > Editor_ ansehen. Dort haben wir VSCode, Cursor, Zed, Sublime Text, Helix, Vim und Emacs aufgeführt. Wenn du nicht findest, wonach du suchst, schau unter _Install > Package_ nach, ob es nicht in einem Arch-Paket steckt (und wenn nicht, versuch _Install > AUR_, um in der AUR nachzusehen).

Der ursprüngliche `vi`-Editor ist ebenfalls direkt ab Werk verfügbar. Führe `vi filename` aus, um eine Datei im Terminal zu bearbeiten.

Ein Abgleich der Themes wird für `VSCode`, `Cursor`, `VSCodium` und `Helix` angeboten.

Du kannst den systemweiten Standard-Editor unter `Setup > Defaults > Editor` festlegen.

## Entwicklungsumgebung

Omarchy unterstützt das Einrichten einer ganzen Reihe von Entwicklungsumgebungen über den Bereich _Install > Development_ im Omarchy Menu (`Super + Space`). Du findest dort natürlich _Ruby on Rails_, aber auch alle drei großen Laufzeitumgebungen für JavaScript (Node.js, Bun, Deno) sowie beliebte PHP-Frameworks wie Laravel und Symfony. Oh, und Go, Rust, Python, Java, Elixir (mit Phoenix), .NET, OCaml, Zig, Clojure und Scala gibt es auch. Es ist eine sehr breite Auswahl!

Die Mehrzahl dieser Umgebungen wird von [Mise](https://mise.jdx.dev/) verwaltet. Es ist ein Tool, mit dem du mehrere Versionen einer Programmiersprache auf derselben Maschine installieren und ausführen kannst. Es ist wie rbenv oder rvm für Ruby oder virtualenv für Python, funktioniert aber für eine ganze Reihe verschiedener Umgebungen.

Um zum Beispiel Ruby zu installieren, würdest du `mise use -g ruby` ausführen, wodurch Ruby sowohl installiert als auch als globaler Standard festgelegt wird. Oder, wenn dein Projekt eine .ruby-version-Datei hat, kannst du einfach `mise i` im Stammverzeichnis dieses Projekts ausführen.

## Vorinstallierte CLI-Tools

Omarchy stellt Tools wie `gh`, `uv` und die meisten [Coding-Agenten](17-ai.md) über [die Lazy Installation von mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) bereit. Beim ersten Ausführen eines solchen Tools installiert mise es. Coding-Agenten prüfen dann vor dem Ausführen, höchstens einmal alle vier Stunden, ob ein Update verfügbar ist; andere Tools wie `gh` und `uv` nutzen die installierte Version weiter, bis du aktualisierst.

Du kannst dir auch die Standardwerte ansehen oder sie im Voraus installieren:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Führe `omarchy update` aus, um installierte Tools zusammen mit dem Rest von Omarchy zu aktualisieren. Der Alias `mup` aktualisiert nur von mise verwaltete Tools. Um ein weiteres Tool zu deiner eigenen Konfiguration hinzuzufügen, verwende `mise use -g <tool>`.

Das Python-Setup installiert `uv` ebenfalls über mise. Beim Entfernen der Python-Entwicklungsumgebung bleibt `uv` als eigenständiges Tool verfügbar.

### Deine eigene Installation verwenden

Die Befehle von mise stehen auf `PATH` vor `~/.local/bin`, sodass ein Tool, das du selbst installiert hast, zum Beispiel mit dem eigenen Installer von Claude Code oder Cursor, trotzdem die Kopie von mise ausführt. Vom Desktop gestartete Apps finden die Befehle von mise ebenfalls vor Systempaketen, sodass eine App, die `gh` ausführt, die Kopie von mise erhält, selbst wenn du `github-cli` mit pacman installiert hast, und mise installiert diese Kopie beim ersten Mal. Um stattdessen deine eigene zu verwenden, deaktiviere die Kopie von mise in `~/.config/mise/config.toml`. Wenn du zum Beispiel Cursor CLI selbst installiert hast:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Wenn du bereits eine `[settings]`-Tabelle hast, füge den Eintrag dort hinzu; erweitere eine vorhandene `disable_tools`-Liste, anstatt sie zu ersetzen. Stelle sicher, dass deine Installation auf `PATH` ist. Verwende den Tool-Namen von mise, der sich von seinem Befehl unterscheiden kann: `oh-my-pi` stellt zum Beispiel `omp` bereit. Der Launcher für den Standard-Agenten bevorzugt ebenfalls einen vom Benutzer installierten Cursor oder Muse in `~/.local/bin`.

### Standardwerte entfernen und wiederherstellen

_Remove > Preinstalls_ entfernt die vorinstallierten Web-Apps, TUIs und Apps von Omarchy und lässt mise die Tool-Deklarationen von Omarchy für deinen Benutzer überspringen, indem sie zu `ignored_config_paths` in `~/.config/mise/miserc.toml` hinzugefügt werden. _Install > Preinstalls_ bringt sie zurück und entfernt diese Zeile wieder. Tools, die du selbst deklarierst, in deiner eigenen Konfiguration oder in der `mise.toml` eines Projekts, funktionieren in beiden Fällen weiter. Wenn du nach dem Entfernen der Preinstalls einen Standard-Agenten auswählst oder Python einrichtest, wird dieses Tool zu deiner eigenen Konfiguration hinzugefügt. Die mise-Einstellung gilt nur für deinen Benutzer, und andere Benutzer behalten ihre eigene Wahl; die Apps sind allerdings Pakete, sodass das Entfernen oder Wiederherstellen sie für alle auf der Maschine verändert.

## Docker

[Docker](https://www.docker.com/) braucht kaum eine Einführung. Es ermöglicht dir, isolierte Container auszuführen, und Omarchy installiert alles, was nötig ist, um es gut zu betreiben, einschließlich Docker selbst und [Docker Compose](https://docs.docker.com/compose/).

Standardmäßig ist dein Benutzer *nicht* in der Gruppe `docker`. Diese Gruppe ist effektiv passwortloses root — alles darin kann `docker run -v /:/host` ausführen und die Maschine übernehmen —, sodass ein einziges bösartiges Skript oder eine Abhängigkeit, die als du läuft, sonst nur einen Befehl von root entfernt wäre. Auf der Kommandozeile führst du Docker also mit `sudo` aus (`sudo docker ps`, `sudo docker compose up`), und die grafischen Tools, die mit dem Daemon sprechen — die Windows VM —, fragen bei Bedarf um Autorisierung. Wenn du die Bequemlichkeit eines Setups ohne `sudo` zurückhaben willst und den Kompromiss verstehst, aktiviere es unter **Setup > Security > Sudoless Docker** (oder führe `omarchy-setup-security-sudoless-docker` aus), wodurch du nach einer Warnung zur Gruppe `docker` hinzugefügt wirst; dann funktionieren einfaches `docker` und der Alias `d` wieder ohne `sudo`.

Du kannst die gängigen Datenbanken für die lokale Entwicklung in Docker über _Install > Development > Docker DB_ im Omarchy-Menü einrichten.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ist als `gh` verfügbar, um vom Terminal aus mit Repositories, Issues und Pull Requests zu arbeiten. Führe `gh auth login` aus, um es bei der ersten Verwendung zu installieren und dich zu authentifizieren, dann `gh repo clone org/repo`, um ein Repository zu klonen. Führe `gh --help` aus, um seine Befehle zu erkunden.

Für eine Terminal-Oberfläche für Pull Requests führe `ghui` aus; mise installiert es ebenfalls bei der ersten Verwendung. [Lazygit](https://github.com/jesseduffield/lazygit) ist für die Arbeit mit Git selbst vorinstalliert.
