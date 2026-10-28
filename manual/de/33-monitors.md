# Monitore

Omarchy geht standardmäßig davon aus, dass du ein 2x-fähiges Display der Retina-Klasse verwendest. Das brauchst du, um diese schönen, gestochen scharfen Programmierer-Schriften zu bekommen. Dafür sind fast alle neuen Premium-Laptops mit hochauflösenden Bildschirmen optimiert. Das würdest du auf einem 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) oder 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) betreiben wollen.

Aber wenn du kein Display mit einer PPI von 218 oder mehr verwendest, wirst du die Monitor-Einstellungen ändern wollen. Wenn du zum Beispiel ein 27" oder 32" 4K hast, kannst du fraktionale Skalierung verwenden, indem du `~/.config/hypr/monitors.lua` öffnest (über _Setup > Monitors_ im Omarchy-Menü) und zur Empfehlung für diese Kombination wechselst:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Wenn du ein 1080p- oder 1440p-Display verwendest, wirst du wahrscheinlich einfach 1x-Skalierung verwenden wollen, also kannst du verwenden:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Änderungen an `GDK_SCALE` gelten für Anwendungen, die nach der Änderung gestartet werden (und GTK akzeptiert nur ganze Zahlen, also belasse es bei der nächsten ganzen Zahl deiner Monitor-Skalierung). Stelle also sicher, dass du die Fenster schließt, die nach der Änderung überdimensioniert sind (oder schließe alle Fenster mit `Ctrl + Alt + Del`!).

Du kannst auch schnell durch die wichtigsten Monitor-Skalierungsverhältnisse (1x, 1.25x, 1.6x, 2x, 3x, 4x) schalten, indem du `Super + /` verwendest, um höher zu gehen, und `Super + Alt + /`, um niedriger zu gehen. Wenn du die Standardkonfiguration hast, bleiben diese Änderungen auch nach einem Neustart erhalten.

### Text größer oder kleiner machen

Die Monitor-Skalierung ändert die Größe von allem. Wenn du nur größeren oder kleineren _Text_ willst, gibt es dafür einen einzigen Regler:

```
omarchy display text size 14
```

Der nimmt eine Pixelgröße zwischen 9 und 20 und passt die Omarchy-Shell, GTK-Anwendungen und dein Terminal gemeinsam an, sodass der gesamte Desktop proportional bleibt. Führe ihn ohne Argument aus, um zu sehen, wo du gerade stehst, und `omarchy display text size reset`, um zum Standard zurückzukehren. Foot ist der einzige Nachzügler: Es hat keine Möglichkeit, seine Konfiguration neu zu laden, sodass laufende Terminals ihre alte Größe behalten, bis du ein neues öffnest.

### Laptop-Displays erweitern und spiegeln

Wenn du einen externen Bildschirm an deinen Laptop anschließt, wird das Display automatisch erweitert. Du kannst das aber stattdessen auf Spiegeln ändern, indem du _Trigger > Hardware_ im Omarchy-Menü oder `Super + Ctrl + Alt + Delete` verwendest. Das ist besonders hilfreich, wenn dieser externe Bildschirm ein Projektor ist und du etwas zeigen willst, während du arbeitest.

Wenn du erweiterst, schaltet das Schließen des Laptop-Deckels den internen Bildschirm automatisch aus. Das Öffnen des Deckels schaltet ihn wieder ein. Du kannst das auch manuell steuern, indem du _Trigger > Hardware_ im Omarchy-Menü oder `Super + Ctrl + Delete` verwendest.

### Mehrere Bildschirme anordnen

Hyprland funktioniert großartig mit mehreren Bildschirmen. Lies mehr darüber, wie du sie anordnest, in [der Hyprland-Monitor-Dokumentation](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy kommen diese in `~/.config/hypr/monitors.lua` als `hl.monitor`-Einträge — die Datei wird mit auskommentierten Beispielen ausgeliefert, um einen bestimmten Monitor auf eine Auflösung, Position und Drehung festzulegen.

Jeder Monitor hat seine eigenen Workspaces 1 bis 10, sodass `Super + 1` immer den ersten Workspace des Monitors bedeutet, auf dem du dich befindest. Hinter den Kulissen nummeriert Hyprland Workspaces weiterhin über alle Monitore hinweg: Dein Laptop-Bildschirm (oder erster Monitor) bekommt 1–10, der nächste Monitor 11–20 und so weiter, und jeder Monitor behält seinen Block jedes Mal, wenn du ihn anschließt. Verwende diese Nummern, wenn du [Workspace-Regeln](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) oder Fensterregeln für einen bestimmten Monitor schreibst, sodass Workspace 12 der zweite Workspace deines zweiten Monitors ist. `~/.local/state/omarchy/monitor-workspaces` listet auf, welchen Block jeder Monitor hat.

Die Pfeiltasten funktionieren über Monitore hinweg, die sich in deinem Layout eine Kante teilen. Bildschirme, die sich nur an einer Ecke berühren oder zwischen denen eine Lücke ist, sind keine Nachbarn, also verwende `Ctrl + Alt + Tab`, um zwischen ihnen zu wechseln.

| Hotkey | Über Monitore hinweg |
| --- | --- |
| `Super + Arrow` | Bewegt den Fokus auf den Monitor auf dieser Seite, sobald es in dieser Richtung kein Fenster mehr gibt |
| `Super + Shift + Arrow` | Tauscht mit einem Fenster auf dem Monitor auf dieser Seite |
| `Super + Alt + Arrow` | Bewegt das Fenster in eine Gruppe auf dem Monitor auf dieser Seite |
| `Super + Shift + Ctrl + Arrow` | Bewegt das Fenster auf den Monitor auf dieser Seite, auf den Workspace, den er zeigt |
| `Super + Shift + Alt + Arrow` | Bewegt den Workspace auf den Monitor auf dieser Seite und behält seine Nummer, wenn sie frei ist |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Bewegt den Fokus auf den nächsten oder vorherigen Monitor, unabhängig vom Layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Bleiben auf dem Monitor, auf dem du dich befindest |

Sieh dir auch [Hyprmon](https://github.com/erans/hyprmon/) an, wenn du eine TUI möchtest, die dir bei der Positionierung mehrerer Bildschirme hilft.

### Helligkeit steuern

Die Monitor-Helligkeit wird über die dedizierten Funktionstasten für Helligkeit hoch/runter gesteuert. Wenn du beim Drücken dieser Tasten Shift gedrückt hältst, gehst du zur maximalen oder minimalen Helligkeit. Die Tasten steuern das Display, auf dem du fokussiert bist, sodass externe Monitore, die DDC/CI sprechen, auf die gleiche Weise angepasst werden wie der Laptop-Bildschirm.

### Apple Displays

Wenn du ein Apple-Display verwendest, funktionieren die regulären Tastatur-Helligkeitstasten auch automatisch, wenn du auf das Apple-Display fokussiert bist. Das geschieht über den Befehl `asdcontrol`.

Beachte, dass du, wenn du ein Apple 6K XDR Display verwendest, möglicherweise einen Phantom-Bildschirm in deiner `hyprctl monitors`-Auflistung siehst. Du kannst das mit etwas wie `hl.monitor({ output = "DP-2", disabled = true })` über _Setup > Monitors_ ausschalten.

Auf Intel-Maschinen solltest du dich über ein reguläres Thunderbolt-Kabel mit Apple-Displays verbinden. Auf anderen Maschinen ohne Thunderbolt musst du in der Regel ein [DP + USB-A -> USB-C-Kabel](https://www.amazon.com/dp/B0BNX7MS6N) verwenden, damit es funktioniert.
