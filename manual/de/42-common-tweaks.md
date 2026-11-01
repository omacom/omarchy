# Häufige Anpassungen

Dies ist eine Sammlung häufiger Anpassungen am Omarchy-Setup. Sei dir bewusst, dass Systemupdates gelegentlich bestimmte Konfigurationen in ihren Ursprungszustand zurückversetzen müssen. Wenn das passiert, gehen deine Änderungen nicht verloren, sondern landen in einer `.bak`-Datei im selben Verzeichnis.

Wenn du etwas vermasselst, kannst du einzelne Konfigurationen über _Aktualisieren > Config_ im Omarchy-Menü auf ihr ursprüngliches Setup zurücksetzen. Wenn du _wirklich_ alles vermasselst, kannst du alle Konfigurationen mit `omarchy-reinstall` zurücksetzen.

### Alle Tray-Symbole immer anzeigen

Standardmäßig verstecken sich Tray-Symbole wie Dropbox, 1Password oder Steam hinter dem Pfeil zum Erweitern der Ablage, der sie zeigt, wenn du mit der Maus darüberfährst. Wenn du sie immer sichtbar haben willst, klicke mit der rechten Maustaste auf den Erweiterungs-Pfeil, um den Tray-Symbol-Manager zu öffnen, und hefte dann die Symbole an, die sichtbar bleiben sollen (du kannst auch die verstecken, die du nie sehen willst).

### Abgerundete Fensterecken

Omarchys Standard-Design setzt auf eckige Ecken, aber wenn du das etwas abmildern willst, kannst du `~/.config/hypr/looknfeel.lua` so ändern, dass die Rundung nicht mehr auskommentiert ist:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Fensterabstände entfernen

Auf Laptop-Displays verschwenden manche lieber kein Pixel für Fensterabstände (oder sogar eine Menüleiste, die du mit `Super + Shift + Space` ausschalten kannst). Alle Abstände und Rahmen schaltest du mit `Super + Shift + Backspace` um, oder du entfernst sie dauerhaft, indem du die Kommentare in diesem Abschnitt von `~/.config/hypr/looknfeel.lua` entfernst:

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
