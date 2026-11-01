# Dotfiles

Omarchy wird in erster Linie über die sogenannten Dotfiles konfiguriert, die in `~/.config` liegen. Sie gelten als deine Dateien für deine Änderungen. Die Dateien in `/usr/share/omarchy` gehören zu Omarchy selbst, und an denen solltest du nicht herumfummeln. Wenn du etwas in `/usr/share/omarchy` ändern musst, solltest du stattdessen den Wert in `~/.config` überschreiben.

Die wichtigsten Konfigurationen lassen sich direkt über das Omarchy-Menü (`Super + Space`) bearbeiten, etwa _Setup > Keyboard > Keybindings_, _Setup > Input_ und _Setup > Config > [file]_. Wenn du es auf diese Weise machst, wird jeder Prozess, der nach Änderungen an der Konfiguration neu gestartet werden muss, automatisch neu gestartet, sobald du den Editor beendest (standardmäßig Neovim — `:wq`, nicht vergessen! —, aber das kannst du über _Setup > Defaults > Editor_ ändern).

Hier ist eine Liste der wichtigsten Dateien in `~/.config` und was sie steuern:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Die Hauptkonfiguration von Hyprland. Lädt die Omarchy-Standardwerte plus deine unten aufgeführten Override-Dateien. [Mehr über Hyprland-Konfigurationen erfahren](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Deine eigenen Tastenkombinationen und Überschreibungen der Standardwerte. |
| `~/.config/hypr/monitors.lua` | Monitoreinstellungen, die das Monitor-Panel nicht abdeckt, wie Rotation, zusätzliche Modi oder einen Monitor ausgeschaltet zu lassen. |
| `~/.config/hypr/input.lua` | Steuert dein Tastaturlayout, deine Maus- und Trackpad-Einstellungen. |
| `~/.config/hypr/looknfeel.lua` | Steuert Abstände, Rahmen, Animationen und den Rest des Erscheinungsbilds. |
| `~/.config/hypr/autostart.lua` | Steuert zusätzliche Prozesse, die mit der Sitzung gestartet werden. |
| `~/.config/omarchy/shell.json` | Steuert die Omarchy-Shell: Position der Leiste, Layout und Widgets sowie Zeitvorgaben für Bildschirmschoner, Sperre und Leerlauf. |
| `~/.config/foot/foot.ini` | Steuert dein Terminal (foot ist die Standardeinstellung). |
| `~/.XCompose` | Definiert deine Schnellzugriffs-Emojis und die Autovervollständigung für Namen/E-Mails. Führe nach Änderungen unbedingt `omarchy-restart-xcompose` aus. |

Wenn du am Ende viele Änderungen vornimmst, um dein eigenes Setup anzupassen, ist es eine gute Idee, all diese Dotfiles zu sichern. [Stow ist eine großartige Möglichkeit dafür](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Eigene Apps mit der Sitzung starten

Wenn du möchtest, dass bei jeder Anmeldung etwas ausgeführt wird — ein Sync-Daemon, eine Chat-App, dein eigenes Skript —, trage es in `~/.config/hypr/autostart.lua` ein:

```lua
o.launch_on_start("my-service")
```

Dadurch wird der Befehl als Teil der Sitzung gestartet, sodass er ordentlich bereinigt wird, wenn du dich wieder abmeldest.

### Skripte bei Systemereignissen ausführen

Omarchy löst Hooks zu einer Handvoll Zeitpunkten aus, und du kannst deine eigenen Skripte daran hängen. Sie liegen in `~/.config/omarchy/hooks/<event>.d/`, ein Verzeichnis pro Ereignis, und jede ausführbare Datei darin wird ausgeführt, wenn das Ereignis eintritt:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Direkt nachdem der Desktop gestartet ist |
| `post-update` | Gegen Ende von `omarchy update`, nach Paketen, Migrationen und Neustarts von Diensten, bevor mise-Tools aktualisiert werden |
| `pre-refresh-pacman` | Nachdem `omarchy refresh pacman` die Paketkonfiguration erneut synchronisiert hat, bevor es Pakete aktualisiert; ein Kanalwechsel führt es während desselben Refresh-Schritts aus |
| `theme-set` | Nach einem Themenwechsel (Themenname in `$1`) |
| `font-set` | Nach einem Schriftartwechsel (Schriftartname in `$1`) |
| `battery-low` | Wenn der Akku schwach wird (Prozentsatz in `$1`) |

Der `pre-refresh-pacman`-Hook ist der Ort, an den benutzerdefinierte Repositories oder `IgnorePkg`-Zeilen gehören, da er vor der Pakettransaktion ausgeführt wird. Beide updatebezogenen Hooks werden als dein Benutzer ausgeführt, nachdem Omarchy seine zwischengespeicherte sudo-Autorisierung gelöscht hat, sodass ein Hook, der `sudo` verwendet, seine eigene Autorisierung benötigt und dich möglicherweise nach deinem Passwort fragt.

Jedes dieser Verzeichnisse enthält bereits eine `.sample`-Datei, die die Form eines Hooks zeigt — entferne das `.sample` aus dem Namen, um ihn in Betrieb zu nehmen. Um ein Skript zu installieren, das du anderswo geschrieben hast, verwende `omarchy hook install post-boot ~/my-hook`, wodurch es hineinkopiert und ausführbar gemacht wird.

### Eigene Menüeinträge hinzufügen

Das Omarchy-Menü (`Super + Space`) lässt sich um eigene Zeilen erweitern, indem du `~/.config/omarchy/extensions/omarchy-menu.jsonc` bearbeitest. Einträge werden über eine gepunktete ID zugeordnet, und die ID platziert sie im Baum, sodass `personal` im Hauptmenü erscheint und `personal.notes` darin erscheint:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Wenn du eine vorhandene ID wiederverwendest, überschreibst du diese Zeile, anstatt eine neue hinzuzufügen. Die Datei wird mit allen verfügbaren Feldern ausgeliefert, die als Kommentare dokumentiert sind.

### Eigene Shell-Exporte, Funktionen und Aliase hinzufügen

Omarchy wird mit einer Menge ergonomischer Aliase und hilfreicher Funktionen ausgeliefert, aber es ist sehr üblich, eigene hinzufügen zu wollen. Sowohl Aliase als auch Funktionen und Exporte solltest du in `~/.bashrc` hinzufügen. Diese Datei wird bei Updates nicht überschrieben. Wenn du einen der Omarchy-Standardwerte ändern möchtest, kannst du sie auch sicher hier hinzufügen.

### Umgebungsvariablen für den Desktop setzen

Exporte für die Desktop-Sitzung gehören in `~/.config/uwsm/env.d/`. Diese Dateien werden ausgeführt, bevor dein Desktop startet, sodass ein Shell-Fehler dich zurück zum Anmeldebildschirm schicken kann. Lass ein funktionierendes Terminal geöffnet, während du sie bearbeitest. Um eine Überschreibung zu deaktivieren, verschiebe sie aus `env.d` heraus. Siehe [Wiederherstellung der Anmeldung](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), wenn eine Änderung die Anmeldung verhindert.

### Interne Omarchy-Dateien ändern

Schau, das ist dein Computer. Du kannst damit machen, was du willst, aber ich würde davon abraten, Änderungen direkt an den Dateien in `/usr/share/omarchy` vorzunehmen. Sie gehören zum Omarchy-Pacman-Paket, sodass deine Änderungen beim nächsten Update einfach überschrieben werden. Du fährst besser damit, alle Standardwerte, die dir nicht gefallen, stattdessen im Ordner `~/.config/*` zu überschreiben.

Auf diese Weise kannst du so gut wie alles ändern, etwa die Standard-Tastenkombinationen. Bearbeite einfach `~/.config/hypr/bindings.lua`, um beispielsweise [Obsidian](https://obsidian.md/) durch [Joplin](https://joplinapp.org/) zu ersetzen (installieren mit `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` entfernt die vorhandene Bindung, bevor es seinen Ersatz hinzufügt. Es nimmt dieselben Argumente wie `o.bind`, einschließlich Starthelfern und Bindungsoptionen. Verwende `o.bind`, um eine Bindung hinzuzufügen, oder `hl.unbind`, um eine zu entfernen, ohne sie zu ersetzen.

Wenn du darauf bestehst, an den internen Omarchy-Dateien herumzuhacken, wechsle über _Update > Channel > Dev_ zum Dev-Kanal. Dadurch wird Omarchy mit einem Git-Checkout des Quellcodes in `~/omarchy` verknüpft, den du nach Herzenslust ändern kannst. Hier wird dir niemand sagen, was du zu tun hast!

### Alle Änderungen zurücksetzen

Wenn du die Konfigurationen am Ende vermasselst, kannst du sie jederzeit über _Update > Config_ im Omarchy-Menü auf die Standardwerte zurücksetzen. Oder indem du `omarchy reinstall configs` ausführst, um alles zurückzusetzen.
