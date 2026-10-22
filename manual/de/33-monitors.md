# Monitore

Omarchy geht standardmäßig davon aus, dass du ein 2x-fähiges Display der Retina-Klasse verwendest. Das brauchst du, um diese schönen, scharfen Programmierschriften zu bekommen. Dafür sind fast alle neuen Premium-Laptops mit hochauflösenden Bildschirmen optimiert. Das möchtest du auf einem 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) oder einem 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) laufen lassen.

Aber wenn du kein Display mit einer PPI von 218 oder höher verwendest, wirst du die Monitoreinstellungen ändern wollen. Wenn du zum Beispiel ein 27" oder 32" 4K hast, kannst du fraktionale Skalierung verwenden, indem du `~/.config/hypr/monitors.lua` (im Omarchy-Menü über _Einrichtung > Monitore_) öffnest und zur Empfehlung für diese Kombination wechselst:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Wenn du ein 1080p- oder 1440p-Display verwendest, wirst du wahrscheinlich einfach 1x-Skalierung verwenden wollen, sodass du Folgendes verwenden kannst:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Änderungen an `GDK_SCALE` gelten für Anwendungen, die nach der Änderung gestartet werden (und GTK akzeptiert nur ganze Zahlen, also halte sie bei der nächsten ganzen Zahl deiner Monitorskalierung). Stelle also sicher, dass du die überdimensionierten Fenster nach der Änderung beendest (oder alle Fenster mit `Ctrl + Alt + Del` schließt!).

Du kannst auch schnell durch die wichtigsten Monitor-Skalierungsverhältnisse (1x, 1.25x, 1.6x, 2x, 3x, 4x) schreiten, mit `Super + /` für höher und `Super + Alt + /` für niedriger. Wenn du die Standardkonfiguration hast, bleiben diese Änderungen auch über einen Neustart hinweg bestehen.

### Text größer oder kleiner machen

Die Monitorskalierung ändert die Größe von allem. Wenn du nur größeren oder kleineren _Text_ willst, gibt es dafür einen einzigen Regler:

```
omarchy display text size 14
```

Der nimmt eine Pixelgröße zwischen 9 und 20 entgegen und bewegt die Omarchy-Shell, GTK-Anwendungen und dein Terminal gemeinsam, sodass der ganze Desktop in Proportion bleibt. Führe ihn ohne Argument aus, um zu sehen, wo du stehst, und `omarchy display text size reset`, um zum Standard zurückzukehren. Foot ist der einzige Nachzügler: Es hat keine Möglichkeit, seine Konfiguration neu zu laden, sodass laufende Terminals ihre alte Größe behalten, bis du ein neues öffnest.

### Laptop-Displays erweitern und spiegeln

Wenn du einen externen Bildschirm an deinen Laptop anschließt, wird die Anzeige automatisch erweitert. Aber du kannst das stattdessen über _Auslösen > Hardware_ im Omarchy-Menü oder `Super + Ctrl + Alt + Delete` auf Spiegeln umstellen. Das ist besonders hilfreich, wenn dieser externe Bildschirm ein Projektor ist und du beim Arbeiten etwas zeigen möchtest.

Beim Erweitern schaltet das Schließen des Laptop-Deckels den internen Bildschirm automatisch aus. Das Öffnen des Deckels schaltet ihn wieder ein. Du kannst dies auch manuell über _Auslösen > Hardware_ im Omarchy-Menü oder `Super + Ctrl + Delete` steuern.

### Mehrere Bildschirme anordnen

Hyprland funktioniert hervorragend mit mehreren Bildschirmen. Lies mehr darüber, wie du sie anordnest, in [der Monitor-Dokumentation von Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Du kannst auch [bestimmte Arbeitsflächen an bestimmte Monitore binden](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). In Omarchy stehen diese Regeln in `~/.config/hypr/monitors.lua` als `hl.monitor`-Einträge — die Datei wird mit auskommentierten Beispielen ausgeliefert, um einen bestimmten Monitor auf eine Auflösung, Position und Drehung festzulegen.

Du kannst dir auch [Hyprmon](https://github.com/erans/hyprmon/) ansehen, wenn du eine TUI möchtest, die dir bei der Positionierung mehrerer Bildschirme hilft.

### Helligkeit steuern

Die Monitorhelligkeit wird über die dedizierten Funktionstasten für Helligkeit rauf/runter gesteuert. Wenn du beim Drücken dieser Tasten die Umschalttaste gedrückt hältst, gelangst du zur maximalen oder minimalen Helligkeit. Die Tasten steuern das Display, auf das du fokussiert bist, sodass externe Monitore, die DDC/CI sprechen, genauso angepasst werden wie der Laptop-Bildschirm.

### Apple-Displays

Wenn du ein Apple-Display verwendest, funktionieren die normalen Tastatur-Helligkeitstasten ebenfalls automatisch, wenn du auf das Apple-Display fokussiert bist. Dies geschieht über den Befehl `asdcontrol`.

Beachte, dass du bei einem Apple 6K XDR-Display in deiner Auflistung `hyprctl monitors` einen Phantombildschirm sehen kannst. Du kannst diesen über _Einrichtung > Monitore_ mit etwas wie `hl.monitor({ output = "DP-2", disabled = true })` ausschalten.

Auf Intel-Rechnern solltest du dich mit einem normalen Thunderbolt-Kabel mit Apple-Displays verbinden. Auf anderen Rechnern ohne Thunderbolt musst du in der Regel ein [DP + USB-A -> USB-C-Kabel](https://www.amazon.com/dp/B0BNX7MS6N) verwenden, damit es funktioniert.
