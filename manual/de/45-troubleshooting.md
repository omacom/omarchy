# Fehlerbehebung

### Ich habe mein System mit einem Update kaputt gemacht!

Versuche zuerst, [dein System auf die Version zurückzusetzen](47-system-snapshots.md), die vor deinem letzten Update lief. Wenn das nicht funktioniert, teile dein Problem mit `omarchy-debug` unter #omarchy-help im Discord. Und wenn alles fehlschlägt, kannst du die Standard-Konfigurationen und -Pakete mit `omarchy-reinstall` neu installieren.

### Warum sind manche Apps auf meinem Display so groß?

Omarchy geht von einem 2x-Display mit hoher Auflösung aus, wofür `GDK_SCALE` in `~/.config/hypr/monitors.lua` auf 2 gesetzt werden muss. Aber wenn du ein 1x-Display hast, kannst du `local omarchy_gdk_scale = 2` in 1 ändern (und dann jede übergroße App neu starten). Siehe [das Handbuch zu Monitoren](33-monitors.md).

Bei Spotify kannst du die Oberfläche mit `Ctrl + Minus` verkleinern (und mit `Ctrl + Plus` vergrößern).

### Mein WLAN, Bluetooth, Audio oder Trackpad hat einfach aufgehört zu funktionieren

Versuche vor einem Neustart, das betroffene Subsystem für sich neu zu starten. Unter _Aktualisieren > Hardware_ im Omarchy-Menü findest du Wi-Fi, Bluetooth, Audio und Trackpad, und eines davon neu zu laden löst die meisten Situationen der Art „vor fünf Minuten ging es noch“ — ein Bluetooth-Headset, das sich nicht wieder verbindet, ein Trackpad, das nach einem Standby tot ist, Ton, der verschwunden ist, als du einen Monitor ausgesteckt hast.

### Warum spielen meine externen Lautsprecher nicht?

Wahrscheinlich, weil sie nicht als primäre Ausgabe gesetzt sind. Klicke auf das Lautsprechersymbol auf der rechten Seite der Leiste, und es öffnet sich das Lautstärke-Popup, in dem du das Ausgabegerät wählen kannst (und auch die Lautstärke pro App mischen).

### Meine Laptop-Lautsprecher klingen komisch

Auf manchen Laptops wendet Omarchy automatisch eine Lautsprecher-Abstimmung an, die den Frequenzgang der eingebauten Lautsprecher korrigiert. `omarchy audio tuning status` sagt dir, ob auf deinem Rechner eine aktiv ist, und `omarchy audio tuning off` schaltet sie aus, wenn du die Lautsprecher lieber roh hören willst.

### Warum kann ich mich mit meinem Passwort nicht anmelden oder sudo nutzen?

Du hast es wahrscheinlich zu oft falsch eingegeben und wurdest ausgesperrt. Wenn das auf dem Sperrbildschirm passiert, drücke `CTRL + ALT + F2`, um ein neues TTY zu starten, in dem du dich als root anmelden kannst, und führe dann `faillock --reset --user [your-username]` aus. Damit wird die Sperre zurückgesetzt, und du kannst weiterarbeiten.

### Warum erscheinen meine 1Password-Autorisierungsabfragen für 1Password SSH Agent / CLI nicht?

Das kann aus 2 Gründen passieren:

Damit die ausführliche Genehmigungsabfrage erscheint, muss Settings > Advanced > Use Hardware Acceleration eingeschaltet sein. _Hinweis: Das erfordert einen Neustart, um zu wirken._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Oder wenn du 1Password seit dem Hochfahren nicht gestartet hast, erscheint die Abfrage nicht.
