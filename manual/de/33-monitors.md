# Monitore

Omarchy geht standardmäßig davon aus, dass du ein 2x-fähiges Display der Retina-Klasse verwendest. Das brauchst du, um diese schönen, gestochen scharfen Programmierer-Schriften zu bekommen. Darauf sind fast alle neuen Premium-Laptops mit hochauflösenden Bildschirmen optimiert. Das ist es, was du auf einem 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) oder 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) betreiben wollen würdest.

Aber wenn du kein Display mit einer PPI von 218 oder mehr betreibst, wirst du die Monitoreinstellungen ändern wollen. Wenn du zum Beispiel einen 27" oder 32" 4K hast, kannst du im Monitor-Panel in der oberen Leiste eine Bruchteil-Skalierung dafür auswählen, oder den Standard für jeden Monitor festlegen, indem du `~/.config/hypr/monitors.lua` öffnest und auf die Empfehlung für diese Kombination umstellst:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Wenn du ein 1080p- oder 1440p-Display verwendest, wirst du vermutlich einfach 1x-Skalierung verwenden wollen, und dasselbe für GTK- und X11-Apps, also kannst du Folgendes verwenden:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Änderungen an `GDK_SCALE` gelten für Anwendungen, die nach der Änderung gestartet werden (und GTK akzeptiert nur ganze Zahlen, also behalte den Wert bei der nächsten ganzen Zahl deiner Monitor-Skalierung). Stelle also sicher, dass du die Fenster schließt, die nach der Änderung übergroß sind (oder schließe alle Fenster mit `Ctrl + Alt + Del`!).

Du kannst auch schnell durch die wichtigsten Skalierungsverhältnisse für Monitore (1x, 1.25x, 1.6x, 2x, 3x, 4x) durchschalten: mit `Super + /` höher und mit `Super + Alt + /` niedriger, oder du wählst eines im Monitor-Panel in der oberen Leiste aus. Diese ändern nur den Monitor, auf dem du gerade den Fokus hast, sodass ein Laptop-Bildschirm und ein externes Display jeweils ihre eigene Skalierung haben können. Das Panel legt außerdem für jeden Monitor Auflösung, Bildwiederholrate und Drehung fest. Deine Auswahl wird für diesen physischen Monitor in `~/.local/state/omarchy/monitors/settings` gespeichert, sodass sie über einen Neustart hinweg bestehen bleibt und dem Monitor zu dem Anschluss oder Dock folgt, an den er als Nächstes angeschlossen wird. Sie hat Vorrang vor jeder Regel für denselben Monitor in `~/.config/hypr/monitors.lua`, die Omarchy niemals bearbeitet. Wenn du deine Monitore lieber vollständig in dieser Datei festlegen möchtest, füge `omarchy_monitor_panel_settings = false` zu ihr hinzu, und die Änderungen des Panels halten dann nur, bis Hyprland neu lädt. Da `GDK_SCALE` ein Wert für alle Bildschirme ist, setzt eine gewählte Skalierung ihn vom Monitor mit der niedrigsten Skalierung, sodass X11-Apps auf dem dichteren Bildschirm etwas klein herauskommen, statt auf dem anderen übergroß zu sein.

### Text größer oder kleiner machen

Die Monitor-Skalierung ändert die Größe von allem. Wenn du nur größeren oder kleineren _Text_ willst, gibt es dafür einen einzigen Regler:

```
omarchy display text size 14
```

Dieser nimmt eine Pixelgröße zwischen 9 und 20 und verschiebt die Omarchy-Shell, GTK-Anwendungen und dein Terminal gemeinsam, sodass der gesamte Desktop proportional bleibt. Führe ihn ohne Argument aus, um zu sehen, wo du gerade stehst, und `omarchy display text size reset`, um zum Standard zurückzukehren. Foot ist der eine Nachzügler: Es hat keine Möglichkeit, seine Konfiguration neu zu laden, also behalten laufende Terminals ihre alte Größe, bis du ein neues öffnest.

### Laptop-Displays erweitern und spiegeln

Wenn du einen externen Bildschirm an deinen Laptop anschließt, wird das Display automatisch erweitert. Aber du kannst das stattdessen zu Spiegeln ändern, mit _Extend_ | _Mirror_ im Monitor-Panel in der oberen Leiste, _Trigger > Hardware_ im Omarchy-Menü oder `Super + Ctrl + Alt + Delete`. Das ist besonders hilfreich, wenn dieser externe Bildschirm ein Projektor ist und du etwas zeigen willst, während du arbeitest.

Wenn du erweiterst, schaltet das Schließen des Deckels am Laptop den internen Bildschirm automatisch aus. Das Öffnen des Deckels schaltet ihn wieder ein. Du kannst das auch manuell steuern, mit _Trigger > Hardware_ im Omarchy-Menü oder `Super + Ctrl + Delete`.

### Mehrere Bildschirme anordnen

Hyprland funktioniert großartig mit mehreren Bildschirmen. Das Monitor-Panel in der oberen Leiste zeichnet sie dort, wo sie sitzen: Ziehe einen gegen die Seite eines anderen, um ihn dorthin zu verschieben, und die Anordnung wird mit den anderen Einstellungen jedes Monitors gespeichert. Für alles, was das Panel nicht abdeckt, lies mehr darüber, wie du sie anordnest, in [der Hyprland-Monitor-Dokumentation](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy gehören diese als `hl.monitor`-Einträge in `~/.config/hypr/monitors.lua` — die Datei wird mit auskommentierten Beispielen ausgeliefert, um einen Monitor ausgeschaltet zu lassen, für Modi, die das Panel nicht anbietet, 10-Bit-Farbe und variable Bildwiederholrate.

Jeder Monitor hat seine eigenen Arbeitsbereiche 1 bis 10, sodass `Super + 1` immer den ersten Arbeitsbereich des Monitors bedeutet, auf dem du dich befindest. Hinter den Kulissen nummeriert Hyprland Arbeitsbereiche trotzdem über alle Monitore hinweg: Dein Laptop-Bildschirm (oder erster Monitor) bekommt 1–10, der nächste Monitor 11–20 und so weiter, und jeder Monitor behält seinen Block jedes Mal, wenn du ihn anschließt. Verwende diese Nummern, wenn du [Arbeitsbereichsregeln](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) oder Fensterregeln für einen bestimmten Monitor schreibst, sodass Arbeitsbereich 12 der zweite Arbeitsbereich deines zweiten Monitors ist. `~/.local/state/omarchy/monitors/workspaces` listet auf, welchen Block jeder Monitor hat.

Die Pfeiltasten funktionieren über Monitore hinweg, die in deinem Layout eine Kante teilen. Bildschirme, die sich nur an einer Ecke berühren oder zwischen denen eine Lücke ist, sind keine Nachbarn, also verwende `Ctrl + Alt + Tab`, um zwischen ihnen zu wechseln.

| Tastenkombination | Zwischen Monitoren |
| --- | --- |
| `Super + Arrow` | Verschiebt den Fokus auf den Monitor auf dieser Seite, sobald in dieser Richtung kein Fenster mehr übrig ist |
| `Super + Shift + Arrow` | Tauscht mit einem Fenster auf dem Monitor auf dieser Seite |
| `Super + Alt + Arrow` | Verschiebt das Fenster in eine Gruppe auf dem Monitor auf dieser Seite |
| `Super + Shift + Ctrl + Arrow` | Verschiebt das Fenster auf den Monitor auf dieser Seite, auf den Arbeitsbereich, den er anzeigt |
| `Super + Shift + Alt + Arrow` | Verschiebt den Arbeitsbereich auf den Monitor auf dieser Seite und behält seine Nummer, falls sie frei ist |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Verschiebt den Fokus auf den nächsten oder vorherigen Monitor, unabhängig vom Layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Bleiben auf dem Monitor, auf dem du dich befindest |

Du kannst dir auch [Hyprmon](https://github.com/erans/hyprmon/) ansehen, wenn du eine TUI möchtest, die dir bei der Positionierung mehrerer Bildschirme hilft.

### Helligkeit steuern

Die Monitorhelligkeit wird über die dedizierten Funktionstasten für Helligkeit hoch/runter gesteuert. Wenn du beim Drücken dieser Tasten die Umschalttaste gedrückt hältst, gehst du zur maximalen oder minimalen Helligkeit. Die Tasten steuern das Display, auf dem du den Fokus hast, sodass externe Monitore, die DDC/CI sprechen, auf dieselbe Weise angepasst werden wie der Laptop-Bildschirm.

### Apple-Displays

Wenn du ein Apple-Display verwendest, funktionieren die regulären Tastatur-Helligkeitstasten ebenfalls automatisch, wenn du den Fokus auf dem Apple-Display hast. Das geschieht über den Befehl `asdcontrol`.

Beachte, dass du, wenn du ein Apple 6K XDR-Display verwendest, möglicherweise einen Phantom-Bildschirm in deiner Auflistung von `hyprctl monitors` siehst. Du kannst diesen mit etwas wie `hl.monitor({ output = "DP-2", disabled = true })` in `~/.config/hypr/monitors.lua` ausschalten.

Auf Intel-Maschinen solltest du dich über ein reguläres Thunderbolt-Kabel mit Apple-Displays verbinden. Auf anderen Maschinen ohne Thunderbolt musst du typischerweise ein [DP + USB-A -> USB-C-Kabel](https://www.amazon.com/dp/B0BNX7MS6N) verwenden, damit es funktioniert.
