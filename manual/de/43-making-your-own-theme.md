# Dein eigenes Theme erstellen

Du kannst eigene Themes zu `~/.config/omarchy/themes` hinzufügen. Kopiere einfach eines der vorhandenen als Basis (sieh in `/usr/share/omarchy/themes` nach) und passe es dann nach Herzenslust an. Solange dein Theme in diesem Ordner liegt, wird es im Menü zur Theme-Auswahl aufgeführt.

Die wichtigste Datei, die du anpassen musst, ist `colors.toml`. Sie definiert den Farbsatz, aus dem dann Konfigurationen für das Terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian und die gesamte Omarchy-Shell (obere Leiste, Menü, Benachrichtigungen, OSD und Sperrbildschirm) generiert werden.

Du kannst auch die mitgelieferte Anwendung Aether verwenden, um mit einer hübschen GUI-Oberfläche ein neues Theme zu erstellen, mit Farben zu spielen und nach Hintergründen zu suchen. Starte sie einfach aus der App-Übersicht mit `Super + Alt + Space`.

### Was ein installiertes Theme enthalten kann

Ein Theme, das du selbst in `~/.config/omarchy/themes` schreibst, kann enthalten, was immer du willst — es ist deine Maschine und deine Datei, und Omarchy wendet alles davon an.

Ein Theme, das du mit `omarchy theme install` aus dem Repo von jemand anderem installierst, behält alles, was Farbe ist, und verliert die Handvoll Dateien, die Code auf deiner Maschine ausführen würden: jede `.lua`-Datei, die Terminal-Konfigurationen (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) und `vscode.json`. Das `hyprland.lua` eines Themes ist Lua, das dein Compositor beim Anmelden ausführt, eine Terminal-Konfiguration benennt das Programm, das dein Terminal startet, und `vscode.json` benennt eine zu installierende VSCode-Erweiterung. Das Theme von jemand anderem zu installieren sollte ändern, wie dein Desktop aussieht, niemals, was er ausführt.

Alles andere funktioniert weiterhin genau so, wie der Autor des Themes es geschrieben hat — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, die Hintergründe und die Vorschauen bleiben alle erhalten. Nur das, was entfernt wurde, wird auf deiner Maschine aus `colors.toml` neu generiert.

Omarchy unterscheidet die beiden danach, ob das Theme ein eigenes Git-Repo in sich trägt, was `omarchy theme install` beim Klonen zurücklässt. So bleibt ein Theme, das du geschrieben hast, deins, und eines, das du aus dem Internet gezogen hast, bleibt reine Farbe.

### Heller Modus

Wenn du ein Theme im hellen Modus erstellst, setze `mode = "light"` an den Anfang deiner `colors.toml`. Dann wird es automatisch mit dem hellen Modus für alle Apps gekoppelt. (Die alte Methode, eine leere Datei namens `light.mode` im Stammverzeichnis deines Themes abzulegen, funktioniert auch weiterhin.)

### Entsperrbild

Themes, die mit den Bildern `unlock.png` und `preview-unlock.png` geliefert werden, werden unter _Appearance > Unlock_ aufgeführt. Dein `unlock.png` sollte vorzugsweise ein transparentes png sein. Und du kannst das Vorschaubild mit `omarchy plymouth preview` erstellen.

### Themes für Apps, die Omarchy nicht abdeckt

Wenn du eine App verwendest, die nicht in dieser Liste steht, kannst du Omarchy mit einer Vorlage selbst beibringen, ein Theme auf sie anzuwenden. Lege eine Datei in `~/.config/omarchy/themed/` ab, die nach der Konfiguration benannt ist, die sie generiert, plus einer `.tpl`-Erweiterung, und schreibe die Konfiguration mit `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` bis `{{ color15 }}` und dem Rest der Palette als Platzhalter. Jedes Mal, wenn du das Theme wechselst, wird die Datei mit den Farben dieses Themes neu generiert.

In diesem Ordner liegt eine vollständig kommentierte `alacritty.toml.tpl.sample`, von der du kopieren kannst — sie listet jede Variable auf, die du verwenden kannst, plus die Modifikatoren `_strip` und `_rgb` für Apps, die ihre Farben ohne das `#` oder als dezimales RGB wollen. Deine Vorlagen haben Vorrang vor Omarchys eigenen, sodass du damit auch überschreiben kannst, wie ein Theme auf eine integrierte App angewendet wird.

### Dein Theme verteilen

Wenn du dein Theme verteilen möchtest, damit andere es verwenden können, musst du es auf einen öffentlichen Git-Server legen, wie GitHub. Dann können Leute es über _Install > Style > Theme_ im Omarchy-Menü mit dieser URL installieren. Es wird empfohlen, der Namenskonvention `omarchy-[themename]-theme` zu folgen, da das Theme nach der Installation im Menü zur Theme-Auswahl korrekt nur als `[themename]` angezeigt wird.

Dieser übrig bleibende `[themename]`-Teil wird zum Verzeichnisnamen des Themes, also muss er einer sein, den Omarchy sicher weiterreichen kann: Er muss mit einem Buchstaben, einer Ziffer oder einem Unterstrich beginnen, und der Rest darf Buchstaben, Ziffern, `.`, `_`, `+` und `-` enthalten. Großbuchstaben werden für dich in Kleinbuchstaben umgewandelt, aber alles andere — ein Leerzeichen, ein Anführungszeichen, ein nicht-englisches Zeichen — wird bei der Installation abgelehnt, statt in einen Verzeichnisnamen verwandelt zu werden. So lassen sich `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` und `omarchy-c++-theme` alle problemlos installieren.

Denke daran, dass, sobald es aus einem Repo installiert wird, jede `.lua`, Terminal-Konfiguration oder `vscode.json`, die es mitliefert, entfernt wird, also baue das Theme nicht um diese herum auf.

Du kannst dein Theme zur [Seite mit den zusätzlichen Themes](https://omarchy.org/themes/) hinzufügen lassen, indem du einen Pull Request an [das omarchy-site Repo](https://github.com/omacom-io/omarchy-site) sendest.
