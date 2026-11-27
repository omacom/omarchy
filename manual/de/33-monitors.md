# Monitore

Omarchy geht standardmäßig davon aus, dass du ein 2x-fähiges Display der Retina-Klasse verwendest. Das brauchst du, um diese schönen, gestochen scharfen Programmier-Schriften zu bekommen. Darauf sind fast alle neuen Premium-Laptops mit hochauflösenden Bildschirmen optimiert. Das ist, was du an einem 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) oder 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) betreiben wollen würdest.

Aber wenn du kein Display mit einer PPI von 218 oder mehr betreibst, wirst du die Monitor-Einstellungen ändern wollen. Wenn du zum Beispiel ein 27" oder 32" 4K hast, kannst du im Monitor-Panel in der oberen Leiste eine gebrochene Skalierung dafür auswählen oder den Standard für jeden Monitor festlegen, indem du `~/.config/hypr/monitors.lua` öffnest und zur Empfehlung für diese Kombination wechselst:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Wenn du ein 1080p- oder 1440p-Display verwendest, wirst du wahrscheinlich einfach 1x-Skalierung verwenden wollen, und dasselbe für GTK- und X11-Apps, also kannst du Folgendes verwenden:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Änderungen an `GDK_SCALE` gelten für Anwendungen, die nach der Änderung gestartet werden (und GTK berücksichtigt nur ganze Zahlen, also behalte es bei der nächsten ganzen Zahl deiner Monitor-Skalierung). Stelle also sicher, dass du die Fenster beendest, die du hast und die nach der Änderung zu groß dargestellt werden (oder schließe alle Fenster mit `Ctrl + Alt + Del`!).

Du kannst auch schnell durch die wichtigsten Monitor-Skalierungsverhältnisse (1x, 1.25x, 1.6x, 2x, 3x, 4x) schalten, mit `Super + /`, um höher zu gehen, und `Super + Alt + /`, um niedriger zu gehen, oder eines aus dem Monitor-Panel in der oberen Leiste auswählen. Diese ändern nur den Monitor, auf dem du dich gerade befindest, sodass ein Laptop-Bildschirm und ein externes Display jeweils ihre eigene Skalierung haben können. Das Panel stellt auch Auflösung, Bildwiederholrate und Drehung jedes Monitors ein. Deine Auswahl wird für diesen physischen Monitor in `~/.local/state/omarchy/monitors/settings` gespeichert, sodass sie einen Neustart überdauert und dem Monitor zu dem Anschluss oder Dock folgt, an dem er als Nächstes angeschlossen wird. Sie hat Vorrang vor jeder Regel für denselben Monitor in `~/.config/hypr/monitors.lua`, die Omarchy niemals bearbeitet. Wenn du deine Monitore lieber vollständig in dieser Datei einstellst, füge `omarchy_monitor_panel_settings = false` zu ihr hinzu, und die Änderungen des Panels gelten nur, bis Hyprland neu lädt. Da `GDK_SCALE` ein Wert für alle Bildschirme ist, setzt eine gewählte Skalierung ihn nach dem Monitor mit der niedrigsten Skalierung, sodass X11-Apps auf dem dichteren Bildschirm etwas klein herauskommen, statt auf dem anderen zu groß.

### Text größer oder kleiner machen

Die Monitor-Skalierung ändert die Größe von allem. Wenn du nur größeren oder kleineren _Text_ willst, gibt es dafür einen einzigen Regler:

```
omarchy display text size 14
```

Das nimmt eine Pixelgröße zwischen 9 und 20 und bewegt die Omarchy-Shell, GTK-Anwendungen und dein Terminal gemeinsam, sodass der gesamte Desktop in Proportion bleibt. Führe es ohne Argument aus, um zu sehen, wo du gerade stehst, und `omarchy display text size reset`, um zum Standard zurückzukehren. Foot ist der einzige Nachzügler: Es hat keine Möglichkeit, seine Konfiguration neu zu laden, sodass laufende Terminals ihre alte Größe behalten, bis du ein neues öffnest.

### Laptop-Displays erweitern und spiegeln

Wenn du einen externen Bildschirm an deinen Laptop anschließt, wird das Display automatisch erweitert. Aber du kannst das stattdessen mit _Erweitern_ | _Spiegeln_ im Monitor-Panel in der oberen Leiste, _Trigger > Hardware_ im Omarchy-Menü oder `Super + Ctrl + Alt + Delete` auf Spiegeln ändern. Das ist besonders hilfreich, wenn dieser externe Bildschirm ein Projektor ist und du etwas zeigen willst, während du arbeitest.

Wenn du erweiterst, schaltet das Schließen des Deckels am Laptop den internen Bildschirm automatisch aus. Das Öffnen des Deckels schaltet ihn wieder ein. Du kannst das auch manuell über _Trigger > Hardware_ im Omarchy-Menü oder `Super + Ctrl + Delete` steuern.

Während der Laptop angeschlossen ist, versetzt das Schließen des Deckels ihn niemals in den Ruhezustand, sodass ein angedockter Laptop wach bleibt, selbst wenn der externe Bildschirm kurzzeitig die Verbindung trennt. Ist kein externer Bildschirm angeschlossen, sperrt das Schließen des Deckels am Netzteil ihn nur. Im Akkubetrieb wird er beim Schließen des Deckels wie üblich in den Ruhezustand versetzt.

### Mehrere Bildschirme anordnen

Hyprland funktioniert großartig mit mehreren Bildschirmen. Das Monitor-Panel in der oberen Leiste zeichnet sie dort, wo sie sich befinden: Ziehe einen gegen die Seite eines anderen, um ihn dorthin zu bewegen, und die Anordnung wird mit den anderen Einstellungen jedes Monitors gespeichert. Für alles, was das Panel nicht abdeckt, lies mehr darüber, wie du sie anordnest, in [der Hyprland-Monitor-Dokumentation](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy gehören diese als `hl.monitor`-Einträge in `~/.config/hypr/monitors.lua` — die Datei wird mit auskommentierten Beispielen geliefert, um einen Monitor ausgeschaltet zu lassen, für Modi, die das Panel nicht anbietet, 10-Bit-Farbe und variable Bildwiederholrate.

Jeder Monitor hat seine eigenen Arbeitsbereiche 1 bis 10, sodass `Super + 1` immer den ersten Arbeitsbereich des Monitors bedeutet, auf dem du dich befindest. Hinter den Kulissen nummeriert Hyprland die Arbeitsbereiche trotzdem über alle Monitore hinweg: Dein Laptop-Bildschirm (oder erster Monitor) bekommt 1–10, der nächste Monitor 11–20 und so weiter, und jeder Monitor behält seinen Block jedes Mal, wenn du ihn anschließt. Verwende diese Nummern, wenn du [Arbeitsbereich-Regeln](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) oder Fensterregeln für einen bestimmten Monitor schreibst, sodass Arbeitsbereich 12 der zweite Arbeitsbereich deines zweiten Monitors ist. `~/.local/state/omarchy/monitors/workspaces` listet auf, welchen Block jeder Monitor hat.

Die Pfeiltasten funktionieren über Monitore hinweg, die sich in deinem Layout eine Kante teilen. Bildschirme, die sich nur an einer Ecke berühren oder zwischen denen eine Lücke ist, sind keine Nachbarn, also verwende `Ctrl + Alt + Tab`, um zwischen ihnen zu wechseln.

| Tastenkürzel | Über Monitore hinweg |
| --- | --- |
| `Super + Arrow` | Bewegt den Fokus auf den Monitor auf dieser Seite, sobald in dieser Richtung kein Fenster mehr übrig ist |
| `Super + Shift + Arrow` | Tauscht mit einem Fenster auf dem Monitor auf dieser Seite |
| `Super + Alt + Arrow` | Bewegt das Fenster in eine Gruppe auf dem Monitor auf dieser Seite |
| `Super + Shift + Ctrl + Arrow` | Bewegt das Fenster auf den Monitor auf dieser Seite, auf den Arbeitsbereich, den er gerade zeigt |
| `Super + Shift + Alt + Arrow` | Bewegt den Arbeitsbereich auf den Monitor auf dieser Seite und behält seine Nummer, wenn sie frei ist |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Bewegt den Fokus auf den nächsten oder vorherigen Monitor, unabhängig vom Layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Bleiben auf dem Monitor, auf dem du dich befindest |

Du kannst dir auch [Hyprmon](https://github.com/erans/hyprmon/) ansehen, wenn du eine TUI möchtest, die dir bei der Positionierung mehrerer Bildschirme hilft.

### Helligkeit steuern

Die Monitorhelligkeit wird über die dedizierten Funktionstasten für Helligkeit hoch/runter gesteuert. Wenn du beim Drücken dieser Tasten Shift gedrückt hältst, gehst du zur maximalen oder minimalen Helligkeit. Die Tasten steuern das Display, auf dem du dich gerade befindest, sodass externe Monitore, die DDC/CI sprechen, genauso angepasst werden wie der Laptop-Bildschirm.

### Apple Displays

Wenn du ein Apple-Display verwendest, funktionieren die regulären Tastatur-Helligkeitstasten auch automatisch, wenn du dich auf dem Apple-Display befindest. Das geschieht über den Befehl `asdcontrol`.

Beachte, dass du, wenn du ein Apple 6K XDR Display verwendest, möglicherweise einen Phantom-Bildschirm in deiner `hyprctl monitors`-Auflistung siehst. Du kannst diesen mit etwas wie `hl.monitor({ output = "DP-2", disabled = true })` in `~/.config/hypr/monitors.lua` ausschalten.

Auf Intel-Maschinen solltest du dich mit Apple-Displays über ein reguläres Thunderbolt-Kabel verbinden. Auf anderen Maschinen ohne Thunderbolt musst du typischerweise ein [DP + USB-A -> USB-C Kabel](https://www.amazon.com/dp/B0BNX7MS6N) verwenden, damit es funktioniert.
