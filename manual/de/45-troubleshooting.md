# Fehlerbehebung

### Ich habe mein System mit einem Update kaputt gemacht!

Versuche zuerst, [dein System zurückzusetzen](47-system-snapshots.md) auf die Version vor deinem letzten Update. Wenn das nicht funktioniert, nutze `omarchy-debug`, um dein Problem auf #omarchy-help im Discord zu teilen. Und wenn alles andere fehlschlägt, kannst du die Standard-Konfigurationen und -Pakete mit `omarchy-reinstall` neu installieren.

### Warum sind manche Apps auf meinem Display so groß?

Omarchy geht von einem hochauflösenden 2x-Display aus, wofür `GDK_SCALE` in `~/.config/hypr/monitors.lua` auf 2 gesetzt werden muss. Wenn du aber ein 1x-Display hast, kannst du `local omarchy_gdk_scale = 2` in 1 ändern (und dann alle Apps neu starten, die zu groß dargestellt werden). Siehe [das Handbuch zu Monitoren](33-monitors.md).

Bei Spotify kannst du mit `Ctrl + Minus` die Oberfläche verkleinern (und mit `Ctrl + Plus` vergrößern).

### Warum funktionieren alle meine Super-Tastenkombinationen nicht mehr?

Auf manchen ASUS ROG- und TUF-Laptops ist `Fn + Super` eine leicht zu übersehende Tastenkombination, die eine Firmware-Sperre für die Windows-Taste umschaltet (gedacht fürs Gaming, damit du ein Spiel nicht versehentlich verlässt). Nichts auf dem Bildschirm zeigt dir an, dass das passiert ist. Solange die Sperre aktiv ist, sendet Super überhaupt nichts — also hört jede Omarchy-Tastenkombination mit Super einfach auf zu funktionieren, und es sieht so aus, als wäre Hyprland kaputt.

Drücke einmal `Fn + Super`, bevor du dich durch `~/.config/hypr/` wühlst, und wenn Super dadurch nicht zurückkommt, drücke es noch einmal, damit du die Sperre nicht versehentlich aktiviert lässt. Das ist nicht die Fn-Sperre, die nur ändert, was die F-Tastenreihe tut.

### Mein Wi-Fi, Bluetooth, Audio oder Trackpad funktioniert plötzlich nicht mehr

Bevor du neu startest, versuche, das betroffene Subsystem für sich neu zu starten. _Update > Hardware_ im Omarchy-Menü enthält Wi-Fi, Bluetooth, Audio und Trackpad, und eines davon neu zu laden behebt die meisten „vor fünf Minuten hat es noch funktioniert“-Situationen — ein Bluetooth-Headset, das sich nicht wieder verbinden will, ein Trackpad, das nach einem Ruhezustand tot ist, Ton, der verschwunden ist, als du einen Monitor ausgesteckt hast.

### Warum geben meine externen Lautsprecher nichts wieder?

Vermutlich, weil sie nicht als primäre Ausgabe eingestellt sind. Klicke auf das Lautsprecher-Symbol auf der rechten Seite der Leiste, dann öffnet sich das Lautstärke-Popup, in dem du das Ausgabegerät wählen (und auch die Lautstärke pro App mischen) kannst.

### Meine Laptop-Lautsprecher klingen komisch

Auf manchen Laptops wendet Omarchy automatisch ein Lautsprecher-Tuning an, das den Frequenzgang der eingebauten Lautsprecher korrigiert. `omarchy audio tuning status` zeigt dir, ob eines auf deinem Rechner aktiv ist, und `omarchy audio tuning off` schaltet es aus, wenn du die Lautsprecher lieber pur hören willst.

### Warum kann ich mich nicht anmelden oder sudo mit meinem Passwort nutzen?

Wahrscheinlich hast du es zu oft falsch eingegeben und wurdest ausgesperrt. Wenn das auf dem Sperrbildschirm passiert, kannst du `CTRL + ALT + F2` drücken, um ein neues TTY zu starten, in dem du dich als root anmelden kannst, und dann `faillock --reset --user [your-username]` ausführen. Das setzt die Sperre zurück, und du kannst weiterarbeiten.

### Warum erscheinen meine 1Password-Autorisierungsabfragen für 1Password SSH Agent / CLI nicht?

Das kann 2 Gründe haben:

Damit die ausführliche Genehmigungsabfrage erscheint, muss Settings > Advanced > Use Hardware Acceleration aktiviert sein. _Hinweis: Das erfordert einen Neustart, damit es zu funktionieren beginnt._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Oder wenn du 1Password seit dem Hochfahren nicht gestartet hast, wird die Abfrage nicht erscheinen.
