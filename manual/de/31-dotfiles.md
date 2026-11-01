# Dotfiles

Omarchy wird hauptsächlich über die sogenannten Dotfiles konfiguriert, die in `~/.config` liegen. Das sind deine Dateien für deine Änderungen. Die Dateien, die in `/usr/share/omarchy` liegen, gehören zu Omarchy selbst, und an denen solltest du nicht herumpfuschen. Wenn du etwas in `/usr/share/omarchy` ändern musst, solltest du stattdessen den Wert in `~/.config` überschreiben.

Die wichtigsten Configs lassen sich direkt im Omarchy-Menü (`Super + Space`) bearbeiten, etwa _Setup > Keybindings_, _Setup > Input_ und _Setup > Config > [file]_. Wenn du es auf diesem Weg machst, wird jeder Prozess, der nach Änderungen an der Config neu gestartet werden muss, automatisch neu gestartet, sobald du den Editor beendet hast (standardmäßig Neovim — `:wq`, schon gemerkt! — aber das kannst du über _Setup > Defaults > Editor_ ändern).

Hier ist eine Liste der wichtigsten Dateien in `~/.config` und was sie steuern:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Die Haupt-Config von Hyprland. Lädt die Omarchy-Standards plus deine Override-Dateien unten. [Mehr über Hyprland-Configs erfahren](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Deine eigenen Keybindings und Overrides der Standards. |
| `~/.config/hypr/monitors.lua` | Monitor-Einstellungen, die das Monitor-Panel nicht abdeckt, wie Rotation, zusätzliche Modi oder einen Monitor ausgeschaltet zu lassen. |
| `~/.config/hypr/input.lua` | Steuert dein Tastaturlayout sowie deine Maus- und Trackpad-Einstellungen. |
| `~/.config/hypr/looknfeel.lua` | Steuert Abstände, Rahmen, Animationen und den Rest des Erscheinungsbilds. |
| `~/.config/hypr/autostart.lua` | Steuert zusätzliche Prozesse, die mit der Sitzung gestartet werden. |
| `~/.config/omarchy/shell.json` | Steuert die Omarchy-Shell: Position der Bar, Layout und Widgets, plus Zeiten für Bildschirmschoner, Sperre und Leerlauf. |
| `~/.config/foot/foot.ini` | Steuert dein Terminal (foot ist der Standard). |
| `~/.XCompose` | Definiert deine Emojis für den Schnellzugriff und die Autovervollständigung von Namen/E-Mails. Führe nach Änderungen unbedingt `omarchy-restart-xcompose` aus. |

Wenn du am Ende viele Änderungen vornimmst, um dein eigenes Setup zu optimieren, ist es eine gute Idee, all diese Dotfiles zu sichern. [Stow ist eine großartige Möglichkeit dafür](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Eigene Apps mit der Sitzung starten

Wenn du möchtest, dass etwas bei jeder Anmeldung läuft — ein Sync-Daemon, eine Chat-App, dein eigenes Skript — trage es in `~/.config/hypr/autostart.lua` ein:

```lua
o.launch_on_start("my-service")
```

Das startet den Befehl als Teil der Sitzung, sodass er ordnungsgemäß bereinigt wird, wenn du dich wieder abmeldest.

### Skripte bei Systemereignissen ausführen

Omarchy löst an einer Handvoll Zeitpunkten Hooks aus, und du kannst deine eigenen Skripte daran hängen. Sie liegen in `~/.config/omarchy/hooks/<event>.d/`, ein Verzeichnis pro Ereignis, und jede ausführbare Datei darin wird ausgeführt, wenn das Ereignis eintritt:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Gleich nachdem der Desktop gestartet ist |
| `post-update` | Gegen Ende von `omarchy update`, nach Paketen, Migrationen und Neustarts von Diensten, bevor mise-Tools aktualisiert werden |
| `pre-refresh-pacman` | Nachdem `omarchy refresh pacman` die Paket-Config neu synchronisiert hat, bevor es Pakete aktualisiert; ein Kanalwechsel führt ihn während desselben Refresh-Schritts aus |
| `theme-set` | Nach einem Theme-Wechsel (Theme-Name in `$1`) |
| `font-set` | Nach einem Font-Wechsel (Font-Name in `$1`) |
| `battery-low` | Wenn der Akku schwach wird (Prozentsatz in `$1`) |

Der `pre-refresh-pacman`-Hook ist der richtige Ort für eigene Repositories oder `IgnorePkg`-Zeilen, da er vor der Paket-Transaktion läuft. Beide updatebezogenen Hooks laufen als dein Benutzer, nachdem Omarchy seine zwischengespeicherte sudo-Autorisierung gelöscht hat, sodass ein Hook, der `sudo` verwendet, seine eigene Autorisierung braucht und dich möglicherweise nach deinem Passwort fragt.

Jedes dieser Verzeichnisse enthält bereits eine `.sample`-Datei, die die Form eines Hooks zeigt — entferne das `.sample` aus dem Namen, um ihn in Betrieb zu nehmen. Um ein Skript zu installieren, das du anderswo geschrieben hast, verwende `omarchy hook install post-boot ~/my-hook`; das kopiert es hinein und macht es ausführbar.

### Eigene Menüeinträge hinzufügen

Das Omarchy-Menü (`Super + Space`) lässt sich mit eigenen Zeilen erweitern, indem du `~/.config/omarchy/extensions/omarchy-menu.jsonc` bearbeitest. Einträge werden über eine gepunktete ID zugeordnet, und die ID ist es, die sie im Baum platziert, sodass `personal` im Hauptmenü erscheint und `personal.notes` darin erscheint:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Wenn du eine bestehende ID wiederverwendest, überschreibst du diese Zeile, statt eine neue hinzuzufügen. Die Datei wird mit allen verfügbaren Feldern ausgeliefert, die als Kommentare dokumentiert sind.

### Eigene Shell-Exports, Funktionen und Aliase hinzufügen

Omarchy wird mit einem Haufen ergonomischer Aliase und hilfreicher Funktionen ausgeliefert, aber es ist sehr üblich, eigene hinzufügen zu wollen. Du solltest Aliase, Funktionen und Exports in `~/.bashrc` hinzufügen. Diese Datei wird bei Updates nicht überschrieben. Wenn du einen der Omarchy-Standards ändern willst, kannst du sie hier ebenfalls sicher hinzufügen.

### Umgebungsvariablen für den Desktop setzen

Exports für die Desktop-Sitzung gehören in `~/.config/uwsm/env.d/`. Diese Dateien werden ausgeführt, bevor dein Desktop startet, sodass ein Shell-Fehler dich zurück zum Anmeldebildschirm schicken kann. Lass ein funktionierendes Terminal offen, während du sie bearbeitest. Um ein Override zu deaktivieren, verschiebe es aus `env.d` heraus. Siehe [Wiederherstellung der Anmeldung](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), wenn eine Änderung die Anmeldung verhindert.

### Interne Omarchy-Dateien ändern

Hör zu, das ist dein Computer. Du kannst damit machen, was du willst, aber ich würde davon abraten, Änderungen direkt an den Dateien in `/usr/share/omarchy` vorzunehmen. Sie gehören zum Omarchy-pacman-Paket, sodass deine Änderungen beim nächsten Update einfach überschrieben werden. Du fährst besser damit, einfach alle Standardwerte, die dir nicht gefallen, stattdessen im Ordner `~/.config/*` zu überschreiben.

Auf diese Weise kannst du so gut wie alles ändern, wie zum Beispiel die Standard-Keybindings. Bearbeite einfach `~/.config/hypr/bindings.lua`, um etwa [Obsidian](https://obsidian.md/) durch [Joplin](https://joplinapp.org/) zu ersetzen (mit `omarchy-pkg-add joplin-bin` installieren):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` entfernt das bestehende Binding, bevor es seinen Ersatz hinzufügt. Es nimmt dieselben Argumente wie `o.bind`, einschließlich Launch-Helfern und Binding-Optionen. Verwende `o.bind`, um ein Binding hinzuzufügen, oder `hl.unbind`, um eines zu entfernen, ohne es zu ersetzen.

Wenn du darauf bestehst, an den internen Omarchy-Dateien herumzuhacken, wechsle über _Update > Channel > Dev_ zum Dev-Kanal. Das verknüpft Omarchy mit einem Git-Checkout des Quellcodes in `~/omarchy`, den du nach Herzenslust ändern kannst. Hier ist niemand, der dir sagt, was du zu tun hast!

### Alle Änderungen zurücksetzen

Wenn du am Ende ein Chaos aus den Konfigurationen gemacht hast, kannst du sie jederzeit über _Update > Config_ im Omarchy-Menü auf die Standards zurücksetzen. Oder indem du `omarchy reinstall configs` ausführst, um alles zurückzusetzen.
