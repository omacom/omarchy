# Monitore

Omarchy geht standardmäßig davon aus, dass du ein 2x-fähiges Display der Retina-Klasse verwendest. Das brauchst du für diese schönen, gestochen scharfen Programmierer-Schriften. Darauf sind fast alle neuen Premium-Laptops mit hochauflösenden Bildschirmen optimiert. Das möchtest du an einem 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) oder 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) betreiben.

Wenn du aber kein Display mit einem PPI-Wert von 218 oder darüber betreibst, solltest du die Monitoreinstellungen ändern. Wenn du zum Beispiel ein 27" oder 32" 4K-Display hast, kannst du im Monitor-Panel in der oberen Leiste eine gebrochene Skalierung dafür auswählen oder den Standard für jeden Monitor festlegen, indem du `~/.config/hypr/monitors.lua` öffnest und zur Empfehlung für diese Kombination wechselst:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Wenn du ein 1080p- oder 1440p-Display verwendest, möchtest du wahrscheinlich einfach eine 1x-Skalierung verwenden, und dasselbe für GTK- und X11-Apps, also kannst du Folgendes verwenden:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Änderungen an `GDK_SCALE` gelten für Anwendungen, die nach der Änderung gestartet werden (und GTK berücksichtigt nur ganze Zahlen, also behalte ihn bei der nächstgelegenen ganzen Zahl deiner Monitorskalierung). Stelle also sicher, dass du nach der Änderung die übergroßen Fenster schließt, die du offen hast (oder schließe alle Fenster mit `Ctrl + Alt + Del`!).

Du kannst auch mit `Super + /` schnell durch die wichtigsten Verhältnisse für die Monitorskalierung (1x, 1.25x, 1.6x, 2x, 3x, 4x) nach oben und mit `Super + Alt + /` nach unten schalten oder eines aus dem Monitor-Panel in der oberen Leiste auswählen. Diese ändern nur den Monitor, auf dem der Fokus liegt, sodass ein Laptop-Bildschirm und ein externes Display jeweils ihre eigene Skalierung haben können. Das Panel legt außerdem die Auflösung, Bildwiederholfrequenz und Rotation jedes Monitors fest. Deine Auswahl wird für diesen physischen Monitor in `~/.local/state/omarchy/monitors/settings` gespeichert, sodass sie einen Neustart überdauert und dem Monitor folgt, an welchen Port oder welche Dock er als Nächstes angeschlossen wird. Sie hat Vorrang vor jeder Regel für denselben Monitor in `~/.config/hypr/monitors.lua`, die Omarchy niemals bearbeitet. Wenn du deine Monitore lieber vollständig in dieser Datei einstellst, füge `omarchy_monitor_panel_settings = false` zu ihr hinzu, und die Änderungen des Panels gelten nur, bis Hyprland neu lädt. Da `GDK_SCALE` ein einziger Wert für alle Bildschirme ist, setzt eine gewählte Skalierung ihn anhand des Monitors mit der niedrigsten Skalierung, sodass X11-Apps auf dem dichteren Bildschirm etwas klein herauskommen statt auf dem anderen übergroß.

### Text größer oder kleiner machen

Die Monitorskalierung ändert die Größe von allem. Wenn du nur größeren oder kleineren _Text_ willst, gibt es dafür einen einzigen Regler:

```
omarchy display text size 14
```

Das nimmt eine Pixelgröße zwischen 9 und 20 und stellt die Omarchy-Shell, GTK-Anwendungen und dein Terminal gemeinsam um, sodass der gesamte Desktop proportional bleibt. Führe den Befehl ohne Argument aus, um zu sehen, wo du gerade stehst, und `omarchy display text size reset`, um zum Standard zurückzukehren. Foot ist der einzige Nachzügler: Es hat keine Möglichkeit, seine Config neu zu laden, sodass laufende Terminals ihre alte Größe behalten, bis du ein neues öffnest.

### Laptop-Displays erweitern und spiegeln

Wenn du einen externen Bildschirm an deinen Laptop anschließt, wird die Anzeige automatisch erweitert. Du kannst das aber stattdessen über _Trigger > Hardware_ im Omarchy-Menü oder mit `Super + Ctrl + Alt + Delete` auf Spiegeln ändern. Das ist besonders hilfreich, wenn dieser externe Bildschirm ein Projektor ist und du während der Arbeit etwas zeigen möchtest.

Wenn du erweiterst, schaltet das Schließen des Laptop-Deckels den internen Bildschirm automatisch aus. Das Öffnen des Deckels schaltet ihn wieder ein. Du kannst das auch manuell über _Trigger > Hardware_ im Omarchy-Menü oder mit `Super + Ctrl + Delete` steuern.

### Mehrere Bildschirme anordnen

Hyprland funktioniert hervorragend mit mehreren Bildschirmen. Das Monitor-Panel in der oberen Leiste zeichnet sie dort, wo sie sitzen: Ziehe einen gegen die Seite eines anderen, um ihn dorthin zu verschieben, und die Anordnung wird zusammen mit den anderen Einstellungen jedes Monitors gespeichert. Für alles, was das Panel nicht abdeckt, lies in [der Hyprland-Monitor-Dokumentation](https://wiki.hypr.land/Configuring/Basics/Monitors/) mehr darüber, wie du sie anordnest. In Omarchy gehören diese als `hl.monitor`-Einträge in `~/.config/hypr/monitors.lua` — die Datei enthält auskommentierte Beispiele dafür, einen Monitor ausgeschaltet zu lassen, für Modi, die das Panel nicht anbietet, für 10-Bit-Farbe und für variable Bildwiederholfrequenz.

Jeder Monitor hat seine eigenen Workspaces 1 bis 10, sodass `Super + 1` immer den ersten Workspace des Monitors bedeutet, auf dem du dich befindest. Hinter den Kulissen nummeriert Hyprland die Workspaces weiterhin über alle Monitore hinweg: Dein Laptop-Bildschirm (oder erster Monitor) bekommt 1–10, der nächste Monitor 11–20 und so weiter, und jeder Monitor behält seinen Block bei jedem Anschließen. Verwende diese Nummern, wenn du [Workspace-Regeln](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) oder Fensterregeln für einen bestimmten Monitor schreibst, sodass Workspace 12 der zweite Workspace deines zweiten Monitors ist. `~/.local/state/omarchy/monitors/workspaces` listet auf, welchen Block jeder Monitor hat.

Die Pfeiltasten funktionieren über Monitore hinweg, die sich in deinem Layout eine Kante teilen. Bildschirme, die sich nur an einer Ecke berühren oder zwischen denen eine Lücke ist, sind keine Nachbarn, also verwende `Ctrl + Alt + Tab`, um zwischen ihnen zu wechseln.

| Hotkey | Monitorübergreifend |
| --- | --- |
| `Super + Arrow` | Verschiebt den Fokus auf den Monitor auf dieser Seite, sobald es in dieser Richtung kein Fenster mehr gibt |
| `Super + Shift + Arrow` | Tauscht mit einem Fenster auf dem Monitor auf dieser Seite |
| `Super + Alt + Arrow` | Verschiebt das Fenster in eine Gruppe auf dem Monitor auf dieser Seite |
| `Super + Shift + Ctrl + Arrow` | Verschiebt das Fenster auf den Monitor auf dieser Seite, auf den Workspace, den dieser gerade zeigt |
| `Super + Shift + Alt + Arrow` | Verschiebt den Workspace auf den Monitor auf dieser Seite und behält seine Nummer, falls sie frei ist |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Verschiebt den Fokus auf den nächsten oder vorherigen Monitor, unabhängig vom Layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Bleiben auf dem Monitor, auf dem du dich befindest |

Du kannst dir auch [Hyprmon](https://github.com/erans/hyprmon/) ansehen, wenn du eine TUI möchtest, die dir bei der Positionierung mehrerer Bildschirme hilft.

### Helligkeit steuern

Die Monitorhelligkeit wird über die dafür vorgesehenen Funktionstasten für Helligkeit rauf/runter gesteuert. Wenn du beim Drücken dieser Tasten Shift gedrückt hältst, springst du auf maximale oder minimale Helligkeit. Die Tasten steuern das Display, auf dem der Fokus liegt, sodass externe Monitore, die DDC/CI sprechen, genauso angepasst werden wie der Laptop-Bildschirm.

### Apple Displays

Wenn du ein Apple-Display verwendest, funktionieren die normalen Helligkeitstasten der Tastatur auch automatisch, wenn der Fokus auf dem Apple-Display liegt. Das geschieht über den Befehl `asdcontrol`.

Beachte: Wenn du ein Apple 6K XDR-Display verwendest, siehst du möglicherweise einen Phantom-Bildschirm in deiner Ausgabe von `hyprctl monitors`. Du kannst ihn mit etwas wie `hl.monitor({ output = "DP-2", disabled = true })` in `~/.config/hypr/monitors.lua` abschalten.

Auf Intel-Rechnern solltest du Apple-Displays mit einem normalen Thunderbolt-Kabel anschließen. Auf anderen Rechnern ohne Thunderbolt musst du in der Regel ein [DP + USB-A -> USB-C-Kabel](https://www.amazon.com/dp/B0BNX7MS6N) verwenden, damit es funktioniert.
