# Fehlerbehebung

### Ich habe mein System mit einem Update kaputt gemacht!

Versuche zuerst, [dein System zurückzusetzen](47-system-snapshots.md) auf die Version vor deinem letzten Update. Wenn das nicht funktioniert, nutze `omarchy-debug`, um dein Problem auf #omarchy-help im Discord zu teilen. Und wenn das alles fehlschlägt, kannst du die Standard-Konfigurationen und -Pakete mit `omarchy-reinstall` neu installieren.

### Warum sind manche Apps auf meinem Display so groß?

Omarchy geht von einem 2x-Display mit hoher Auflösung aus, also setzt es `GDK_SCALE` auf 2, bis du im Monitor-Panel eine Skalierung auswählst. Wenn du ein 1x-Display hast und GTK- oder X11-Apps überdimensioniert dargestellt werden, wähle im Monitor-Panel 1x dafür aus, oder füge `hl.env("GDK_SCALE", "1")` zu `~/.config/hypr/monitors.lua` hinzu (und starte dann jede überdimensionierte App neu). Siehe [das Handbuch zu Monitoren](33-monitors.md).

Für Spotify kannst du `Ctrl + Minus` verwenden, um die UI zu verkleinern (und `Ctrl + Plus`, um sie zu vergrößern).

### Warum funktionieren alle meine Super-Tastenbindungen nicht mehr?

Bei manchen ASUS ROG- und TUF-Laptops ist `Fn + Super` eine leicht zu übersehende Tastenkombination, die eine Firmware-Sperre für die Windows-Taste umschaltet (gedacht für Gaming, damit du ein Spiel nicht versehentlich verlässt). Nichts auf dem Bildschirm zeigt dir an, dass das passiert ist. Solange die Sperre aktiv ist, sendet Super überhaupt nichts — also hört jede Omarchy-Bindung, die Super verwendet, einfach auf zu funktionieren, und es sieht so aus, als wäre Hyprland kaputt.

Drücke einmal `Fn + Super`, bevor du dich in `~/.config/hypr/` vertiefst, und wenn das Super nicht zurückbringt, drücke es erneut, damit du die Sperre nicht aktiviert lässt. Das ist nicht die Fn-Sperre, die nur ändert, was die F-Tastenreihe tut.

### Mein Wi-Fi, Bluetooth, Audio oder Trackpad funktioniert plötzlich nicht mehr

Bevor du neu startest, versuche, das betroffene Subsystem einzeln neu zu starten. _Update > Hardware_ im Omarchy-Menü hat Wi-Fi, Bluetooth, Audio und Trackpad, und das Neuladen eines davon behebt die Mehrheit der „vor fünf Minuten hat es noch funktioniert“-Situationen — ein Bluetooth-Headset, das sich nicht wiederverbindet, ein Trackpad, das nach einem Suspend tot ist, Ton, der verschwunden ist, als du einen Monitor abgesteckt hast.

### Warum spielen meine externen Lautsprecher nichts ab?

Wahrscheinlich, weil sie nicht als primäre Ausgabe gesetzt sind. Klicke auf das Lautsprecher-Symbol auf der rechten Seite der Leiste, dann öffnet sich das Lautstärke-Popup, in dem du das Ausgabegerät auswählen kannst (und auch die Lautstärke pro App mischen kannst).

### Meine Laptop-Lautsprecher klingen komisch

Bei manchen Laptops wendet Omarchy automatisch ein Lautsprecher-Tuning an, das den Frequenzgang der eingebauten Lautsprecher korrigiert. `omarchy audio tuning status` zeigt dir, ob eines auf deinem Gerät aktiv ist, und `omarchy audio tuning off` schaltet es aus, wenn du die Lautsprecher lieber unverfälscht hören willst.

### Warum kann ich mich nicht einloggen oder sudo mit meinem Passwort verwenden?

Du hast es wahrscheinlich zu oft falsch eingegeben und wurdest ausgesperrt. Wenn das auf dem Sperrbildschirm passiert, kannst du `CTRL + ALT + F2` drücken, um eine neue TTY zu starten, in der du dich als root einloggen und dann `faillock --reset --user [your-username]` ausführen kannst. Das setzt die Sperre zurück, und du kannst weitermachen.

### Mein Passwort wird akzeptiert, aber ich lande wieder auf dem Login-Bildschirm

Eine kaputte Sitzungs-Umgebungsdatei kann verhindern, dass der Desktop startet, selbst wenn dein Passwort korrekt ist. Das ist besonders dann einen Blick wert, wenn du `~/.config/uwsm/env.d/` bearbeitet hast.

Drücke `Ctrl + Alt + F2`, logge dich mit deinem normalen Benutzernamen und Passwort ein und schau dir das User-Journal des aktuellen Boots an:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Suche nach einem Fehler, der eine deiner Umgebungsdateien nennt, wie `bad substitution`, kurz vor einer Meldung, dass die Env-Output-Markierung nicht gefunden wurde. Verschiebe diese Datei aus `env.d`, bevor du versuchst, dich erneut einzuloggen. Wenn der Fehler zum Beispiel `99-custom` nennt:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM überspringt eine Datei mit einem Syntaxfehler, aber ein fataler Fehler, der erst beim Ausführen der Datei auftritt, wie `bad substitution`, kann trotzdem verhindern, dass der Desktop startet. Ein Rollback auf einen System-Snapshot repariert diese Dateien nicht, weil `/home` nicht zurückgesetzt wird.

Sobald du dich einloggen kannst, repariere die gespeicherte Kopie, bevor du sie zurückverschiebst. `sh -n` erkennt Syntaxfehler, ohne die Datei auszuführen, kann aber nicht jeden Fehler erkennen, der auftritt, wenn sie eingelesen wird. Lass ein funktionierendes Terminal offen, während du Änderungen testest.

### Warum erscheinen meine 1Password-Autorisierungsabfragen für den 1Password SSH Agent / die CLI nicht?

Das kann 2 Gründe haben:

Damit die ausführliche Genehmigungsabfrage erscheint, muss Settings > Advanced > Use Hardware Acceleration eingeschaltet sein. _Hinweis: Das erfordert einen Neustart, um zu funktionieren._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Oder wenn du 1Password seit dem Hochfahren nicht gestartet hast, erscheint die Abfrage nicht.
