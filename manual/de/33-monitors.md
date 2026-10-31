# Monitore

Omarchy geht standardmäßig davon aus, dass du ein 2x-fähiges Display der Retina-Klasse verwendest. Das brauchst du, um diese schönen, gestochen scharfen Programmierer-Schriften zu bekommen. Dafür sind fast alle neuen Premium-Laptops mit hochauflösenden Bildschirmen optimiert. Das würdest du auf einem 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) oder 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) verwenden wollen.

Aber wenn du kein Display mit einer PPI von 218 oder mehr verwendest, wirst du die Monitor-Einstellungen ändern wollen. Wenn du zum Beispiel ein 27" oder 32" 4K hast, kannst du im Monitor-Panel in der oberen Leiste eine gebrochene Skalierung dafür auswählen oder den Standard für jeden Monitor festlegen, indem du `~/.config/hypr/monitors.lua` öffnest und zur Empfehlung für diese Kombination wechselst:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Wenn du ein 1080p- oder 1440p-Display verwendest, willst du wahrscheinlich einfach eine 1x-Skalierung verwenden, und dasselbe für GTK- und X11-Apps, also kannst du Folgendes verwenden:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Änderungen an `GDK_SCALE` gelten für Anwendungen, die nach der Änderung gestartet werden (und GTK akzeptiert nur ganze Zahlen, also behalte den Wert bei der nächstgelegenen ganzen Zahl deiner Monitor-Skalierung). Stelle also sicher, dass du die Fenster schließt, die du nach der Änderung in Übergröße hast (oder schließe alle Fenster mit `Ctrl + Alt + Del`!).

Du kannst auch schnell durch die wichtigsten Monitor-Skalierungsverhältnisse (1x, 1.25x, 1.6x, 2x, 3x, 4x) durchschalten, indem du `Super + /` verwendest, um höher zu gehen, und `Super + Alt + /`, um niedriger zu gehen, oder eines aus dem Monitor-Panel in der oberen Leiste auswählst. Diese ändern nur den Monitor, auf dem du dich gerade befindest, sodass ein Laptop-Bildschirm und ein externes Display jeweils ihre eigene Skalierung haben können. Über das Panel wird auch die Auflösung jedes Monitors eingestellt. Deine Auswahl wird für diesen physischen Monitor in `~/.local/state/omarchy/monitors/settings` gespeichert, sodass sie einen Neustart überdauert und dem Monitor zu dem Anschluss oder Dock folgt, an den er als Nächstes angeschlossen wird. Sie hat Vorrang vor jeder Regel für denselben Monitor in `~/.config/hypr/monitors.lua`, die Omarchy niemals bearbeitet. Da `GDK_SCALE` ein einziger Wert für alle Bildschirme ist, wird er aus dem Monitor mit der niedrigsten Skalierung gesetzt, sodass X11-Apps auf dem dichteren Bildschirm etwas klein herauskommen, statt auf dem anderen übergroß zu sein.

### Text größer oder kleiner machen

Die Monitor-Skalierung ändert die Größe von allem. Wenn du nur größeren oder kleineren _Text_ willst, gibt es dafür einen einzigen Regler:

```
omarchy display text size 14
```

Dieser nimmt eine Pixelgröße zwischen 9 und 20 und verschiebt die Omarchy-Shell, GTK-Anwendungen und dein Terminal gemeinsam, sodass der gesamte Desktop im richtigen Verhältnis bleibt. Führe ihn ohne Argument aus, um zu sehen, wo du gerade stehst, und `omarchy display text size reset`, um zum Standard zurückzukehren. Foot ist der einzige Nachzügler: Es hat keine Möglichkeit, seine Konfiguration neu zu laden, sodass geöffnete Terminals ihre alte Größe behalten, bis du ein neues öffnest.

### Laptop-Displays erweitern und spiegeln

Wenn du einen externen Bildschirm an deinen Laptop anschließt, wird das Display automatisch erweitert. Aber du kannst das stattdessen auf Spiegeln ändern, indem du _Trigger > Hardware_ im Omarchy-Menü oder `Super + Ctrl + Alt + Delete` verwendest. Das ist besonders hilfreich, wenn dieser externe Bildschirm ein Projektor ist und du etwas zeigen willst, während du arbeitest.

Wenn du erweiterst, wird beim Schließen des Laptop-Deckels der interne Bildschirm automatisch ausgeschaltet. Beim Öffnen des Deckels wird er wieder eingeschaltet. Du kannst dies auch manuell steuern, indem du _Trigger > Hardware_ im Omarchy-Menü oder `Super + Ctrl + Delete` verwendest.

### Mehrere Bildschirme anordnen

Hyprland funktioniert großartig mit mehreren Bildschirmen. Das Monitor-Panel in der oberen Leiste zeichnet sie dort, wo sie sitzen: Ziehe einen gegen die Seite eines anderen, um ihn dorthin zu verschieben, und die Anordnung wird mit den anderen Einstellungen jedes Monitors gespeichert. Für alles, was das Panel nicht abdeckt, lies mehr darüber, wie du sie anordnest, in [der Hyprland-Monitor-Dokumentation](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy gehören diese als `hl.monitor`-Einträge in `~/.config/hypr/monitors.lua` — die Datei wird mit auskommentierten Beispielen ausgeliefert, um einen bestimmten Monitor auf eine Auflösung, Position und Drehung festzulegen.

Jeder Monitor hat seine eigenen Workspaces 1 bis 10, sodass `Super + 1` immer den ersten Workspace des Monitors bedeutet, auf dem du dich befindest. Hinter den Kulissen nummeriert Hyprland Workspaces immer noch über alle Monitore hinweg: Dein Laptop-Bildschirm (oder erster Monitor) bekommt 1–10, der nächste Monitor 11–20 und so weiter, und jeder Monitor behält seinen Block jedes Mal, wenn du ihn anschließt. Verwende diese Nummern, wenn du [Workspace-Regeln](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) oder Fensterregeln für einen bestimmten Monitor schreibst, sodass Workspace 12 der zweite Workspace deines zweiten Monitors ist. `~/.local/state/omarchy/monitors/workspaces` listet auf, welchen Block jeder Monitor hat.

Die Pfeiltasten funktionieren über Monitore hinweg, die sich in deinem Layout eine Kante teilen. Bildschirme, die sich nur an einer Ecke berühren oder zwischen denen eine Lücke ist, sind keine Nachbarn, also verwende `Ctrl + Alt + Tab`, um zwischen ihnen zu wechseln.

| Hotkey | Über mehrere Monitore hinweg |
| --- | --- |
| `Super + Arrow` | Verschiebt den Fokus auf den Monitor auf dieser Seite, sobald in dieser Richtung kein Fenster mehr übrig ist |
| `Super + Shift + Arrow` | Tauscht mit einem Fenster auf dem Monitor auf dieser Seite aus |
| `Super + Alt + Arrow` | Verschiebt das Fenster in eine Gruppe auf dem Monitor auf dieser Seite |
| `Super + Shift + Ctrl + Arrow` | Verschiebt das Fenster auf den Monitor auf dieser Seite, auf den Workspace, den er anzeigt |
| `Super + Shift + Alt + Arrow` | Verschiebt den Workspace auf den Monitor auf dieser Seite und behält seine Nummer, wenn sie frei ist |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Verschiebt den Fokus auf den nächsten oder vorherigen Monitor, unabhängig vom Layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Bleiben auf dem Monitor, auf dem du dich befindest |

Sieh dir auch [Hyprmon](https://github.com/erans/hyprmon/) an, wenn du eine TUI möchtest, die dir bei der Positionierung mehrerer Bildschirme hilft.

### Helligkeit steuern

Die Monitor-Helligkeit wird über die dedizierten Funktionstasten für Helligkeit rauf/runter gesteuert. Wenn du beim Drücken dieser Tasten Shift gedrückt hältst, gehst du zur maximalen oder minimalen Helligkeit. Die Tasten steuern das Display, auf dem du dich gerade befindest, sodass externe Monitore, die DDC/CI sprechen, genauso angepasst werden wie der Laptop-Bildschirm.

### Apple Displays

Wenn du ein Apple-Display verwendest, funktionieren die regulären Tastatur-Helligkeitstasten auch automatisch, wenn du dich auf dem Apple-Display befindest. Dies geschieht über den Befehl `asdcontrol`.

Beachte, dass du, wenn du ein Apple 6K XDR-Display verwendest, möglicherweise einen Phantom-Bildschirm in deiner `hyprctl monitors`-Auflistung siehst. Du kannst dies mit etwas wie `hl.monitor({ output = "DP-2", disabled = true })` in `~/.config/hypr/monitors.lua` ausschalten.

Auf Intel-Rechnern solltest du Apple-Displays mit einem regulären Thunderbolt-Kabel anschließen. Auf anderen Rechnern ohne Thunderbolt musst du in der Regel ein [DP + USB-A -> USB-C-Kabel](https://www.amazon.com/dp/B0BNX7MS6N) verwenden, damit es funktioniert.
