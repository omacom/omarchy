# Dein eigenes Theme erstellen

Du kannst deine eigenen Themes zu `~/.config/omarchy/themes` hinzufügen. Kopiere einfach eines der vorhandenen als Grundlage (sieh in `/usr/share/omarchy/themes` nach) und passe es dann nach Herzenslust an. Solange dein Theme in diesem Ordner liegt, erscheint es im Menü zur Theme-Auswahl.

Die Hauptdatei, die du anpassen musst, ist `colors.toml`. Sie definiert den Farbsatz, der dann verwendet wird, um Konfigurationen für das Terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt-Apps, die Tastatur-Hintergrundbeleuchtung, die Eingabemethode, die Auswahl für die Bildschirmfreigabe, die App-Symbole, mehrere KI-Tools (Claude, Pi, Hermes, T3 Code, Herdr) und die gesamte Omarchy-Shell (obere Leiste, Menü, Benachrichtigungen, OSD und Sperrbildschirm) zu generieren.

Du kannst auch die mitgelieferte Anwendung Aether verwenden, um ein neues Theme über eine schöne GUI-Oberfläche zu erstellen, mit Farben zu spielen und nach Hintergründen zu suchen. Starte sie einfach aus der App-Übersicht mit `Super + Alt + Space`.

### Was ein installiertes Theme enthalten kann

Ein Theme, das du selbst in `~/.config/omarchy/themes` schreibst, kann enthalten, was immer du willst — es ist dein Rechner und deine Datei, und Omarchy wendet alles davon an.

Ein Theme, das du mit `omarchy theme install` aus dem Repo eines anderen installierst, behält alles, was Farbe ist, und verliert die Handvoll Dateien, die Code auf deinem Rechner ausführen würden: jede `.lua`-Datei, die Terminal-Konfigurationen (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) und `vscode.json`. Die `hyprland.lua` eines Themes ist Lua, das dein Compositor bei der Anmeldung ausführt, eine Terminal-Konfiguration benennt das Programm, das dein Terminal startet, und `vscode.json` benennt eine zu installierende VSCode-Erweiterung. Das Theme eines anderen zu installieren sollte ändern, wie dein Desktop aussieht, niemals, was er ausführt.

Alles andere funktioniert weiterhin genau so, wie der Autor des Themes es geschrieben hat — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, die Hintergründe und die Vorschauen bleiben alle erhalten. Nur das, was entfernt wurde, wird auf deinem Rechner aus `colors.toml` neu generiert.

Omarchy unterscheidet die beiden danach, ob das Theme ein eigenes Git-Repo in sich trägt, was `omarchy theme install` beim Klonen zurücklässt. So bleibt ein Theme, das du geschrieben hast, deines, und eines, das du aus dem Internet gezogen hast, bleibt Farben.

### Heller Modus

Wenn du ein Theme für den hellen Modus erstellst, setze `mode = "light"` oben in deine `colors.toml`. Dann wird es automatisch für alle Apps mit dem hellen Modus gekoppelt. (Die alte Methode, eine leere Datei namens `light.mode` im Wurzelverzeichnis deines Themes abzulegen, funktioniert auch noch.)

### Entsperrbild

Themes, die mit den Bildern `unlock.png` und `preview-unlock.png` ausgeliefert werden, werden unter _Aussehen > Entsperren_ aufgeführt. Deine `unlock.png` sollte vorzugsweise eine transparente PNG sein. Und du kannst das Vorschaubild mit `omarchy plymouth preview` erstellen.

### Apps mit einem Theme versehen, die Omarchy nicht abdeckt

Wenn du eine App verwendest, die nicht in dieser Liste steht, kannst du Omarchy mit einer Vorlage selbst beibringen, sie mit einem Theme zu versehen. Lege eine Datei in `~/.config/omarchy/themed/` ab, die nach der Konfiguration benannt ist, die sie generiert, plus der Erweiterung `.tpl`, und schreibe die Konfiguration mit `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` bis `{{ color15 }}` und dem Rest der Palette als Platzhalter. Jedes Mal, wenn du das Theme wechselst, wird die Datei mit den Farben dieses Themes neu generiert.

In diesem Ordner gibt es eine vollständig kommentierte `alacritty.toml.tpl.sample`, von der du kopieren kannst — sie listet jede Variable auf, die du verwenden kannst, plus die Modifikatoren `_strip` und `_rgb` für Apps, die ihre Farben ohne das `#` oder als dezimale RGB-Werte wollen. Deine Vorlagen haben Vorrang vor Omarchys eigenen, du kannst damit also auch überschreiben, wie eine eingebaute App mit einem Theme versehen wird.

### Dein Theme verteilen

Wenn du dein Theme verteilen willst, damit andere es verwenden können, musst du es auf einen öffentlichen Git-Server legen, wie GitHub. Dann können Leute es über diese URL mit _Installieren > Stil > Theme_ im Omarchy-Menü installieren. Es wird empfohlen, dass du der Namenskonvention `omarchy-[themename]-theme` folgst, da das Theme nach der Installation korrekt nur als `[themename]` im Menü zur Theme-Auswahl angezeigt wird.

Dieses übrig bleibende `[themename]` wird zum Verzeichnisnamen des Themes, also muss es einer sein, den Omarchy sicher weiterreichen kann: Es muss mit einem Buchstaben, einer Ziffer oder einem Unterstrich beginnen, und der Rest darf Buchstaben, Ziffern, `.`, `_`, `+` und `-` enthalten. Großbuchstaben werden für dich in Kleinbuchstaben umgewandelt, aber alles andere — ein Leerzeichen, ein Anführungszeichen, ein nicht-englisches Zeichen — wird bei der Installation abgelehnt, statt in einen Verzeichnisnamen verwandelt zu werden. So lassen sich `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` und `omarchy-c++-theme` alle problemlos installieren.

Denke daran, dass, sobald es aus einem Repo installiert wird, jede `.lua`, Terminal-Konfiguration oder `vscode.json`, die es mitliefert, entfernt wird, also baue das Theme nicht um diese herum auf.

Du kannst dein Theme auf [die Seite mit den zusätzlichen Themes](https://omarchy.org/themes/) aufnehmen lassen, indem du einen Pull Request an [das omarchy-site-Repo](https://github.com/omacom-io/omarchy-site) sendest.
