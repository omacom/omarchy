# Fehlerbehebung

### Ich habe mein System mit einem Update kaputt gemacht!

Versuche zuerst, [dein System zurückzusetzen](47-system-snapshots.md) auf die Version vor deinem letzten Update. Wenn das nicht funktioniert, nutze `omarchy-debug`, um dein Problem auf #omarchy-help im Discord zu teilen. Und wenn alles andere fehlschlägt, kannst du die Standard-Konfigurationen und -Pakete mit `omarchy-reinstall` neu installieren.

### Warum sind manche Apps auf meinem Display so groß?

Omarchy geht von einem 2x hochauflösenden Display aus, also setzt es `GDK_SCALE` auf 2, bis du im Monitor-Panel eine Skalierung auswählst. Wenn du ein 1x-Display hast und GTK- oder X11-Apps übergroß dargestellt werden, wähle im Monitor-Panel 1x dafür aus, oder füge `hl.env("GDK_SCALE", "1")` zu `~/.config/hypr/monitors.lua` hinzu (und starte danach jede App neu, die übergroß ist). Siehe [das Handbuch zu Monitoren](33-monitors.md).

Bei Spotify kannst du mit `Ctrl + Minus` die UI verkleinern (und mit `Ctrl + Plus` vergrößern).

### Warum funktionieren plötzlich alle meine Super-Tastenkombinationen nicht mehr?

Bei manchen ASUS ROG und TUF Laptops ist `Fn + Super` eine leicht zu übersehende Tastenkombination, die eine firmware-seitige Windows-Tasten-Sperre umschaltet (gedacht fürs Gaming, damit du ein Spiel nicht versehentlich verlässt). Auf dem Bildschirm wird dir nicht angezeigt, dass das passiert ist. Solange die Sperre aktiv ist, sendet Super überhaupt nichts — also hört jede Omarchy-Tastenkombination mit Super einfach auf zu funktionieren, und es sieht so aus, als wäre Hyprland kaputt.

Drücke einmal `Fn + Super`, bevor du dich durch `~/.config/hypr/` wühlst, und wenn das Super nicht zurückbringt, drücke sie erneut, damit du die Sperre nicht aktiviert lässt. Das ist nicht die Fn-Sperre, die nur ändert, was die F-Tastenreihe macht.

### Mein Wi-Fi, Bluetooth, Audio oder Trackpad funktioniert plötzlich nicht mehr

Bevor du neu startest, versuche, das betroffene Subsystem für sich allein neu zu starten. _Update > Hardware_ im Omarchy-Menü enthält Wi-Fi, Bluetooth, Audio und Trackpad, und eines davon neu zu laden behebt die meisten „vor fünf Minuten ging es noch“-Situationen — ein Bluetooth-Headset, das sich nicht wieder verbinden will, ein Trackpad, das nach einem Suspend tot ist, Sound, der verschwunden ist, als du einen Monitor ausgesteckt hast.

### Warum geben meine externen Lautsprecher nichts wieder?

Wahrscheinlich, weil sie nicht als primäre Ausgabe eingestellt sind. Klicke auf das Lautsprecher-Symbol auf der rechten Seite der Leiste, dann öffnet sich das Lautstärke-Popup, in dem du das Ausgabegerät auswählen kannst (und auch die Lautstärken pro App mischen kannst).

### Meine Laptop-Lautsprecher klingen komisch

Bei manchen Laptops wendet Omarchy automatisch eine Lautsprecher-Abstimmung an, die den Frequenzgang der eingebauten Lautsprecher korrigiert. `omarchy audio tuning status` verrät dir, ob eine auf deinem Gerät aktiv ist, und `omarchy audio tuning off` schaltet sie aus, wenn du die Lautsprecher lieber pur hören willst.

### Warum kann ich mich mit meinem Passwort nicht anmelden oder sudo verwenden?

Du hast es wahrscheinlich zehnmal falsch eingegeben und wurdest ausgesperrt. Die Sperre hebt sich nach zwei Minuten von selbst auf. Wenn du nicht warten kannst und das auf dem Sperrbildschirm passiert, kannst du `CTRL + ALT + F2` drücken, um ein neues TTY zu starten, in dem du dich als root anmelden kannst, und dann `faillock --reset --user [your-username]` ausführen. Das setzt die Sperre zurück, und es kann weitergehen.

### Mein Passwort wird akzeptiert, aber ich lande wieder auf dem Anmeldebildschirm

Eine kaputte Datei für die Sitzungsumgebung kann verhindern, dass der Desktop startet, selbst wenn dein Passwort korrekt ist. Das lohnt sich besonders nach dem Bearbeiten von `~/.config/uwsm/env.d/` zu prüfen.

Drücke `Ctrl + Alt + F2`, melde dich mit deinem normalen Benutzernamen und Passwort an und sieh dir das Benutzer-Journal des aktuellen Boots an:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Suche nach einem Fehler, der eine deiner Umgebungsdateien benennt, etwa `bad substitution`, direkt vor einer Meldung, dass die Markierung für die env-Ausgabe nicht gefunden wurde. Verschiebe diese Datei aus `env.d`, bevor du versuchst, dich erneut anzumelden. Wenn der Fehler zum Beispiel `99-custom` benennt:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM überspringt eine Datei mit einem Syntaxfehler, aber ein fataler Fehler, der erst beim Ausführen der Datei auftritt, wie `bad substitution`, kann trotzdem verhindern, dass der Desktop startet. Ein Zurücksetzen auf einen System-Snapshot repariert diese Dateien nicht, weil `/home` nicht zurückgesetzt wird.

Sobald du dich wieder anmelden kannst, repariere die gespeicherte Kopie, bevor du sie zurückverschiebst. `sh -n` findet Syntaxfehler, ohne die Datei auszuführen, kann aber nicht jeden Fehler finden, der auftritt, wenn sie eingelesen wird. Lass beim Testen von Änderungen ein funktionierendes Terminal geöffnet.

### Warum erscheinen meine 1Password-Autorisierungsabfragen für den 1Password SSH Agent / die CLI nicht?

Das kann 2 Gründe haben:

Damit die ausführliche Genehmigungsabfrage erscheint, muss Settings > Advanced > Use Hardware Acceleration eingeschaltet sein. _Hinweis: Das erfordert einen Neustart, damit es funktioniert._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Oder wenn du 1Password seit dem Hochfahren nicht gestartet hast, erscheint die Abfrage nicht.
