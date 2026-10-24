# Dein eigenes Design erstellen

Du kannst eigene Designs in `~/.config/omarchy/themes` hinzufügen. Kopiere einfach eines der vorhandenen als Basis (schau in `/usr/share/omarchy/themes`) und passe es nach Belieben an. Solange dein Design in diesem Ordner liegt, erscheint es im Menü zur Designauswahl.

Die Hauptdatei, die du anpassen musst, ist `colors.toml`. Sie definiert den Farbsatz, aus dem dann Konfigurationen für das Terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian und die gesamte Omarchy-Shell (Menüleiste, Menü, Benachrichtigungen, OSD und Sperrbildschirm) erzeugt werden.

Du kannst auch die enthaltene Anwendung Aether nutzen, um mit einer schönen grafischen Oberfläche ein neues Design zu erstellen, mit Farben zu spielen und Hintergründe zu suchen. Starte sie einfach aus dem App-Raster mit `Super + Alt + Space`.

### Was ein installiertes Design enthalten kann

Ein Design, das du selbst in `~/.config/omarchy/themes` schreibst, kann enthalten, was du willst — es ist dein Rechner und deine Datei, und Omarchy wendet alles davon an.

Ein Design, das du aus dem Repo eines anderen mit `omarchy theme install` installierst, behält alles, was Farbe ist, und verliert die Handvoll Dateien, die Code auf deinem Rechner ausführen würden: jede `.lua`-Datei, die Terminal-Konfigurationen (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) und `vscode.json`. Die `hyprland.lua` eines Designs ist Lua, das dein Compositor beim Anmelden ausführt, eine Terminal-Konfiguration nennt das Programm, das dein Terminal startet, und `vscode.json` nennt eine zu installierende VSCode-Erweiterung. Das Design eines anderen zu installieren sollte ändern, wie dein Desktop aussieht, niemals, was er ausführt.

Alles andere funktioniert weiterhin genau so, wie der Designautor es geschrieben hat — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, die Hintergründe und die Vorschauen bleiben alle erhalten. Nur was weggefallen ist, wird auf deinem Rechner aus `colors.toml` neu erzeugt.

Omarchy unterscheidet die beiden daran, ob das Design sein eigenes Git-Repo in sich trägt, was `omarchy theme install` beim Klonen zurücklässt. So bleibt ein Design, das du geschrieben hast, deins, und eines aus dem Internet bleibt Farbe.

### Heller Modus

Wenn du ein Design im hellen Modus erstellst, setze `mode = "light"` oben in deine `colors.toml`. Dann wird es automatisch mit dem hellen Modus für alle Apps gepaart. (Die alte Methode, eine leere Datei namens `light.mode` in das Stammverzeichnis deines Designs zu legen, funktioniert auch noch.)

### Symbolfarben

Wenn du die Symbole des Dateimanagers farblich auf dein Design abstimmen willst, füge eine Datei namens `icons.theme` mit dem Namen des gewünschten Symbolsatzes hinzu. Standardmäßig sind die Optionen: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Entsperrbild

Designs, die mit den Bildern `unlock.png` und `preview-unlock.png` geliefert werden, erscheinen unter _Stil > Entsperren_. Deine `unlock.png` sollte vorzugsweise ein transparentes PNG sein. Und das Vorschaubild erstellst du mit `omarchy plymouth preview`.

### Apps thematisieren, die Omarchy nicht abdeckt

Wenn du eine App nutzt, die nicht in dieser Liste steht, kannst du Omarchy beibringen, sie selbst zu thematisieren, und zwar mit einer Vorlage. Lege eine Datei in `~/.config/omarchy/themed/` ab, die nach der Konfiguration benannt ist, die sie erzeugt, plus einer Endung `.tpl`, und schreibe die Konfiguration mit `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` bis `{{ color15 }}` und dem Rest der Palette als Platzhalter. Jedes Mal, wenn du das Design wechselst, wird die Datei mit den Farben dieses Designs neu erzeugt.

In diesem Ordner liegt eine vollständig kommentierte `alacritty.toml.tpl.sample` zum Kopieren — sie listet jede Variable auf, die du verwenden kannst, plus die Modifikatoren `_strip` und `_rgb` für Apps, die ihre Farben ohne das `#` oder als dezimales RGB wollen. Deine Vorlagen haben Vorrang vor Omarchys eigenen, sodass du damit auch überschreiben kannst, wie eine eingebaute App thematisiert wird.

### Dein Design verteilen

Wenn du dein Design verteilen willst, sodass andere es nutzen können, musst du es auf einen öffentlichen Git-Server wie GitHub stellen. Dann können Leute es über _Installieren > Stil > Design_ im Omarchy-Menü mit dieser URL installieren. Es wird empfohlen, der Namenskonvention `omarchy-[themename]-theme` zu folgen, weil das Design nach der Installation im Menü zur Designauswahl korrekt als nur `[themename]` angezeigt wird.

Dieses übrig bleibende `[themename]` wird zum Verzeichnisnamen des Designs, also muss es einer sein, den Omarchy sicher weiterreichen kann: Er muss mit einem Buchstaben, einer Ziffer oder einem Unterstrich beginnen, und der Rest darf Buchstaben, Ziffern, `.`, `_`, `+` und `-` enthalten. Großbuchstaben werden für dich kleingeschrieben, aber alles andere — ein Leerzeichen, ein Anführungszeichen, ein nicht-englisches Zeichen — wird bei der Installation verweigert, statt in einen Verzeichnisnamen verwandelt zu werden. `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` und `omarchy-c++-theme` lassen sich alle problemlos installieren.

Denke daran, dass nach einer Installation aus einem Repo jede enthaltene `.lua`, Terminal-Konfiguration oder `vscode.json` wegfällt, also baue das Design nicht um diese Dateien herum.

Dein Design lässt du auf [die Seite mit den zusätzlichen Designs](https://omarchy.org/themes/) aufnehmen, indem du einen Pull Request an [das omarchy-site Repo](https://github.com/omacom-io/omarchy-site) sendest.
