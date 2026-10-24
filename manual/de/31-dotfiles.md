# Dotfiles

Omarchy wird primär über die sogenannten Dotfiles konfiguriert, die in `~/.config` leben. Diese gelten als deine Dateien für deine Änderungen. Die Dateien, die in `/usr/share/omarchy` leben, gehören zu Omarchy selbst, und an denen solltest du nicht herumspielen. Wenn du in `/usr/share/omarchy` etwas ändern musst, solltest du stattdessen den Wert in `~/.config` überschreiben.

Die wichtigsten Konfigurationen lassen sich direkt aus dem Omarchy-Menü (`Super + Space`) bearbeiten, zum Beispiel _Einrichtung > Monitore_, _Einrichtung > Tastenkürzel_, _Einrichtung > Eingabe_ und _Einrichtung > Config > [file]_. Wenn du es auf diesem Weg tust, wird jeder Prozess, der nach Konfigurationsänderungen neu gestartet werden muss, automatisch neu gestartet, nachdem du den Editor beendet hast (standardmäßig Neovim — `:wq`, denk daran! — aber du kannst das über _Einrichtung > Defaults > Editor_ ändern).

Hier ist eine Liste der wichtigsten Dateien in `~/.config` und was sie steuern:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Die Haupt-Konfiguration von Hyprland. Lädt die Omarchy-Standards plus deine untenstehenden Override-Dateien. [Mehr über Hyprland-Konfigurationen erfahren](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Deine eigenen Tastenkürzel und Überschreibungen der Standards. |
| `~/.config/hypr/monitors.lua` | Steuert deine Monitore, Auflösung und Position. |
| `~/.config/hypr/input.lua` | Steuert dein Tastaturlayout, deine Maus und deine Trackpad-Einstellungen. |
| `~/.config/hypr/looknfeel.lua` | Steuert Abstände, Rahmen, Animationen und den Rest des Aussehens. |
| `~/.config/hypr/autostart.lua` | Steuert zusätzliche Prozesse, die mit der Sitzung gestartet werden. |
| `~/.config/omarchy/shell.json` | Steuert die Omarchy-Shell: Leistenposition, Layout und Widgets, plus Zeitsteuerungen für Bildschirmschoner, Sperre und Leerlauf. |
| `~/.config/foot/foot.ini` | Steuert dein Terminal (foot ist der Standard). |
| `~/.XCompose` | Definiert deine Schnellzugriffs-Emojis und die Namens-/E-Mail-Autovervollständigung. Stelle sicher, dass du nach Änderungen `omarchy-restart-xcompose` ausführst. |

Wenn du schließlich viele Änderungen vornimmst, um dein eigenes Setup zu verfeinern, ist es eine gute Idee, all diese Dotfiles zu sichern. [Stow ist dafür großartig](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Eigene Apps mit der Sitzung starten

Wenn etwas bei jeder Anmeldung laufen soll — ein Sync-Daemon, eine Chat-App, dein eigenes Skript — trage es in `~/.config/hypr/autostart.lua` ein:

```lua
o.launch_on_start("my-service")
```

Das startet den Befehl als Teil der Sitzung, sodass er beim Abmelden ordentlich aufgeräumt wird.

### Skripte bei Systemereignissen ausführen

Omarchy löst zu einer Handvoll Zeitpunkte Hooks aus, an die du deine eigenen Skripte hängen kannst. Sie leben in `~/.config/omarchy/hooks/<event>.d/`, ein Verzeichnis pro Ereignis, und jede ausführbare Datei darin läuft, wenn das Ereignis eintritt:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Gleich nachdem der Desktop gestartet ist |
| `post-update` | Gegen Ende von `omarchy update`, nach Paketen, Migrationen und Dienst-Neustarts, bevor mise-Werkzeuge aktualisiert werden |
| `pre-refresh-pacman` | Nachdem `omarchy refresh pacman` die Paketkonfiguration neu synchronisiert hat, bevor es Pakete aktualisiert; ein Kanalwechsel führt ihn während desselben Refresh-Schritts aus |
| `theme-set` | Nach einem Designwechsel (Designname in `$1`) |
| `font-set` | Nach einem Schriftwechsel (Schriftname in `$1`) |
| `battery-low` | Wenn der Akku schwach wird (Prozentsatz in `$1`) |

Der Hook `pre-refresh-pacman` ist der Ort, an den benutzerdefinierte Repositories oder `IgnorePkg`-Zeilen gehören, da er vor der Pakettransaktion läuft. Beide updatebezogenen Hooks laufen als dein Benutzer, nachdem Omarchy seine zwischengespeicherte sudo-Autorisierung gelöscht hat, sodass ein Hook, der `sudo` nutzt, seine eigene Autorisierung braucht und nach deinem Passwort fragen kann.

Jedes dieser Verzeichnisse enthält bereits eine Datei `.sample`, die die Form eines Hooks zeigt — entferne das `.sample` aus dem Namen, um ihn in Betrieb zu nehmen. Um ein anderswo geschriebenes Skript zu installieren, verwende `omarchy hook install post-boot ~/my-hook`, was es hineinkopiert und ausführbar macht.

### Eigene Menüeinträge hinzufügen

Das Omarchy-Menü (`Super + Space`) lässt sich durch Bearbeiten von `~/.config/omarchy/extensions/omarchy-menu.jsonc` um eigene Zeilen erweitern. Einträge werden per gepunkteter ID eingetragen, und die ID ist es, die sie im Baum platziert, sodass `personal` im Hauptmenü erscheint und `personal.notes` darin erscheint:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Verwendest du eine bestehende ID erneut, überschreibst du diese Zeile, statt eine neue hinzuzufügen. Die Datei wird mit allen verfügbaren Feldern als Kommentare dokumentiert ausgeliefert.

### Eigene Shell-Exports, -Funktionen und -Aliase hinzufügen

Omarchy bringt eine Reihe ergonomischer Aliase und hilfreicher Funktionen mit, aber es ist sehr üblich, eigene hinzufügen zu wollen. Du solltest Aliase, Funktionen und Exports in `~/.bashrc` hinzufügen. Diese Datei wird bei Aktualisierungen nicht überschrieben. Wenn du einen der Omarchy-Standards ändern möchtest, kannst du ihn auch sicher hier hinzufügen.

### Interne Omarchy-Dateien ändern

Sieh mal, das ist dein Computer. Du kannst damit machen, was du willst, aber ich würde davon abraten, die Dateien in `/usr/share/omarchy` direkt zu ändern. Sie gehören zum Omarchy-pacman-Paket, sodass deine Änderungen bei der nächsten Aktualisierung einfach überschrieben werden. Du fährst besser damit, einfach alle Standardwerte, die dir nicht gefallen, im Ordner `~/.config/*` zu überschreiben.

Auf diesem Weg kannst du so gut wie alles ändern, zum Beispiel die Standard-Tastenkürzel. Bearbeite einfach `~/.config/hypr/bindings.lua`, um etwa [Obsidian](https://obsidian.md/) durch [Joplin](https://joplinapp.org/) zu ersetzen (mit `omarchy-pkg-add joplin-bin` installieren):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` entfernt die bestehende Bindung, bevor es ihren Ersatz hinzufügt. Es nimmt dieselben Argumente wie `o.bind` entgegen, einschließlich Starthelfern und Bindungsoptionen. Verwende `o.bind`, um eine Bindung hinzuzufügen, oder `hl.unbind`, um eine zu entfernen, ohne sie zu ersetzen.

Wenn du darauf bestehst, an den internen Omarchy-Dateien herumzuhacken, wechsle über _Aktualisieren > Channel > Dev_ auf den Dev-Kanal. Das verknüpft Omarchy mit einem Git-Checkout des Quellcodes in `~/omarchy`, den du nach Herzenslust ändern darfst. Hier ist niemand, der dir vorschreibt, was du zu tun hast!

### Änderungen zurücksetzen

Wenn du die Konfigurationen durcheinanderbringst, kannst du sie jederzeit im Omarchy-Menü über _Aktualisieren > Config_ auf die Standards zurücksetzen. Oder indem du `omarchy reinstall configs` ausführst, um alles zurückzusetzen.
