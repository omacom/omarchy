# Fehlerbehebung

### Ich habe mein System mit einem Update kaputt gemacht!

Versuche zuerst, [dein System zurückzusetzen](47-system-snapshots.md) auf die Version vor deinem letzten Update. Wenn das nicht funktioniert, nutze `omarchy-debug`, um dein Problem auf #omarchy-help im Discord zu teilen. Und wenn alles andere fehlschlägt, kannst du die Standard-Konfigurationen und -Pakete mit `omarchy-reinstall` neu installieren.

### Warum sind manche Apps auf meinem Display so groß?

Omarchy geht von einem 2x-Display mit hoher Auflösung aus, daher setzt es `GDK_SCALE` auf 2, bis du im Monitor-Panel eine Skalierung auswählst. Wenn du ein 1x-Display hast und GTK- oder X11-Apps übergroß dargestellt werden, wähle im Monitor-Panel 1x dafür aus oder füge `hl.env("GDK_SCALE", "1")` zu `~/.config/hypr/monitors.lua` hinzu (und starte dann jede übergroße App neu). Siehe [das Handbuch zu Monitoren](33-monitors.md).

Bei Spotify kannst du mit `Ctrl + Minus` die UI verkleinern (und mit `Ctrl + Plus` vergrößern).

### Warum funktionieren alle meine Super-Tastenkombinationen nicht mehr?

Auf manchen ASUS ROG- und TUF-Laptops ist `Fn + Super` eine leicht zu übersehende Tastenkombination, die eine firmware-seitige Windows-Tastensperre umschaltet (für Gaming gedacht, damit du ein Spiel nicht aus Versehen verlässt). Nichts auf dem Bildschirm zeigt dir an, dass das passiert ist. Solange die Sperre aktiv ist, sendet Super überhaupt nichts — also hört jede Omarchy-Tastenkombination mit Super einfach auf zu funktionieren, und es sieht so aus, als wäre Hyprland kaputt.

Drücke einmal `Fn + Super`, bevor du dich in `~/.config/hypr/` vergräbst, und wenn Super dadurch nicht zurückkommt, drücke sie erneut, damit du die Sperre nicht aktiviert lässt. Das ist nicht die Fn-Sperre, die nur ändert, was die F-Tastenreihe tut.

### Mein Wi-Fi, Bluetooth, Audio oder Trackpad funktioniert plötzlich nicht mehr

Bevor du neu startest, versuche, das betroffene Subsystem einzeln neu zu starten. _Update > Hardware_ im Omarchy-Menü enthält Wi-Fi, Bluetooth, Audio und Trackpad, und eines davon neu zu laden behebt die meisten „Es hat vor fünf Minuten noch funktioniert“-Situationen — ein Bluetooth-Headset, das sich nicht wieder verbindet, ein Trackpad, das nach einem Suspend tot ist, Ton, der verschwunden ist, als du einen Monitor abgesteckt hast.

### Warum geben meine externen Lautsprecher nichts wieder?

Wahrscheinlich, weil sie nicht als primäre Ausgabe eingestellt sind. Klicke auf das Lautsprecher-Symbol auf der rechten Seite der Leiste, dann öffnet sich das Lautstärke-Popup, in dem du das Ausgabegerät auswählen kannst (und auch die Lautstärke pro App mischen kannst).

### Meine Laptop-Lautsprecher klingen komisch

Auf manchen Laptops wendet Omarchy automatisch ein Lautsprecher-Tuning an, das den Frequenzgang der eingebauten Lautsprecher korrigiert. `omarchy audio tuning status` sagt dir, ob eines auf deinem Rechner aktiv ist, und mit `omarchy audio tuning off` schaltest du es aus, wenn du die Lautsprecher lieber unverändert hören möchtest.

### Warum kann ich mich nicht mit meinem Passwort anmelden oder sudo nutzen?

Du hast es wahrscheinlich zu oft falsch eingegeben und wurdest ausgesperrt. Wenn das auf dem Sperrbildschirm passiert, kannst du `CTRL + ALT + F2` drücken, um ein neues TTY zu starten, in dem du dich als root anmelden kannst, und dann `faillock --reset --user [your-username]` ausführen. Das setzt die Sperre zurück, und du kannst weiterarbeiten.

### Warum erscheinen meine 1Password-Autorisierungsabfragen für den 1Password SSH Agent / die CLI nicht?

Das kann zwei Gründe haben:

Damit die ausführliche Genehmigungsabfrage erscheint, muss Settings > Advanced > Use Hardware Acceleration aktiviert sein. _Hinweis: Damit das funktioniert, ist ein Neustart erforderlich._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Oder wenn du 1Password seit dem Hochfahren nicht gestartet hast, erscheint die Abfrage nicht.
