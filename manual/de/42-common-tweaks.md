# Gängige Anpassungen

Dies ist eine Sammlung gängiger Anpassungen an der Omarchy-Einrichtung. Beachte, dass es gelegentlich notwendig sein kann, dass Systemaktualisierungen bestimmte Konfigurationen in ihren ursprünglichen Zustand zurückversetzen. Wenn das geschieht, gehen deine Änderungen nicht verloren, sondern werden in einer `.bak.<timestamp>`-Datei neben dem Original abgelegt.

Wenn du etwas vermasselst, kannst du einzelne Konfigurationen über _Update > Config_ im Omarchy-Menü auf ihre ursprüngliche Einrichtung zurücksetzen. Wenn du _wirklich_ alles vermasselst, kannst du alle Konfigurationen mit `omarchy reinstall configs` zurücksetzen oder mit `omarchy reinstall` jedes Standardpaket und jede Konfiguration neu installieren.

### Alle Tray-Icons jederzeit anzeigen

Standardmäßig sind Tray-Icons wie Dropbox, 1password oder Steam hinter dem Pfeil zum Ausklappen der Tray verborgen, der sie anzeigt, wenn du mit der Maus darüberfährst. Wenn du sie lieber jederzeit sichtbar haben möchtest, klicke mit der rechten Maustaste auf den Ausklapp-Pfeil, um den Tray-Icon-Manager zu öffnen, und pinne dann die Icons, die du sichtbar halten möchtest (du kannst auch diejenigen ausblenden, die du nie sehen willst).

### Abgerundete Fensterecken

Omarchys Standarddesign hat eckige Ecken, aber wenn du das ein bisschen weicher machen möchtest, wähle _Appearance > Windows > Window Corners > Rounded Corners_ im Omarchy-Menü oder führe `omarchy hyprland corners rounded` aus. _Theme Corners_ kehrt zu dem zurück, was das Theme verwendet. Um deinen eigenen Radius zu wählen, bleibe bei _Theme Corners_ (`omarchy hyprland corners theme`), da Rounded und Sharp nach deiner Konfiguration geladen werden und sie überschreiben, und entferne die Kommentarzeichen bei der Rundung in `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Fensterabstände entfernen

Auf Laptop-Displays ziehen es manche Leute vor, keine Pixel für Fensterabstände zu verschwenden (oder sogar für eine obere Leiste, die du mit `Super + Shift + Space` ein- und ausblenden kannst). Du kannst alle Abstände und Rahmen mit `Super + Shift + Backspace` deaktivieren oder sie dauerhaft entfernen, indem du die Kommentare in diesem Abschnitt von `~/.config/hypr/looknfeel.lua` entfernst:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
