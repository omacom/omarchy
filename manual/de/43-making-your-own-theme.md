# Dein eigenes Theme erstellen

Du kannst deine eigenen Themes zu `~/.config/omarchy/themes` hinzufügen. Kopiere einfach eines der vorhandenen Themes als Grundlage (sieh in `/usr/share/omarchy/themes` nach) und passe es dann nach Herzenslust an. Solange dein Theme in diesem Ordner liegt, wird es im Menü zur Theme-Auswahl aufgenommen.

Die wichtigste Datei, die du anpassen musst, ist `colors.toml`. Sie definiert das Farbschema, aus dem dann Konfigurationen für das Terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian und die gesamte Omarchy-Shell (obere Leiste, Menü, Benachrichtigungen, OSD und Sperrbildschirm) generiert werden.

Du kannst auch die mitgelieferte Anwendung Aether verwenden, um ein neues Theme über eine hübsche GUI-Oberfläche zu erstellen, mit Farben zu spielen und nach Hintergründen zu suchen. Starte sie einfach aus der App-Übersicht mit `Super + Alt + Space`.

### Was ein installiertes Theme enthalten darf

Ein Theme, das du selbst in `~/.config/omarchy/themes` schreibst, kann enthalten, was immer du willst — es ist dein Rechner und deine Datei, und Omarchy wendet alles davon an.

Ein Theme, das du mit `omarchy theme install` aus dem Repo einer anderen Person installierst, behält alles, was Farbe ist, und verliert die Handvoll Dateien, die Code auf deinem Rechner ausführen würden: jede `.lua`-Datei, die Terminal-Konfigurationen (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) und `vscode.json`. Die `hyprland.lua` eines Themes ist Lua, das dein Compositor bei der Anmeldung ausführt, eine Terminal-Konfiguration benennt das Programm, das dein Terminal startet, und `vscode.json` benennt eine zu installierende VSCode-Erweiterung. Das Theme einer anderen Person zu installieren sollte ändern, wie dein Desktop aussieht, niemals, was er ausführt.

Alles andere funktioniert weiterhin genau so, wie der Autor des Themes es geschrieben hat — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, die Hintergründe und die Vorschauen bleiben alle erhalten. Nur das, was entfernt wurde, wird auf deinem Rechner aus `colors.toml` neu generiert.

Omarchy unterscheidet die beiden danach, ob das Theme ein eigenes git-Repo in sich trägt, was `omarchy theme install` beim Klonen zurücklässt. So bleibt ein Theme, das du geschrieben hast, deins, und eines, das du aus dem Internet gezogen hast, bleibt Farben.

### Heller Modus

Wenn du ein Theme für den hellen Modus erstellst, setze `mode = "light"` an den Anfang deiner `colors.toml`. Dann wird es für alle Apps automatisch mit dem hellen Modus gekoppelt. (Der alte Weg, eine leere Datei namens `light.mode` im Stammverzeichnis deines Themes abzulegen, funktioniert auch noch.)

### Symbolfarben

Wenn du die Symbole des Dateimanagers farblich an dein Theme anpassen möchtest, füge eine Datei namens `icons.theme` mit dem Namen des Symbolsatzes hinzu, den du verwenden möchtest. Standardmäßig sind die Optionen: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Bild zum Entsperren

Themes, die mit den Bildern `unlock.png` und `preview-unlock.png` ausgeliefert werden, werden unter _Darstellung > Entsperren_ aufgeführt. Deine `unlock.png` sollte vorzugsweise ein transparentes png sein. Und du kannst das Vorschaubild mit `omarchy plymouth preview` erstellen.

### Themes für Apps, die Omarchy nicht abdeckt

Wenn du eine App verwendest, die nicht in dieser Liste steht, kannst du Omarchy mit einem Template selbst beibringen, ein Theme für sie anzuwenden. Lege eine Datei in `~/.config/omarchy/themed/` ab, benannt nach der Konfiguration, die sie generiert, plus einer `.tpl`-Erweiterung, und schreibe die Konfiguration mit `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` bis `{{ color15 }}` und dem Rest der Palette als Platzhalter. Jedes Mal, wenn du Themes wechselst, wird die Datei mit den Farben dieses Themes neu generiert.

In diesem Ordner liegt eine vollständig kommentierte `alacritty.toml.tpl.sample`, von der du kopieren kannst — sie listet jede Variable auf, die du verwenden kannst, plus die Modifikatoren `_strip` und `_rgb` für Apps, die ihre Farben ohne das `#` oder als dezimales RGB wollen. Deine Templates haben Vorrang vor Omarchys eigenen, sodass du damit auch überschreiben kannst, wie für eine eingebaute App ein Theme angewendet wird.

### Dein Theme verteilen

Wenn du dein Theme verteilen möchtest, damit andere es verwenden können, musst du es auf einen öffentlichen git-Server legen, wie GitHub. Dann können Leute es über _Installieren > Stil > Theme_ im Omarchy-Menü mit dieser URL installieren. Es wird empfohlen, dass du der Namenskonvention `omarchy-[themename]-theme` folgst, da das Theme nach der Installation korrekt als nur `[themename]` im Menü zur Theme-Auswahl angezeigt wird.

Dieser übrig bleibende `[themename]` wird zum Verzeichnisnamen des Themes, also muss er einer sein, den Omarchy sicher herumreichen kann: Er muss mit einem Buchstaben, einer Ziffer oder einem Unterstrich beginnen, und der Rest darf Buchstaben, Ziffern, `.`, `_`, `+` und `-` enthalten. Großbuchstaben werden für dich in Kleinbuchstaben umgewandelt, aber alles andere — ein Leerzeichen, ein Anführungszeichen, ein nicht-englisches Zeichen — wird bei der Installation abgelehnt, statt in einen Verzeichnisnamen verwandelt zu werden. So lassen sich `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` und `omarchy-c++-theme` alle problemlos installieren.

Denke daran, dass, sobald es aus einem Repo installiert wird, jede mitgelieferte `.lua`-Datei, Terminal-Konfiguration oder `vscode.json` entfernt wird, also baue das Theme nicht um diese herum auf.

Du kannst dein Theme zur [Seite mit den zusätzlichen Themes](https://omarchy.org/themes/) hinzufügen lassen, indem du einen Pull Request an [das omarchy-site-Repo](https://github.com/omacom-io/omarchy-site) sendest.
