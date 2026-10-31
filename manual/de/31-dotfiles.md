# Dotfiles

Omarchy wird hauptsächlich über die sogenannten Dotfiles konfiguriert, die in `~/.config` liegen. Diese gelten als deine Dateien für deine Änderungen. Die Dateien in `/usr/share/omarchy` gehören zu Omarchy selbst, und du solltest nicht an ihnen herumspielen. Wenn du etwas in `/usr/share/omarchy` ändern musst, solltest du stattdessen den Wert in `~/.config` überschreiben.

Die wichtigsten Konfigurationen lassen sich direkt aus dem Omarchy-Menü (`Super + Space`) bearbeiten, wie _Setup > Keybindings_, _Setup > Input_ und _Setup > Config > [file]_. Wenn du es auf diese Weise machst, wird jeder Prozess, der nach Änderungen an der Konfiguration neu gestartet werden muss, automatisch neu gestartet, nachdem du den Editor beendet hast (standardmäßig Neovim — `:wq`, nicht vergessen! — aber du kannst das über _Setup > Defaults > Editor_ ändern).

Hier ist eine Liste der wichtigsten Dateien in `~/.config` und was sie steuern:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Die Hauptkonfiguration von Hyprland. Lädt die Omarchy-Standards plus deine untenstehenden Override-Dateien. [Mehr über Hyprland-Konfigurationen erfahren](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Deine eigenen Tastaturbelegungen und Überschreibungen der Standards. |
| `~/.config/hypr/monitors.lua` | Monitor-Einstellungen, die das Monitor-Panel nicht abdeckt, etwa Rotation, zusätzliche Modi oder einen Monitor ausgeschaltet lassen. |
| `~/.config/hypr/input.lua` | Steuert dein Tastaturlayout, deine Maus- und Trackpad-Einstellungen. |
| `~/.config/hypr/looknfeel.lua` | Steuert Abstände, Rahmen, Animationen und den Rest des Erscheinungsbilds. |
| `~/.config/hypr/autostart.lua` | Steuert zusätzliche Prozesse, die mit der Session gestartet werden. |
| `~/.config/omarchy/shell.json` | Steuert die Omarchy-Shell: Position der Leiste, Layout und Widgets, plus Zeiten für Bildschirmschoner, Sperre und Leerlauf. |
| `~/.config/foot/foot.ini` | Steuert dein Terminal (foot ist der Standard). |
| `~/.XCompose` | Definiert deine Schnellzugriff-Emojis und die Autovervollständigung für Namen/E-Mail. Führe nach Änderungen unbedingt `omarchy-restart-xcompose` aus. |

Wenn du am Ende viele Änderungen vornimmst, um dein eigenes Setup anzupassen, ist es eine gute Idee, alle diese Dotfiles zu sichern. [Stow ist eine großartige Möglichkeit dafür](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Eigene Apps mit der Session starten

Wenn du möchtest, dass bei jeder Anmeldung etwas läuft — ein Sync-Daemon, eine Chat-App, dein eigenes Skript — trage es in `~/.config/hypr/autostart.lua` ein:

```lua
o.launch_on_start("my-service")
```

Das startet den Befehl als Teil der Session, sodass er ordnungsgemäß bereinigt wird, wenn du dich wieder abmeldest.

### Skripte bei Systemereignissen ausführen

Omarchy löst zu einer Handvoll Zeitpunkte Hooks aus, und du kannst deine eigenen Skripte daran hängen. Sie liegen in `~/.config/omarchy/hooks/<event>.d/`, ein Verzeichnis pro Ereignis, und jede ausführbare Datei darin wird ausgeführt, wenn das Ereignis eintritt:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Direkt nachdem der Desktop gestartet ist |
| `post-update` | Gegen Ende von `omarchy update`, nach Paketen, Migrationen und Neustarts von Diensten, bevor mise-Tools aktualisiert werden |
| `pre-refresh-pacman` | Nachdem `omarchy refresh pacman` die Paketkonfiguration neu synchronisiert hat, bevor es Pakete aktualisiert; ein Kanalwechsel führt ihn während desselben Refresh-Schritts aus |
| `theme-set` | Nach einem Theme-Wechsel (Theme-Name in `$1`) |
| `font-set` | Nach einem Schriftwechsel (Schriftname in `$1`) |
| `battery-low` | Wenn der Akku zur Neige geht (Prozentsatz in `$1`) |

Der `pre-refresh-pacman`-Hook ist der richtige Ort für benutzerdefinierte Repositories oder `IgnorePkg`-Zeilen, da er vor der Paket-Transaktion läuft. Beide updatebezogenen Hooks laufen als dein Benutzer, nachdem Omarchy seine zwischengespeicherte sudo-Autorisierung gelöscht hat, sodass ein Hook, der `sudo` verwendet, seine eigene Autorisierung benötigt und möglicherweise nach deinem Passwort fragt.

Jedes dieser Verzeichnisse enthält bereits eine `.sample`-Datei, die zeigt, wie ein Hook aufgebaut ist — entferne das `.sample` aus dem Namen, um ihn in Betrieb zu nehmen. Um ein Skript zu installieren, das du anderswo geschrieben hast, verwende `omarchy hook install post-boot ~/my-hook`, womit es einkopiert und ausführbar gemacht wird.

### Eigene Menüeinträge hinzufügen

Das Omarchy-Menü (`Super + Space`) kann durch Bearbeiten von `~/.config/omarchy/extensions/omarchy-menu.jsonc` mit eigenen Zeilen erweitert werden. Einträge werden über eine gepunktete ID zugeordnet, und die ID ist das, was sie im Baum platziert, sodass `personal` im Hauptmenü erscheint und `personal.notes` darin:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Wenn du eine vorhandene ID wiederverwendest, überschreibst du diese Zeile, statt eine neue hinzuzufügen. Die Datei wird mit allen verfügbaren Feldern ausgeliefert, die als Kommentare dokumentiert sind.

### Eigene Shell-Exporte, Funktionen und Aliase hinzufügen

Omarchy wird mit einem Haufen ergonomischer Aliase und hilfreicher Funktionen ausgeliefert, aber es ist sehr üblich, eigene hinzufügen zu wollen. Du solltest sowohl Aliase, Funktionen als auch Exporte in `~/.bashrc` hinzufügen. Diese Datei wird bei Updates nicht überschrieben. Wenn du irgendwelche Omarchy-Standards ändern möchtest, kannst du sie auch sicher hier hinzufügen.

### Interne Omarchy-Dateien ändern

Schau, das ist dein Computer. Du kannst damit machen, was du willst, aber ich würde davon abraten, Änderungen direkt an den Dateien in `/usr/share/omarchy` vorzunehmen. Sie gehören zum Omarchy-pacman-Paket, sodass deine Änderungen beim nächsten Update einfach überschrieben werden. Du fährst besser damit, einfach alle Standardwerte, die dir nicht gefallen, stattdessen im Ordner `~/.config/*` zu überschreiben.

So kannst du so gut wie alles ändern, wie die Standard-Tastaturbelegungen. Bearbeite einfach `~/.config/hypr/bindings.lua`, um zum Beispiel [Obsidian](https://obsidian.md/) durch [Joplin](https://joplinapp.org/) zu ersetzen (mit `omarchy-pkg-add joplin-bin` installieren):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` entfernt die vorhandene Bindung, bevor es seine Ersetzung hinzufügt. Es nimmt dieselben Argumente wie `o.bind`, einschließlich Launch-Helfern und Bindungsoptionen. Verwende `o.bind`, um eine Bindung hinzuzufügen, oder `hl.unbind`, um eine zu entfernen, ohne sie zu ersetzen.

Wenn du darauf bestehst, an den internen Omarchy-Dateien herumzuhacken, wechsle über _Update > Channel > Dev_ zum Dev-Kanal. Das verknüpft Omarchy mit einem Git-Checkout des Quellcodes in `~/omarchy`, den du nach Herzenslust ändern kannst. Hier sagt dir niemand, was du zu tun hast!

### Alle Änderungen zurücksetzen

Wenn du die Konfigurationen am Ende durcheinanderbringst, kannst du sie jederzeit über _Update > Config_ im Omarchy-Menü auf die Standards zurücksetzen. Oder indem du `omarchy reinstall configs` ausführst, um alles zurückzusetzen.
