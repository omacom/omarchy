# Dotfiles

Omarchy wird hauptsächlich über die sogenannten Dotfiles konfiguriert, die in `~/.config` liegen. Diese gelten als deine Dateien für deine Änderungen. Die Dateien, die in `/usr/share/omarchy` liegen, gehören zu Omarchy selbst, und an denen solltest du nicht herumfummeln. Wenn du etwas in `/usr/share/omarchy` ändern musst, solltest du stattdessen den Wert in `~/.config` überschreiben.

Die wichtigsten Konfigurationen können direkt über das Omarchy-Menü (`Super + Space`) bearbeitet werden, etwa _Setup > Keyboard > Keybindings_, _Setup > Input_ und _Setup > Config > [file]_. Wenn du es auf diese Weise machst, wird jeder Prozess, der nach Änderungen an der Konfiguration neu gestartet werden muss, automatisch neu gestartet, nachdem du den Editor beendet hast (standardmäßig Neovim — `:wq`, nicht vergessen! — aber du kannst das über _Setup > Defaults > Editor_ ändern).

Hier ist eine Liste der wichtigsten Dateien in `~/.config` und was sie steuern:

| Datei | Zweck |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Die Hauptkonfiguration von Hyprland. Lädt die Omarchy-Standards plus deine untenstehenden Override-Dateien. [Mehr über Hyprland-Konfigurationen erfahren](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Deine eigenen Tastenkombinationen und Overrides der Standards. |
| `~/.config/hypr/monitors.lua` | Monitor-Einstellungen, die das Monitor-Panel nicht abdeckt, wie Drehung, zusätzliche Modi oder einen Monitor ausgeschaltet zu lassen. |
| `~/.config/hypr/input.lua` | Steuert dein Tastaturlayout, deine Maus- und Trackpad-Einstellungen. |
| `~/.config/hypr/looknfeel.lua` | Steuert Abstände, Rahmen, Animationen und den Rest des Aussehens. |
| `~/.config/hypr/autostart.lua` | Steuert zusätzliche Prozesse, die mit der Sitzung gestartet werden. |
| `~/.config/omarchy/shell.json` | Steuert die Omarchy-Shell: Position der Leiste, Layout und Widgets, plus Zeitsteuerungen für Bildschirmschoner, Sperre und Leerlauf. |
| `~/.config/foot/foot.ini` | Steuert dein Terminal (foot ist der Standard). |
| `~/.XCompose` | Definiert deine Emoji für den Schnellzugriff und die Autovervollständigung für Namen/E-Mails. Stelle sicher, dass du nach Änderungen `omarchy-restart-xcompose` ausführst. |

Wenn du am Ende viele Änderungen vornimmst, um dein eigenes Setup zu optimieren, ist es eine gute Idee, all diese Dotfiles zu sichern. [Stow ist eine großartige Möglichkeit, das zu tun](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Eigene Apps mit der Sitzung starten

Wenn du möchtest, dass etwas jedes Mal ausgeführt wird, wenn du dich anmeldest — ein Sync-Daemon, eine Chat-App, dein eigenes Skript — trage es in `~/.config/hypr/autostart.lua` ein:

```lua
o.launch_on_start("my-service")
```

Das startet den Befehl als Teil der Sitzung, sodass er ordnungsgemäß bereinigt wird, wenn du dich wieder abmeldest.

### Skripte bei Systemereignissen ausführen

Omarchy löst an einigen wenigen Momenten Hooks aus, und du kannst deine eigenen Skripte daran hängen. Sie liegen in `~/.config/omarchy/hooks/<event>.d/`, ein Verzeichnis pro Ereignis, und jede Datei darin, die nicht auf `.sample` endet, wird mit bash ausgeführt, wenn das Ereignis eintritt:

| Ereignis | Wann es ausgeführt wird |
| ----- | ------------ |
| `post-boot` | Direkt nachdem der Desktop gestartet ist |
| `post-update` | Gegen Ende von `omarchy update`, nach Paketen, Migrationen und Neustarts von Diensten, bevor die mise-Tools aktualisiert werden |
| `pre-refresh-pacman` | Nachdem `omarchy refresh pacman` die Paketkonfiguration erneut synchronisiert hat, bevor es Pakete aktualisiert; ein Kanalwechsel führt es während desselben Refresh-Schritts aus |
| `theme-set` | Nach einem Theme-Wechsel (Theme-Name in `$1`) |
| `font-set` | Nach einer Änderung der Schriftart (Name der Schriftart in `$1`) |
| `battery-low` | Wenn der Akku schwach wird (Prozentsatz in `$1`) |

Der `pre-refresh-pacman`-Hook ist der Ort, an den benutzerdefinierte Repositories oder `IgnorePkg`-Zeilen gehören, da er vor der Pakettransaktion ausgeführt wird. Beide werden als dein Benutzer ausgeführt. `post-update` läuft, solange die sudo-Autorisierung von `omarchy update` noch frisch ist, sodass ein Hook, der `sudo` verwendet, nicht erneut nach deinem Passwort fragt; `pre-refresh-pacman` läuft direkt, nachdem `omarchy refresh pacman` selbst sudo verwendet hat.

Jedes dieser Verzeichnisse enthält bereits eine `.sample`-Datei, die die Form eines Hooks zeigt — entferne das `.sample` aus dem Namen, um ihn in Betrieb zu nehmen. Um ein Skript zu installieren, das du anderswo geschrieben hast, verwende `omarchy hook install post-boot ~/my-hook`, was es hineinkopiert und ausführbar macht.

### Eigene Menüeinträge hinzufügen

Das Omarchy-Menü (`Super + Space`) kann mit deinen eigenen Zeilen erweitert werden, indem du `~/.config/omarchy/extensions/omarchy-menu.jsonc` bearbeitest. Einträge werden durch eine gepunktete ID identifiziert, und die ID ist das, was sie im Baum platziert, sodass `personal` im Hauptmenü erscheint und `personal.notes` darin erscheint:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Wenn du eine vorhandene ID wiederverwendest, überschreibst du diese Zeile, statt eine neue hinzuzufügen. Die Datei wird mit allen verfügbaren Feldern ausgeliefert, die als Kommentare dokumentiert sind.

### Eigene Shell-Exporte, -Funktionen und -Aliase hinzufügen

Omarchy wird mit einem Haufen ergonomischer Aliase und hilfreicher Funktionen ausgeliefert, aber es ist sehr üblich, eigene hinzufügen zu wollen. Du solltest Aliase, Funktionen und Exporte in `~/.bashrc` hinzufügen. Diese Datei wird bei Updates nicht überschrieben. Wenn du irgendwelche Omarchy-Standards ändern möchtest, kannst du sie auch sicher hier hinzufügen.

### Umgebungsvariablen für den Desktop setzen

Exporte für die Desktop-Sitzung gehören in `~/.config/uwsm/env.d/`. Diese Dateien werden ausgeführt, bevor dein Desktop startet, sodass ein Shell-Fehler dich zurück zum Anmeldebildschirm schicken kann. Halte ein funktionierendes Terminal geöffnet, während du sie bearbeitest. Um einen Override zu deaktivieren, verschiebe ihn aus `env.d` heraus. Siehe [Wiederherstellung der Anmeldung](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), falls eine Änderung die Anmeldung verhindert.

### Interne Omarchy-Dateien ändern

Sieh mal, das ist dein Computer. Du kannst damit machen, was immer du willst, aber ich würde davon abraten, Änderungen direkt an den Dateien in `/usr/share/omarchy` vorzunehmen. Sie gehören zum Omarchy-pacman-Paket, sodass deine Änderungen beim nächsten Update einfach überschrieben werden. Es ist besser, wenn du stattdessen einfach alle Standardwerte, die dir nicht gefallen, im Ordner `~/.config/*` überschreibst.

Auf diese Weise kannst du so gut wie alles ändern, etwa die Standard-Tastenkombinationen. Bearbeite einfach `~/.config/hypr/bindings.lua`, um beispielsweise [Obsidian](https://obsidian.md/) durch [Joplin](https://joplinapp.org/) zu ersetzen (installiere es mit `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` entfernt die vorhandene Belegung, bevor es ihren Ersatz hinzufügt. Es nimmt dieselben Argumente wie `o.bind`, einschließlich Launch-Helfern und Belegungsoptionen. Verwende `o.bind`, um eine Belegung hinzuzufügen, oder `hl.unbind`, um eine zu entfernen, ohne sie zu ersetzen.

Wenn du darauf bestehst, an den internen Omarchy-Dateien herumzuhacken, wechsle über _Update > Channel > Dev_ zum Dev-Kanal. Das verknüpft Omarchy mit einem git-Checkout des Quellcodes in `~/omarchy`, den du nach Herzenslust ändern kannst. Hier ist niemand, der dir sagt, was du zu tun hast!

### Alle Änderungen zurücksetzen

Wenn du am Ende ein Chaos aus den Konfigurationen gemacht hast, kannst du sie über _Update > Config_ im Omarchy-Menü jederzeit auf die Standards zurücksetzen. Oder indem du `omarchy reinstall configs` ausführst, um alles zurückzusetzen.
